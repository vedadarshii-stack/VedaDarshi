import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Static placeholder data for the Gun Milan result screen, per the approved
/// Figma "C2 · Gun Milan — Result" (node 20:2) concept.
///
/// Standing in for the Vedika API's 36-point Ashtakoota Gun Milan endpoint
/// (see `projects/CLAUDE.md`'s "Confirmed stack decisions" section) — nothing
/// here is a real calculation, only presentation-ready placeholder copy.
///
/// [brideName] is static because no bride profile can be selected yet
/// (multi-profile support isn't built — see `gun_milan_static_data.dart`'s
/// doc comment for the same gap on the Select screen). The groom name on
/// this screen comes from the real saved [BirthProfile] instead.
abstract final class GunMilanResultStaticData {
  static const String brideName = 'Ananya';

  static const double totalScore = 27.5;
  static const int maxScore = 36;
  static const int compatibilityPercent = 76;
  static const String verdict = 'Excellent Match — marriage is favourable';

  static const String aiSummary =
      'A strong emotional and mental match (Gana 6/6, Maitri 5/5). The lower '
      'Nadi score suggests health-related remedies before marriage — overall '
      'this is a favourable union with 76% compatibility.';

  static const String nadiWarning =
      "Nadi scored 3/8 — consult remedies section for suggested upayas.";

  /// The 8 gunas in the design's display order (Figma node 20:21).
  static const List<GunaScore> gunas = [
    GunaScore(id: 'varna', score: 1, max: 1, band: GunaBand.strong),
    GunaScore(id: 'vashya', score: 2, max: 2, band: GunaBand.strong),
    GunaScore(id: 'tara', score: 2.5, max: 3, band: GunaBand.strong),
    GunaScore(id: 'yoni', score: 3, max: 4, band: GunaBand.strong),
    GunaScore(id: 'grahaMaitri', score: 5, max: 5, band: GunaBand.strong),
    GunaScore(id: 'gana', score: 6, max: 6, band: GunaBand.strong),
    GunaScore(id: 'bhakoot', score: 5, max: 7, band: GunaBand.strong),
    // Nadi is 3/8 = 37.5% — see [GunaBand]'s doc comment for why this is
    // MODERATE rather than Weak despite the legend's own thresholds.
    GunaScore(id: 'nadi', score: 3, max: 8, band: GunaBand.moderate),
  ];
}

/// One row of the Ashtakoota breakdown grid.
class GunaScore {
  const GunaScore({
    required this.id,
    required this.score,
    required this.max,
    required this.band,
  });

  /// Stable id resolved to an l10n label by the screen (`gunaVarna`,
  /// `gunaVashya`, etc.) — not itself display text.
  final String id;
  final double score;
  final int max;
  final GunaBand band;
}

/// Strong / Moderate / Weak classification for a single guna score.
///
/// **Stored EXPLICITLY per [GunaScore] rather than computed from
/// `score / max`, on purpose.** The design's own legend (Figma node 51:3)
/// states Strong ≥75%, Moderate 40–74%, Weak <40% — yet Nadi at 3/8 (37.5%)
/// is coloured MODERATE (amber) in the approved design, not Weak (red). This
/// file follows the design's rendering rather than "fixing" the apparent
/// inconsistency, because:
///  1. It may be intentional — Nadi Dosha has partial-cancellation rules in
///     real Ashtakoota practice that a flat percentage cutoff doesn't
///     capture, and the Figma author may have applied one.
///  2. When the Vedika API is wired up it will return its OWN classification
///     per guna anyway, making any client-side threshold logic here
///     temporary scaffolding at best.
/// Do not silently switch this to a computed `score/max` classification —
/// confirm with the client first if the mismatch looks like a design bug.
enum GunaBand {
  strong,
  moderate,
  weak;

  /// Tinted background for a band, reusing the same tokens as the rest of
  /// the app's shubh/caution/ashubh color language (see `app_colors.dart`'s
  /// Gun Milan Result section) rather than introducing new literals.
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
