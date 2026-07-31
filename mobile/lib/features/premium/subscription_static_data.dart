/// Static placeholder data for the Subscription Paywall screen, per the
/// approved Figma "C5 · Subscription Paywall" (node 23:2) concept.
///
/// Every price, currency symbol and billing period below is a HARDCODED
/// PLACEHOLDER. In production these MUST come from RevenueCat's `Offerings`
/// API (which in turn reads them from the Google Play Console), never
/// hardcoded here — Google Play localises prices per country/region, and
/// Play Console pricing can change without an app update, so a hardcoded
/// price would silently go stale or show the wrong currency to users
/// outside India. Purchases themselves go through RevenueCat +
/// Google Play Billing; Razorpay is out of V1 scope per `projects/CLAUDE.md`'s
/// "Confirmed stack decisions". This file exists purely to drive the static
/// UI pass; wiring RevenueCat later should only touch this file, not the
/// widget tree.
library;

/// Which subscription plan a card represents.
enum PlanId { monthly, yearly, lifetime }

/// One plan card's presentation + pricing data.
///
/// `subtitle` and `ctaPrice` contain PRICES/DATA (not UI chrome), so they
/// live here rather than in l10n ARB files, matching the split used by
/// `ReportsStaticData`. `subtitle` is nullable because the recommended
/// (yearly) plan's subtitle is itself a derived value (see the class-level
/// note below), while monthly/lifetime resolve theirs from plain l10n
/// strings in the screen.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.price,
    required this.ctaPrice,
    this.subtitle,
    this.badge,
    this.isRecommended = false,
  });

  final PlanId id;

  /// Price shown on the plan card itself, e.g. "₹299".
  final String price;

  /// Price shown in the CTA label when this plan is selected, e.g.
  /// "₹299/month" — kept separate from [price] because the CTA needs the
  /// billing period appended while the card just shows the number.
  final String ctaPrice;

  /// Data-driven subtitle line (e.g. "₹167/month · billed yearly"). Null for
  /// plans whose subtitle is plain UI chrome resolved from l10n in the
  /// screen instead (monthly/lifetime).
  final String? subtitle;

  /// Badge pill text (e.g. "MOST POPULAR · SAVE 44%"). Null when no badge.
  final String? badge;

  /// Whether this plan is pre-selected and visually emphasized by default.
  final bool isRecommended;
}

abstract final class SubscriptionStaticData {
  /// The 3 plans shown in the design, in the exact order approved in Figma
  /// node 23:29.
  ///
  /// NOTE: the yearly plan's `subtitle` ("₹167/month · billed yearly") and
  /// its `badge`'s "SAVE 44%" are DERIVED values in production — computed
  /// from the real per-month-equivalent and the real discount versus the
  /// monthly plan, both sourced from RevenueCat/Play Console — not fixed
  /// strings. They are hardcoded here only because there is no live pricing
  /// source yet.
  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(id: PlanId.monthly, price: '₹299', ctaPrice: '₹299/month'),
    SubscriptionPlan(
      id: PlanId.yearly,
      price: '₹1,999',
      ctaPrice: '₹1,999/year',
      subtitle: '₹167/month · billed yearly',
      badge: 'MOST POPULAR · SAVE 44%',
      isRecommended: true,
    ),
    SubscriptionPlan(id: PlanId.lifetime, price: '₹4,999', ctaPrice: '₹4,999'),
  ];
}
