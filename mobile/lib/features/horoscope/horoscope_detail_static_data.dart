import 'package:flutter/foundation.dart' show immutable;

/// STATIC CONTENT for the "Horoscope Detail" screen — see "B4 · Horoscope
/// Detail" (Figma node 16:2).
///
/// **Now that the Vedika API is wired (see `horoscope_repository.dart` /
/// `horoscope_data.dart`), this file has two different roles per field,
/// and it matters which one applies to a given value:**
///
/// 1. **Fallback for a real field Vedika sometimes omits** — [date],
///    [luckyColor], [luckyNumber], [luckyTime] and the individual
///    [predictions]' text/rating all have a genuine equivalent in
///    `DailyHoroscope`, and [weeklyAdvice]/[monthlyTheme] likewise fall back
///    for `WeeklyHoroscope.advice`/`MonthlyHoroscope.monthlyTheme` on the
///    Weekly/Monthly periods. `horoscope_detail_screen.dart` prefers the
///    live value and falls back to the constant here only when Vedika
///    didn't return one (every field is nullable — see
///    `horoscope_data.dart`), so the screen never renders blank.
/// 2. **Permanent placeholder for a field Vedika has NO equivalent for at
///    all** — [direction], [avoidTime], [remedy], [scores] (Vedika's daily
///    endpoint returns one aggregate theme+rating for the whole day, not
///    independent career/love/health/money/luck scores) and [mantra] stay
///    static regardless of API state. These are real content gaps, not
///    loading states — see the per-field comments in
///    `horoscope_detail_screen.dart` for why each one can't be sourced from
///    Vedika, the same way the Horoscope — All Signs screen documents why
///    its Yearly chip has no API behind it.
abstract final class HoroscopeDetailStaticData {
  static const String date = 'Saturday, 12 July 2026';

  static const String luckyColor = 'Gold';
  static const String luckyNumber = '3, 9';
  static const String direction = 'East';

  static const List<HoroscopeScore> scores = [
    HoroscopeScore(HoroscopeScoreId.career, 85),
    HoroscopeScore(HoroscopeScoreId.love, 72),
    HoroscopeScore(HoroscopeScoreId.health, 80),
    HoroscopeScore(HoroscopeScoreId.money, 65),
    HoroscopeScore(HoroscopeScoreId.luck, 90),
  ];

  static const String luckyTime = '10:30 AM – 12:45 PM';
  static const String avoidTime = '04:30 – 06:00 PM';

  static const List<HoroscopePrediction> predictions = [
    HoroscopePrediction(
      HoroscopeSectionId.career,
      4,
      'Jupiter in your 10th house brings recognition at work. A pending '
      'payment is likely to clear after 2 PM. Avoid impulsive investments '
      'today.',
    ),
    HoroscopePrediction(
      HoroscopeSectionId.love,
      4,
      'Venus favours honest conversations. Single Simhas may receive an '
      'unexpected message. Couples: plan something simple together this '
      'evening.',
    ),
    HoroscopePrediction(
      HoroscopeSectionId.health,
      4,
      'Energy peaks in the morning — schedule important tasks early. Watch '
      'your posture; a short walk after sunset restores balance.',
    ),
  ];

  static const String remedy =
      "Today's remedy: Offer water to the rising Sun and chant Aditya "
      'Hridayam once.';

  static const String mantra =
      'ॐ ह्रां ह्रीं ह्रौं सः सूर्याय नमः — 108 times at sunrise';

  /// Fallback for `WeeklyHoroscope.advice` when Vedika's weekly response
  /// doesn't include one — see category 1 above.
  static const String weeklyAdvice =
      'Stay mindful of your priorities this week and pace yourself — '
      'steady, consistent effort brings better results than a rushed push.';

  /// Fallback for `MonthlyHoroscope.monthlyTheme` when Vedika's monthly
  /// response doesn't include one — see category 1 above.
  static const String monthlyTheme =
      'A month for steady progress — focus on consistency over big leaps.';
}

/// Identifies which l10n label/colour a [HoroscopeScore] row should render
/// with — the widget layer owns that presentation mapping since labels and
/// colours are UI chrome, not placeholder data.
enum HoroscopeScoreId { career, love, health, money, luck }

/// One row in the "Today's scores" card.
@immutable
class HoroscopeScore {
  const HoroscopeScore(this.id, this.percent);

  final HoroscopeScoreId id;

  /// 0–100.
  final int percent;
}

/// Identifies which l10n title/colour/icon a [HoroscopePrediction] card
/// should render with.
enum HoroscopeSectionId { career, love, health }

/// One prediction card (Career & Money / Love & Relationships /
/// Health & Energy).
@immutable
class HoroscopePrediction {
  const HoroscopePrediction(this.id, this.rating, this.body);

  final HoroscopeSectionId id;

  /// 0–5, drives the filled-dot rating row.
  final int rating;

  final String body;
}
