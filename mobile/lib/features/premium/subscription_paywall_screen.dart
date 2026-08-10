import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/purchases/purchases_providers.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/purchases/subscription_catalogue.dart';
import '../../core/purchases/subscription_tier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_radio_dot.dart';
import '../../l10n/app_localizations.dart';
import '../reports/reports_static_data.dart';

/// Subscription Paywall, per the approved Figma "C5 · Subscription Paywall"
/// (node 23:2) concept, now driven by the LIVE RevenueCat offering.
///
/// A full-screen navy sheet with NO bottom nav — pushed (via
/// [AppMotion.fadeThroughRoute]) from every "upgrade" affordance already
/// built: the Premium Reports "Go Premium" banner + Upgrade pill and its
/// locked report cards, the Horoscope Detail premium teaser, the AI
/// Astrologer "Upgrade for unlimited questions" link, and the Gun Milan
/// Result "Get Detailed Compatibility Report" CTA.
///
/// **Every price on this screen comes from `StoreProduct.priceString`**, i.e.
/// from Google Play via RevenueCat. Nothing here is hardcoded, and the two
/// derived figures — the annual plan's per-month equivalent and its "SAVE
/// n%" badge — are computed from those live prices (see
/// [SubscriptionCatalogue]). This replaced a static placeholder table whose
/// "₹1,999 · SAVE 44%" would have become a false claim the first time Play
/// pricing changed.
///
/// The shape changed with the catalogue: the design's 3 cards
/// (monthly/yearly/lifetime) do not match what is actually sold, which is 4
/// tiers × 2 billing periods and no lifetime plan at all. So the periods
/// became a toggle and the tiers became the cards — the card visuals, gold
/// selection treatment and CTA are unchanged.
///
/// An EMPTY offering is an expected state, not a bug: until the AAB is on a
/// Play track with the products Active, `getOfferings()` legitimately returns
/// nothing. That renders as [_PlansUnavailable] with a retry, never as a
/// crash or a screen of blanks.
class SubscriptionPaywallScreen extends ConsumerStatefulWidget {
  const SubscriptionPaywallScreen({super.key});

  @override
  ConsumerState<SubscriptionPaywallScreen> createState() =>
      _SubscriptionPaywallScreenState();
}

class _SubscriptionPaywallScreenState
    extends ConsumerState<SubscriptionPaywallScreen> {
  /// Annual is pre-selected because it is the better value per month, and
  /// the saving is shown rather than asserted.
  BillingPeriod _period = BillingPeriod.annual;

  /// Null until the catalogue loads, then defaulted by [_defaultTier].
  SubscriptionTier? _selectedTier;

  /// Guards the CTA and the restore link against a second tap while a
  /// billing call is in flight. Play's own sheet is modal, but the gap
  /// between our tap handler and that sheet appearing is not — and a double
  /// tap there means two purchase flows racing.
  bool _isBusy = false;

  /// Pre-selects the second-cheapest available tier.
  ///
  /// A deliberate product choice, not a technical one: the design
  /// pre-selected the middle of its three options, and the middle-low tier
  /// is the honest equivalent here. Pre-selecting the most expensive tier
  /// would be a dark pattern; pre-selecting the cheapest buries the range.
  /// Change this one line if the client wants a different anchor.
  SubscriptionTier _defaultTier(List<SubscriptionPlan> options) {
    if (options.isEmpty) return SubscriptionTier.bronze;
    return options[options.length > 1 ? 1 : 0].tier;
  }

  Future<void> _handlePurchase(SubscriptionPlan option) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final l10n = AppLocalizations.of(context)!;
    final status = ref.read(subscriptionStatusValueProvider);

    // If they already hold a different subscription, this is an upgrade or
    // downgrade — Play needs to be told which purchase it replaces.
    final currentProductId = status.activeProductIds
        .where((id) => id != option.package.storeProduct.identifier)
        .firstOrNull;

    try {
      await ref
          .read(purchasesServiceProvider)
          .purchase(option, replacingProductId: currentProductId);
      if (!mounted) return;
      _showMessage(l10n.purchaseSuccess);
      Navigator.of(context).pop();
    } on PurchaseException catch (e) {
      if (!mounted) return;
      // A cancelled purchase is the user changing their mind, not a failure
      // to report back at them.
      if (e.reason == PurchaseFailure.cancelled) return;
      _showMessage(_failureMessage(l10n, e.reason));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleRestore() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final status = await ref.read(purchasesServiceProvider).restore();
      if (!mounted) return;
      if (status.hasPaidAccess) {
        _showMessage(l10n.purchasesRestored);
        Navigator.of(context).pop();
      } else {
        _showMessage(l10n.purchasesNothingToRestore);
      }
    } on PurchaseException catch (e) {
      if (!mounted) return;
      if (e.reason == PurchaseFailure.cancelled) return;
      _showMessage(_failureMessage(l10n, e.reason));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _failureMessage(AppLocalizations l10n, PurchaseFailure reason) {
    return switch (reason) {
      PurchaseFailure.notAllowed => l10n.purchaseErrorNotAllowed,
      PurchaseFailure.network => l10n.purchaseErrorNetwork,
      PurchaseFailure.alreadyOwned => l10n.purchaseErrorAlreadyOwned,
      PurchaseFailure.productUnavailable => l10n.purchaseErrorUnavailable,
      PurchaseFailure.cancelled || PurchaseFailure.unknown =>
        l10n.purchaseErrorGeneric,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final topSafe = MediaQuery.paddingOf(context).top;
    final topInset = (topSafe + 16) > 52 ? topSafe + 16 : 52.0;
    final catalogueAsync = ref.watch(subscriptionCatalogueProvider);
    final status = ref.watch(subscriptionStatusValueProvider);

    return Scaffold(
      // Deliberately NOT wrapped in a top SafeArea — the navy gradient must
      // run under the status bar, matching the design's full-bleed sheet.
      // Only the content padding respects the safe area (topInset below).
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.paywallGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, topInset, 22, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                l10n: l10n,
                locale: locale,
                onRestore: _isBusy ? null : _handleRestore,
              ),
              const SizedBox(height: 16),
              _Hero(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _BenefitList(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              catalogueAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                // fetchCatalogue() never throws — it returns an empty
                // catalogue instead — so this branch only fires if the
                // provider itself breaks. Same treatment either way.
                error: (_, _) => _PlansUnavailable(
                  l10n: l10n,
                  locale: locale,
                  onRetry: () => ref.invalidate(subscriptionCatalogueProvider),
                ),
                data: (catalogue) => _Plans(
                  catalogue: catalogue,
                  status: status,
                  period: _period,
                  selectedTier: _selectedTier,
                  isBusy: _isBusy,
                  onPeriodChanged: (period) => setState(() => _period = period),
                  onTierSelected: (tier) =>
                      setState(() => _selectedTier = tier),
                  onPurchase: _handlePurchase,
                  onRetry: () => ref.invalidate(subscriptionCatalogueProvider),
                  defaultTier: _defaultTier,
                  l10n: l10n,
                  locale: locale,
                ),
              ),
              const SizedBox(height: 16),
              _FinePrint(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ),
    );
  }
}

/// Period toggle + tier cards + CTA, or the unavailable state.
///
/// Split out of the screen so the "which tier is selected" fallback logic
/// lives next to the data it depends on: [_SubscriptionPaywallScreenState]
/// cannot pick a default before the catalogue arrives, and the selection it
/// picked for one period may not exist in the other (a tier could be sold
/// monthly but not annually), so the effective selection is resolved here on
/// every build rather than being stored.
class _Plans extends StatelessWidget {
  const _Plans({
    required this.catalogue,
    required this.status,
    required this.period,
    required this.selectedTier,
    required this.isBusy,
    required this.onPeriodChanged,
    required this.onTierSelected,
    required this.onPurchase,
    required this.onRetry,
    required this.defaultTier,
    required this.l10n,
    required this.locale,
  });

  final SubscriptionCatalogue catalogue;
  final SubscriptionStatus status;
  final BillingPeriod period;
  final SubscriptionTier? selectedTier;
  final bool isBusy;
  final ValueChanged<BillingPeriod> onPeriodChanged;
  final ValueChanged<SubscriptionTier> onTierSelected;
  final ValueChanged<SubscriptionPlan> onPurchase;
  final VoidCallback onRetry;
  final SubscriptionTier Function(List<SubscriptionPlan>) defaultTier;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (catalogue.isEmpty) {
      return _PlansUnavailable(l10n: l10n, locale: locale, onRetry: onRetry);
    }

    final options = catalogue.optionsForPeriod(period);
    if (options.isEmpty) {
      return _PlansUnavailable(l10n: l10n, locale: locale, onRetry: onRetry);
    }

    // Fall back when nothing is selected yet, or when the tier the user
    // picked isn't sold on the period they just switched to.
    final effectiveTier =
        options.any((option) => option.tier == selectedTier) && selectedTier != null
        ? selectedTier!
        : defaultTier(options);
    final selectedOption = options.firstWhere(
      (option) => option.tier == effectiveTier,
    );
    final periods = catalogue.availablePeriods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Only worth showing when there is an actual choice to make.
        if (periods.length > 1) ...[
          _PeriodToggle(
            periods: periods,
            selected: period,
            onChanged: onPeriodChanged,
            l10n: l10n,
            locale: locale,
          ),
          const SizedBox(height: 14),
        ],
        for (var i = 0; i < options.length; i++) ...[
          if (i != 0) const SizedBox(height: 10),
          _PlanCard(
            option: options[i],
            catalogue: catalogue,
            isSelected: options[i].tier == effectiveTier,
            isCurrent: status.isKnown && status.tier == options[i].tier,
            onTap: () => onTierSelected(options[i].tier),
            l10n: l10n,
            locale: locale,
          ),
        ],
        const SizedBox(height: 16),
        _Cta(
          option: selectedOption,
          isBusy: isBusy,
          onTap: () => onPurchase(selectedOption),
          l10n: l10n,
          locale: locale,
        ),
      ],
    );
  }
}

/// Monthly / Annual segmented toggle.
class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.periods,
    required this.selected,
    required this.onChanged,
    required this.l10n,
    required this.locale,
  });

  final List<BillingPeriod> periods;
  final BillingPeriod selected;
  final ValueChanged<BillingPeriod> onChanged;
  final AppLocalizations l10n;
  final Locale locale;

  String _label(BillingPeriod period) => switch (period) {
    BillingPeriod.monthly => l10n.planMonthly,
    BillingPeriod.annual => l10n.planYearly,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final period in periods)
            Expanded(
              child: Semantics(
                button: true,
                selected: period == selected,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: period == selected
                          ? AppColors.gold
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _label(period),
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: period == selected
                            ? AppColors.onGold
                            : AppColors.mutedOnNavy,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Close button + "Restore purchase" link (Figma node 23:3).
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.l10n,
    required this.locale,
    required this.onRestore,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// Null while a billing call is in flight, which also greys the label.
  final VoidCallback? onRestore;

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
          enabled: onRestore != null,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            onTap: onRestore ?? () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                l10n.restorePurchase,
                style: AppFonts.body(
                  locale,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: onRestore == null
                      ? AppColors.paywallFinePrint
                      : AppColors.mutedOnNavy,
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
          style: AppFonts.body(
            locale,
            fontSize: 13,
            color: AppColors.mutedOnNavy,
          ),
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
          child: Icon(Icons.check_rounded, size: 11, color: AppColors.gold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              color: AppColors.headerSubtle,
            ),
          ),
        ),
      ],
    );
  }
}

/// One selectable tier card. The selected card gets the gold border/glow
/// treatment and is the only one wrapped in [GoldGlowPulse] — the approved
/// motion spec (node 80:2 item 5) calls for the pulse to follow the
/// selection.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.option,
    required this.catalogue,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
    required this.l10n,
    required this.locale,
  });

  final SubscriptionPlan option;
  final SubscriptionCatalogue catalogue;
  final bool isSelected;

  /// Whether this is the tier the user is already subscribed to.
  final bool isCurrent;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final Locale locale;

  String get _tierName => switch (option.tier) {
    SubscriptionTier.bronze => l10n.tierBronze,
    SubscriptionTier.silver => l10n.tierSilver,
    SubscriptionTier.gold => l10n.tierGold,
    SubscriptionTier.platinum => l10n.tierPlatinum,
    // Unreachable: a card is only ever built from a SubscriptionPlan, and
    // those are only resolved for SubscriptionTier.paid. Present because the
    // switch must be exhaustive; blank rather than a wrong tier name, so a
    // future regression shows up as a missing label instead of quietly
    // mislabelling one plan as another.
    SubscriptionTier.free => '',
  };

  @override
  Widget build(BuildContext context) {
    // Both derived from live store prices — see SubscriptionCatalogue.
    final perMonth = catalogue.monthlyEquivalent(option, locale.toString());
    final savings = option.period == BillingPeriod.annual
        ? catalogue.annualSavingsPercent(option.tier)
        : null;
    final subtitle = perMonth == null
        ? (option.period == BillingPeriod.monthly ? l10n.perMonth : null)
        : l10n.perMonthBilledYearly(perMonth);

    final badge = isCurrent
        ? l10n.currentPlanLabel
        : (savings == null ? null : l10n.savePercent(savings.toString()));

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
                    if (badge != null) ...[
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
                          badge,
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
                      _tierName,
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
                option.priceString,
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
  const _Cta({
    required this.option,
    required this.isBusy,
    required this.onTap,
    required this.l10n,
    required this.locale,
  });

  final SubscriptionPlan option;
  final bool isBusy;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      enabled: !isBusy,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        // Purchases go through RevenueCat + Google Play Billing and are only
        // ever granted by the entitlement that comes back — never
        // client-side, and never on the strength of this tap.
        onTap: isBusy ? () {} : onTap,
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
          child: isBusy
              ? SizedBox(
                  height: 19,
                  width: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onGold,
                  ),
                )
              : Text(
                  l10n.startPremium(option.priceString),
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
    return GoldGlowPulse(
      borderRadius: BorderRadius.circular(999),
      child: button,
    );
  }
}

/// Shown when the live offering is empty or could not be fetched.
///
/// This is the state the app is in RIGHT NOW and will stay in until the
/// signed AAB is on a Play track with the 8 subscription products Active —
/// `getOfferings()` returning nothing is Play working as documented, not a
/// failure, so this reads as "not available yet" rather than as an error.
class _PlansUnavailable extends StatelessWidget {
  const _PlansUnavailable({
    required this.l10n,
    required this.locale,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 30,
            color: AppColors.mutedOnNavy,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.plansUnavailableTitle,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              locale,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.plansUnavailableMessage,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              locale,
              fontSize: 12,
              color: AppColors.mutedOnNavy,
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            button: true,
            child: PressableScale(
              borderRadius: BorderRadius.circular(999),
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  l10n.retry,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
      style: AppFonts.body(
        locale,
        fontSize: 10.5,
        color: AppColors.paywallFinePrint,
      ),
    );
  }
}
