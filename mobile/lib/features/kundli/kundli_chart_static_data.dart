import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Chart-rendering types and fixed UI config for the "Kundli Chart" screen
/// — see "B6 · Kundli Chart" (Figma node 18:2).
///
/// [PlanetCode] and [ChartPlanet] were originally modelled here as
/// STATIC PLACEHOLDER value holders (planet → house/retrograde/exalted);
/// they are now the real render model the live **Vedika API** response is
/// mapped onto — see `kundli_data.dart`'s `KundliData.toChartPlanets()` /
/// `KundliPlanet.toChartPlanet()`. The per-birth VALUES that used to live in
/// this file (planet placements, Lagna/Rashi/Nakshatra, dosha summary) now
/// come from that real response instead — see `kundli_chart_screen.dart`.
/// Only [legendOrder] remains a static constant here, because it's a fixed
/// UI layout decision (which 6 of 10 possible planet codes get a "KEY
/// PLANETS" legend chip), not astrology data that varies per birth.
abstract final class KundliChartStaticData {
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

/// One planet's placement on the chart — modelled to match the real Vedika
/// API response 1:1 (planet code, house, retrograde/exalted flags), so
/// `KundliData.toChartPlanets()` in `kundli_data.dart` is the only place
/// that builds a list of these; the widgets that render them
/// (`north_indian_chart.dart`) never needed to change.
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
