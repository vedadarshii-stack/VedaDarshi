import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'gun_milan_result_static_data.dart';
import 'gun_milan_static_data.dart';

/// Gun Milan — Result, per the approved Figma "C2 · Gun Milan — Result"
/// (node 20:2) concept.
///
/// Reached from the Gun Milan — Select screen's "Match Kundlis" CTA. Like
/// that screen, this has NO bottom nav in the design — it's a pushed
/// destination with its own back button.
///
/// Every astrology VALUE shown below (guna scores, verdict, AI summary) is
/// STATIC PLACEHOLDER DATA from [GunMilanResultStaticData]; see that file's
/// doc comment for what eventually replaces it (the Vedika API).
class GunMilanResultScreen extends ConsumerStatefulWidget {
  const GunMilanResultScreen({super.key});

  @override
  ConsumerState<GunMilanResultScreen> createState() =>
      _GunMilanResultScreenState();
}

class _GunMilanResultScreenState extends ConsumerState<GunMilanResultScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    // Same fallback convention as the Select screen — see that screen's own
    // comment on why `valueOrNull` alone (no loading flash) is correct here.
    final profile = ref.watch(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final groomName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : GunMilanStaticData.fallbackGroomName;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(l10n: l10n, locale: locale, groomName: groomName),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ashtakootaBreakdown,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                _LegendRow(l10n: l10n, locale: locale),
                const SizedBox(height: 10),
                _GunaGrid(l10n: l10n, locale: locale),
                const SizedBox(height: 10),
                _AiSummaryCard(l10n: l10n, locale: locale),
                const SizedBox(height: 10),
                _NadiWarning(locale: locale),
                const SizedBox(height: 10),
                _ReportCta(l10n: l10n, locale: locale),
                const SizedBox(height: 10),
                _FooterHint(l10n: l10n, locale: locale),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header hero (Figma node 20:3): back + download, the animated score ring,
/// verdict pill and couple line.
///
/// Deliberately NOT inside a top [SafeArea] — [AppColors.navyHeroGradient]
/// must run under the status bar, same convention as the Horoscope Detail
/// header.
class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.locale,
    required this.groomName,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String groomName;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 16 > 52 ? statusBarInset + 16 : 52.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.navyHeroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  l10n.matchResult,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  // No-op for now: PDF export is a later feature, not part
                  // of this screen build.
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ScoreRing(locale: locale, l10n: l10n),
          const SizedBox(height: 16),
          Text(
            l10n.percentCompatible(GunMilanResultStaticData.compatibilityPercent),
            style: AppFonts.body(
              locale,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          _VerdictPill(locale: locale),
          const SizedBox(height: 10),
          Text(
            '$groomName  💞  ${GunMilanResultStaticData.brideName}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.headerSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Green verdict pill (Figma node 20:9). The verdict copy is long and grows
/// further in Indic locales, so it's allowed to wrap to 2 lines and stays
/// centred rather than overflowing.
class _VerdictPill extends StatelessWidget {
  const _VerdictPill({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.tileGreenFg.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.tileGreenFg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.check_rounded,
              size: 13,
              color: AppColors.matchSuccessText,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              GunMilanResultStaticData.verdict,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                locale,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.matchSuccessText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The 150×150 animated compatibility ring (Figma node 20:5). Replaces the
/// design's two exported ellipse PNGs — a static raster ring can't animate
/// its sweep or scale cleanly, whereas a [CustomPainter] can do both and
/// derives every measurement from the canvas size it's given.
class _ScoreRing extends StatefulWidget {
  const _ScoreRing({required this.locale, required this.l10n});

  final Locale locale;
  final AppLocalizations l10n;

  @override
  State<_ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<_ScoreRing> {
  @override
  Widget build(BuildContext context) {
    final target = GunMilanResultStaticData.compatibilityPercent / 100;

    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: target),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: const Size(150, 150),
                painter: _ScoreRingPainter(progress: value),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatScore(GunMilanResultStaticData.totalScore),
                style: AppFonts.heading(
                  widget.locale,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.l10n.outOfMax(GunMilanResultStaticData.maxScore),
                style: AppFonts.body(
                  widget.locale,
                  fontSize: 11,
                  color: AppColors.mutedOnNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.0667; // ~10 at 150px
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Formats a guna/total score so 2.5 shows as "2.5" and 1.0 shows as "1"
/// (never a trailing ".0").
String _formatScore(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// Strong / Moderate / Weak legend row (Figma node 51:3).
class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LegendChip(
            label: l10n.bandStrong,
            band: GunaBand.strong,
            locale: locale,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _LegendChip(
            label: l10n.bandModerate,
            band: GunaBand.moderate,
            locale: locale,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _LegendChip(
            label: l10n.bandWeak,
            band: GunaBand.weak,
            locale: locale,
          ),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.band,
    required this.locale,
  });

  final String label;
  final GunaBand band;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: band.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: band.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                locale,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: band.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves the l10n label for a [GunaScore.id].
String _gunaLabel(String id, AppLocalizations l10n) {
  switch (id) {
    case 'varna':
      return l10n.gunaVarna;
    case 'vashya':
      return l10n.gunaVashya;
    case 'tara':
      return l10n.gunaTara;
    case 'yoni':
      return l10n.gunaYoni;
    case 'grahaMaitri':
      return l10n.gunaGrahaMaitri;
    case 'gana':
      return l10n.gunaGana;
    case 'bhakoot':
      return l10n.gunaBhakoot;
    case 'nadi':
      return l10n.gunaNadi;
    default:
      return id;
  }
}

/// 4×2 guna score grid (Figma node 20:21), driven entirely by
/// [GunMilanResultStaticData.gunas].
class _GunaGrid extends StatelessWidget {
  const _GunaGrid({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final gunas = GunMilanResultStaticData.gunas;
    final rows = <Widget>[];
    for (var i = 0; i < gunas.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      final second = i + 1 < gunas.length ? gunas[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _GunaCard(guna: gunas[i], l10n: l10n, locale: locale)),
            const SizedBox(width: 8),
            Expanded(
              child: second != null
                  ? _GunaCard(guna: second, l10n: l10n, locale: locale)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _GunaCard extends StatelessWidget {
  const _GunaCard({required this.guna, required this.l10n, required this.locale});

  final GunaScore guna;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    // Tap is intentionally a no-op — the footer hint below promises a
    // per-guna explanation sheet, but the explanatory copy for the 8 gunas
    // hasn't been approved by the client yet, so we don't invent it.
    return Semantics(
      button: true,
      label: _gunaLabel(guna.id, l10n),
      child: PressableScale(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _gunaLabel(guna.id, l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: guna.band.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_formatScore(guna.score)}/${guna.max}',
                  style: AppFonts.body(
                    locale,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: guna.band.foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rishi AI summary card (Figma node 51:10).
class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.tilePurpleBg,
        border: Border.all(color: AppColors.aiCardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.rishiAiSummary,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.aiTitle,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tilePurpleFg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '✨ ${l10n.aiBadge}',
                  style: AppFonts.body(
                    locale,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            GunMilanResultStaticData.aiSummary,
            style: AppFonts.body(
              locale,
              fontSize: 11.5,
              color: AppColors.aiBody,
              height: 1.58,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nadi warning banner (Figma node 20:58).
class _NadiWarning extends StatelessWidget {
  const _NadiWarning({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warnBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.tileGoldFg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              GunMilanResultStaticData.nadiWarning,
              style: AppFonts.body(locale, fontSize: 11.5, color: AppColors.tileGoldFg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width "Get Detailed Compatibility Report" CTA (Figma node 20:60).
class _ReportCta extends StatelessWidget {
  const _ReportCta({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.detailedCompatibilityReport,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        // Detailed compatibility is a premium report — opens the paywall.
        onTap: () => Navigator.of(context).push(
          fadeThroughRoute(const SubscriptionPaywallScreen()),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.tileBlueFg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l10n.detailedCompatibilityReport,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer hint (Figma node 51:17).
class _FooterHint extends StatelessWidget {
  const _FooterHint({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline, size: 11, color: AppColors.hint),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.tapGunaHint,
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 10.5, color: AppColors.hint),
          ),
        ),
      ],
    );
  }
}
