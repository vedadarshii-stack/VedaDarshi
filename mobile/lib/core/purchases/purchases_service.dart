import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'subscription_catalogue.dart';
import 'subscription_tier.dart';

/// Why a purchase or restore did not go through.
///
/// The UI never inspects a raw [PlatformException] or a
/// [PurchasesErrorCode] — [PurchasesService] normalizes everything into one
/// of these so screens can `switch` on a stable enum, mirroring the
/// `AuthErrorCode` / `AiAstrologerErrorCode` split used elsewhere in this
/// codebase.
enum PurchaseFailure {
  /// The user backed out of the Play sheet. **Not an error to report** — no
  /// snackbar, no log noise; they simply changed their mind.
  cancelled,

  /// Play refuses purchases on this device/account (parental controls,
  /// unsupported device, billing unavailable in this country).
  notAllowed,

  /// Offline, or Play/RevenueCat unreachable.
  network,

  /// Already owned. Usually means the entitlement just needs syncing, so the
  /// UI should suggest "Restore purchase" rather than "try again".
  alreadyOwned,

  /// The product is missing or inactive in Play Console. Expect this until
  /// the catalogue is actually created and the build is on a Play track.
  productUnavailable,

  /// Anything else, including the SDK not being configured.
  unknown,
}

/// The single exception type [PurchasesService] throws.
class PurchaseException implements Exception {
  const PurchaseException(this.reason);

  final PurchaseFailure reason;

  @override
  String toString() => 'PurchaseException(${reason.name})';
}

/// Thin wrapper over the RevenueCat SDK.
///
/// **The entitlement source of truth is RevenueCat's [CustomerInfo], and
/// nothing else.** Access is never granted client-side, never inferred from
/// "the purchase call returned without throwing", and never mirrored into a
/// Firestore field the client can write — any of those turn a paywall into a
/// suggestion. Everything this class exposes derives from [CustomerInfo].
///
/// The service is safe to use when RevenueCat is NOT configured: with no
/// `REVENUECAT_ANDROID_KEY` in `.env`, [configure] logs and returns, every
/// read yields an empty/unknown result, and the paywall shows its
/// "plans unavailable" state instead of the app failing to boot. That mirrors
/// the existing treatment of the optional Google Places key.
class PurchasesService {
  /// `.env` key holding the RevenueCat **public SDK key** for Android.
  ///
  /// Public on purpose — this key is designed to ship inside the client and
  /// can only read offerings and the calling user's own state. It is NOT the
  /// secret API key and NOT the Play service-account JSON, neither of which
  /// may ever enter this repo.
  static const String envKeyName = 'REVENUECAT_ANDROID_KEY';

  bool _configured = false;

  /// Whether [configure] found a key and the SDK came up.
  bool get isConfigured => _configured;

  /// Reads the key exactly the way `GooglePlacesSearch` does: resolved on
  /// access (dotenv values only exist after `dotenv.load()`), and never
  /// throwing, because an absent key is a supported state.
  static String get _apiKey {
    try {
      return dotenv.env[envKeyName]?.trim() ?? '';
    } catch (_) {
      // dotenv.load() never ran (e.g. a test harness) — treat as unset.
      return '';
    }
  }

  /// Brings the SDK up. Call once, from `main()`, before anything else here.
  ///
  /// Deliberately swallows every failure: a billing SDK that cannot start is
  /// a reason to hide the paywall, never a reason to stop the app booting.
  Future<void> configure() async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      debugPrint(
        'PurchasesService: no $envKeyName in .env — purchases disabled',
      );
      return;
    }
    try {
      if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
      // No appUserID: the SDK starts anonymous and is later aliased onto the
      // Firebase uid by [logIn]. Configuring with a uid we may not have yet
      // would mean a null id on a cold start before auth resolves.
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (e) {
      debugPrint('PurchasesService: configure failed ($e) — purchases disabled');
    }
  }

  /// Aliases the RevenueCat user onto the Firebase uid, so entitlements
  /// follow the ACCOUNT rather than the device install.
  ///
  /// Without this a user who reinstalls, or signs in on a second device,
  /// looks like a brand-new anonymous RevenueCat user and loses access they
  /// paid for until they hit "Restore purchase". Anonymous Firebase users
  /// have a uid too, and passing it is correct: if that account is later
  /// linked to a real credential the uid is preserved, so the purchase
  /// history carries over.
  Future<void> logIn(String firebaseUid) async {
    if (!_configured || firebaseUid.isEmpty) return;
    try {
      await Purchases.logIn(firebaseUid);
    } catch (e) {
      debugPrint('PurchasesService: logIn failed ($e)');
    }
  }

  /// Returns the SDK to an anonymous user on sign-out, so the next person to
  /// sign in on this device does not inherit the previous user's
  /// entitlements.
  Future<void> logOut() async {
    if (!_configured) return;
    try {
      // logOut() throws if the current user is already anonymous, which is
      // the normal state on a fresh install — checking first keeps that
      // non-event out of the logs.
      if (await Purchases.isAnonymous) return;
      await Purchases.logOut();
    } catch (e) {
      debugPrint('PurchasesService: logOut failed ($e)');
    }
  }

  /// The current offering, resolved into tier+period options.
  ///
  /// Returns an EMPTY catalogue rather than throwing when the SDK is
  /// unconfigured or Play has no products yet — which is the expected state
  /// until the AAB is on a Play track and the products are Active. An empty
  /// catalogue is a UI state, not an error.
  Future<SubscriptionCatalogue> fetchCatalogue() async {
    if (!_configured) return const SubscriptionCatalogue.empty();
    try {
      final offerings = await Purchases.getOfferings();
      return SubscriptionCatalogue.fromOffering(offerings.current);
    } catch (e) {
      debugPrint('PurchasesService: getOfferings failed ($e)');
      return const SubscriptionCatalogue.empty();
    }
  }

  /// Latest known entitlement state.
  Future<SubscriptionStatus> fetchStatus() async {
    if (!_configured) return const SubscriptionStatus.unknown();
    try {
      return SubscriptionStatus.fromCustomerInfo(await Purchases.getCustomerInfo());
    } catch (e) {
      debugPrint('PurchasesService: getCustomerInfo failed ($e)');
      return const SubscriptionStatus.unknown();
    }
  }

  /// Fires whenever RevenueCat's view of the user changes — a purchase
  /// completing, a renewal, a cancellation, an expiry, or a restore.
  ///
  /// This is what keeps access correct without the app polling: gates that
  /// watch it lock themselves the moment an entitlement lapses.
  Stream<SubscriptionStatus> statusChanges() {
    if (!_configured) return const Stream<SubscriptionStatus>.empty();
    final controller = StreamController<SubscriptionStatus>();
    void listener(CustomerInfo info) {
      controller.add(SubscriptionStatus.fromCustomerInfo(info));
    }

    Purchases.addCustomerInfoUpdateListener(listener);
    controller.onCancel = () {
      Purchases.removeCustomerInfoUpdateListener(listener);
    };
    return controller.stream;
  }

  /// Buys [option] and returns the entitlement state Play + RevenueCat agree
  /// on afterwards.
  ///
  /// The returned status comes from the SDK's own [CustomerInfo], so a
  /// purchase that Play accepted but RevenueCat has not validated does not
  /// unlock anything.
  /// Pass [replacingProductId] when the user already holds a DIFFERENT
  /// subscription in the same Play group — that is what turns the purchase
  /// into an upgrade/downgrade instead of a second, conflicting purchase.
  /// Omitting it on a tier switch is what surfaces "you already own this
  /// item".
  ///
  /// [StoreProductChangeInfo.replacementMode] is left unset, so Play applies
  /// its own default proration. **This is the one part of the billing flow
  /// that cannot be verified yet** — an upgrade needs two real Play products
  /// and a live subscription to exercise, neither of which exists until the
  /// catalogue is created. Re-check it against the client's intent then;
  /// the alternatives are the [StoreReplacementMode] values.
  Future<SubscriptionStatus> purchase(
    SubscriptionPlan option, {
    String? replacingProductId,
  }) async {
    if (!_configured) throw const PurchaseException(PurchaseFailure.unknown);
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(
          option.package,
          productChangeInfo: replacingProductId == null
              ? null
              : StoreProductChangeInfo(replacingProductId),
        ),
      );
      return SubscriptionStatus.fromCustomerInfo(result.customerInfo);
    } on PlatformException catch (e) {
      throw PurchaseException(_classify(e));
    } catch (e) {
      debugPrint('PurchasesService: purchase failed ($e)');
      throw const PurchaseException(PurchaseFailure.unknown);
    }
  }

  /// Re-syncs purchases made on another device or before a reinstall.
  /// Re-syncs purchases made on another device or before a reinstall.
  ///
  /// ## `firebaseUid` is REQUIRED, and that is the point (8 Sep 2026)
  ///
  /// This used to call `Purchases.restorePurchases()` directly, trusting that
  /// something else had already aliased the SDK onto the signed-in user.
  /// `subscriptionStatusProvider` does call [logIn] — but only when IT runs,
  /// and restore can fire before that resolves, or after a user switch.
  ///
  /// Restoring against the wrong app-user id is the classic, silent restore
  /// bug: Play returns the receipts, RevenueCat attaches them to whichever id
  /// the SDK currently holds, and the call REPORTS SUCCESS. On a shared
  /// device that binds one person's subscription to another person's account,
  /// and nothing visible goes wrong until someone notices they are paying for
  /// somebody else's Platinum.
  ///
  /// Making the uid a required parameter means a caller cannot forget it —
  /// the compiler asks. Aliasing first is cheap and idempotent.
  ///
  /// Pass an empty string ONLY for a deliberately anonymous restore (a signed
  /// -out user recovering a purchase before signing in); the alias is then
  /// skipped, exactly as [logIn] already handles.
  Future<SubscriptionStatus> restore({required String firebaseUid}) async {
    if (!_configured) throw const PurchaseException(PurchaseFailure.unknown);
    // Awaited, not fire-and-forget: the whole point is that the alias is in
    // place BEFORE the receipts are attached.
    await logIn(firebaseUid);
    try {
      return SubscriptionStatus.fromCustomerInfo(
        await Purchases.restorePurchases(),
      );
    } on PlatformException catch (e) {
      throw PurchaseException(_classify(e));
    } catch (e) {
      debugPrint('PurchasesService: restore failed ($e)');
      throw const PurchaseException(PurchaseFailure.unknown);
    }
  }

  static PurchaseFailure _classify(PlatformException e) {
    final PurchasesErrorCode code;
    try {
      code = PurchasesErrorHelper.getErrorCode(e);
    } catch (_) {
      // getErrorCode parses e.code as a number and throws on anything else.
      return PurchaseFailure.unknown;
    }
    return switch (code) {
      PurchasesErrorCode.purchaseCancelledError => PurchaseFailure.cancelled,
      PurchasesErrorCode.purchaseNotAllowedError ||
      PurchasesErrorCode.storeProblemError ||
      PurchasesErrorCode.paymentPendingError => PurchaseFailure.notAllowed,
      PurchasesErrorCode.networkError ||
      PurchasesErrorCode.offlineConnectionError => PurchaseFailure.network,
      PurchasesErrorCode.productAlreadyPurchasedError ||
      PurchasesErrorCode.receiptAlreadyInUseError => PurchaseFailure.alreadyOwned,
      PurchasesErrorCode.productNotAvailableForPurchaseError ||
      PurchasesErrorCode.configurationError => PurchaseFailure.productUnavailable,
      _ => PurchaseFailure.unknown,
    };
  }
}
