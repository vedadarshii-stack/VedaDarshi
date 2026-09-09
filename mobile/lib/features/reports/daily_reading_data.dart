import 'package:flutter/foundation.dart';

import '../kundli/kundli_json.dart';

/// The Personalized Daily Reading, from `POST /v2/astrology/prediction/daily`.
///
/// BUILT 9 Sep 2026. The Play product `vedadarshi_daily_reading` and the
/// RevenueCat `daily_reading` offering had existed since 16 Aug with nothing
/// in the app able to sell or show it.
///
/// ## Not the same thing as the Horoscope screen
///
/// Worth being clear about, because they look similar and the difference is
/// the entire justification for charging: the Horoscope screens call
/// `/v2/astrology/horoscope/{sign}` and are **sun-sign** based — every
/// Sagittarius in the world gets the same text. This endpoint takes the
/// user's birth details and returns a reading computed from **their own
/// chart**, including their live dasha lords and their transit summary.
///
/// If that distinction is ever lost — e.g. someone "simplifies" this to reuse
/// the horoscope repository — the product stops being worth money.
@immutable
class DailyReadingArea {
  const DailyReadingArea({
    required this.area,
    this.score,
    this.sentiment,
    this.text,
    this.tip,
  });

  /// `career` / `finance` / `health` / `relationship`.
  final String area;
  final int? score;
  final String? sentiment;
  final String? text;

  /// A concrete action ("Drink a full glass of water first thing"). Vedika's
  /// own copy — never ours; writing our own would be inventing astrology.
  final String? tip;

  static DailyReadingArea? fromJson(String area, dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return DailyReadingArea(
      area: area,
      score: parseInt(raw['score']),
      sentiment: parseFreeText(raw['sentiment']),
      text: parseFreeText(raw['text']),
      tip: parseFreeText(raw['tip']),
    );
  }
}

@immutable
class DailyReadingLucky {
  const DailyReadingLucky({
    this.colour,
    this.day,
    this.direction,
    this.number,
    this.time,
  });

  final String? colour;
  final String? day;
  final String? direction;
  final int? number;
  final String? time;

  bool get isEmpty =>
      colour == null &&
      day == null &&
      direction == null &&
      number == null &&
      time == null;

  factory DailyReadingLucky.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return const DailyReadingLucky();
    return DailyReadingLucky(
      colour: parseFreeText(raw['luckyColor']),
      day: parseFreeText(raw['luckyDay']),
      direction: parseFreeText(raw['luckyDirection']),
      number: parseInt(raw['luckyNumber']),
      time: parseFreeText(raw['luckyTime']),
    );
  }
}

@immutable
class DailyReading {
  const DailyReading({
    this.summary,
    this.overallScore,
    this.rashi,
    this.areas = const [],
    this.lucky = const DailyReadingLucky(),
    this.remedies = const [],
    this.quote,
    this.quoteSource,
    this.mahaDashaLord,
    this.antarDashaLord,
  });

  final String? summary;
  final int? overallScore;
  final String? rashi;
  final List<DailyReadingArea> areas;
  final DailyReadingLucky lucky;
  final List<String> remedies;
  final String? quote;
  final String? quoteSource;
  final String? mahaDashaLord;
  final String? antarDashaLord;

  /// Nothing worth rendering. The screen shows an honest empty state rather
  /// than a shell of headings with no content under them.
  bool get isEmpty =>
      summary == null && areas.isEmpty && remedies.isEmpty && lucky.isEmpty;

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    // `predictions` is an OBJECT keyed by area, not a list — so the order is
    // fixed here rather than taken from the payload, which has no order.
    final predictions = json['predictions'];
    final areas = <DailyReadingArea>[];
    if (predictions is Map<String, dynamic>) {
      for (final key in const ['career', 'finance', 'health', 'relationship']) {
        final area = DailyReadingArea.fromJson(key, predictions[key]);
        if (area != null) areas.add(area);
      }
    }

    final dasha = json['dasha'];
    return DailyReading(
      summary: parseFreeText(json['summary']),
      overallScore: parseInt(json['overallScore']),
      rashi: parseFreeText(json['rashi']),
      areas: areas,
      lucky: DailyReadingLucky.fromJson(json['luckyElements']),
      remedies: parseStrings(json['remedies']),
      quote: parseFreeText(
        json['quote'] is Map<String, dynamic>
            ? (json['quote'] as Map<String, dynamic>)['text']
            : null,
      ),
      quoteSource: parseFreeText(
        json['quote'] is Map<String, dynamic>
            ? (json['quote'] as Map<String, dynamic>)['source']
            : null,
      ),
      mahaDashaLord: parseFreeText(
        dasha is Map<String, dynamic> ? dasha['mahaDashaLord'] : null,
      ),
      antarDashaLord: parseFreeText(
        dasha is Map<String, dynamic> ? dasha['antarDashaLord'] : null,
      ),
    );
  }
}
