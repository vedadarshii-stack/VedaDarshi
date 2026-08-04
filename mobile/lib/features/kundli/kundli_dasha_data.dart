import 'package:flutter/foundation.dart';

import 'kundli_data.dart' show KundliNakshatra;
import 'kundli_json.dart';

/// Typed, null-safe models for the Vedika `POST /v2/astrology/vimshottari-dasha`
/// response — powers the Kundli Chart screen's "Vimshottari Dasha" tab.
///
/// Same defensive-parsing policy as `kundli_data.dart`/`kundli_dosha_data.dart`:
/// every field is nullable, a missing/malformed value degrades to
/// `null`/empty rather than throwing.
///
/// [KundliNakshatra] is reused as-is from `kundli_data.dart` — Vedika's
/// `nakshatra` object here has the identical shape (id/name/lord/pada), so
/// modelling a second copy would just be duplication.
///
/// **Deliberately NOT modelled:** `current_dasha.interpretation` and
/// `current_dasha.antar_interpretation` — each is a large hand-written essay
/// (career/health/relationships/spiritual paragraphs, advice lists,
/// remedies…) that would need its own detail screen to do justice to.
/// [guidance] already surfaces Vedika's own condensed version of the same
/// content (`current_phase`, `theme`, `key_advice`, `recommended_remedies`,
/// `time_remaining`), which is what the Dasha tab actually renders — see
/// `kundli_dasha_tab.dart`.
@immutable
class VimshottariDashaData {
  const VimshottariDashaData({
    this.currentDasha,
    this.dashaBalance,
    this.guidance,
    this.mahaDashaPeriods = const [],
    this.nakshatra,
  });

  final CurrentDasha? currentDasha;

  /// The balance of the FIRST maha-dasha remaining **at birth** (a standard
  /// Vimshottari concept — every chart starts partway through whichever
  /// planet's period the Moon's nakshatra falls in) — NOT "time remaining
  /// in the CURRENT dasha now". See [currentDasha] /
  /// [VimshottariDashaData.mahaDashaPeriods] for what's running today.
  final DashaBalance? dashaBalance;
  final DashaGuidance? guidance;

  /// The full birth-to-∞ sequence of maha-dasha periods (Vedika returns all
  /// 9 planets' worth, cycling more than once across a ~120-year
  /// Vimshottari cycle) — "the maha_dasha period list" the Dasha tab
  /// renders, with [DashaPeriod.isCurrent] marking which one is running now.
  final List<DashaPeriod> mahaDashaPeriods;

  /// The Moon's birth nakshatra — same value as `KundliData.nakshatra`
  /// (both are derived from the same birth moment), fetched again here
  /// only because it arrives on this response too; not duplicated into a
  /// second network call.
  final KundliNakshatra? nakshatra;

  factory VimshottariDashaData.fromJson(Map<String, dynamic> json) {
    return VimshottariDashaData(
      currentDasha: parseObj(json['current_dasha'], CurrentDasha.fromJson),
      dashaBalance: parseObj(json['dasha_balance'], DashaBalance.fromJson),
      guidance: parseObj(json['guidance'], DashaGuidance.fromJson),
      mahaDashaPeriods: parseList(json['maha_dasha'], DashaPeriod.fromJson),
      nakshatra: parseObj(json['nakshatra'], KundliNakshatra.fromJson),
    );
  }
}

/// The three nested levels running right now — Vedika computes these
/// directly rather than the app having to walk [VimshottariDashaData.mahaDashaPeriods]
/// and its sub-periods to find "now".
@immutable
class CurrentDasha {
  const CurrentDasha({this.mahaDasha, this.antarDasha, this.pratyantarDasha});

  final DashaLevel? mahaDasha;
  final DashaLevel? antarDasha;
  final DashaLevel? pratyantarDasha;

  factory CurrentDasha.fromJson(Map<String, dynamic> json) {
    return CurrentDasha(
      mahaDasha: parseObj(json['maha_dasha'], DashaLevel.fromJson),
      antarDasha: parseObj(json['antar_dasha'], DashaLevel.fromJson),
      pratyantarDasha: parseObj(json['pratyantar_dasha'], DashaLevel.fromJson),
    );
  }
}

/// One dasha level's ruling planet + date range — the shape shared by
/// [CurrentDasha]'s maha/antar/pratyantar entries.
@immutable
class DashaLevel {
  const DashaLevel({this.planet, this.vedicName, this.startDate, this.endDate});

  /// English planet name, e.g. `"Moon"`.
  final String? planet;

  /// Sanskrit/Vedic name, e.g. `"Chandra"`.
  final String? vedicName;

  /// `"yyyy-MM-dd"`.
  final String? startDate;
  final String? endDate;

  factory DashaLevel.fromJson(Map<String, dynamic> json) {
    return DashaLevel(
      planet: json['planet'] as String?,
      vedicName: json['vedic_name'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }
}

/// Balance of the first maha-dasha remaining at birth — see
/// [VimshottariDashaData.dashaBalance]'s doc comment.
@immutable
class DashaBalance {
  const DashaBalance({
    this.planet,
    this.vedicName,
    this.years,
    this.months,
    this.days,
    this.elapsedPercentage,
  });

  final String? planet;
  final String? vedicName;
  final int? years;
  final int? months;
  final int? days;
  final double? elapsedPercentage;

  factory DashaBalance.fromJson(Map<String, dynamic> json) {
    return DashaBalance(
      planet: json['planet'] as String?,
      vedicName: json['vedic_name'] as String?,
      years: parseInt(json['years']),
      months: parseInt(json['months']),
      days: parseInt(json['days']),
      elapsedPercentage: parseDouble(json['elapsed_percentage']),
    );
  }
}

/// Vedika's own condensed summary of the CURRENT running period — see
/// [VimshottariDashaData]'s class doc for why this is used instead of the
/// much larger `interpretation` essay objects.
@immutable
class DashaGuidance {
  const DashaGuidance({
    this.currentPhase,
    this.theme,
    this.timeRemaining,
    this.keyAdvice = const [],
    this.recommendedRemedies = const [],
  });

  /// e.g. `"You are in Moon (Chandra) Maha Dasha"`.
  final String? currentPhase;

  /// e.g. `"Emotions, Mind, and Nurturing"`.
  final String? theme;

  /// e.g. `"18 years, 11 months remaining"` — a ready-to-display sentence,
  /// not a value this app recomputes.
  final String? timeRemaining;
  final List<String> keyAdvice;
  final List<String> recommendedRemedies;

  factory DashaGuidance.fromJson(Map<String, dynamic> json) {
    return DashaGuidance(
      currentPhase: json['current_phase'] as String?,
      theme: json['theme'] as String?,
      timeRemaining: json['time_remaining'] as String?,
      keyAdvice: parseStrings(json['key_advice']),
      recommendedRemedies: parseStrings(json['recommended_remedies']),
    );
  }
}

/// One period in the full Vimshottari timeline — either a top-level
/// maha-dasha entry in [VimshottariDashaData.mahaDashaPeriods], or one of
/// its own [antarDashas] sub-periods (same shape, one level shallower:
/// Vedika does not send a third level of nesting inside these, unlike
/// [CurrentDasha] which goes maha → antar → pratyantar for "now" only).
@immutable
class DashaPeriod {
  const DashaPeriod({
    this.planet,
    this.vedicName,
    this.startDate,
    this.endDate,
    this.durationYears,
    this.dignity,
    this.dignityStrength,
    this.isCurrent = false,
    this.antarDashas = const [],
  });

  final String? planet;
  final String? vedicName;
  final String? startDate;
  final String? endDate;
  final double? durationYears;

  /// e.g. `"own"`, `"neutral"` — same vocabulary as
  /// `KundliPlanetDignity.dignity` in `kundli_data.dart`.
  final String? dignity;
  final double? dignityStrength;

  /// True for exactly one entry in the whole timeline — the period
  /// covering today's date.
  final bool isCurrent;

  /// Parsed for completeness; the Dasha tab currently renders only the
  /// top-level [VimshottariDashaData.mahaDashaPeriods] list, not each
  /// period's own antar-dasha breakdown — that level of detail is future
  /// work (see [VimshottariDashaData]'s "not modelled" note for the
  /// reasoning behind scoping this tab to the condensed view).
  final List<DashaPeriod> antarDashas;

  factory DashaPeriod.fromJson(Map<String, dynamic> json) {
    return DashaPeriod(
      planet: json['planet'] as String?,
      vedicName: json['vedic_name'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      durationYears: parseDouble(json['duration_years']),
      dignity: json['dignity'] as String?,
      dignityStrength: parseDouble(json['dignity_strength']),
      isCurrent: (json['is_current'] as bool?) ?? false,
      antarDashas: parseList(json['antar_dasha'], DashaPeriod.fromJson),
    );
  }
}
