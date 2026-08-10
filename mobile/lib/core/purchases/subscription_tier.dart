import 'package:purchases_flutter/purchases_flutter.dart';

/// The four paid subscription tiers, plus [free] for everyone else.
///
/// **Entitlements are CUMULATIVE, and that is not a detail you can ignore.**
/// A Platinum subscriber holds all four RevenueCat entitlements at once
/// (`vedadarshi_bronze`, `_silver`, `_gold`, `_platinum`), a Gold subscriber
/// holds three, and so on down. That is deliberate: it lets a feature gate
/// name the LOWEST tier that unlocks it and stop caring about the tiers above
/// (see [hasAtLeast]).
///
/// Two consequences worth spelling out, because both have bitten this project:
///
/// 1. **Never gate a paid feature on `vedadarshi_silver` meaning "is this user
///    paying".** Before Bronze was added on 1 Aug 2026, Silver *was* the
///    lowest tier and that check was correct. It is now wrong, and wrong
///    silently — a paying Bronze subscriber would be locked out of everything
///    they bought. The "is this user paying at all" check is
///    [SubscriptionStatus.hasPaidAccess], i.e. the Bronze entitlement.
/// 2. **Never resolve the tier by looking at the purchased product id.**
///    Resolve it from the active entitlements, taking the highest — which is
///    exactly what [SubscriptionTier.fromEntitlements] does.
///
/// The entitlement identifiers below must match the `lookup_key`s in the
/// RevenueCat dashboard character-for-character; they are listed in
/// `projects/claudedocs/play-console-iap-setup.md`.
enum SubscriptionTier {
  free(entitlementId: null, rank: 0),
  bronze(entitlementId: 'vedadarshi_bronze', rank: 1),
  silver(entitlementId: 'vedadarshi_silver', rank: 2),
  gold(entitlementId: 'vedadarshi_gold', rank: 3),
  platinum(entitlementId: 'vedadarshi_platinum', rank: 4);

  const SubscriptionTier({required this.entitlementId, required this.rank});

  /// RevenueCat entitlement `lookup_key`, or `null` for [free] (which is the
  /// absence of every entitlement, not an entitlement of its own).
  final String? entitlementId;

  /// Ordering position. Higher unlocks everything a lower one unlocks.
  final int rank;

  /// The paid tiers, cheapest first — the order the paywall renders them in.
  static const List<SubscriptionTier> paid = [bronze, silver, gold, platinum];

  /// Whether this tier unlocks a feature gated at [required].
  bool hasAtLeast(SubscriptionTier required) => rank >= required.rank;

  /// Resolves the tier from RevenueCat's set of ACTIVE entitlement ids.
  ///
  /// Takes the highest matching tier, which is what makes the cumulative
  /// model work: a Platinum subscriber's active set contains all four ids and
  /// must resolve to [platinum], not to whichever happens to be iterated
  /// first.
  static SubscriptionTier fromEntitlements(Set<String> activeEntitlementIds) {
    var resolved = SubscriptionTier.free;
    for (final tier in paid) {
      if (activeEntitlementIds.contains(tier.entitlementId) &&
          tier.rank > resolved.rank) {
        resolved = tier;
      }
    }
    return resolved;
  }
}

/// How the app's subscription state is exposed to the UI.
///
/// [isKnown] exists to keep "we have not heard back from RevenueCat yet"
/// distinct from "this user is definitely on the free tier". Conflating the
/// two would flash a paywall at a paying subscriber for the first frames
/// after launch, so gates should treat an unknown status as "don't decide
/// yet" rather than "deny".
class SubscriptionStatus {
  const SubscriptionStatus({
    required this.tier,
    required this.isKnown,
    this.activeProductIds = const {},
  });

  /// Startup value: nothing fetched yet.
  const SubscriptionStatus.unknown()
    : tier = SubscriptionTier.free,
      isKnown = false,
      activeProductIds = const {};

  /// The SDK answered and the user holds no paid entitlement.
  const SubscriptionStatus.free()
    : tier = SubscriptionTier.free,
      isKnown = true,
      activeProductIds = const {};

  factory SubscriptionStatus.fromCustomerInfo(CustomerInfo info) {
    return SubscriptionStatus(
      tier: SubscriptionTier.fromEntitlements(info.entitlements.active.keys.toSet()),
      isKnown: true,
      activeProductIds: info.activeSubscriptions.toSet(),
    );
  }

  final SubscriptionTier tier;

  /// `false` until RevenueCat has actually answered once.
  final bool isKnown;

  /// Store identifiers of the subscriptions currently active for this user.
  ///
  /// Needed to switch tiers: Google Play treats an upgrade/downgrade inside a
  /// subscription group as a REPLACEMENT of the existing purchase, so the
  /// old product id has to be handed to the billing flow. Buying a second
  /// subscription without naming the one it replaces is what produces
  /// "you already own this item" on an upgrade attempt.
  final Set<String> activeProductIds;

  /// The "is this user paying at all" check. Correct because Bronze is the
  /// lowest paid tier and every higher tier also holds its entitlement.
  bool get hasPaidAccess => tier != SubscriptionTier.free;

  /// Whether a feature gated at [required] should be unlocked.
  ///
  /// Returns `false` while [isKnown] is `false` — callers that would rather
  /// wait than deny should check [isKnown] first.
  bool unlocks(SubscriptionTier required) => isKnown && tier.hasAtLeast(required);
}
