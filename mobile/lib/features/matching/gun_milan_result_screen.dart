import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'guna_milan_data.dart';
import 'guna_milan_repository.dart';
import 'gun_milan_static_data.dart';

/// Gun Milan — Result, per the approved Figma "C2 · Gun Milan — Result"
/// (node 20:2) concept.
///
/// Reached from the Gun Milan — Select screen's "Match Kundlis" CTA. Like
/// that screen, this has NO bottom nav in the design — it's a pushed
/// destination with its own back button.
///
/// **Wired to the real Vedika Ashtakoota Gun Milan endpoint** (`POST
/// /v2/astrology/guna-milan` — see `guna_milan_data.dart` +
/// `guna_milan_repository.dart`). The GROOM side is the real signed-in
/// [BirthProfile]; the BRIDE side is still a placeholder because
/// multi-profile support isn't built — see
/// [GunMilanStaticData.placeholderBridePartnerParams]'s doc comment for the
/// exact gap.
///
/// **Known gap: API text is English-only.** `interpretation`,
/// `recommendation`, `match_result` and `remedies` all come back in English
/// from Vedika regardless of the app's active locale, and are rendered
/// as-is below rather than run through [AppLocalizations] — there is
/// nothing to translate them with client-side, and Vedika does not offer a
/// language parameter on this endpoint. This affects the 4 Indic locales
/// and needs a real fix (either a translation pass server-side, or asking
/// Vedika for locale support) before this screen is fully localized.
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

    final maleParams = profile != null
        ? GunaMilanPartnerParams.fromBirthProfile(profile)
        : GunMilanStaticData.fallbackGroomPartnerParams;
    // BRIDE side has no real profile to read — see
    // GunMilanStaticData.placeholderBridePartnerParams's doc comment for
    // why this is a fixed placeholder rather than a second saved profile,
    // and the multi-profile gap that causes it.
    final femaleParams = GunMilanStaticData.placeholderBridePartnerParams;
    final request = (male: maleParams, female: femaleParams);

    final resultAsync = ref.watch(gunaMilanResultProvider(request));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: resultAsync.when(
        data: (result) => _ResultContent(
          l10n: l10n,
          locale: locale,
          groomName: groomName,
          result: result,
        ),
        loading: () => _LoadingBody(l10n: l10n, locale: locale),
        error: (error, stackTrace) => _ErrorBody(
          l10n: l10n,
          locale: locale,
          onRetry: () => ref.invalidate(gunaMilanResultProvider(request)),
        ),
      ),
    );
  }
}

/// Back button alone, used by both the loading and error bodies so the user
/// is never stuck on this screen while a match is in flight or failed —
/// neither state has an approved Figma frame, so this is a minimal,
/// design-system-consistent stand-in rather than the full navy hero.
class _MinimalBackBar extends StatelessWidget {
  const _MinimalBackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
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
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(Icons.arrow_back, size: 16, color: AppColors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown while `gunaMilanResultProvider` is in flight.
class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _MinimalBackBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.saffron,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.matchLoading,
                    style: AppFonts.body(
                      locale,
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when `gunaMilanResultProvider` throws — most likely a
/// [VedikaException] (network/timeout/balance), but any error is treated
/// the same generic way here rather than surfacing Vedika's raw error text
/// to the user.
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.l10n,
    required this.locale,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _MinimalBackBar(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  iconBackgroundColor: AppColors.ashubhBg,
                  iconForegroundColor: AppColors.ashubhFg,
                  title: l10n.matchErrorTitle,
                  message: l10n.matchErrorMessage,
                  actionLabel: l10n.retry,
                  onAction: onRetry,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The real "C2 · Gun Milan — Result" content, once [GunaMilanResult] has
/// loaded — this is the previous static-data build() body, now driven by
/// real data end to end.
class _ResultContent extends StatelessWidget {
  const _ResultContent({
    required this.l10n,
    required this.locale,
    required this.groomName,
    required this.result,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String groomName;
  final GunaMilanResult result;

  @override
  Widget build(BuildContext context) {
    final aiSummary = result.interpretation.displayText;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(l10n: l10n, locale: locale, groomName: groomName, result: result),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (VedikaConfig.isSandbox) ...[
                _SandboxBanner(l10n: l10n, locale: locale),
                const SizedBox(height: 10),
              ],
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
              _GunaGrid(gunas: result.gunas, l10n: l10n, locale: locale),
              if (aiSummary != null) ...[
                const SizedBox(height: 10),
                _AiSummaryCard(
                  l10n: l10n,
                  locale: locale,
                  summary: aiSummary,
                ),
              ],
              if (result.remedies.isNotEmpty) ...[
                const SizedBox(height: 10),
                _RemediesBanner(locale: locale, remedies: result.remedies),
              ],
              const SizedBox(height: 10),
              _ReportCta(l10n: l10n, locale: locale),
              const SizedBox(height: 10),
              _FooterHint(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ],
    );
  }
}

/// Informational banner shown only while pointed at Vedika's sandbox (see
/// `VedikaConfig.isSandbox`'s doc comment) — the sandbox returns one FIXED
/// sample match regardless of the birth details posted, so presenting it as
/// a real reading for these two people would be actively misleading.
class _SandboxBanner extends StatelessWidget {
  const _SandboxBanner({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tileCyanBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.tileCyanFg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.sandboxResultBanner,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.tileCyanFg,
              ),
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
    required this.result,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String groomName;
  final GunaMilanResult result;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 16 > 52 ? statusBarInset + 16 : 52.0;
    final verdictText = result.verdictText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 24),
      decoration: BoxDecoration(
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
          _ScoreRing(locale: locale, l10n: l10n, result: result),
          const SizedBox(height: 16),
          Text(
            l10n.percentCompatible(result.effectivePercent),
            style: AppFonts.body(
              locale,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          if (verdictText != null) ...[
            const SizedBox(height: 16),
            _VerdictPill(locale: locale, verdictText: verdictText),
          ],
          const SizedBox(height: 10),
          Text(
            '$groomName  💞  ${GunMilanStaticData.placeholderBrideName}',
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
///
/// Kept visually IDENTICAL to the approved design (green background,
/// checkmark icon) regardless of what [verdictText] actually says — the
/// integration brief calls for swapping the data source, not redesigning
/// the pill's styling to react to a poor match. See
/// `GunaMilanResult.verdictText`'s doc comment: this is raw, non-localized
/// API text.
class _VerdictPill extends StatelessWidget {
  const _VerdictPill({required this.locale, required this.verdictText});

  final Locale locale;
  final String verdictText;

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
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.check_rounded,
              size: 13,
              color: AppColors.matchSuccessText,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              verdictText,
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
  const _ScoreRing({
    required this.locale,
    required this.l10n,
    required this.result,
  });

  final Locale locale;
  final AppLocalizations l10n;
  final GunaMilanResult result;

  @override
  State<_ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<_ScoreRing> {
  @override
  Widget build(BuildContext context) {
    final target = widget.result.effectivePercent / 100;
    final maxPoints = widget.result.maximumPoints;

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
                _formatNullableScore(widget.result.totalPoints),
                style: AppFonts.heading(
                  widget.locale,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (maxPoints != null)
                Text(
                  widget.l10n.outOfMax(maxPoints),
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

/// Same as [_formatScore] but for a nullable score (the API's `total_points`
/// / per-guna `score` may be absent) — renders an em dash rather than
/// inventing a 0.
String _formatNullableScore(double? value) {
  if (value == null) return '—';
  return _formatScore(value);
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

/// Resolves the l10n label for a [GunaMilanGuna.id]. **Not** the API's own
/// `name` field — see that field's doc comment for why the card keeps this
/// existing short localized label as its title.
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

/// 4×2 guna score grid (Figma node 20:21), driven by [gunas] — the API's
/// `gunaDetails` map, parsed in the approved display order (see
/// `guna_milan_data.dart`'s `_gunaOrder`). Renders whatever came back rather
/// than assuming exactly 8 entries.
class _GunaGrid extends StatelessWidget {
  const _GunaGrid({
    required this.gunas,
    required this.l10n,
    required this.locale,
  });

  final List<GunaMilanGuna> gunas;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (gunas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          l10n.matchNoGunaData,
          textAlign: TextAlign.center,
          style: AppFonts.body(locale, fontSize: 11.5, color: AppColors.muted),
        ),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < gunas.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      final second = i + 1 < gunas.length ? gunas[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _GunaCard(guna: gunas[i], l10n: l10n, locale: locale),
            ),
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
  const _GunaCard({
    required this.guna,
    required this.l10n,
    required this.locale,
  });

  final GunaMilanGuna guna;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final band = guna.band;
    // Neutral fallback when score/maxPoints is missing — see
    // GunaMilanGuna.band's doc comment; never invent a band.
    final badgeBg = band?.background ?? AppColors.surfaceAlt;
    final badgeFg = band?.foreground ?? AppColors.muted;
    final scoreLabel = (guna.score != null && guna.maxPoints != null)
        ? '${_formatScore(guna.score!)}/${guna.maxPoints}'
        : '—';

    // Tap is intentionally a no-op — the footer hint below promises a
    // per-guna explanation sheet, but the explanatory copy for the 8 gunas
    // hasn't been approved by the client yet, so we don't invent it. The
    // API's own per-guna `interpretation`/`significance`/`tips` (see
    // GunaMilanGuna) are exactly what that future sheet would show.
    return Semantics(
      button: true,
      label: _gunaLabel(guna.id, l10n),
      child: PressableScale(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  scoreLabel,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
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

/// Rishi AI summary card (Figma node 51:10) — body copy is now
/// [GunaMilanInterpretation.displayText] (real API text), shown only when
/// non-null; the card is omitted entirely rather than showing empty space.
class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({
    required this.l10n,
    required this.locale,
    required this.summary,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String summary;

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
            summary,
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

/// Suggested-remedies banner (Figma node 20:58's slot — previously a
/// Nadi-specific hardcoded warning, now generic). Rendered only when
/// [remedies] is non-empty; each remedy is already a complete sentence from
/// the API (e.g. "Nadi Dosha: Perform Nadi Dosha Nivarana Puja"), not
/// wrapped in any additional template copy — see `GunaMilanResult.remedies`
/// doc comment.
class _RemediesBanner extends StatelessWidget {
  const _RemediesBanner({required this.locale, required this.remedies});

  final Locale locale;
  final List<String> remedies;

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
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.tileGoldFg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < remedies.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  Text(
                    remedies[i],
                    style: AppFonts.body(
                      locale,
                      fontSize: 11.5,
                      color: AppColors.tileGoldFg,
                    ),
                  ),
                ],
              ],
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
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
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
        Padding(
          padding: const EdgeInsets.only(top: 1),
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
