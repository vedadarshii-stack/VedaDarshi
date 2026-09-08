import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/vedika/vedika_client.dart';
import '../kundli/kundli_repository.dart';
import 'report_content.dart';

/// Fetches the readable content behind a premium report card.
///
/// BUILT 2 Sep 2026 alongside [ReportContent] — see its class doc for why the
/// eight different endpoints collapse into one shape.
///
/// ## The endpoint map is the interesting part
///
/// These paths were found by PROBING the live API, not by reading the
/// contract: `vedika.io/openapi.json` lists 601 paths and **none of the
/// `/v2/reports/*` routes are among them**. `/v2/reports/complete`,
/// `career-report`, `marriage-report`, `health-report` and
/// `birth-chart-report` all return 200 with real payloads; every other
/// `/v2/reports/*` name tried returns 404. So the contract is incomplete, and
/// "not in openapi.json" is NOT evidence an endpoint is missing — the same
/// lesson the dosha banner taught in reverse. Re-probe before assuming a new
/// report is impossible.
class ReportRepository {
  ReportRepository(this._client);

  final VedikaClient _client;

  /// Vedika path per report id. Ids match `ReportsStaticData.reports`.
  ///
  /// Note the two conventions living side by side: the `/v2/reports/*`
  /// family is our own report endpoints, while wealth/sade-sati/gemstone/
  /// numerology borrow the topical endpoints that already return the same
  /// substance. A report having no dedicated `/v2/reports/` route does not
  /// mean the data is unavailable.
  static const Map<String, String> endpoints = {
    'complete': '/v2/reports/complete',
    'career': '/v2/reports/career-report',
    'marriage': '/v2/reports/marriage-report',
    'health': '/v2/reports/health-report',
    'wealth': '/v2/career/finance/wealth-timing',
    'sadeSati': '/v2/astrology/sade-sati',
    'gemstone': '/v2/astrology/remedies/gemstone',
    'numerology': '/v2/astrology/numerology/complete-report',
  };

  /// In-memory, keyed by report id + birth parameters. A report is a pure
  /// function of a birth chart, so re-opening a card must not re-bill the
  /// client's Vedika wallet.
  ///
  /// Caches the RAW payload, not a built [ReportContent]. That split matters:
  /// the built content carries localized labels, so caching it would serve
  /// the previous language's labels after a language switch — while the
  /// payload itself is locale-independent (Vedika answers in English no
  /// matter what is asked of it). Building is cheap; the billed call is not.
  /// ⚠️ Keyed on a RECORD, not on an interpolated string. `'$reportId|$request'`
  /// looked reasonable and was silently broken: [KundliRequest] has no
  /// `toString`, so every request stringified to the same
  /// `Instance of 'KundliRequest'` and all birth profiles collapsed onto ONE
  /// entry per report — serving the first profile's report to everyone after
  /// it. A record compares structurally through [KundliRequest]'s own
  /// `==`/`hashCode`, so profiles stay distinct by construction.
  final Map<(String, KundliRequest), Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>> fetch({
    required String reportId,
    required KundliRequest request,
  }) async {
    final path = endpoints[reportId];
    if (path == null) return const {};

    final key = (reportId, request);
    if (_cache[key] case final cached?) return cached;

    final data = await _client.post(
      path,
      body: {
        'datetime': _isoLocal(request.datetime),
        'latitude': request.latitude,
        'longitude': request.longitude,
        'timezone': request.tzOffset,
        // NUMEROLOGY ONLY — and it is REQUIRED there, not optional:
        // `/v2/astrology/numerology/complete-report` answers
        // `400 INVALID_BIRTH_DETAILS: name (or fullName) is required` without
        // it, which is why this report failed for every user until 8 Sep 2026
        // while the other seven returned 200 on the identical body.
        //
        // Sent ONLY for this report, never for all eight. The Cloud Functions
        // proxy hashes the request BODY into its cache key, so adding a name
        // everywhere would fragment the year-long chart-report cache per
        // person — turning shared HITs into billed MISSes for data that does
        // not depend on the name at all.
        if (reportId == 'numerology') 'name': ?_trimmedName(request.name),
      },
    );
    _cache[key] = data;
    return data;
  }

  /// The name with surrounding whitespace removed, or null if nothing is
  /// left. Vedika rejects `""` and `"   "` with the SAME
  /// `name (or fullName) is required` 400 as a missing field (both probed
  /// live), so a blank name must be treated as absent rather than sent and
  /// hoped for.
  static String? _trimmedName(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// LOCAL wall-clock with no zone suffix — the convention every Vedika POST
  /// endpoint uses, paired with the separate `timezone` offset.
  static String _isoLocal(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}'
        'T${two(value.hour)}:${two(value.minute)}:00';
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(vedikaClientProvider));
});

/// Identifies one report for one birth chart.
@immutable
class ReportRequest {
  const ReportRequest({required this.reportId, required this.birth});

  final String reportId;
  final KundliRequest birth;

  @override
  bool operator ==(Object other) =>
      other is ReportRequest &&
      other.reportId == reportId &&
      other.birth == birth;

  @override
  int get hashCode => Object.hash(reportId, birth);
}

/// The RAW report payload. The screen turns it into a [ReportContent] with
/// its own [AppLocalizations] — see [ReportRepository._cache].
final reportContentProvider =
    FutureProvider.family<Map<String, dynamic>, ReportRequest>((ref, request) {
      return ref
          .watch(reportRepositoryProvider)
          .fetch(reportId: request.reportId, request: request.birth);
    });
