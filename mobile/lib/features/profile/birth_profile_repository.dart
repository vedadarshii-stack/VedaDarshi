import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/data/firestore_refs.dart';
import '../../core/data/user_repository.dart';
import '../../core/locale/locale_controller.dart';
import 'birth_profile.dart';

const String _prefsKey = 'birth_profile';

/// How long [BirthProfileRepository.load] waits for the remote Firestore
/// read before giving up and treating it the same as "no profile" — a
/// reinstall/new-device restore should never hang the startup routing
/// decision (`RootGate`) indefinitely on a bad connection.
const Duration _remoteLoadTimeout = Duration(seconds: 8);

/// Persists the signed-in user's [BirthProfile], offline-first:
/// [SharedPreferences] is the LOCAL CACHE and always the fast path, with
/// Cloud Firestore layered on top for cross-device / reinstall durability
/// once the user is signed in (`/users/{uid}/birthProfiles/primary` — see
/// `lib/core/data/firestore_refs.dart`).
///
/// Only a single (the account owner's own) profile is supported here —
/// multi-profile support for family/friends is a follow-up, per the M1
/// data-layer plan (the profile document already carries `isPrimary: true`
/// in anticipation of that).
///
/// Every dependency is injected so nothing in this class hard-references a
/// Firebase singleton at construction time (mirrors `AuthService`'s
/// pattern) — see [birthProfileRepositoryProvider] for how the live
/// instances are wired up.
class BirthProfileRepository {
  // Initializing formals — the callsite (birthProfileRepositoryProvider,
  // below) still uses the public labels firestore/userRepository/
  // currentUid/currentLocaleCode; Dart maps them onto these private fields.
  BirthProfileRepository({
    required this._firestore,
    required this._userRepository,
    required this._currentUid,
    required this._currentLocaleCode,
  });

  /// Resolved LAZILY (a getter, not an eagerly-passed instance) because
  /// `FirebaseFirestore.instance` throws if `Firebase.initializeApp` has not
  /// completed. Touching it while building the provider would take the whole
  /// startup path down with it — `RootGate` reads this repository on the
  /// first frame — instead of degrading to local-only persistence.
  final FirebaseFirestore Function() _firestore;
  final UserRepository _userRepository;

  /// Returns the signed-in Firebase user's uid, or `null` when nobody is
  /// signed in (guest browsing — anonymous auth is currently disabled in
  /// the Firebase console, so a guest never has a uid).
  final String? Function() _currentUid;

  /// Returns the current app language code (e.g. `"en"`), for stamping
  /// alongside the account document on every cloud sync.
  final String? Function() _currentLocaleCode;

  /// Wraps [_currentUid] so a Firebase-not-ready failure (e.g. `_currentUid`
  /// touching `FirebaseAuth.instance` before `Firebase.initializeApp` has
  /// resolved) can never surface as an exception here — it is treated the
  /// same as "not signed in", so the birth-details save path always falls
  /// back to local-only persistence instead of throwing.
  String? _safeUid() {
    try {
      return _currentUid();
    } catch (_) {
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>> _primaryDocFor(String uid) {
    return _firestore()
        .collection(usersCollection)
        .doc(uid)
        .collection(birthProfilesCollection)
        .doc(primaryProfileId);
  }

  /// Loads the saved profile, or `null` if none was ever saved (locally or
  /// remotely), or if the stored data is corrupt/unparseable — never throws
  /// for bad stored data, it is simply treated as "no profile yet" so the
  /// user is asked to fill the form in again.
  Future<BirthProfile?> load() async {
    final local = await _loadLocal();
    if (local != null) return local;

    final uid = _safeUid();
    if (uid == null) return null;

    // No local cache — this is a reinstall or a new device. Try to restore
    // from Firestore so the user isn't asked to redo onboarding.
    //
    // Trade-off: on timeout, a permission error, a missing doc, or
    // malformed remote data, this just returns null rather than throwing —
    // the user is asked to fill the Birth Details form in again, and that
    // re-save (see [save]) then overwrites whatever (if anything) is
    // sitting in Firestore. That's an acceptable cost for never blocking
    // app startup on a flaky network.
    try {
      final snapshot = await _primaryDocFor(
        uid,
      ).get().timeout(_remoteLoadTimeout);
      final profile = BirthProfile.tryFromFirestore(snapshot.data());
      if (profile == null) return null;
      await _saveLocal(profile);
      return profile;
    } catch (e) {
      debugPrint('BirthProfileRepository.load: remote fetch failed: $e');
      return null;
    }
  }

  Future<void> save(BirthProfile profile) async {
    // 1. Local cache first, and awaited — this always succeeds and is what
    // makes the UI instant regardless of network state.
    await _saveLocal(profile);

    final uid = _safeUid();
    if (uid == null) {
      // Guest (no signed-in Firebase user — anonymous auth is disabled) —
      // local-only, nothing to sync.
      return;
    }

    // 2. Kick off the Firestore write WITHOUT awaiting the network.
    // Firestore persists writes to its local cache immediately and replays
    // them to the server automatically when connectivity returns (offline
    // persistence is enabled in main.dart), so awaiting the round trip here
    // would block the user behind a spinner for no benefit, and would fail
    // outright while offline. Errors are caught and logged, never thrown
    // back at the caller.
    unawaited(_syncToCloud(uid, profile));
  }

  /// Guest → signed-in migration path: if a local profile exists and the
  /// user is now signed in, upload it. Called right after a successful
  /// sign-in (see `lib/features/profile/post_sign_in_route.dart`) so someone
  /// who completed onboarding as a guest keeps their profile once they sign
  /// in later.
  Future<void> pushLocalProfileToCloud() async {
    final uid = _safeUid();
    if (uid == null) return;
    final local = await _loadLocal();
    if (local == null) return;
    // Same fire-and-forget write as save()'s step 2 — see that method's
    // comment for why the network round trip isn't awaited.
    unawaited(_syncToCloud(uid, local));
  }

  Future<void> _syncToCloud(String uid, BirthProfile profile) async {
    try {
      await _primaryDocFor(
        uid,
      ).set(profile.toFirestore(), SetOptions(merge: true));
      await _userRepository.upsertCurrentUser(locale: _currentLocaleCode());
    } catch (e) {
      debugPrint('BirthProfileRepository: Firestore sync failed: $e');
    }
  }

  /// Deletes the cached local profile.
  ///
  /// Sign-out MUST call this (and invalidate [birthProfileProvider] /
  /// [hasBirthProfileProvider]), otherwise `RootGate` keeps routing a
  /// signed-out user straight to Home off the stale cached profile.
  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<BirthProfile?> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return BirthProfile.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLocal(BirthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
  }
}

final birthProfileRepositoryProvider = Provider<BirthProfileRepository>((
  ref,
) {
  return BirthProfileRepository(
    firestore: () => FirebaseFirestore.instance,
    userRepository: ref.watch(userRepositoryProvider),
    currentUid: () => ref.read(authServiceProvider).currentUser?.uid,
    currentLocaleCode: () => ref.read(localeControllerProvider)?.languageCode,
  );
});

/// The current user's saved [BirthProfile], or `null` if none exists yet.
///
/// Shared by [hasBirthProfileProvider] (which just checks presence) and the
/// Home Dashboard screen (which prefers the real saved name/initial over
/// its static placeholder greeting once a profile is available).
final birthProfileProvider = FutureProvider<BirthProfile?>((ref) {
  return ref.watch(birthProfileRepositoryProvider).load();
});

/// Whether the current user has already completed the Birth Details screen
/// — used by the post-sign-in routing helper to decide whether to show the
/// Birth Details screen or skip straight to Home.
final hasBirthProfileProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(birthProfileProvider.future);
  return profile != null;
});
