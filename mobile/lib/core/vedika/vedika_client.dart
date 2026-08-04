import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'vedika_config.dart';

/// Anything that went wrong talking to Vedika, already turned into
/// something a screen can render.
///
/// [code] is Vedika's own machine-readable code when it sent one
/// (`MISSING_LATITUDE`, `INSUFFICIENT_BALANCE`, `NOT_FOUND`, …), otherwise
/// one of the synthetic codes below.
class VedikaException implements Exception {
  const VedikaException(this.message, {this.code, this.statusCode});

  /// The request never completed — no connectivity, DNS failure, TLS error.
  static const String codeNetwork = 'NETWORK';

  /// The request completed but took longer than the per-call timeout.
  static const String codeTimeout = 'TIMEOUT';

  /// A 2xx arrived but the body was not the `{success, data, …}` envelope.
  static const String codeMalformed = 'MALFORMED_RESPONSE';

  /// The endpoint does not exist on the CURRENT base URL. Most likely cause
  /// is an `/api/*` route while pointed at the sandbox — the sandbox only
  /// serves `/v2/*` (verified 1 Aug 2026).
  static const String codeNotFound = 'NOT_FOUND';

  /// Live-only: the account's prepaid balance is exhausted.
  static const String codeInsufficientBalance = 'INSUFFICIENT_BALANCE';

  final String message;
  final String? code;
  final int? statusCode;

  /// True when retrying the identical request could plausibly succeed.
  /// Billing/validation failures are NOT retryable — repeating them just
  /// burns calls.
  bool get isRetryable =>
      code == codeNetwork || code == codeTimeout || (statusCode ?? 0) >= 500;

  @override
  String toString() =>
      'VedikaException(${code ?? '-'}${statusCode != null ? ' $statusCode' : ''}): $message';
}

/// Thin HTTP client for the Vedika Intelligence API.
///
/// Every Vedika response — success or failure — is the same envelope:
///
/// ```json
/// { "success": true,
///   "data": { … },
///   "billing": { "charged": 0.028, "balanceAfter": 24.4, … },
///   "meta": { "engine": "vedika-intelligence", "mode": "sandbox" } }
/// ```
///
/// [get] and [post] unwrap it and hand back just `data`, so no repository
/// has to know the envelope exists. A `success: false` body is raised as a
/// [VedikaException] carrying Vedika's own `code`, which is what makes
/// failures distinguishable downstream (a missing latitude is a bug in our
/// request; an exhausted balance is the client's problem; a 404 usually
/// means we're on the sandbox).
///
/// **Not cached here.** Caching is per-feature because the natural key
/// differs — panchang is per date+location, horoscope per sign+period+day,
/// a kundli per birth profile and effectively immutable. See each
/// repository.
class VedikaClient {
  VedikaClient({http.Client? httpClient, this.timeout = _defaultTimeout})
    : _http = httpClient ?? http.Client();

  /// Generous because Vedika computes ephemeris server-side; a full kundli
  /// is measurably slower than a horoscope lookup. Still bounded so a
  /// hanging request can't wedge a screen on its loading spinner forever.
  static const Duration _defaultTimeout = Duration(seconds: 30);

  final http.Client _http;
  final Duration timeout;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) => _send('GET', path, query: query);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) => _send('POST', path, body: body);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(
      '${VedikaConfig.baseUrl}$path',
    ).replace(queryParameters: query?.isEmpty ?? true ? null : query);

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      // Absent in sandbox and in a correctly-configured production build,
      // where the Cloud Functions proxy adds it — see VedikaConfig.apiKey.
      if (VedikaConfig.apiKey != null) 'X-API-Key': VedikaConfig.apiKey!,
    };

    http.Response response;
    try {
      final future = method == 'GET'
          ? _http.get(uri, headers: headers)
          : _http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
      response = await future.timeout(timeout);
    } on TimeoutException {
      throw VedikaException(
        'Vedika did not respond within ${timeout.inSeconds}s.',
        code: VedikaException.codeTimeout,
      );
    } catch (e) {
      throw VedikaException(
        'Could not reach Vedika: $e',
        code: VedikaException.codeNetwork,
      );
    }

    Map<String, dynamic> decoded;
    try {
      final raw = jsonDecode(response.body);
      if (raw is! Map<String, dynamic>) throw const FormatException('not a map');
      decoded = raw;
    } catch (_) {
      throw VedikaException(
        'Vedika returned a body that is not JSON (HTTP ${response.statusCode}).',
        code: VedikaException.codeMalformed,
        statusCode: response.statusCode,
      );
    }

    // Vedika answers some failures with HTTP 200 and `success: false`, and
    // others (404 on an /api/* path, 401 without a key) with a bare
    // {status, code, message} object and no `success` at all. Treat both as
    // failures rather than trusting the status code alone.
    final success = decoded['success'];
    if (success == false || (success == null && decoded['data'] == null)) {
      throw VedikaException(
        (decoded['error'] ?? decoded['message'] ?? 'Unknown Vedika error')
            .toString(),
        code: (decoded['code'] as String?) ?? _codeForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 400) {
      throw VedikaException(
        'Vedika returned HTTP ${response.statusCode}.',
        code: _codeForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw VedikaException(
        'Vedika response had no `data` object.',
        code: VedikaException.codeMalformed,
        statusCode: response.statusCode,
      );
    }

    if (kDebugMode && VedikaConfig.isSandbox) {
      debugPrint('Vedika[sandbox] $method $path -> ${data.keys.length} keys');
    }
    return data;
  }

  static String? _codeForStatus(int status) => switch (status) {
    404 => VedikaException.codeNotFound,
    402 => VedikaException.codeInsufficientBalance,
    _ => null,
  };

  void close() => _http.close();
}

final vedikaClientProvider = Provider<VedikaClient>((ref) {
  final client = VedikaClient();
  ref.onDispose(client.close);
  return client;
});
