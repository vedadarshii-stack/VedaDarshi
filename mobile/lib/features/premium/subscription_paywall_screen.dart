import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_radio_dot.dart';
import '../../l10n/app_localizations.dart';
import '../reports/reports_static_data.dart';
import 'subscription_static_data.dart';

/// Subscription Paywall, per the approved Figma "C5 · Subscription Paywall"
/// (node 23:2) concept.
///
/// A full-screen navy sheet with NO bottom nav — pushed (via
/// [AppMotion.fadeThroughRoute]) from every "upgrade" affordance already
/// built: the Premium Reports "Go Premium" banner + Upgrade pill and its
/// locked report cards, the Horoscope Detail premium teaser, the AI
/// Astrologer "Upgrade for unlimited questions" link, and the Gun Milan
/// Result "Get Detailed Compatibility Report" CTA.
///
/// Plan selection is FUNCTIONAL local state (default: yearly, the
/// recommended plan) — it drives which card is gold-bordered/glowing and
/// which price shows in the CTA label. Every price shown is STATIC
/// PLACEHOLDER DATA from [SubscriptionStaticData]; see that file's doc
/// comment for why prices must come from RevenueCat/Google Play in
/// production, never hardcoded. Both the "Restore purchase" link and the
/// "Start Premium" CTA are deliberate no-ops — see their inline comments —
/// because RevenueCat is not wired up yet and purchases must never be
/// granted client-side.
class SubscriptionPaywallScreen extends ConsumerStatefulWidget {
  const SubscriptionPaywallScreen({super.key});

  @override
  ConsumerState<SubscriptionPaywallScreen> createState() =>
      _SubscriptionPaywallScreenState();
}

class _SubscriptionPaywallScreenState
    extends ConsumerState<SubscriptionPaywallScreen> {
  PlanId _selected = PlanId.yearly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final topSafe = MediaQuery.paddingOf(context).top;
    final topInset = (topSafe + 16) > 52 ? topSafe + 16 : 52.0;
    final selectedPlan = SubscriptionStaticData.plans.firstWhere(
      (plan) => plan.id == _selected,
    );

    return Scaffold(
      // Deliberately NOT wrapped in a top SafeArea — the navy gradient must
      // run under the status bar, matching the design's full-bleed sheet.
      // Only the content padding respects the safe area (topInset below).
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.paywallGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, topInset, 22, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _Hero(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _BenefitList(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _PlanList(
                selected: _selected,
                onSelect: (id) => setState(() => _selected = id),
                l10n: l10n,
                locale: locale,
              ),
              const SizedBox(height: 16),
              _Cta(plan: selectedPlan, l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _FinePrint(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ),
    );
  }
}

/// Close button + "Restore purchase" link (Figma node 23:3).
class _TopBar extends StatelessWidget {
  const _TopBar({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
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
            // No-op for now: calls Purchases.restorePurchases() once
            // RevenueCat is wired up.
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: Text(
                l10n.restorePurchase,
                style: AppFonts.body(
                  locale,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedOnNavy,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Crown + title + tagline hero (Figma node 23:8), with a static soft gold
/// glow behind the crown (not [GoldGlowPulse] — that's reserved for CTAs).
class _Hero extends StatelessWidget {
  const _Hero({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.35),
                blurRadius: 15,
              ),
            ],
          ),
          child: Text('👑', style: AppFonts.body(locale, fontSize: 34)),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.vedadarshiPremium,
          textAlign: TextAlign.center,
          style: AppFonts.heading(
            locale,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.premiumTagline,
          textAlign: TextAlign.center,
          style: AppFonts.body(locale, fontSize: 13, color: AppColors.mutedOnNavy),
        ),
      ],
    );
  }
}

/// 4-row benefit list (Figma node 23:12).
class _BenefitList extends StatelessWidget {
  const _BenefitList({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final benefits = [
      l10n.benefitReports(ReportsStaticData.totalReports.toString()),
      l10n.benefitUnlimitedAi,
      l10n.benefitAdvancedKundli,
      l10n.benefitAdFree,
    ];

    return Column(
      children: [
        for (var i = 0; i < benefits.length; i++) ...[
          if (i != 0) const SizedBox(height: 8),
          _BenefitRow(text: benefits[i], locale: locale),
        ],
      ],
    );
  }
}

/// One benefit row: a small gold check circle + wrapping text.
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 11, color: AppColors.gold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppFonts.body(locale, fontSize: 12.5, color: AppColors.headerSubtle),
          ),
        ),
      ],
    );
  }
}

/// The 3 plan cards, generated from [SubscriptionStaticData.plans] (Figma
/// node 23:29).
class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.selected,
    required this.onSelect,
    required this.l10n,
    required this.locale,
  });

  final PlanId selected;
  final ValueChanged<PlanId> onSelect;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final plans = SubscriptionStaticData.plans;

    return Column(
      children: [
        for (var i = 0; i < plans.length; i++) ...[
          if (i != 0) const SizedBox(height: 10),
          _PlanCard(
            plan: plans[i],
            isSelected: plans[i].id == selected,
            onTap: () => onSelect(plans[i].id),
            l10n: l10n,
            locale: locale,
          ),
        ],
      ],
    );
  }
}

/// One selectable plan card. The currently-selected card (default: yearly,
/// the recommended plan) gets the gold border/glow treatment and is the
/// only one wrapped in [GoldGlowPulse] — the approved motion spec (node
/// 80:2 item 5) calls for the pulse to follow the selection, not stay
/// hardcoded to Yearly.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
    required this.locale,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final Locale locale;

  String get _planName {
    switch (plan.id) {
      case PlanId.monthly:
        return l10n.planMonthly;
      case PlanId.yearly:
        return l10n.planYearly;
      case PlanId.lifetime:
        return l10n.planLifetime;
    }
  }

  /// Monthly/lifetime subtitles are plain UI chrome resolved from l10n here;
  /// the yearly plan's subtitle is data (contains a price) and comes
  /// straight from [SubscriptionStaticData].
  String? get _subtitle {
    switch (plan.id) {
      case PlanId.monthly:
        return l10n.perMonth;
      case PlanId.yearly:
        return plan.subtitle;
      case PlanId.lifetime:
        return l10n.oneTimePayment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle;

    final card = Semantics(
      button: true,
      selected: isSelected,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldBright
                  : Colors.white.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AppRadioDot(isSelected: isSelected, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (plan.badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          plan.badge!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onGold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      _planName,
                      style: AppFonts.body(
                        locale,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 10.5,
                          color: AppColors.mutedOnNavy,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                plan.price,
                style: AppFonts.heading(
                  locale,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.quoteGold : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isSelected) return card;
    return GoldGlowPulse(borderRadius: BorderRadius.circular(16), child: card);
  }
}

/// Full-width gold gradient "Start Premium" CTA (Figma node 23:50), whose
/// price updates with the selected plan.
class _Cta extends StatelessWidget {
  const _Cta({required this.plan, required this.l10n, required this.locale});

  final SubscriptionPlan plan;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        // No-op for now: calls Purchases.purchasePackage() via RevenueCat.
        // The SDK, the Play Console products and the server-side entitlement
        // check are all still to be set up — purchases must NEVER be
        // granted client-side.
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: AppColors.goldCtaGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            l10n.startPremium(plan.ctaPrice),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppFonts.body(
              locale,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: AppColors.onGold,
            ),
          ),
        ),
      ),
    );

    // Motion spec item 5 explicitly calls for the gold glow pulse on the
    // Upgrade CTA, in addition to its own static drop shadow above.
    return GoldGlowPulse(borderRadius: BorderRadius.circular(999), child: button);
  }
}

/// Centred billing fine print (Figma node 23:52).
class _FinePrint extends StatelessWidget {
  const _FinePrint({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.billingFinePrint,
      textAlign: TextAlign.center,
      style: AppFonts.body(locale, fontSize: 10.5, color: AppColors.paywallFinePrint),
    );
  }
}
