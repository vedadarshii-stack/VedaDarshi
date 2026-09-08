import '../../core/purchases/purchases_service.dart';
import '../../l10n/app_localizations.dart';

/// Maps a [PurchaseFailure] to localized copy.
///
/// EXTRACTED 8 Sep 2026 from `subscription_paywall_screen.dart`, where it was
/// a private static, once Profile's "Restore Purchases" needed the same
/// mapping. Same convention as `auth_error_messages.dart` and
/// `account_deletion_error_messages.dart`: one mapper per failure enum, so
/// two screens can never describe the same failure differently.
///
/// [PurchaseFailure.cancelled] maps to the generic string for completeness,
/// but callers should NOT show it — the user closed the Play sheet on
/// purpose, and a snackbar telling them their own action failed is noise.
String purchaseFailureMessage(
  AppLocalizations l10n,
  PurchaseFailure reason,
) {
  return switch (reason) {
    PurchaseFailure.notAllowed => l10n.purchaseErrorNotAllowed,
    PurchaseFailure.network => l10n.purchaseErrorNetwork,
    PurchaseFailure.alreadyOwned => l10n.purchaseErrorAlreadyOwned,
    PurchaseFailure.productUnavailable => l10n.purchaseErrorUnavailable,
    PurchaseFailure.cancelled || PurchaseFailure.unknown =>
      l10n.purchaseErrorGeneric,
  };
}
