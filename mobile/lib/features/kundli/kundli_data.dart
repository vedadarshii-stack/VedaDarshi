import 'package:flutter/foundation.dart';

import 'kundli_chart_static_data.dart' show ChartPlanet, PlanetCode;
import 'kundli_json.dart';

/// Typed, null-safe models for the Vedika `/v2/astrology/kundli` response —
/// see "B6 · Kundli Chart" (Figma node 18:2).
///
/// `VedikaClient.post` already unwraps Vedika's `{success, data, billing,
/// meta}` envelope, so every `fromJson` factory here starts directly from
/// the inner `data` map. **Every field is treated as nullable and parsed
/// defensively** — the real sandbox response was inspected directly
/// (`curl … | python3 -m json.tool`, 1 Aug 2026) and every key modelled
/// below was actually observed there, but Vedika's docs make no contractual
/// guarantee any of them will always be present, so a missing or
/// wrongly-typed value anywhere in the tree degrades to `null`/an empty
/// list rather than throwing — one absent nested field must never take
/// down the whole chart.
@immutable
class KundliData {
  const KundliData({
    this.ascendant,
    this.ayanamsa,
    this.birthDetails,
    this.houses = const [],
    this.planets = const [],
    this.moonSign,
    this.nakshatra,
    this.sunSign,
    this.tithi,
    this.summary,
    this.zodiacSystem,
    this.zodiacType,
    this.source,
  });

  final KundliAscendant? ascendant;
  final KundliAyanamsa? ayanamsa;
  final KundliBirthDetails? birthDetails;

  /// All 12 houses. Not currently consumed by [NorthIndianChart] — a North
  /// Indian chart's house *positions* are fixed (Lagna always occupies the
  /// top diamond; house numbers 1–12 read clockwise from there regardless
  /// of which rashi occupies which house), so nothing on today's Chart tab
  /// needs to know which sign sits in which house. Parsed anyway since it's
  /// part of the response and will matter the moment a South Indian chart
  /// (where sign position IS fixed and house number rotates) or a
  /// Planet-Positions detail view is built.
  final List<KundliHouse> houses;

  final List<KundliPlanet> planets;

  /// The Moon's rashi (sign), e.g. `"Sagittarius"` — the traditional
  /// "Rashi" shown on the Kundli Chart screen's stat card.
  final String? moonSign;

  /// The Moon's birth star, e.g. `"Purva Ashadha"`.
  final String? nakshatra;

  final String? sunSign;

  /// Lunar day at the birth moment, e.g. `"Krishna Purnima/Amavasya"`.
  final String? tithi;

  final KundliSummary? summary;

  /// `"vedic"` in every observed response.
  final String? zodiacSystem;

  /// `"sidereal"` in every observed response.
  final String? zodiacType;

  /// Vedika's own attribution for the calculation engine, e.g.
  /// `"vedika-ephemeris"`.
  final String? source;

  factory KundliData.fromJson(Map<String, dynamic> json) {
    return KundliData(
      ascendant: parseObj(json['ascendant'], KundliAscendant.fromJson),
      ayanamsa: parseObj(json['ayanamsa'], KundliAyanamsa.fromJson),
      birthDetails: parseObj(json['birth_details'], KundliBirthDetails.fromJson),
      houses: parseList(json['houses'], KundliHouse.fromJson),
      planets: parseList(json['planets'], KundliPlanet.fromJson),
      moonSign: json['moonSign'] as String?,
      nakshatra: json['nakshatra'] as String?,
      sunSign: json['sunSign'] as String?,
      tithi: json['tithi'] as String?,
      summary: parseObj(json['summary'], KundliSummary.fromJson),
      zodiacSystem: json['zodiacSystem'] as String?,
      zodiacType: json['zodiacType'] as String?,
      source: json['source'] as String?,
    );
  }

  /// The Ascendant plus every placeable entry in [planets], mapped onto the
  /// [ChartPlanet]/[PlanetCode] model `NorthIndianChart` already knows how
  /// to paint (see `north_indian_chart.dart` — deliberately unchanged by
  /// this wiring, it already expected exactly this shape). The Ascendant is
  /// always pinned to house 1 — the defining convention of a North Indian
  /// chart — and each planet's house comes straight from Vedika's own
  /// `house` field (already 1–12, no recomputation from the Ascendant's
  /// sign needed). A planet [KundliPlanet.toChartPlanet] can't place (no
  /// recognizable planet code, or `house` missing/out of range) is silently
  /// dropped rather than guessed at.
  List<ChartPlanet> toChartPlanets() {
    final result = <ChartPlanet>[
      const ChartPlanet(PlanetCode.ascendant, house: 1),
    ];
    for (final planet in planets) {
      final chartPlanet = planet.toChartPlanet();
      if (chartPlanet != null) result.add(chartPlanet);
    }
    return result;
  }
}

@immutable
class KundliAscendant {
  const KundliAscendant({
    this.sign,
    this.signNumber,
    this.signLord,
    this.degree,
    this.fullDegree,
    this.nakshatra,
    this.interpretation,
  });

  final String? sign;
  final int? signNumber;
  final String? signLord;
  final double? degree;
  final double? fullDegree;
  final KundliNakshatra? nakshatra;
  final KundliAscendantInterpretation? interpretation;

  factory KundliAscendant.fromJson(Map<String, dynamic> json) {
    return KundliAscendant(
      sign: json['sign'] as String?,
      signNumber: parseInt(json['signNumber']),
      signLord: json['signLord'] as String?,
      degree: parseDouble(json['degree']),
      fullDegree: parseDouble(json['fullDegree']),
      nakshatra: parseObj(json['nakshatra'], KundliNakshatra.fromJson),
      interpretation: parseObj(
        json['interpretation'],
        KundliAscendantInterpretation.fromJson,
      ),
    );
  }
}

@immutable
class KundliAscendantInterpretation {
  const KundliAscendantInterpretation({
    this.element,
    this.quality,
    this.symbol,
    this.traits = const [],
    this.strengths = const [],
    this.challenges = const [],
    this.career = const [],
    this.compatibility = const [],
  });

  final String? element;
  final String? quality;
  final String? symbol;
  final List<String> traits;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> career;
  final List<String> compatibility;

  factory KundliAscendantInterpretation.fromJson(Map<String, dynamic> json) {
    return KundliAscendantInterpretation(
      element: json['element'] as String?,
      quality: json['quality'] as String?,
      symbol: json['symbol'] as String?,
      traits: parseStrings(json['traits']),
      strengths: parseStrings(json['strengths']),
      challenges: parseStrings(json['challenges']),
      career: parseStrings(json['career']),
      compatibility: parseStrings(json['compatibility']),
    );
  }
}

@immutable
class KundliNakshatra {
  const KundliNakshatra({this.id, this.name, this.lord, this.deity, this.pada});

  final int? id;
  final String? name;
  final String? lord;
  final String? deity;
  final int? pada;

  factory KundliNakshatra.fromJson(Map<String, dynamic> json) {
    return KundliNakshatra(
      id: parseInt(json['id']),
      name: json['name'] as String?,
      lord: json['lord'] as String?,
      deity: json['deity'] as String?,
      pada: parseInt(json['pada']),
    );
  }
}

@immutable
class KundliPlanet {
  const KundliPlanet({
    this.id,
    this.name,
    this.vedicName,
    this.house,
    this.sign,
    this.signNumber,
    this.degree,
    this.fullDegree,
    this.isRetrograde = false,
    this.nakshatra,
    this.interpretation,
  });

  final int? id;
  final String? name;
  final String? vedicName;
  final int? house;
  final String? sign;
  final int? signNumber;
  final double? degree;
  final double? fullDegree;
  final bool isRetrograde;
  final KundliNakshatra? nakshatra;
  final KundliPlanetInterpretation? interpretation;

  factory KundliPlanet.fromJson(Map<String, dynamic> json) {
    return KundliPlanet(
      id: parseInt(json['id']),
      name: json['name'] as String?,
      vedicName: json['vedic_name'] as String?,
      house: parseInt(json['house']),
      sign: json['sign'] as String?,
      signNumber: parseInt(json['signNumber']),
      degree: parseDouble(json['degree']),
      fullDegree: parseDouble(json['fullDegree']),
      // Vedika sends both `isRetrograde` and a duplicate `retrograde` key
      // (verified against the live sandbox response, 1 Aug 2026) — prefer
      // the former, fall back to the latter, default false so a genuinely
      // missing flag never renders a planet as wrongly retrograde.
      isRetrograde:
          (json['isRetrograde'] as bool?) ??
          (json['retrograde'] as bool?) ??
          false,
      nakshatra: parseObj(json['nakshatra'], KundliNakshatra.fromJson),
      interpretation: parseObj(
        json['interpretation'],
        KundliPlanetInterpretation.fromJson,
      ),
    );
  }

  /// Maps Vedika's planet `id` (0=Sun … 8=Ketu, verified against the live
  /// sandbox response 1 Aug 2026) onto this app's [PlanetCode]. Falls back
  /// to matching [name] case-insensitively when `id` is missing or outside
  /// the known 0–8 range — Vedika's docs don't contractually guarantee `id`
  /// will always be present, even though it was in every observed response.
  PlanetCode? get code {
    const byId = [
      PlanetCode.sun,
      PlanetCode.moon,
      PlanetCode.mars,
      PlanetCode.mercury,
      PlanetCode.jupiter,
      PlanetCode.venus,
      PlanetCode.saturn,
      PlanetCode.rahu,
      PlanetCode.ketu,
    ];
    final planetId = id;
    if (planetId != null && planetId >= 0 && planetId < byId.length) {
      return byId[planetId];
    }
    final planetName = name?.trim().toLowerCase();
    if (planetName == null) return null;
    for (final candidate in PlanetCode.values) {
      if (candidate != PlanetCode.ascendant && candidate.name == planetName) {
        return candidate;
      }
    }
    return null;
  }

  /// This planet's placement on the North Indian chart, or `null` if
  /// there's not enough data to place it safely (no recognizable [code], or
  /// no `house` in the valid 1–12 range) — [KundliData.toChartPlanets]
  /// drops a `null` here rather than guessing a position.
  ChartPlanet? toChartPlanet() {
    final planetCode = code;
    final planetHouse = house;
    if (planetCode == null ||
        planetHouse == null ||
        planetHouse < 1 ||
        planetHouse > 12) {
      return null;
    }
    return ChartPlanet(
      planetCode,
      house: planetHouse,
      isRetrograde: isRetrograde,
      isExalted:
          interpretation?.inThisChart?.dignity?.trim().toLowerCase() ==
          'exalted',
    );
  }
}

@immutable
class KundliPlanetInterpretation {
  const KundliPlanetInterpretation({
    this.color,
    this.day,
    this.gemstone,
    this.governs = const [],
    this.significance,
    this.inThisChart,
  });

  final String? color;
  final String? day;
  final String? gemstone;
  final List<String> governs;
  final String? significance;
  final KundliPlanetDignity? inThisChart;

  factory KundliPlanetInterpretation.fromJson(Map<String, dynamic> json) {
    return KundliPlanetInterpretation(
      color: json['color'] as String?,
      day: json['day'] as String?,
      gemstone: json['gemstone'] as String?,
      governs: parseStrings(json['governs']),
      significance: json['significance'] as String?,
      inThisChart: parseObj(json['inThisChart'], KundliPlanetDignity.fromJson),
    );
  }
}

/// A planet's strength/weakness IN this specific chart — Vedika's
/// `interpretation.inThisChart` object.
@immutable
class KundliPlanetDignity {
  const KundliPlanetDignity({
    this.dignity,
    this.dignityEffect,
    this.dignityMeaning,
    this.houseInfluence,
    this.houseName,
    this.housePosition,
  });

  /// e.g. `"own"`, `"neutral"`, `"exalted"`, `"debilitated"` — observed
  /// values in the sandbox were `"neutral"` and `"own"`; the exalted marker
  /// drawn on the chart (see [KundliPlanet.toChartPlanet]) matches this
  /// case-insensitively against `"exalted"`.
  final String? dignity;
  final String? dignityEffect;
  final String? dignityMeaning;
  final String? houseInfluence;
  final String? houseName;
  final int? housePosition;

  factory KundliPlanetDignity.fromJson(Map<String, dynamic> json) {
    return KundliPlanetDignity(
      dignity: json['dignity'] as String?,
      dignityEffect: json['dignityEffect'] as String?,
      dignityMeaning: json['dignityMeaning'] as String?,
      houseInfluence: json['houseInfluence'] as String?,
      houseName: json['houseName'] as String?,
      housePosition: parseInt(json['housePosition']),
    );
  }
}

@immutable
class KundliHouse {
  const KundliHouse({
    this.number,
    this.sign,
    this.signNumber,
    this.cusp,
    this.degree,
    this.interpretation,
  });

  final int? number;
  final String? sign;
  final int? signNumber;
  final double? cusp;
  final double? degree;
  final KundliHouseInterpretation? interpretation;

  factory KundliHouse.fromJson(Map<String, dynamic> json) {
    return KundliHouse(
      number: parseInt(json['number']),
      sign: json['sign'] as String?,
      signNumber: parseInt(json['signNumber']),
      cusp: parseDouble(json['cusp']),
      degree: parseDouble(json['degree']),
      interpretation: parseObj(
        json['interpretation'],
        KundliHouseInterpretation.fromJson,
      ),
    );
  }
}

@immutable
class KundliHouseInterpretation {
  const KundliHouseInterpretation({
    this.name,
    this.karaka,
    this.governs = const [],
    this.significance,
  });

  final String? name;
  final String? karaka;
  final List<String> governs;
  final String? significance;

  factory KundliHouseInterpretation.fromJson(Map<String, dynamic> json) {
    return KundliHouseInterpretation(
      name: json['name'] as String?,
      karaka: json['karaka'] as String?,
      governs: parseStrings(json['governs']),
      significance: json['significance'] as String?,
    );
  }
}

@immutable
class KundliAyanamsa {
  const KundliAyanamsa({this.id, this.name, this.value});

  final int? id;
  final String? name;
  final double? value;

  factory KundliAyanamsa.fromJson(Map<String, dynamic> json) {
    return KundliAyanamsa(
      id: parseInt(json['id']),
      name: json['name'] as String?,
      value: parseDouble(json['value']),
    );
  }
}

@immutable
class KundliBirthDetails {
  const KundliBirthDetails({
    this.latitude,
    this.longitude,
    this.datetime,
    this.timezone,
  });

  final double? latitude;
  final double? longitude;

  /// Echoed back by Vedika, e.g. `"1995-01-01T12:00:00+05:30"`. **In
  /// sandbox mode this is NOT the birth details that were posted** — see
  /// `VedikaConfig.isSandbox`'s doc comment; the sandbox always echoes back
  /// its one fixed sample chart's details regardless of the request body.
  final String? datetime;
  final String? timezone;

  factory KundliBirthDetails.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];
    final coordinateMap = coordinates is Map<String, dynamic>
        ? coordinates
        : null;
    return KundliBirthDetails(
      latitude: parseDouble(coordinateMap?['latitude']),
      longitude: parseDouble(coordinateMap?['longitude']),
      datetime: json['datetime'] as String?,
      timezone: json['timezone'] as String?,
    );
  }
}

@immutable
class KundliSummary {
  const KundliSummary({
    this.overview,
    this.keyStrengths = const [],
    this.areasOfFocus = const [],
    this.tips = const [],
  });

  /// A short paragraph combining the Ascendant/Sun/Moon signs into one
  /// narrative, e.g. "With Pisces rising, you embody Intuitive,
  /// Compassionate, Artistic qualities…" — see `_SummaryBanner` in
  /// `kundli_chart_screen.dart` for where this is shown. It is the
  /// FALLBACK content for that banner slot when the real dosha verdict
  /// (`kundli_dosha_data.dart`, `/v2/astrology/all-doshas`) is unavailable
  /// — see `_DoshaOrSummaryBanner` in `kundli_chart_screen.dart`.
  final String? overview;
  final List<String> keyStrengths;
  final List<String> areasOfFocus;
  final List<String> tips;

  factory KundliSummary.fromJson(Map<String, dynamic> json) {
    return KundliSummary(
      overview: json['overview'] as String?,
      keyStrengths: parseStrings(json['keyStrengths']),
      areasOfFocus: parseStrings(json['areasOfFocus']),
      tips: parseStrings(json['tips']),
    );
  }
}
