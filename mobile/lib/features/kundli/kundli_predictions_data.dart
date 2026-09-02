import 'package:flutter/foundation.dart';

import 'kundli_json.dart';

/// The natal reading behind the Kundli **Predictions** tab, from
/// `POST /v2/reports/birth-chart-report`.
///
/// BUILT 2 Sep 2026. That tab had no content at ALL before this — the pill
/// was never selectable, it just opened the paywall. Selling a reading that
/// does not exist is the same problem as the "unlimited AI" copy that had to
/// be removed from the paywall, so the tab now shows the real reading and
/// puts the paywall partway through it (see `PremiumGlimpse`).
///
/// ## Why this endpoint and not `/v2/astrology/kundli`
///
/// The kundli endpoint returns chart GEOMETRY — planets, houses, degrees —
/// which the Chart and Planet Positions tabs already render. It carries no
/// interpretation. This one returns per-house prose and named yogas, which
/// is what a "Predictions" tab is actually for.
///
/// ## Deliberately not modelled
///
/// `strengthTable` (shadbala per planet) and `dashaTimeline` are both in the
/// response and both omitted: shadbala is a number without an explanation
/// attached, and the dasha timeline is already the Dasha tab's entire job —
/// rendering a second, differently-shaped copy of it here would invite the
/// two to disagree. `ascendantSign`/`moonSign` are omitted for the same
/// reason: the Chart tab's stat cards already show them.
@immutable
class KundliPredictions {
  const KundliPredictions({this.houses = const [], this.yogas = const []});

  /// The twelve houses, each with Vedika's own interpretation sentence.
  final List<KundliHouseReading> houses;

  /// Named yogas detected in this chart.
  final List<KundliYoga> yogas;

  bool get isEmpty => houses.isEmpty && yogas.isEmpty;

  factory KundliPredictions.fromJson(Map<String, dynamic> json) {
    return KundliPredictions(
      houses: parseList(json['houses'], KundliHouseReading.fromJson),
      yogas: parseList(json['yogas'], KundliYoga.fromJson),
    );
  }
}

/// One house's reading.
@immutable
class KundliHouseReading {
  const KundliHouseReading({
    this.house,
    this.lord,
    this.interpretation,
    this.planetsInHouse = const [],
  });

  final int? house;
  final String? lord;

  /// Vedika's own English sentence — rendered as-is regardless of app
  /// locale, the same documented gap as every other free-text field from
  /// this API.
  final String? interpretation;

  final List<String> planetsInHouse;

  static KundliHouseReading fromJson(Map<String, dynamic> json) {
    return KundliHouseReading(
      house: parseInt(json['house']),
      lord: json['lord'] as String?,
      interpretation: parseFreeText(json['interpretation']),
      planetsInHouse: parseStrings(json['planetsInHouse']),
    );
  }
}

/// A named yoga present in the chart.
@immutable
class KundliYoga {
  const KundliYoga({
    this.name,
    this.meaning,
    this.score,
    this.planets = const [],
  });

  final String? name;
  final String? meaning;

  /// Vedika's own 0-100 strength for the yoga. Nullable — never defaulted
  /// to 0, which would read as "this yoga is worthless" rather than
  /// "unknown".
  final double? score;

  final List<String> planets;

  static KundliYoga fromJson(Map<String, dynamic> json) {
    return KundliYoga(
      name: json['name'] as String?,
      meaning: parseFreeText(json['meaning']),
      score: parseDouble(json['score']),
      planets: parseStrings(json['planets']),
    );
  }
}
