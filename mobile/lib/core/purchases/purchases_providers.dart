import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth_providers.dart';
import 'ai_pack_catalogue.dart';
import 'purchases_service.dart';
import 'subscription_catalogue.dart';
import 'subscription_tier.dart';

/// App-wide [PurchasesService], following the same "plain service class
/// behind a `Provider`" pattern as `authServiceProvider`.
final purchasesServiceProvider = Provider<PurchasesService>(
  (ref) => PurchasesService(),
);

/// Live entitlement state.
///
/// Rebuilds whenever Firebase auth changes, and the first thing it does on
/// each rebuild is alias RevenueCat onto the new uid (or return it to
/// anonymous on sign-out). That ordering matters: fetching status BEFORE the
/// alias would answer for the previous user, which on a shared device means
/// showing one person's subscription to another.
///
/// After the initial fetch it stays subscribed to RevenueCat's own update
/// listener, so a cancellation, expiry or renewal re-locks or re-unlocks the
/// app without a restart and without polling.
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((
  ref,
) async* {
  final service = ref.watch(purchasesServiceProvider);
  final authState = ref.watch(authStateProvider);

  // Only act once auth has actually resolved — while it is still loading we
  // do not know whether this is a signed-in user or a signed-out one, and
  // guessing either way would alias the wrong RevenueCat identity.
  if (authState.hasValue) {
    final user = authState.value;
    if (user == null) {
      await service.logOut();
    } else {
      await service.logIn(user.uid);
    }
  }

  yield await service.fetchStatus();
  yield* service.statusChanges();
});

/// The entitlement state feature gates should read.
///
/// Collapses the [AsyncValue] to a plain [SubscriptionStatus], substituting
/// [SubscriptionStatus.unknown] while loading or on error. Unknown is NOT
/// the same as free — see [SubscriptionStatus.isKnown]; a gate that wants to
/// wait rather than deny should check it.
final subscriptionStatusValueProvider = Provider<SubscriptionStatus>((ref) {
  return ref.watch(subscriptionStatusProvider).valueOrNull ??
      const SubscriptionStatus.unknown();
});

/// The purchasable plans, read from the live RevenueCat offering.
///
/// Resolves to an EMPTY catalogue (never an error) when RevenueCat is
/// unconfigured or Play has no active products — the paywall renders that as
/// a "plans unavailable" state. `ref.invalidate` this to retry.
final subscriptionCatalogueProvider = FutureProvider<SubscriptionCatalogue>((
  ref,
) async {
  // Depend on the status stream so the catalogue is refetched after a
  // sign-in switches RevenueCat users: offerings can be targeted per user,
  // so the previous user's offering must not linger on screen.
  ref.watch(subscriptionStatusProvider);
  return ref.watch(purchasesServiceProvider).fetchCatalogue();
});

/// The buyable AI question packs.
///
/// Separate from [subscriptionCatalogueProvider] because it reads a DIFFERENT
/// RevenueCat offering (`ai_packs`, not `current`). Resolves to an empty
/// catalogue rather than an error when RevenueCat is unconfigured or the
/// products are not Active in Play — the sheet renders that as
/// "packs unavailable" with a retry, exactly like the paywall does.
final aiPackCatalogueProvider = FutureProvider<AiPackCatalogue>((ref) async {
  // Same dependency as the subscription catalogue: offerings can be targeted
  // per user, so a sign-in must not leave the previous user's packs on screen.
  ref.watch(subscriptionStatusProvider);
  return ref.watch(purchasesServiceProvider).fetchAiPacks();
});

/// Questions remaining across the user's live packs.
///
/// ⚠️ Read from **Firestore, not from the SDK**. A pack is a consumable: the
/// store confirms the PURCHASE, but how many questions are left is our own
/// server-side ledger (`functions/src/aiPacks.ts`), written by the RevenueCat
/// webhook and spent by `askAiAstrologer`. Asking RevenueCat "how many
/// questions do I have" would be asking the wrong system.
///
/// The collection is client-readable but `allow write: if false`, so this is
/// a trustworthy read of a value the user cannot forge.
final aiPackBalanceProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(0);

  final nowMs = DateTime.now().millisecondsSinceEpoch;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('aiPacks')
      // Expiry is filtered CLIENT-side after the read rather than in the
      // query: `where(expiresAtMs > now)` would need a composite index and,
      // worse, would not re-evaluate as time passes on a live snapshot —
      // a pack expiring while the screen is open would keep counting.
      .snapshots()
      .map((snap) {
        var total = 0;
        for (final doc in snap.docs) {
          final data = doc.data();
          final expiresAtMs = (data['expiresAtMs'] as num?)?.toInt() ?? 0;
          if (expiresAtMs <= nowMs) continue;
          final remaining = (data['remaining'] as num?)?.toInt() ?? 0;
          final pending = (data['pending'] as num?)?.toInt() ?? 0;
          total += (remaining - pending).clamp(0, remaining);
        }
        return total;
      })
      .handleError((_) => 0);
});
