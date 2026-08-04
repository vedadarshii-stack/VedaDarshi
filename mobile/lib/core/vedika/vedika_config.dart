import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Where the app talks to the Vedika Intelligence API, and how it
/// authenticates — **the single place that changes when we go live.**
///
/// ## Going live is one line in `.env`
///
/// ```
/// # Sandbox (default): free, no key, FIXED sample data
/// VEDIKA_BASE_URL=https://api.vedika.io/sandbox
///
/// # Live
/// VEDIKA_BASE_URL=https://<region>-vedadarshi-20989.cloudfunctions.net/vedika
/// ```
///
/// Nothing else in the app hardcodes a host or a path prefix — every
/// repository builds its request from [baseUrl] + the same `/v2/...` path,
/// because the sandbox mirrors production's routes exactly under a
/// `/sandbox` prefix. So flipping the two lines above switches the whole
/// app over with no code change.
///
/// ## Why live points at Cloud Functions, not `https://api.vedika.io`
///
/// Production Vedika requires an `X-API-Key`, and that key is **billed per
/// call** ($0.012–0.048 each). Shipping it inside the APK would hand anyone
/// who unzips the app the ability to spend the client's balance — and a
/// `.env` asset is plain text inside the APK (see the `.env` note in
/// CLAUDE.md), so bundling it is not protection. The live base URL therefore
/// points at our own Cloud Functions proxy, which holds the key server-side,
/// injects it, and caches responses.
///
/// [apiKey] exists only as an escape hatch for LOCAL developer testing
/// against production before that proxy is written. It is deliberately
/// absent from `.env.example`. Never ship a build with it set.
abstract final class VedikaConfig {
  /// Default: the free, unauthenticated sandbox.
  static const String sandboxBaseUrl = 'https://api.vedika.io/sandbox';

  /// Vedika's real host. Present for documentation/comparison; the app
  /// should reach this THROUGH our proxy, not directly (see class doc).
  static const String productionBaseUrl = 'https://api.vedika.io';

  /// Base URL every Vedika request is built on, with no trailing slash.
  static String get baseUrl {
    final raw = _env('VEDIKA_BASE_URL');
    if (raw == null || raw.isEmpty) return sandboxBaseUrl;
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Optional `X-API-Key`. Null in sandbox (which takes no auth) and null in
  /// a correctly-configured production build (the proxy holds the key).
  static String? get apiKey {
    final raw = _env('VEDIKA_API_KEY');
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  /// True while pointed at Vedika's sandbox.
  ///
  /// The UI uses this to be honest with the user rather than to change
  /// behaviour: **the sandbox ignores the birth details you send it and
  /// returns one fixed sample chart** (verified 1 Aug 2026 — posting
  /// Hyderabad 1990 coordinates comes back as Delhi 1995-01-01). Showing a
  /// stranger's chart as if it were the user's own would be worse than
  /// showing nothing, so screens surface a "sample data" banner while this
  /// is true.
  static bool get isSandbox => baseUrl.contains('/sandbox');

  /// dotenv throws if `load()` never ran (e.g. in a widget test that skips
  /// `main()`); every caller here treats "not configured" as a valid state,
  /// so swallow that and fall through to the defaults.
  static String? _env(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }
}
