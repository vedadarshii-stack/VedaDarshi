import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Region the `deleteAccount` Cloud Function is deployed to — same
/// `asia-south1` region as every other callable in this backend (see
/// `lib/features/ai/ai_repository.dart`'s identical constant, and
/// `functions/src/deleteAccount.ts`'s `onCall({region: "asia-south1"})`).
/// The SDK's default region (`us-central1`) would 404 against this project.
const String _functionsRegion = 'asia-south1';

/// Failure reasons an [AccountDeletionRepository.deleteAccount] call can
/// surface to the UI — mirrors `lib/features/ai/ai_repository.dart`'s
/// `AiAstrologerErrorCode` split, so the UI never inspects a raw
/// [FirebaseFunctionsException].
enum AccountDeletionErrorCode {
  /// HttpsError code `unauthenticated` — the callable's own uid check
  /// (`request.auth?.uid`) failed, e.g. the ID token expired mid-flow.
  unauthenticated,

  /// HttpsError code `internal` (a genuine Firestore/Auth deletion
  /// failure — see `functions/src/deleteAccount.ts`'s doc comment on why
  /// Firestore is deleted before Auth), or anything else not otherwise
  /// classified.
  unknown,
}

/// The single exception type [AccountDeletionRepository.deleteAccount]
/// throws.
class AccountDeletionException implements Exception {
  const AccountDeletionException(this.code);

  final AccountDeletionErrorCode code;

  @override
  String toString() => 'AccountDeletionException(${code.name})';
}

/// Talks to the `deleteAccount` Cloud Function (`functions/src/
/// deleteAccount.ts`) — see `projects/CLAUDE.md`'s "Delete Account —
/// Cloud Function built 24 Aug 2026" section for the backend contract: no
/// arguments (the uid is read from the verified auth token server-side,
/// never sent by the client), deletes the whole `/users/{uid}` Firestore
/// subtree via `recursiveDelete` and THEN the Auth user (order is
/// load-bearing there — Firestore first so a mid-way failure leaves the
/// caller still authenticated and able to retry), returns `{success: true}`.
/// The function is idempotent — a missing document or an already-deleted
/// Auth user (`auth/user-not-found`) is treated as success, so retrying
/// after a transient failure is always safe.
///
/// [FirebaseFunctions] is injected as a LAZY getter, not an eagerly
/// resolved instance — same convention as `AiRepository`/
/// `BirthProfileRepository` — touching it before `Firebase.initializeApp`
/// completes throws, and providers are constructed well before that.
class AccountDeletionRepository {
  // Initializing formal — the callsite (accountDeletionRepositoryProvider)
  // still uses the public label `functions`; Dart maps it onto this
  // private field. Matches `AiRepository`'s identical convention.
  AccountDeletionRepository({required this._functions});

  final FirebaseFunctions Function() _functions;

  /// Calls the `deleteAccount` callable. Throws [AccountDeletionException]
  /// on any failure.
  ///
  /// This repository ONLY talks to the backend — it does not sign the
  /// user out (there is nothing left to sign out of once this succeeds:
  /// the Firebase Auth user is already gone server-side), clear the local
  /// birth profile cache, or navigate. `ProfileSettingsScreen._deleteAccount`
  /// owns all of that, mirroring the same split `_signOut` already has
  /// between `AuthService.signOut()` (backend) and its own local
  /// cleanup + navigation.
  Future<void> deleteAccount() async {
    try {
      final callable = _functions().httpsCallable('deleteAccount');
      await callable.call<Map<String, dynamic>>();
    } on FirebaseFunctionsException catch (e) {
      throw AccountDeletionException(_mapErrorCode(e.code));
    } catch (e) {
      debugPrint(
        'AccountDeletionRepository.deleteAccount: unexpected failure: $e',
      );
      throw const AccountDeletionException(AccountDeletionErrorCode.unknown);
    }
  }

  AccountDeletionErrorCode _mapErrorCode(String? code) {
    switch (code) {
      case 'unauthenticated':
        return AccountDeletionErrorCode.unauthenticated;
      default:
        return AccountDeletionErrorCode.unknown;
    }
  }
}

final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository>(
  (ref) {
    return AccountDeletionRepository(
      functions: () => FirebaseFunctions.instanceFor(region: _functionsRegion),
    );
  },
);
