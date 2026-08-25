import '../../l10n/app_localizations.dart';
import 'account_deletion_repository.dart';

/// Maps an [AccountDeletionErrorCode] to its localized, user-facing
/// message — mirrors `lib/features/ai/ai_error_messages.dart`'s
/// `aiErrorMessage`. The raw `deleteAccount` HttpsError code/message is
/// never shown to the user.
String accountDeletionErrorMessage(
  AppLocalizations l10n,
  AccountDeletionErrorCode code,
) {
  switch (code) {
    case AccountDeletionErrorCode.unauthenticated:
      return l10n.accountDeletionErrorUnauthenticated;
    case AccountDeletionErrorCode.unknown:
      return l10n.accountDeletionErrorGeneric;
  }
}
