import '../../l10n/app_localizations.dart';
import 'birth_profile_repository.dart';

/// Maps a [BirthProfileFailureReason] to its localized, user-facing
/// message — mirrors `account_deletion_error_messages.dart`'s
/// `accountDeletionErrorMessage`. Used by `birth_profiles_screen.dart` and
/// `birth_profile_editor_screen.dart` so a raw [BirthProfileFailure] is
/// never shown to the user.
String birthProfileFailureMessage(
  AppLocalizations l10n,
  BirthProfileFailureReason reason,
) {
  switch (reason) {
    case BirthProfileFailureReason.notSignedIn:
      return l10n.birthProfilesSignInRequired;
    case BirthProfileFailureReason.cannotDeletePrimary:
      return l10n.birthProfilesPrimaryDeleteHint;
  }
}
