import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// STATIC PLACEHOLDER CONTENT for the "Kundli Chart" screen — see
/// "B6 · Kundli Chart" (Figma node 18:2).
///
/// Every value here stands in for what will eventually come from the
/// **Vedika API** (vedika.io) — kundli computed once per birth profile and
/// cached in Firestore (see the "Astrology data" section of the project's
/// top-level CLAUDE.md). [PlanetCode] and [ChartPlanet] are modelled so a
/// real API response (planet → house/retrograde/exalted) drops straight
/// into [placements] without any widget changes.
abstract final class KundliChartStaticData {
  static const String lagna = 'Vrischika';
  static const String rashi = 'Vrishabha';
  static const String nakshatra = 'Rohini';

  static const String doshaSummary =
      'No Mangal Dosha detected · Kaal Sarp: Partial (view details)';

  /// Planet placements shown on the North Indian chart, per the approved
  /// design (Figma node 18:20).
  static const List<ChartPlanet> placements = [
    ChartPlanet(PlanetCode.ascendant, house: 1),
    ChartPlanet(PlanetCode.sun, house: 12),
    ChartPlanet(PlanetCode.mercury, house: 12),
    ChartPlanet(PlanetCode.moon, house: 4),
    ChartPlanet(PlanetCode.jupiter, house: 3, isExalted: true),
    ChartPlanet(PlanetCode.mars, house: 7),
    ChartPlanet(PlanetCode.venus, house: 9),
    ChartPlanet(PlanetCode.saturn, house: 10, isRetrograde: true),
    ChartPlanet(PlanetCode.rahu, house: 6),
    ChartPlanet(PlanetCode.ketu, house: 8),
  ];

  /// Order the "KEY PLANETS" legend chips render in (Figma node 50:29) — a
  /// deliberate 6-of-10 subset of [PlanetCode], matching the design (not
  /// every placed planet gets a legend chip).
  static const List<PlanetCode> legendOrder = [
    PlanetCode.ascendant,
    PlanetCode.sun,
    PlanetCode.moon,
    PlanetCode.rahu,
    PlanetCode.ketu,
    PlanetCode.saturn,
  ];
}

/// Identifies a planet (or the Ascendant) for chart placement.
enum PlanetCode {
  ascendant,
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,
  ketu;

  /// Two-letter abbreviation drawn inside the North Indian chart.
  String get shortLabel {
    switch (this) {
      case PlanetCode.ascendant:
        return 'As';
      case PlanetCode.sun:
        return 'Su';
      case PlanetCode.moon:
        return 'Mo';
      case PlanetCode.mars:
        return 'Ma';
      case PlanetCode.mercury:
        return 'Me';
      case PlanetCode.jupiter:
        return 'Ju';
      case PlanetCode.venus:
        return 'Ve';
      case PlanetCode.saturn:
        return 'Sa';
      case PlanetCode.rahu:
        return 'Ra';
      case PlanetCode.ketu:
        return 'Ke';
    }
  }

  /// Color this planet's short label is drawn in inside the North Indian
  /// chart. Every value here REUSES an existing [AppColors] token — see
  /// that class's "Kundli Chart" section for the full reuse list.
  Color get chartColor {
    switch (this) {
      case PlanetCode.ascendant:
        return AppColors.genderSelectedText;
      case PlanetCode.sun:
      case PlanetCode.mercury:
      case PlanetCode.moon:
      case PlanetCode.venus:
        return AppColors.tileBlueFg;
      case PlanetCode.jupiter:
        return AppColors.tileGreenFg;
      case PlanetCode.mars:
        return AppColors.ashubhFg;
      case PlanetCode.saturn:
        return AppColors.tilePurpleFg;
      case PlanetCode.rahu:
        return AppColors.muted;
      case PlanetCode.ketu:
        return AppColors.planetKetu;
    }
  }

  /// Color of this planet's dot + label in the "KEY PLANETS" legend row.
  ///
  /// Identical to [chartColor] for every planet EXCEPT the Sun. Inside the
  /// chart itself, Sun/Mercury/Moon/Venus all share one blue (the design's
  /// tile-color system), but the legend needs 6 visually DISTINCT swatches
  /// (Ascendant/Sun/Moon/Rahu/Ketu/Saturn) — Sun and Moon would otherwise
  /// render as the same indistinguishable blue dot — so the approved design
  /// gives Sun's legend chip the gold `mantraLabel` tone instead.
  Color get legendColor =>
      this == PlanetCode.sun ? AppColors.mantraLabel : chartColor;
}

/// One planet's placement on the chart — modelled to match a future Vedika
/// API response 1:1 (planet code, house, retrograde/exalted flags) so
/// wiring the real API later only replaces
/// [KundliChartStaticData.placements], never the widgets that render it.
@immutable
class ChartPlanet {
  const ChartPlanet(
    this.code, {
    required this.house,
    this.isRetrograde = false,
    this.isExalted = false,
  });

  final PlanetCode code;

  /// 1–12.
  final int house;

  final bool isRetrograde;
  final bool isExalted;
}
