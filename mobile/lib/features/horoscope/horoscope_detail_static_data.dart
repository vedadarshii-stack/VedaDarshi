import 'package:flutter/foundation.dart' show immutable;

/// STATIC PLACEHOLDER CONTENT for the "Horoscope Detail" screen — see
/// "B4 · Horoscope Detail" (Figma node 16:2).
///
/// Every value in this file stands in for what will eventually come from
/// the **Vedika API** (vedika.io), cached once per day per language in
/// Firestore (see the "Astrology data" section of the project's top-level
/// CLAUDE.md).
///
/// Keeping every placeholder value in this one file (rather than scattered
/// across the widget tree in `horoscope_detail_screen.dart`) means wiring up
/// that real data source later is a matter of replacing the provider that
/// supplies these values — it should never require touching the widgets
/// themselves.
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
