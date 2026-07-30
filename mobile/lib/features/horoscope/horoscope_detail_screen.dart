import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'horoscope_detail_static_data.dart';
import 'zodiac_sign.dart';

/// Horoscope Detail — per the approved Figma "B4 · Horoscope Detail"
/// (node 16:2) concept.
///
/// Pushed from the Horoscope — All Signs grid (tapping any sign card, see
/// `horoscope_signs_screen.dart`) and from the Home dashboard's "Today's
/// Horoscope" teaser card (which resolves the user's own sign). Like
/// "B3 · Horoscope — All Signs", this screen has NO bottom nav — it's a
/// level deeper in the navigation stack and gets a back button instead.
///
/// Every astrology VALUE shown below (scores, lucky/avoid time, predictions,
/// remedy, mantra) is STATIC PLACEHOLDER DATA from
/// [HoroscopeDetailStaticData]; see that file's doc comment for what
/// eventually replaces it (the Vedika API).
class HoroscopeDetailScreen extends ConsumerStatefulWidget {
  const HoroscopeDetailScreen({super.key, required this.sign});

  final ZodiacSign sign;

  @override
  ConsumerState<HoroscopeDetailScreen> createState() =>
      _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends ConsumerState<HoroscopeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(sign: widget.sign, l10n: l10n, locale: locale),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoresCard(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
                _TimesRow(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
                for (
                  var i = 0;
                  i < HoroscopeDetailStaticData.predictions.length;
                  i++
                ) ...[
                  _PredictionCard(
                    prediction: HoroscopeDetailStaticData.predictions[i],
                    l10n: l10n,
                    locale: locale,
                  ),
                  const SizedBox(height: 12),
                ],
                _RemedyCard(locale: locale),
                const SizedBox(height: 12),
                _MantraCard(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
                _PremiumTeaser(l10n: l10n, locale: locale),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header hero (Figma node 16:3): back + share, sign avatar + names + date,
/// and the 3 lucky-fact chips.
///
/// Deliberately NOT inside a top [SafeArea] — [AppColors.horoscopeHeaderGradient]
/// must run under the status bar, per the design.
class _Header extends StatelessWidget {
  const _Header({required this.sign, required this.l10n, required this.locale});

  final ZodiacSign sign;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 16 > 52 ? statusBarInset + 16 : 52.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 22),
      decoration: const BoxDecoration(
        gradient: AppColors.horoscopeHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
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
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
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
              const Spacer(),
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  // No-op for now: share/deeplink lands with that feature
                  // work, not this screen build.
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.creamText),
                ),
                child: Text(
                  sign.glyph,
                  style: AppFonts.zodiac(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${sign.sanskritName} · ${sign.englishName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        locale,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HoroscopeDetailStaticData.date,
                      style: AppFonts.body(
                        locale,
                        fontSize: 12,
                        color: AppColors.creamText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                // Reuses the existing `luckyColor` key ("Lucky Color") rather
                // than adding a near-duplicate "Lucky Colour" key — the
                // design's spelling difference isn't worth a second string.
                child: _HeaderChip(
                  label: l10n.luckyColor,
                  value: HoroscopeDetailStaticData.luckyColor,
                  locale: locale,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderChip(
                  label: l10n.luckyNumber,
                  value: HoroscopeDetailStaticData.luckyNumber,
                  locale: locale,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderChip(
                  label: l10n.direction,
                  value: HoroscopeDetailStaticData.direction,
                  locale: locale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.value,
    required this.locale,
  });

  final String label;
  final String value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              locale,
              fontSize: 9.5,
              color: AppColors.creamText,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              locale,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves the l10n label + colour for a [HoroscopeScoreId] row.
({String label, Color color}) _scoreMeta(
  HoroscopeScoreId id,
  AppLocalizations l10n,
) {
  switch (id) {
    case HoroscopeScoreId.career:
      return (label: l10n.scoreCareer, color: AppColors.tileBlueFg);
    case HoroscopeScoreId.love:
      return (label: l10n.scoreLove, color: AppColors.tilePinkFg);
    case HoroscopeScoreId.health:
      return (label: l10n.scoreHealth, color: AppColors.tileGreenFg);
    case HoroscopeScoreId.money:
      return (label: l10n.scoreMoney, color: AppColors.tileGoldFg);
    case HoroscopeScoreId.luck:
      return (label: l10n.scoreLuck, color: AppColors.genderSelectedText);
  }
}

/// "Today's scores" card (Figma node 49:2) — 5 animated score bars.
class _ScoresCard extends StatelessWidget {
  const _ScoresCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final scores = HoroscopeDetailStaticData.scores;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todaysScores,
            style: AppFonts.body(
              locale,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < scores.length; i++) ...[
            if (i != 0) const SizedBox(height: 10),
            _ScoreRow(score: scores[i], index: i, l10n: l10n, locale: locale),
          ],
        ],
      ),
    );
  }
}

class _ScoreRow extends StatefulWidget {
  const _ScoreRow({
    required this.score,
    required this.index,
    required this.l10n,
    required this.locale,
  });

  final HoroscopeScore score;
  final int index;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  State<_ScoreRow> createState() => _ScoreRowState();
}

class _ScoreRowState extends State<_ScoreRow> {
  // Starts at 0 and is only bumped to the real target after the per-row
  // stagger delay below — TweenAnimationBuilder animates automatically
  // whenever its `end` changes, so this delayed setState is what makes the
  // bars cascade in one after another instead of growing in lockstep. Same
  // delayed-setState pattern as EntranceFadeSlide.
  double _target = 0;

  @override
  void initState() {
    super.initState();
    final delay = kEntranceStagger * widget.index;
    Future.delayed(delay, () {
      if (mounted) setState(() => _target = widget.score.percent / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = _scoreMeta(widget.score.id, widget.l10n);

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            meta.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              widget.locale,
              fontSize: 11.5,
              color: AppColors.muted,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              color: AppColors.rowDivider,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _target),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    alignment: Alignment.centerLeft,
                    child: Container(color: meta.color),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            '${widget.score.percent}%',
            textAlign: TextAlign.end,
            style: AppFonts.body(
              widget.locale,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: meta.color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Lucky-time / avoid-time pair (Figma node 49:29).
class _TimesRow extends StatelessWidget {
  const _TimesRow({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TimeCard(
            background: AppColors.geoChipBg,
            badgeIcon: Icons.check_rounded,
            badgeLabel: l10n.luckyTime,
            badgeColor: AppColors.tileGreenFg,
            value: HoroscopeDetailStaticData.luckyTime,
            valueColor: AppColors.geoChipText,
            locale: locale,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TimeCard(
            background: AppColors.ashubhBg,
            badgeIcon: Icons.close_rounded,
            badgeLabel: l10n.avoidTime,
            badgeColor: AppColors.ashubhFg,
            value: HoroscopeDetailStaticData.avoidTime,
            valueColor: AppColors.avoidText,
            locale: locale,
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.background,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.badgeColor,
    required this.value,
    required this.valueColor,
    required this.locale,
  });

  final Color background;
  final IconData badgeIcon;
  final String badgeLabel;
  final Color badgeColor;
  final String value;
  final Color valueColor;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badgeIcon, size: 10, color: badgeColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  badgeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves the l10n title / tile background / rating-dot colour / emoji
/// for a [HoroscopeSectionId] prediction card.
({String title, Color tileBg, Color dotColor, String emoji}) _sectionMeta(
  HoroscopeSectionId id,
  AppLocalizations l10n,
) {
  switch (id) {
    case HoroscopeSectionId.career:
      return (
        title: l10n.sectionCareerMoney,
        tileBg: AppColors.tileBlueBg,
        dotColor: AppColors.tileBlueFg,
        emoji: '💼',
      );
    case HoroscopeSectionId.love:
      return (
        title: l10n.sectionLoveRelationships,
        tileBg: AppColors.tilePinkBg,
        dotColor: AppColors.tilePinkFg,
        emoji: '❤️',
      );
    case HoroscopeSectionId.health:
      return (
        title: l10n.sectionHealthEnergy,
        tileBg: AppColors.geoChipBg,
        dotColor: AppColors.tileGreenFg,
        emoji: '🌿',
      );
  }
}

/// One prediction card (Figma nodes 16:27 / 16:40 / 16:53).
class _PredictionCard extends StatelessWidget {
  const _PredictionCard({
    required this.prediction,
    required this.l10n,
    required this.locale,
  });

  final HoroscopePrediction prediction;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final meta = _sectionMeta(prediction.id, l10n);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: meta.tileBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(meta.emoji, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  meta.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Spacer(),
              _RatingDots(rating: prediction.rating, color: meta.dotColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prediction.body,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// 5-dot rating row, drawn instead of using the Figma export's 42×6 image:
/// the dots must be tinted per section AND driven by [rating], and three
/// static PNGs (one per section) couldn't do either — they'd also be raster
/// at a fixed 42×6 rather than crisp at any density.
class _RatingDots extends StatelessWidget {
  const _RatingDots({required this.rating, required this.color});

  final int rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i != 0) const SizedBox(width: 3),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < rating ? color : AppColors.rowDivider,
            ),
          ),
        ],
      ],
    );
  }
}

/// Remedy card (Figma node 16:66).
class _RemedyCard extends StatelessWidget {
  const _RemedyCard({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🪷', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              HoroscopeDetailStaticData.remedy,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                color: AppColors.mantraBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantra card (Figma node 49:36).
class _MantraCard extends StatelessWidget {
  const _MantraCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tileBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📿', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.todaysMantra,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tileBlueFg,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 1),
                // Forced to 'hi' regardless of the app's active locale — the
                // mantra is Devanagari and has no glyph in Poppins/Playfair
                // (see the project's TYPOGRAPHY RULE).
                Text(
                  HoroscopeDetailStaticData.mantra,
                  style: AppFonts.body(
                    const Locale('hi'),
                    fontSize: 12,
                    color: AppColors.navyTop,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium teaser card (Figma node 49:41) with the gold glow pulse (motion
/// spec item 5).
class _PremiumTeaser extends StatelessWidget {
  const _PremiumTeaser({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return GoldGlowPulse(
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        button: true,
        child: PressableScale(
          borderRadius: BorderRadius.circular(16),
          // No-op for now: opens the Subscription Paywall (section C),
          // which isn't built yet.
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.premiumDarkGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Text('👑', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.premiumUnlockPredictions,
                    style: AppFonts.body(
                      locale,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.quoteGold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.premiumCta,
                      style: AppFonts.body(
                        locale,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 11,
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
