import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/vedika/vedika_client.dart';
import 'horoscope_data.dart';
import 'zodiac_sign.dart';

/// Fetches and caches horoscope readings from the Vedika Intelligence API.
///
/// **Endpoints** (daily/weekly/monthly verified live against the sandbox
/// 1 Aug 2026; yearly verified live against production 26 Aug 2026):
/// ```
/// GET  /v2/astrology/horoscope/{sign}             daily
/// GET  /v2/astrology/horoscope/{sign}/weekly       weekly
/// GET  /v2/astrology/horoscope/{sign}/monthly      monthly
/// POST /v2/astrology/prediction/yearly             yearly, body {"rashi": <sign>}
/// ```
/// `{sign}`/`rashi` is the lowercase English zodiac name
/// (`ZodiacSign.englishName` lower-cased) — `aries`, `taurus`, … `pisces`.
///
/// **Yearly DOES exist — it just lives under a different path family.**
/// `GET /v2/astrology/horoscope/{sign}/yearly` (the naturally-guessed path,
/// matching the daily/weekly/monthly shape) genuinely 404s — that half of
/// the earlier investigation was correct. What was wrong was concluding
/// from that single 404 that Vedika has no yearly endpoint at all: it does,
/// at `POST /v2/astrology/prediction/yearly` (body `{"rashi": "leo"}`),
/// under `/prediction/*` rather than `/horoscope/*`. **Lesson recorded here
/// so it isn't repeated**: a 404 on the pattern-matched URL only proves
/// that URL is wrong, not that the capability is missing — check the full
/// OpenAPI contract (`vedika.io/openapi.json`) before concluding an
/// endpoint "doesn't exist".
///
/// **Caching**: an in-memory map keyed `"{sign}|{period}|{yyyy-MM-dd}"`.
/// Horoscope readings change once per calendar day, not per request, so
/// within a session the same sign+period is served from memory after the
/// first fetch rather than re-billing Vedika for an identical answer. The
/// cache lives on this instance, and [horoscopeRepositoryProvider] is a
/// plain (non-autoDispose) `Provider`, so it survives for the app session —
/// exactly the "once per day" lifetime this is meant to have. It is
/// intentionally NOT persisted to disk (unlike `BirthProfileRepository`):
/// horoscope content isn't precious the way a birth profile is, and a cold
/// start already gets a fresh "today" for free.
class HoroscopeRepository {
  HoroscopeRepository({required this._client});

  final VedikaClient _client;

  final Map<String, DailyHoroscope> _dailyCache = {};
  final Map<String, WeeklyHoroscope> _weeklyCache = {};
  final Map<String, MonthlyHoroscope> _monthlyCache = {};
  final Map<String, YearlyHoroscope> _yearlyCache = {};

  Future<DailyHoroscope> fetchDaily(String signId) async {
    final key = _cacheKey(signId, 'daily');
    final cached = _dailyCache[key];
    if (cached != null) return cached;

    final data = await _client.get(
      '/v2/astrology/horoscope/${_apiSign(signId)}',
    );
    final horoscope = DailyHoroscope.fromJson(data);
    _dailyCache[key] = horoscope;
    return horoscope;
  }

  Future<WeeklyHoroscope> fetchWeekly(String signId) async {
    final key = _cacheKey(signId, 'weekly');
    final cached = _weeklyCache[key];
    if (cached != null) return cached;

    final data = await _client.get(
      '/v2/astrology/horoscope/${_apiSign(signId)}/weekly',
    );
    final horoscope = WeeklyHoroscope.fromJson(data);
    _weeklyCache[key] = horoscope;
    return horoscope;
  }

  Future<MonthlyHoroscope> fetchMonthly(String signId) async {
    final key = _cacheKey(signId, 'monthly');
    final cached = _monthlyCache[key];
    if (cached != null) return cached;

    final data = await _client.get(
      '/v2/astrology/horoscope/${_apiSign(signId)}/monthly',
    );
    final horoscope = MonthlyHoroscope.fromJson(data);
    _monthlyCache[key] = horoscope;
    return horoscope;
  }

  /// Yearly reading for [signId] — `POST /v2/astrology/prediction/yearly`
  /// with body `{"rashi": _apiSign(signId)}`, unlike the `GET`s above (see
  /// the class doc comment for why yearly is a `POST` under a different
  /// path family). Cached the same "once per device-day" way as the other
  /// periods, even though the underlying reading is really a rolling
  /// 12-month window — re-fetching more than once a day would just re-bill
  /// Vedika for a reading that hasn't meaningfully changed.
  Future<YearlyHoroscope> fetchYearly(String signId) async {
    final key = _cacheKey(signId, 'yearly');
    final cached = _yearlyCache[key];
    if (cached != null) return cached;

    final data = await _client.post(
      '/v2/astrology/prediction/yearly',
      body: {'rashi': _apiSign(signId)},
    );
    final horoscope = YearlyHoroscope.fromJson(data);
    _yearlyCache[key] = horoscope;
    return horoscope;
  }

  /// `"{sign}|{period}|{yyyy-MM-dd}"`, dated to the DEVICE's current date
  /// (not the API's own `data.date`, which isn't known until after the
  /// fetch this key is used to avoid) — a device that's still on "today"
  /// after midnight UTC keeps serving yesterday's cached reading for the
  /// rest of its local day, which is the intended per-day granularity.
  String _cacheKey(String signId, String period) {
    final today = DateTime.now();
    final y = today.year.toString().padLeft(4, '0');
    final m = today.month.toString().padLeft(2, '0');
    final d = today.day.toString().padLeft(2, '0');
    return '$signId|$period|$y-$m-$d';
  }

  /// [signId] is our internal [ZodiacSign.id] (e.g. `'simha'`); Vedika's
  /// path segment is the lowercase English name (e.g. `'leo'`).
  String _apiSign(String signId) {
    final sign = kZodiacSigns.firstWhere(
      (s) => s.id == signId,
      orElse: () => throw ArgumentError('Unknown zodiac sign id: $signId'),
    );
    return sign.englishName.toLowerCase();
  }
}

final horoscopeRepositoryProvider = Provider<HoroscopeRepository>((ref) {
  return HoroscopeRepository(client: ref.watch(vedikaClientProvider));
});

/// Today's [DailyHoroscope] for the given [ZodiacSign.id], watched by
/// `horoscope_detail_screen.dart`.
final dailyHoroscopeProvider = FutureProvider.family<DailyHoroscope, String>((
  ref,
  signId,
) {
  return ref.watch(horoscopeRepositoryProvider).fetchDaily(signId);
});

/// This week's [WeeklyHoroscope] for the given [ZodiacSign.id], watched by
/// `horoscope_detail_screen.dart` when the Weekly period chip is selected.
final weeklyHoroscopeProvider = FutureProvider.family<WeeklyHoroscope, String>((
  ref,
  signId,
) {
  return ref.watch(horoscopeRepositoryProvider).fetchWeekly(signId);
});

/// This month's [MonthlyHoroscope] for the given [ZodiacSign.id], watched by
/// `horoscope_detail_screen.dart` when the Monthly period chip is selected.
final monthlyHoroscopeProvider =
    FutureProvider.family<MonthlyHoroscope, String>((ref, signId) {
      return ref.watch(horoscopeRepositoryProvider).fetchMonthly(signId);
    });

/// This year's [YearlyHoroscope] for the given [ZodiacSign.id], watched by
/// `horoscope_detail_screen.dart` when the Yearly period chip is selected.
final yearlyHoroscopeProvider =
    FutureProvider.family<YearlyHoroscope, String>((ref, signId) {
      return ref.watch(horoscopeRepositoryProvider).fetchYearly(signId);
    });
