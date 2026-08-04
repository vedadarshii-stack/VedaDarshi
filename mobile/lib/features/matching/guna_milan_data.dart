import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../profile/birth_profile.dart';

/// Birth details for ONE partner, in the exact shape Vedika's
/// `POST /v2/astrology/guna-milan` expects inside the request body.
///
/// **The request keys are `"male"`/`"female"` — NOT `"boy"`/`"girl"`.**
/// Posting `boy`/`girl` returns Vedika's `MISSING_PARTNER_DETAILS` error
/// (verified against the live sandbox 1 Aug 2026 while building this
/// feature) — [GunaMilanMatchRequest] and `guna_milan_repository.dart` are
/// what actually attach the `male`/`female` keys; this class only knows how
/// to serialize ONE side.
class GunaMilanPartnerParams {
  const GunaMilanPartnerParams({
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  /// Local (naive) ISO-8601 datetime, no offset suffix — e.g.
  /// `"1995-06-20T10:30:00"`.
  final String datetime;
  final double latitude;
  final double longitude;

  /// Fixed UTC offset string, e.g. `"+05:30"` — a numeric offset, NOT an
  /// IANA zone id. Vedika's ephemeris call wants the offset AT the birth
  /// moment, same reasoning as [BirthProfile.toFirestore]'s
  /// `utcOffsetMinutes` field.
  final String timezone;

  /// Builds the request shape from a real saved [BirthProfile] — resolves
  /// the HISTORICAL UTC offset via the same `package:timezone` machinery
  /// [BirthProfile] itself uses ([utcOffsetMinutesFor]), so a pre-1970 or
  /// foreign birth still gets the correct offset rather than today's.
  factory GunaMilanPartnerParams.fromBirthProfile(BirthProfile profile) {
    final offsetMinutes = utcOffsetMinutesFor(
      profile.city,
      profile.dateOfBirth,
      profile.timeOfBirth,
    );
    return GunaMilanPartnerParams(
      datetime: _isoDatetime(profile.dateOfBirth, profile.timeOfBirth),
      latitude: profile.city.latitude,
      longitude: profile.city.longitude,
      timezone: _formatOffset(offsetMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
    'datetime': datetime,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
  };

  static String _isoDatetime(DateTime date, TimeOfDay time) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$y-$m-${d}T$h:$min:00';
  }

  static String _formatOffset(int minutes) {
    final sign = minutes < 0 ? '-' : '+';
    final abs = minutes.abs();
    final h = (abs ~/ 60).toString().padLeft(2, '0');
    final m = (abs % 60).toString().padLeft(2, '0');
    return '$sign$h:$m';
  }

  // Manual equality (no `equatable` dependency in this project) — required
  // so [GunaMilanMatchRequest], a record made of two of these, gets correct
  // structural `==`/`hashCode` for Riverpod's `.family` cache key.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GunaMilanPartnerParams &&
          other.datetime == datetime &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.timezone == timezone);

  @override
  int get hashCode => Object.hash(datetime, latitude, longitude, timezone);
}

/// The two partners for one Gun Milan match — the `.family` key consumed by
/// `gunaMilanResultProvider` in `guna_milan_repository.dart`.
///
/// A **record**, not a class: records get structural `==`/`hashCode` for
/// free (given [GunaMilanPartnerParams]'s own manual `==` above), which is
/// exactly what Riverpod needs to dedupe two watchers requesting the same
/// match and what the repository's cache map key needs.
typedef GunaMilanMatchRequest = ({
  GunaMilanPartnerParams male,
  GunaMilanPartnerParams female,
});

/// Strong / Moderate / Weak classification for a single guna score.
///
/// **Computed from `score / maxPoints`**, against the design's own legend
/// (Figma node 51:3, "C2 · Gun Milan — Result"): Strong ≥75%, Moderate
/// 40–74%, Weak <40%. This replaces the OLD placeholder data
/// (`gun_milan_result_static_data.dart`, now deleted), which stored the
/// band explicitly per guna because its hand-picked Nadi example (3/8 =
/// 37.5%) was shown as Moderate despite the legend's own Weak cutoff — see
/// `projects/CLAUDE.md`'s note on that design inconsistency. There is no
/// such special case here: every real guna score is classified by this one
/// formula, so if the API's Nadi score also lands at 37.5% one day it WILL
/// render Weak (red), not Moderate — that is the intended, documented
/// behaviour of wiring the real API, not a bug to "fix" back to the old
/// placeholder's exception.
enum GunaBand {
  strong,
  moderate,
  weak;

  static GunaBand fromRatio(double ratio) {
    if (ratio >= 0.75) return GunaBand.strong;
    if (ratio >= 0.40) return GunaBand.moderate;
    return GunaBand.weak;
  }

  /// Tinted background for a band, reusing the same tokens as the rest of
  /// the app's shubh/caution/ashubh color language (see `app_colors.dart`'s
  /// Gun Milan Result section).
  Color get background {
    switch (this) {
      case GunaBand.strong:
        return AppColors.geoChipBg;
      case GunaBand.moderate:
        return AppColors.warnBg;
      case GunaBand.weak:
        return AppColors.ashubhBg;
    }
  }

  /// Tinted foreground for a band.
  Color get foreground {
    switch (this) {
      case GunaBand.strong:
        return AppColors.tileGreenFg;
      case GunaBand.moderate:
        return AppColors.mantraLabel;
      case GunaBand.weak:
        return AppColors.ashubhFg;
    }
  }
}

/// One entry of the Ashtakoota breakdown, parsed from the API's
/// `gunaDetails` MAP (keyed by koota id — see [GunaMilanResult.fromJson]
/// for how the map is walked in display order).
///
/// Every field but [id] is nullable/defaulted — the API response is treated
/// as untrusted per the integration brief, so a screen must render whatever
/// actually came back rather than assuming all 8 kootas, or all of a
/// koota's sub-fields, are always present.
class GunaMilanGuna {
  const GunaMilanGuna({
    required this.id,
    this.name,
    this.score,
    this.maxPoints,
    this.interpretation,
    this.significance,
    this.tips = const [],
  });

  /// Our own stable id, used for the l10n label lookup + fixed display
  /// order (`_gunaLabel` in `gun_milan_result_screen.dart`).
  ///
  /// **Note the API spells the 2nd koota `"vasya"`; this app's id/l10n key
  /// stays `"vashya"`** (already approved in Figma + all 5 ARB files as
  /// `gunaVashya` before this endpoint was ever inspected). Renaming the
  /// ARB key to match Vedika's spelling would touch every locale for a
  /// cosmetic reason, so [GunaMilanResult.fromJson] does the key
  /// translation instead — this field always holds OUR spelling.
  final String id;

  /// The API's own descriptive name for this koota (e.g. "Bhakoot
  /// (Financial & Family Prosperity)") — NOT used as the grid card's title;
  /// the card keeps using the existing short localized label. Kept here for
  /// a future explanatory sheet.
  final String? name;

  final double? score;
  final int? maxPoints;
  final String? interpretation;
  final String? significance;
  final List<String> tips;

  /// `null` when [score] or [maxPoints] is missing or [maxPoints] is zero —
  /// a screen must handle that (e.g. render a neutral badge) rather than
  /// divide by zero or invent a band.
  GunaBand? get band {
    final s = score;
    final max = maxPoints;
    if (s == null || max == null || max == 0) return null;
    return GunaBand.fromRatio(s / max);
  }
}

/// Moon sign/nakshatra for one partner (the API's `male_info`/`female_info`
/// objects).
///
/// Parsed but currently UNRENDERED — there is no approved Figma slot for it
/// on "C2 · Gun Milan — Result" (only names + the score breakdown are
/// shown), and the integration brief is explicit about keeping this
/// screen's visual design unchanged. Captured here so a future design pass
/// can surface it without another API-shape investigation.
class GunaMilanPartnerInfo {
  const GunaMilanPartnerInfo({this.moonSign, this.moonNakshatra});

  final String? moonSign;
  final String? moonNakshatra;

  factory GunaMilanPartnerInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GunaMilanPartnerInfo();
    return GunaMilanPartnerInfo(
      moonSign: json['moon_sign'] as String?,
      moonNakshatra: json['moon_nakshatra'] as String?,
    );
  }
}

/// The API's `interpretation` object.
///
/// **NOT a plain string** — the integration brief described it as
/// abbreviated, and inspecting the live sandbox response (1 Aug 2026)
/// confirmed it is a structured object (`summary`, `marriageProspects`,
/// `strengths[]`, `challenges[]`, `guidance[]`), not free text.
class GunaMilanInterpretation {
  const GunaMilanInterpretation({
    this.summary,
    this.marriageProspects,
    this.strengths = const [],
    this.challenges = const [],
    this.guidance = const [],
  });

  final String? summary;
  final String? marriageProspects;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> guidance;

  factory GunaMilanInterpretation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GunaMilanInterpretation();
    return GunaMilanInterpretation(
      summary: json['summary'] as String?,
      marriageProspects: json['marriageProspects'] as String?,
      strengths: _stringList(json['strengths']),
      challenges: _stringList(json['challenges']),
      guidance: _stringList(json['guidance']),
    );
  }

  /// The Rishi AI summary card's body copy: [summary] followed by
  /// [marriageProspects], whichever of the two are actually present. `null`
  /// when neither is — the card is hidden entirely rather than showing
  /// empty space (see the result screen).
  ///
  /// Raw API English text either way — the API does not localize this
  /// field per the app's active locale, a known, documented gap for the 4
  /// Indic locales (see the result screen's own doc comment).
  String? get displayText {
    final parts = [
      summary,
      marriageProspects,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}

/// Fixed display order + id mapping for [GunaMilanResult.fromJson] — first
/// element is the API's `gunaDetails` map key, second is this app's own id
/// (see [GunaMilanGuna.id]'s doc comment for the one deliberate mismatch,
/// `vasya` → `vashya`). Matches the approved Figma grid (node 20:21) and
/// the order the old placeholder data used.
const List<(String apiKey, String ourId)> _gunaOrder = [
  ('varna', 'varna'),
  ('vasya', 'vashya'),
  ('tara', 'tara'),
  ('yoni', 'yoni'),
  ('grahaMaitri', 'grahaMaitri'),
  ('gana', 'gana'),
  ('bhakoot', 'bhakoot'),
  ('nadi', 'nadi'),
];

/// Ashtakoota Gun Milan match result — the parsed `data` object from
/// `POST /v2/astrology/guna-milan`.
///
/// Every field is nullable/defaulted; see [GunaMilanGuna]'s doc comment for
/// why — the same "never assume presence" rule applies at this top level.
class GunaMilanResult {
  const GunaMilanResult({
    this.totalPoints,
    this.maximumPoints,
    this.percentage,
    this.matchResult,
    this.recommendation,
    this.remedies = const [],
    this.interpretation = const GunaMilanInterpretation(),
    this.maleInfo = const GunaMilanPartnerInfo(),
    this.femaleInfo = const GunaMilanPartnerInfo(),
    this.gunas = const [],
  });

  final double? totalPoints;
  final int? maximumPoints;
  final int? percentage;
  final String? matchResult;
  final String? recommendation;

  /// Suggested remedies/upayas, already full sentences (e.g. "Nadi Dosha:
  /// Perform Nadi Dosha Nivarana Puja") — rendered as-is, not templated
  /// into a sentence the way the old placeholder's Nadi-specific warning
  /// text was, since these can be about any koota, not just Nadi.
  final List<String> remedies;

  final GunaMilanInterpretation interpretation;
  final GunaMilanPartnerInfo maleInfo;
  final GunaMilanPartnerInfo femaleInfo;

  /// The gunas actually present in the API's `gunaDetails` map, in the
  /// approved Figma display order — see [_gunaOrder]. May have fewer than 8
  /// entries if the API omits one; the grid renders whatever this list
  /// holds rather than assuming a fixed length of 8.
  final List<GunaMilanGuna> gunas;

  /// Verdict-pill copy: `"$matchResult — $recommendation"`, or just
  /// whichever half is present, or `null` if neither is (the pill is
  /// hidden in that case — see the result screen).
  ///
  /// Raw API English text, same non-localized-content gap as
  /// [GunaMilanInterpretation.displayText].
  String? get verdictText {
    final result = matchResult?.trim();
    final rec = recommendation?.trim();
    final hasResult = result != null && result.isNotEmpty;
    final hasRec = rec != null && rec.isNotEmpty;
    if (hasResult && hasRec) return '$result — $rec';
    if (hasResult) return result;
    if (hasRec) return rec;
    return null;
  }

  /// Compatibility percentage to drive the score ring, resilient to the API
  /// omitting `percentage` outright: falls back to `total/max` when both of
  /// those are present, else `0` (an empty ring, not a crash).
  int get effectivePercent {
    final pct = percentage;
    if (pct != null) return pct;
    final total = totalPoints;
    final max = maximumPoints;
    if (total != null && max != null && max > 0) {
      return ((total / max) * 100).round();
    }
    return 0;
  }

  factory GunaMilanResult.fromJson(Map<String, dynamic> json) {
    final rawGunaDetails = json['gunaDetails'];
    final gunaMap = rawGunaDetails is Map<String, dynamic>
        ? rawGunaDetails
        : const <String, dynamic>{};

    final gunas = <GunaMilanGuna>[];
    for (final pair in _gunaOrder) {
      final raw = gunaMap[pair.$1];
      if (raw is! Map<String, dynamic>) continue;
      gunas.add(
        GunaMilanGuna(
          id: pair.$2,
          name: raw['name'] as String?,
          score: (raw['score'] as num?)?.toDouble(),
          maxPoints: (raw['maxPoints'] as num?)?.toInt(),
          interpretation: raw['interpretation'] as String?,
          significance: raw['significance'] as String?,
          tips: _stringList(raw['tips']),
        ),
      );
    }

    return GunaMilanResult(
      totalPoints: (json['total_points'] as num?)?.toDouble(),
      maximumPoints: (json['maximum_points'] as num?)?.toInt(),
      percentage: (json['percentage'] as num?)?.toInt(),
      matchResult: json['match_result'] as String?,
      recommendation: json['recommendation'] as String?,
      remedies: _stringList(json['remedies']),
      interpretation: GunaMilanInterpretation.fromJson(
        json['interpretation'] as Map<String, dynamic>?,
      ),
      maleInfo: GunaMilanPartnerInfo.fromJson(
        json['male_info'] as Map<String, dynamic>?,
      ),
      femaleInfo: GunaMilanPartnerInfo.fromJson(
        json['female_info'] as Map<String, dynamic>?,
      ),
      gunas: gunas,
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList();
}
