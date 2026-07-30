import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_refs.dart';

/// Writes the account document `/users/{uid}` — the single Firestore doc
/// that mirrors the signed-in identity (as opposed to the birth profile
/// data, which lives in the `birthProfiles` subcollection — see
/// `lib/core/data/firestore_refs.dart`).
///
/// Both dependencies are injected (defaulting to the live singletons) so
/// nothing hard-references `FirebaseAuth.instance` / `FirebaseFirestore
/// .instance` at construction time, following the same pattern as
/// `AuthService` (see `lib/core/auth/auth_service.dart`).
class UserRepository {
  UserRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  /// Creates/updates `/users/{uid}` for the currently signed-in user.
  ///
  /// A no-op when nobody is signed in (guest browsing) — there is no uid to
  /// key the document on.
  Future<void> upsertCurrentUser({required String? locale}) async {
    // Guarded: `currentUser` touches `FirebaseAuth.instance`, which throws
    // if Firebase isn't initialised yet. This method is called from
    // fire-and-forget background syncs (see BirthProfileRepository), so a
    // Firebase-not-ready hiccup must never surface as an uncaught
    // exception — it's treated the same as "not signed in".
    final User? user;
    try {
      user = _firebaseAuth.currentUser;
    } catch (_) {
      return;
    }
    if (user == null) return;

    final docRef = _firestore.collection(usersCollection).doc(user.uid);

    // `createdAt` is only stamped the first time this document is written,
    // so it reflects when the account first appeared in Firestore rather
    // than being overwritten on every sign-in. If the existence check
    // itself fails (offline, transient error), fall through and still
    // attempt the merge write below, just without `createdAt` — a missing
    // `createdAt` on a brand-new doc is a cosmetic loss, not worth blocking
    // the whole upsert over.
    bool docExists = true;
    try {
      final snapshot = await docRef.get();
      docExists = snapshot.exists;
    } catch (_) {
      docExists = true;
    }

    final data = <String, dynamic>{
      // The deployed Firestore security rule requires
      // `request.resource.data.uid == userId`, so `uid` must be written
      // into the document body itself, not just used as the doc id.
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoURL,
      'providers': user.providerData.map((p) => p.providerId).toList(),
      'locale': locale,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!docExists) 'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data, SetOptions(merge: true));
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);
