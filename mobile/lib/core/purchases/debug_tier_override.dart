import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'purchases_providers.dart';
import 'subscription_tier.dart';

/// Pretends the signed-in user holds a paid tier, **in debug builds only**,
/// so entitlement gating can be exercised without a real Play purchase — and
/// switched live, without a restart.
///
/// BUILT 9 Sep 2026. Testing a gate otherwise means a full Play round trip: a
/// locally-signed release APK cannot do billing at all, because Play re-signs
/// distributed builds with the **app signing key** (`2d5bf952…`) while a
/// local build carries the **upload key** (`8a82bad1…`) — and the app signing
/// private key is held by Google and cannot be downloaded. There is no way to
/// make a local build purchase anything, but no need to for most of the work.
///
/// ## What this proves, and what it does not
///
/// Most outstanding premium work is entitlement *consumption*: does the
/// banner hide, does the report expand, is the weekly horoscope unlocked.
/// That needs a tier, not a purchase.
///
/// ⚠️ **CLIENT-SIDE gates only.** The AI daily quota and the AI pack ledger
/// are enforced server-side against the real `/entitlements/{uid}` document
/// and are completely unaffected by this switch. That is not a limitation to
/// work around — it is precisely why those gates are the trustworthy ones.
/// To exercise them, write a tier into that document with the Admin SDK.
///
/// ⚠️ It also cannot test purchase, restore or tier-switch, which talk to
/// Play. Use **Internal app sharing** for those — it needs no `versionCode`
/// bump, so it is nearly as fast as a local install.
///
/// ## Why it cannot ship
///
/// Two independent guards, because a single edit away from "every user is
/// silently Platinum" is not a safe place to be:
///
///  1. Every entry point is behind [kDebugMode], so a release build
///     tree-shakes the whole thing away. Verified by grepping a built
///     release APK: zero occurrences of this class or its env key.
///  2. [initialTier] reads `DEBUG_FORCE_TIER` from `.env`, which is
///     gitignored and has the line commented out by default.
///
/// ## Two ways to use it
///
/// Set a starting tier in `mobile/.env`:
///
/// ```
/// DEBUG_FORCE_TIER=gold      # free | bronze | silver | gold | platinum
/// ```
///
/// …or leave it unset and flip tiers at runtime from **Profile → Debug:
/// subscription tier**, which is the faster loop: the change propagates
/// through Riverpod immediately, so gates re-render without a restart.
class DebugTierOverride {
  const DebugTierOverride._();

  static const String envKeyName = 'DEBUG_FORCE_TIER';

  /// Whether the debug switcher is available at all. Every call site checks
  /// this, so release builds contain no path to it.
  static bool get isAvailable => kDebugMode;

  /// Starting tier from `.env`, or `null` to use the REAL entitlement.
  static SubscriptionTier? get initialTier {
    if (!kDebugMode) return null;
    String raw;
    try {
      raw = dotenv.env[envKeyName]?.trim().toLowerCase() ?? '';
    } catch (_) {
      return null; // dotenv.load() never ran — treat as unset.
    }
    if (raw.isEmpty) return null;
    for (final tier in SubscriptionTier.values) {
      if (tier.name == raw) return tier;
    }
    debugPrint(
      'DebugTierOverride: "$raw" is not a tier — ignoring. Expected one of '
      '${SubscriptionTier.values.map((t) => t.name).join(', ')}',
    );
    return null;
  }
}

/// The tier the debug switcher is currently forcing, or `null` for "use the
/// real entitlement".
///
/// A [Notifier] rather than a constant so the tier can be changed from the
/// UI and every gate re-renders immediately — editing `.env` and restarting
/// for each of five tiers is exactly the slow loop this exists to remove.
class DebugTierController extends Notifier<SubscriptionTier?> {
  @override
  SubscriptionTier? build() =>
      DebugTierOverride.isAvailable ? DebugTierOverride.initialTier : null;

  /// `null` restores the real RevenueCat-backed entitlement.
  void set(SubscriptionTier? tier) {
    if (!DebugTierOverride.isAvailable) return;
    state = tier;
    debugPrint(
      tier == null
          ? 'DebugTierOverride: cleared — using the real entitlement again.'
          : '⚠️  DebugTierOverride: pretending this user is ${tier.name} '
                '(client-side gates only).',
    );
  }
}

final debugTierControllerProvider =
    NotifierProvider<DebugTierController, SubscriptionTier?>(
      DebugTierController.new,
    );

/// The `ProviderScope` override installed by `main()` in debug builds.
///
/// It does NOT hard-code a tier: it defers to [debugTierControllerProvider],
/// and when that is `null` it reproduces the real provider's behaviour
/// exactly. So installing it is harmless — with no tier forced, the app reads
/// live RevenueCat state as usual, and there is no separate "is the override
/// on" state that could drift.
Override debugTierOverride() {
  return subscriptionStatusValueProvider.overrideWith((ref) {
    final forced = ref.watch(debugTierControllerProvider);
    if (forced != null) {
      // `isKnown: true` matters as much as the tier itself: a gate that waits
      // for RevenueCat to answer would otherwise sit in its unknown state and
      // the override would look like it had done nothing.
      return SubscriptionStatus(tier: forced, isKnown: true);
    }
    return ref.watch(subscriptionStatusProvider).valueOrNull ??
        const SubscriptionStatus.unknown();
  });
}
