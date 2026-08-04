import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';

/// Non-negotiable banner shown on every Kundli Chart tab whenever
/// `VedikaConfig.isSandbox` is true — see that getter's doc comment.
///
/// **Applies to all three live tabs, not just Chart.** Verified 1 Aug 2026
/// by comparing the sandbox's `/kundli`, `/planet-positions` and
/// `/vimshottari-dasha` responses for the SAME birth request: all three
/// echo back identical fixture data (e.g. the same "Purva Ashadha"
/// nakshatra) regardless of what was actually posted — one shared sandbox
/// fixture backs every one of these endpoints, not just `/kundli`. So the
/// Planet Positions and Vimshottari Dasha tabs are showing sample data
/// exactly as much as the Chart tab is, and silently omitting this banner
/// on either would misrepresent that. Originally private to
/// `kundli_chart_screen.dart`; promoted to a shared widget for this reason.
class KundliSandboxBanner extends StatelessWidget {
  const KundliSandboxBanner({super.key, required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // Reuses the Panchang "caution" tone — a sample-data notice is a
        // heads-up, not an error, so the ashubh (error) tint would overstate
        // it and the geo-chip (neutral info) tone would understate it.
        color: AppColors.warnBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, size: 14, color: AppColors.mantraLabel),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.kundliSandboxBanner,
              style: AppFonts.body(
                locale,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.mantraLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
