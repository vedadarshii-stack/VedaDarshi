import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/premium_glimpse.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import 'kundli_predictions_data.dart';
import 'kundli_shimmer_block.dart';

/// Kundli **Predictions** tab — the natal reading, shown as a premium
/// glimpse.
///
/// BUILT 2 Sep 2026, replacing a pill that was not a tab at all: it opened
/// the paywall on tap and rendered nothing, ever. That asked the user to buy
/// a reading they had not seen a word of.
///
/// The reading is REAL — `POST /v2/reports/birth-chart-report`, computed
/// from this chart's own birth details, showing each house's interpretation
/// and the yogas actually present. [PremiumGlimpse] cuts it off partway
/// through, so the paywall lands after the user has read something specific
/// to themselves rather than before.
///
/// Order is deliberate: **yogas first, houses second.** A yoga is the
/// headline finding of a chart — a named combination with a meaning — and
/// there are only a handful, so it is what makes the first few visible lines
/// worth reading. Twelve house paragraphs in the glimpse would show one and
/// a half houses and read like a truncated list.
class KundliPredictionsTab extends ConsumerWidget {
  const KundliPredictionsTab({
    super.key,
    required this.l10n,
    required this.locale,
    required this.predictionsAsync,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// Null when no birth request could be built — same convention as the
  /// sibling tabs.
  final AsyncValue<KundliPredictions>? predictionsAsync;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = predictionsAsync;
    if (async == null) return const SizedBox.shrink();

    return async.when(
      // Same shimmer the sibling tabs use, sized to the glimpse so the
      // layout does not jump when the reading lands.
      loading: () => KundliShimmerBlock(height: 240, borderRadius: BorderRadius.circular(16)),
      error: (error, stackTrace) => _ErrorState(
        l10n: l10n,
        locale: locale,
        onRetry: onRetry,
      ),
      data: (predictions) {
        // Nothing real to show → show nothing. Never fall through to a
        // teaser over empty content: fading out an empty box would sell a
        // reading that does not exist, which is the exact failure this tab
        // was built to fix.
        if (predictions.isEmpty) {
          return _ErrorState(l10n: l10n, locale: locale, onRetry: onRetry);
        }
        return PremiumGlimpse(
          locale: locale,
          previewHeight: 240,
          ctaLabel: l10n.kundliPredictionsCta,
          subtitle: l10n.kundliPredictionsSubtitle,
          onUpgrade: () => Navigator.of(
            context,
          ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (predictions.yogas.isNotEmpty) ...[
                _SectionTitle(l10n.kundliYogasTitle, locale: locale),
                const SizedBox(height: 8),
                for (final yoga in predictions.yogas)
                  _YogaRow(yoga: yoga, locale: locale),
                const SizedBox(height: 14),
              ],
              if (predictions.houses.isNotEmpty) ...[
                _SectionTitle(l10n.kundliHousesTitle, locale: locale),
                const SizedBox(height: 8),
                for (final house in predictions.houses)
                  _HouseRow(house: house, locale: locale, l10n: l10n),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppFonts.heading(
      locale,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
}

class _YogaRow extends StatelessWidget {
  const _YogaRow({required this.yoga, required this.locale});

  final KundliYoga yoga;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final name = yoga.name;
    if (name == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppFonts.body(
              locale,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.saffron,
            ),
          ),
          if (yoga.meaning case final meaning?)
            Text(
              meaning,
              style: AppFonts.body(
                locale,
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _HouseRow extends StatelessWidget {
  const _HouseRow({
    required this.house,
    required this.locale,
    required this.l10n,
  });

  final KundliHouseReading house;
  final Locale locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final interpretation = house.interpretation;
    if (interpretation == null) return const SizedBox.shrink();
    final number = house.house;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (number != null)
            Text(
              // Localized 2 Sep 2026 — this read a hardcoded English
              // "House 1" in every locale, part of what the client reported
              // as things staying in English. The NUMBER stays in Latin
              // digits, which is chart notation, the same as the chart
              // painters use.
              l10n.lblHouseN(number),
              style: AppFonts.body(
                locale,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          Text(
            interpretation,
            style: AppFonts.body(locale, fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.l10n,
    required this.locale,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            l10n.kundliLoadErrorMessage,
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
          ),
          if (onRetry case final retry?) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: retry, child: Text(l10n.retry)),
          ],
        ],
      ),
    );
  }
}
