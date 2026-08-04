import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/vedika/vedika_client.dart';
import 'horoscope_data.dart';
import 'zodiac_sign.dart';

/// Fetches and caches horoscope readings from the Vedika Intelligence API.
///
/// **Endpoints** (verified live against the sandbox 1 Aug 2026):
/// ```
/// GET /v2/astrology/horoscope/{sign}            daily
/// GET /v2/astrology/horoscope/{sign}/weekly      weekly
/// GET /v2/astrology/horoscope/{sign}/monthly     monthly
/// ```
/// `{sign}` is the lowercase English zodiac name (`ZodiacSign.englishName`
/// lower-cased) — `aries`, `taurus`, … `pisces`.
///
/// **Yearly does not exist.** `GET .../yearly` answers `success: true` with
/// an error payload in `data` (`{error, message, requested}`) rather than a
/// 404 or a real reading, so `VedikaClient` can't detect it as a failure —
/// it looks like a normal successful response until you read `data.error`.
/// There is deliberately no `fetchYearly` here; the Horoscope — All Signs
/// screen's Yearly chip stays on its existing static content (see
/// `horoscope_signs_screen.dart`).
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
