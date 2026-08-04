import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/vedika/vedika_client.dart';
import 'panchang_data.dart';

/// Talks to Vedika's panchang (`/v2/astrology/panchang/*`) and daily
/// muhurta (`/v2/daily/muhurta`) endpoints, with a simple IN-MEMORY cache
/// for both — this repository lives as long as [vedikaClientProvider]
/// does (the life of the app process), so the cache is a per-session
/// optimization, not durable storage.
///
/// **Why cache at all:** every Vedika call is billed per request. Panchang
/// values don't change once computed for a given date+location, and the
/// screen's date-stepper arrows make it trivial to re-request a date the
/// user already viewed a moment ago (step forward, then back) — caching
/// turns that into a free lookup instead of a second billed call.
class PanchangRepository {
  PanchangRepository(this._client);

  final VedikaClient _client;

  final Map<String, PanchangData> _panchangCache = {};

  // Muhurta has no date/location parameters in the verified endpoint
  // contract (it's simply "today's" muhurta), so it needs only a
  // single cached value — invalidated when the calendar day changes,
  // in case the app is left open overnight.
  MuhurtaData? _muhurtaCache;
  String? _muhurtaCacheDateKey;

  /// Fetches (or returns the cached) panchang for [date] at [lat]/[lon].
  ///
  /// ## Query parameter names — a bug worth remembering
  ///
  /// This originally sent `lat`/`lon`/`tz`, which "worked" only in the sense
  /// that the request returned 200. **Vedika's sandbox ignores location
  /// entirely and serves one fixed sample**, so unrecognised parameter names
  /// are indistinguishable from correct ones there — the response looks
  /// perfect either way. The real contract (`vedika.io/openapi.json`,
  /// `GET /v2/astrology/panchang/today` and `/{date}`) names them
  /// **`latitude` / `longitude` / `timezone`**, and both endpoints accept all
  /// three (the dated one is NOT restricted to lat/lon as previously
  /// believed). Left unfixed, every user in production would have silently
  /// received the API's default location's panchang.
  ///
  /// **Cannot be verified until production.** Two cities return byte-identical
  /// panchang from the sandbox under either spelling — verified 1 Aug 2026.
  /// The first thing to check against the live key is that two distant cities
  /// return DIFFERENT tithi values.
  ///
  /// [tz] is the IANA zone id (e.g. `Asia/Kolkata`). The contract gives no
  /// example for `timezone` on this endpoint; every POST endpoint in the same
  /// contract takes a UTC-offset string (`"+05:30"`), so that form is sent
  /// here too for consistency — also unverifiable on the sandbox, and also
  /// worth confirming on the first live call.
  Future<PanchangData> fetch({
    required DateTime date,
    required double lat,
    required double lon,
    required String tz,
  }) async {
    final cacheKey = _panchangCacheKey(date, lat, lon);
    final cached = _panchangCache[cacheKey];
    if (cached != null) return cached;

    final isToday = _isSameCalendarDay(date, DateTime.now());
    final path = isToday
        ? '/v2/astrology/panchang/today'
        : '/v2/astrology/panchang/${_isoDate(date)}';
    final query = <String, String>{
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'timezone': _utcOffsetFor(tz, date),
    };

    final json = await _client.get(path, query: query);
    final data = PanchangData.fromJson(json);
    _panchangCache[cacheKey] = data;
    return data;
  }

  /// Fetches (or returns the cached) daily muhurta data.
  Future<MuhurtaData> fetchMuhurta() async {
    final todayKey = _isoDate(DateTime.now());
    final cached = _muhurtaCache;
    if (cached != null && _muhurtaCacheDateKey == todayKey) return cached;

    final json = await _client.get('/v2/daily/muhurta');
    final data = MuhurtaData.fromJson(json);
    _muhurtaCache = data;
    _muhurtaCacheDateKey = todayKey;
    return data;
  }

  /// `"yyyy-MM-dd|lat|lon"`, rounded to 4 decimal places (~11m of
  /// precision) so two requests for the same saved birth profile always
  /// land on the same cache entry regardless of any floating-point noise.
  static String _panchangCacheKey(DateTime date, double lat, double lon) =>
      '${_isoDate(date)}|${lat.toStringAsFixed(4)}|${lon.toStringAsFixed(4)}';

  static bool _isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Converts an IANA zone id (`Asia/Kolkata`) to the `"+05:30"` UTC-offset
  /// form the rest of the Vedika contract uses, resolved AT [date] so a zone
  /// with daylight saving gives the offset actually in force that day rather
  /// than today's. Falls back to the raw id if the zone is unknown to the
  /// bundled tz database — sending something is strictly better than sending
  /// nothing, since the endpoint treats `timezone` as optional.
  static String _utcOffsetFor(String ianaId, DateTime date) {
    try {
      final location = tz.getLocation(ianaId);
      final offset = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
      ).timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final abs = offset.abs();
      final h = abs.inHours.toString().padLeft(2, '0');
      final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
      return '$sign$h:$m';
    } catch (_) {
      return ianaId;
    }
  }

  static String _isoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

final panchangRepositoryProvider = Provider<PanchangRepository>((ref) {
  return PanchangRepository(ref.watch(vedikaClientProvider));
});

/// Request key for [panchangDataProvider] — a Dart 3 record rather than a
/// hand-written class, so Riverpod's `.family` gets correct structural
/// `==`/`hashCode` (and therefore correct request de-duplication /
/// caching-by-key) for free.
typedef PanchangRequest = ({DateTime date, double lat, double lon, String tz});

/// The panchang for one [PanchangRequest] (date + location). Watching this
/// with a different request re-fetches (subject to [PanchangRepository]'s
/// own cache above) rather than reusing a stale value — that's what makes
/// the screen's date-stepper arrows load the newly-selected day.
final panchangDataProvider =
    FutureProvider.family<PanchangData, PanchangRequest>((ref, request) {
      return ref
          .watch(panchangRepositoryProvider)
          .fetch(
            date: request.date,
            lat: request.lat,
            lon: request.lon,
            tz: request.tz,
          );
    });

/// Today's daily muhurta data (choghadiya/hora/Rahu Kaal). Unlike
/// [panchangDataProvider] this isn't parameterized by date — see
/// [PanchangRepository.fetchMuhurta].
final muhurtaDataProvider = FutureProvider<MuhurtaData>((ref) {
  return ref.watch(panchangRepositoryProvider).fetchMuhurta();
});
