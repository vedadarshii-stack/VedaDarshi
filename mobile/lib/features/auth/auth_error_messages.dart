import '../../core/auth/auth_service.dart';
import '../../l10n/app_localizations.dart';

/// Maps an [AuthErrorCode] to its localized, user-facing message.
///
/// Returns `null` for [AuthErrorCode.cancelled] — the user intentionally
/// backed out of an interactive flow (e.g. closed the Google account
/// picker), which is not a failure and should never surface a snackbar.
/// Callers should skip showing anything when this returns `null`.
String? authErrorMessage(AppLocalizations l10n, AuthErrorCode code) {
  switch (code) {
    case AuthErrorCode.network:
      return l10n.authErrorNetwork;
    case AuthErrorCode.invalidPhone:
      return l10n.authErrorInvalidPhone;
    case AuthErrorCode.invalidOtp:
      return l10n.authErrorInvalidOtp;
    case AuthErrorCode.otpExpired:
      return l10n.authErrorOtpExpired;
    case AuthErrorCode.tooManyRequests:
      return l10n.authErrorTooManyRequests;
    case AuthErrorCode.providerDisabled:
      return l10n.authErrorProviderDisabled;
    case AuthErrorCode.cancelled:
      return null;
    case AuthErrorCode.unknown:
      return l10n.authErrorUnknown;
  }
}
