import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/vedika/response_store.dart';
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
  InauspiciousPeriods? _inauspiciousCache;
  String? _inauspiciousCacheKey;
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

    // ON-DEVICE, day-scoped (4 Sep 2026). The proxy already makes this free
    // in money terms after the day's first caller; this makes it free in
    // TIME for every launch after the first, and lets Home render offline.
    // Memory first, disk second, network last.
    final dayKey = dayKeyFor(date);
    final stored = await VedikaResponseStore.instance.read(cacheKey, dayKey);
    if (stored != null) {
      try {
        final data = PanchangData.fromJson(stored);
        _panchangCache[cacheKey] = data;
        return data;
      } catch (e) {
        // A stored payload that no longer parses (an app update changed the
        // model, or the write was truncated) must not be fatal — fall
        // through and re-fetch rather than failing the screen.
        debugPrint('panchang: stored payload unusable, refetching ($e)');
      }
    }

    // The BUNDLE route, not /today or /{date} — switched 21 Aug 2026.
    //
    // `/v2/astrology/panchang` takes the same date+location parameters and
    // returns the same five elements, PLUS an `include` parameter that adds
    // blocks the other routes have no equivalent for. `include=sunrise` is
    // what finally makes sunrise/sunset/moonrise/moonset real: they were a
    // fixed "05:52 AM / 07:04 PM / 11:20 AM / 11:52 PM" shown to every user
    // in every city, because the route the app happened to call does not
    // return them and that was mistaken for the API not having them.
    //
    // Costs the same $0.02 as before per the billing block on the response,
    // so this is strictly more data for the same money and the same one
    // call. `festivals` and `muhurta` are also available here — muhurta
    // stays a separate call for now because it is already correct and
    // independently cached; festivals are not wired to any surface yet.
    //
    // Response shape differs slightly between routes (`vaara` vs `vara`,
    // paksha as an object rather than a string). `PanchangData.fromJson`
    // accepts BOTH, so this switch cannot silently blank a field.
    const path = '/v2/astrology/panchang';
    final query = <String, String>{
      // `datetime` IS REQUIRED — added 21 Aug 2026.
      //
      // Without it the API anchors to the SERVER's "now", in UTC. Any time
      // between 00:00 and 05:30 IST that is still YESTERDAY in UTC, so the
      // app fetched the previous day's panchang and rendered it under
      // today's heading. Measured at 04:00 IST on Friday 21 Aug 2026, same
      // location, one request with the parameter and one without:
      //
      //   without : nakshatra Anuradha, vara THURSDAY
      //   with    : nakshatra Jyeshtha, vara FRIDAY   <- correct
      //
      // The screen said "Friday, 21 August 2026" while every value under it
      // described Thursday. Same failure mode as `/v2/daily/muhurta` above:
      // a 200 and a well-formed body prove only that the ROUTE exists.
      //
      // Local NOON of the requested day, not midnight: midnight sits on the
      // boundary between two Vedic days (which turn at sunrise), so noon is
      // the unambiguous "this calendar day" anchor, and it also makes the
      // value stable for every request made during that day.
      'datetime': _localNoonIso(date),
      // Rounded to 4 decimal places (~11 m) — the SAME precision
      // [_panchangCacheKey] already rounds to for this repository's own
      // in-memory cache, and the precision the Cloud Functions proxy's
      // `vedikaCache` now rounds to server-side (26 Aug 2026 — see
      // `functions/src/vedikaCache.ts`). Sending the raw, unrounded
      // `double` here would still be caught by that server-side rounding,
      // but keeping the two in agreement means this repository is
      // correct on its own, not merely bailed out by the proxy — and it
      // is the actual root cause of a real incident: an app build that
      // sent raw GPS precision in this query minted a fresh, separately
      // billed Vedika call on nearly every request for what should have
      // been one cached day+location entry (see CLAUDE.md, "Vedika API
      // integration").
      'latitude': lat.toStringAsFixed(4),
      'longitude': lon.toStringAsFixed(4),
      'timezone': _utcOffsetFor(tz, date),
      // sunrise -> sun/moon times; festivals -> the real festival card.
      // Both are add-on blocks on the same call, so neither costs extra.
      'include': 'sunrise,festivals',
    };

    final json = await _client.get(path, query: query);
    final data = PanchangData.fromJson(json);
    _panchangCache[cacheKey] = data;
    // Fire-and-forget: persisting is an optimisation for NEXT launch, so it
    // must never delay returning data to this one.
    unawaited(VedikaResponseStore.instance.write(cacheKey, dayKey, json));
    return data;
  }

  /// Fetches (or returns the cached) daily muhurta data for [lat]/[lon].
  ///
  /// ## `datetime` + location are REQUIRED — omitting them returns garbage
  ///
  /// FIXED 21 Aug 2026. This used to call `/v2/daily/muhurta` with **no
  /// query parameters at all**, on the belief (recorded in the old comment
  /// here) that the endpoint is simply "today's muhurta" and takes none.
  /// It returns 200 either way, which is why it looked fine — but the
  /// parameter-less response is **not a usable reading**:
  ///
  /// ```
  /// no params : {"start":"2026-08-20T18:55:59Z",      // 00:25 IST
  ///              "end"  :"2026-08-20T17:33:56.750Z",  // 23:03 IST — BEFORE start
  ///              "is_day": false}
  /// ```
  ///
  /// End before start, `is_day:false`, and a ~10-hour span — Rahu Kaal is
  /// ~1.5 hours. On screen that rendered as "06:55 – 05:33 PM".
  ///
  /// Sending `datetime` + `latitude`/`longitude`/`timezone` (the same shape
  /// every other endpoint here takes) returns a correct reading:
  ///
  /// ```
  /// with params: 05:24:09Z – 07:01:26Z  ->  10:54–12:31 IST, is_day:true,
  ///              1.62 h — and Friday Rahu Kaal really is ~10:30–12:00.
  /// ```
  ///
  /// This is the same class of bug as the `lat`/`lon`/`tz` naming mistake
  /// documented above: a 200 with a well-shaped body proves nothing about
  /// whether the inputs were understood.
  ///
  /// Cached per day AND per location, because the answer now genuinely
  /// depends on both.
  /// The day's inauspicious/auspicious windows — Rahu Kaal, Yamaganda,
  /// Gulika Kaal and Abhijit Muhurat — plus real sunrise/sunset.
  ///
  /// `POST /v2/astrology/inauspicious-period`. See
  /// [InauspiciousPeriods]'s doc comment for why this is a second call
  /// rather than more fields on [fetchMuhurta] (that endpoint simply does
  /// not return Yamaganda, Gulika or Abhijit — verified live).
  ///
  /// Same day+location in-memory cache key as [fetchMuhurta]: these windows
  /// are fixed for a calendar day at a location, so one call per day per
  /// city is all that is ever needed. Coordinates are rounded to 4dp for
  /// the same reason they are there — so GPS jitter cannot produce a fresh
  /// billed call for what is the same place.
  /// The day's Rahu Kaal / Yamaganda / Gulika / Abhijit / Brahma windows.
  ///
  /// **Endpoint changed 2 Sep 2026** from `/v2/astrology/inauspicious-period`
  /// to `/v2/astrology/brahma-muhurta`. The latter returns a strict SUPERSET
  /// — the same four windows in the same shape, plus `brahmaMuhurta` and
  /// `durmuhurta` — so the client's request for a Brahma Muhurta card costs
  /// no extra call and no extra billing. Verified field-by-field against
  /// live responses before switching.
  ///
  /// **[date] became a real parameter at the same time, and that was a bug
  /// fix, not a feature.** This used to stamp `DateTime.now()` unconditionally
  /// and cache on today's calendar day, so the Panchang date stepper moved
  /// the header while every muhurat window below it stayed on today's
  /// values. That is exactly what the client reported as *"Rahu kal it's not
  /// changing for every day"* — making the values live had fixed only half
  /// of it. Verified the endpoint genuinely varies by date: for Hyderabad,
  /// Rahu Kaal moves 06:47–08:20 on 2 Sep to 03:40–05:13 on 5 Sep (UTC),
  /// which is correct — Rahu Kaal is keyed to the weekday.
  Future<InauspiciousPeriods> fetchInauspiciousPeriods({
    required double lat,
    required double lon,
    required String tz,
    required DateTime date,
  }) async {
    final key = '${_isoDate(date)}|${lat.toStringAsFixed(4)}|'
        '${lon.toStringAsFixed(4)}|$tz';
    final cached = _inauspiciousCache;
    if (cached != null && _inauspiciousCacheKey == key) return cached;

    final json = await _client.post(
      '/v2/astrology/brahma-muhurta',
      body: {
        'datetime': _localNoonIso(date),
        'latitude': double.parse(lat.toStringAsFixed(4)),
        'longitude': double.parse(lon.toStringAsFixed(4)),
        'timezone': _utcOffsetFor(tz, date),
      },
    );
    final parsed =
        InauspiciousPeriods.fromJson(json) ?? const InauspiciousPeriods();
    _inauspiciousCache = parsed;
    _inauspiciousCacheKey = key;
    return parsed;
  }

  Future<MuhurtaData> fetchMuhurta({
    required double lat,
    required double lon,
    required String tz,
  }) async {
    final now = DateTime.now();
    final todayKey = '${_isoDate(now)}|$lat|$lon|$tz';
    final cached = _muhurtaCache;
    if (cached != null && _muhurtaCacheDateKey == todayKey) return cached;

    final json = await _client.get(
      '/v2/daily/muhurta',
      query: {
        // Local wall-clock, no zone suffix — same convention as the POST
        // endpoints; `timezone` carries the offset separately.
        'datetime': _localNoonIso(now),
        // Rounded for the same reason as `fetch()` above — keeps this
        // repository's own request in agreement with the server-side
        // cache-key rounding in `functions/src/vedikaCache.ts`.
        'latitude': lat.toStringAsFixed(4),
        'longitude': lon.toStringAsFixed(4),
        'timezone': tz,
      },
    );
    final data = MuhurtaData.fromJson(json);
    _muhurtaCache = data;
    _muhurtaCacheDateKey = todayKey;
    return data;
  }

  /// Local NOON on [day], as `YYYY-MM-DDTHH:mm:ss`.
  ///
  /// Noon rather than "now" so the reading is stable for the whole calendar
  /// day (the cache key is the date, so a request at 00:05 and one at 23:55
  /// must agree), and so a pre-dawn request still resolves to the daytime
  /// Rahu Kaal a user expects to plan around rather than the previous
  /// night's.
  static String _localNoonIso(DateTime day) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${day.year}-${two(day.month)}-${two(day.day)}T12:00:00';
  }

  /// `"yyyy-MM-dd|lat|lon"`, rounded to 4 decimal places (~11m of
  /// precision) so two requests for the same saved birth profile always
  /// land on the same cache entry regardless of any floating-point noise.
  static String _panchangCacheKey(DateTime date, double lat, double lon) =>
      '${_isoDate(date)}|${lat.toStringAsFixed(4)}|${lon.toStringAsFixed(4)}';

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

/// Location key for [muhurtaDataProvider].
///
/// Muhurta is now parameterized by LOCATION (21 Aug 2026). It previously
/// was not, because the endpoint was thought to take no parameters — it
/// does, and calling it without them returns an invalid window. Rahu Kaal
/// is derived from sunrise/sunset, so it genuinely differs by place.
typedef MuhurtaRequest = ({double lat, double lon, String tz});

/// Today's daily muhurta (choghadiya/hora/Rahu Kaal) for one location.
///
/// Date is always "today" — the repository stamps local noon and keys its
/// cache on the calendar day, so this does not need a date in the key.
final muhurtaDataProvider =
    FutureProvider.family<MuhurtaData, MuhurtaRequest>((ref, request) {
      return ref
          .watch(panchangRepositoryProvider)
          .fetchMuhurta(lat: request.lat, lon: request.lon, tz: request.tz);
    });

/// One location AND one calendar day. Separate from [MuhurtaRequest]
/// specifically because the date is part of the key here — see
/// [PanchangRepository.fetchInauspiciousPeriods] for the bug that caused.
typedef PeriodsRequest = ({double lat, double lon, String tz, DateTime date});

/// The day's Rahu Kaal / Yamaganda / Gulika / Abhijit / Brahma Muhurta
/// windows for one location on one DATE — feeds the Panchang muhurat grid
/// and Home's muhurat tiles.
final inauspiciousPeriodsProvider =
    FutureProvider.family<InauspiciousPeriods, PeriodsRequest>((ref, request) {
      return ref
          .watch(panchangRepositoryProvider)
          .fetchInauspiciousPeriods(
            lat: request.lat,
            lon: request.lon,
            tz: request.tz,
            date: request.date,
          );
    });
