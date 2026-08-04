import 'package:flutter/foundation.dart';

import 'kundli_json.dart';

/// Typed, null-safe models for the Vedika `POST /v2/astrology/all-doshas`
/// response — the real dosha verdicts for the Kundli Chart screen's
/// dosha-summary banner (Figma node 18:59, "No Mangal Dosha detected · Kaal
/// Sarp: Partial").
///
/// One call answers all three doshas at once (`mangal_dosha`,
/// `kaal_sarp_dosha`, `pitru_dosha`) rather than hitting the three
/// individual `/v2/astrology/{mangal,kaal-sarp}-dosha` endpoints
/// separately — verified against the live sandbox 1 Aug 2026.
///
/// Same defensive-parsing policy as `kundli_data.dart`: **every field is
/// nullable**, a missing/malformed value degrades to `null`/empty rather
/// than throwing.
///
/// Only the top-level verdict fields (`has_dosha`, `severity`, `type`/
/// `dosha_type`, `description`, `remedies`) are modelled — each dosha also
/// carries a large `interpretation` object (meaning/overview/remedial
/// measures/matching advice, hundreds of words) that nothing in the app
/// renders yet, so it is deliberately NOT parsed here. Add it if a detailed
/// per-dosha explanation screen is ever built.
@immutable
class AllDoshasData {
  const AllDoshasData({this.mangalDosha, this.kaalSarpDosha, this.pitruDosha});

  final MangalDosha? mangalDosha;
  final KaalSarpDosha? kaalSarpDosha;

  /// Parsed for completeness (it's part of the response this screen
  /// already fetches) but not currently shown anywhere — the Kundli Chart
  /// banner only surfaces Mangal Dosha and Kaal Sarp Dosha, matching the
  /// approved Figma design's original two-verdict banner. Nothing today
  /// asks for a third clause.
  final PitruDosha? pitruDosha;

  factory AllDoshasData.fromJson(Map<String, dynamic> json) {
    return AllDoshasData(
      mangalDosha: parseObj(json['mangal_dosha'], MangalDosha.fromJson),
      kaalSarpDosha: parseObj(json['kaal_sarp_dosha'], KaalSarpDosha.fromJson),
      pitruDosha: parseObj(json['pitru_dosha'], PitruDosha.fromJson),
    );
  }
}

@immutable
class MangalDosha {
  const MangalDosha({
    this.hasDosha,
    this.doshaType,
    this.description,
    this.severity,
    this.percentage,
    this.doshaFromLagna,
    this.doshaFromMoon,
    this.doshaFromVenus,
    this.hasException = false,
    this.isCancelled = false,
    this.cancellationReasons = const [],
    this.exceptions = const [],
    this.remedies = const [],
  });

  final bool? hasDosha;

  /// `null` in every observed "no dosha" response; a specific dosha
  /// sub-type name when [hasDosha] is true.
  final String? doshaType;

  /// Vedika's own one-sentence verdict, e.g. "No Mangal Dosha found in
  /// your birth chart." — English only, same "API text stays English"
  /// caveat as everywhere else in this feature.
  final String? description;

  /// e.g. `"None"`, `"Mild"`, `"Moderate"`, `"Severe"`.
  final String? severity;
  final double? percentage;

  final bool? doshaFromLagna;
  final bool? doshaFromMoon;
  final bool? doshaFromVenus;
  final bool hasException;
  final bool isCancelled;
  final List<String> cancellationReasons;
  final List<String> exceptions;
  final List<String> remedies;

  factory MangalDosha.fromJson(Map<String, dynamic> json) {
    return MangalDosha(
      hasDosha: json['has_dosha'] as bool?,
      doshaType: json['dosha_type'] as String?,
      description: json['description'] as String?,
      severity: json['severity'] as String?,
      percentage: parseDouble(json['percentage']),
      doshaFromLagna: json['dosha_from_lagna'] as bool?,
      doshaFromMoon: json['dosha_from_moon'] as bool?,
      doshaFromVenus: json['dosha_from_venus'] as bool?,
      hasException: (json['has_exception'] as bool?) ?? false,
      isCancelled: (json['is_cancelled'] as bool?) ?? false,
      cancellationReasons: parseStrings(json['cancellation_reasons']),
      exceptions: parseStrings(json['exceptions']),
      remedies: parseStrings(json['remedies']),
    );
  }
}

@immutable
class KaalSarpDosha {
  const KaalSarpDosha({
    this.hasDosha,
    this.description,
    this.direction,
    this.type,
    this.severity,
    this.isAnulom = false,
    this.isVilom = false,
    this.remedies = const [],
  });

  final bool? hasDosha;

  /// A GENERAL definition of Kaal Sarp Dosha (e.g. "Rahu in 8th house,
  /// sudden losses, accidents"), not a personalized verdict sentence —
  /// unlike [MangalDosha.description]. Verified against the real sandbox
  /// response 1 Aug 2026: this field is present and worded the same way
  /// whether [hasDosha] is true or false, so it is NOT used as the banner
  /// text on its own — see `_DoshaVerdict` in `kundli_chart_screen.dart`.
  final String? description;

  /// `"None"` when [hasDosha] is false; otherwise which nodal axis houses
  /// are involved.
  final String? direction;

  /// One of the 12 Kaal Sarp types (e.g. `"Ananta"`, `"Kulik"`) when
  /// [hasDosha] is true; `"None"` otherwise.
  final String? type;
  final String? severity;

  /// Direct-motion (Anulom) vs reverse-motion (Vilom) Kaal Sarp — only
  /// meaningful when [hasDosha] is true.
  final bool isAnulom;
  final bool isVilom;
  final List<String> remedies;

  factory KaalSarpDosha.fromJson(Map<String, dynamic> json) {
    return KaalSarpDosha(
      hasDosha: json['has_dosha'] as bool?,
      description: json['description'] as String?,
      direction: json['direction'] as String?,
      type: json['type'] as String?,
      severity: json['severity'] as String?,
      isAnulom: (json['is_anulom'] as bool?) ?? false,
      isVilom: (json['is_vilom'] as bool?) ?? false,
      remedies: parseStrings(json['remedies']),
    );
  }
}

@immutable
class PitruDosha {
  const PitruDosha({
    this.hasDosha,
    this.severity,
    this.percentage,
    this.remedies = const [],
  });

  final bool? hasDosha;
  final String? severity;
  final double? percentage;
  final List<String> remedies;

  factory PitruDosha.fromJson(Map<String, dynamic> json) {
    return PitruDosha(
      hasDosha: json['has_dosha'] as bool?,
      severity: json['severity'] as String?,
      percentage: parseDouble(json['percentage']),
      remedies: parseStrings(json['remedies']),
    );
  }
}
