import '../../l10n/app_localizations.dart';
import 'ai_repository.dart';

/// Maps an [AiAstrologerErrorCode] to its localized, user-facing message —
/// mirrors `lib/features/auth/auth_error_messages.dart`'s
/// `authErrorMessage`. The raw `askAiAstrologer` HttpsError code/message is
/// never shown to the user.
String aiErrorMessage(AppLocalizations l10n, AiAstrologerErrorCode code) {
  switch (code) {
    case AiAstrologerErrorCode.quotaExceeded:
      return l10n.aiErrorQuotaExceeded;
    case AiAstrologerErrorCode.birthDetailsMissing:
      return l10n.aiErrorBirthDetailsMissing;
    case AiAstrologerErrorCode.invalidQuestion:
      return l10n.aiErrorInvalidQuestion;
    case AiAstrologerErrorCode.serviceUnavailable:
      return l10n.aiErrorServiceUnavailable;
    case AiAstrologerErrorCode.unknown:
      return l10n.aiErrorGeneric;
  }
}
