import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/user_repository.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/notifications/push_notification_service.dart';
import '../home/home_dashboard_screen.dart';
import 'birth_details_screen.dart';
import 'birth_profile_repository.dart';

/// Navigates to the correct screen after a SUCCESSFUL sign-in — Google,
/// email/password, or guest — clearing the nav stack so back never returns
/// to the auth screens.
///
/// Shared by [WelcomeLoginScreen] (email/password sign-in + Google + guest)
/// and [EmailSignUpScreen] (email/password sign-up) so the "does this
/// identity already have a birth profile?" decision lives in one place
/// instead of being duplicated across both screens.
///
/// Goes to [HomeDashboardScreen] if a [BirthProfile] was already saved for
/// this device, otherwise to [BirthDetailsScreen] to collect it first.
Future<void> navigateAfterSignIn(BuildContext context, WidgetRef ref) async {
  // Guest → signed-in migration: if this identity was previously used as a
  // guest and already has a locally-saved profile, upload it now that a uid
  // exists to key it on. Wrapped in try/catch so a sync failure can never
  // block navigation to the next screen — and, per
  // BirthProfileRepository.pushLocalProfileToCloud, this doesn't actually
  // wait on the network round trip either, only on the local-cache read.
  try {
    await ref.read(birthProfileRepositoryProvider).pushLocalProfileToCloud();
  } catch (_) {
    // Best-effort only; the local profile (if any) is unaffected.
  }

  // Also ensure the /users/{uid} account document exists from the very
  // first sign-in, independent of whether a birth profile exists yet.
  // Not awaited — this is a background sync, not something the user should
  // ever wait on.
  unawaited(
    ref
        .read(userRepositoryProvider)
        .upsertCurrentUser(
          locale: ref.read(localeControllerProvider)?.languageCode,
        )
        .catchError((_) {}),
  );

  // Register this device's FCM token against the now-known uid so a push can
  // actually be delivered to it (see PushNotificationService's Firestore
  // schema doc). Also fire-and-forget and never allowed to block navigation
  // — notification permission may not even be granted yet at this point
  // (that's requested later, on first reaching NotificationsScreen), and
  // getToken() still succeeds without it; only delivery to a denied device
  // is affected, not this sync.
  unawaited(
    ref
        .read(pushNotificationServiceProvider)
        .syncTokenForCurrentUser(
          locale: ref.read(localeControllerProvider)?.languageCode,
        )
        .catchError((_) {}),
  );

  final profile = await ref.read(birthProfileRepositoryProvider).load();

  // ⚠️ INVALIDATE BEFORE NAVIGATING — this is load-bearing, and its absence
  // was a real first-run bug (found on a device 15 Oct 2026).
  //
  // On a fresh install `RootGate` reads the profile on the FIRST FRAME,
  // before anyone has signed in. With no local cache and no authenticated
  // user, that read resolves to null — and `birthProfileProvider` caches it.
  // Signing in does not change that: the `load()` above is called on the
  // REPOSITORY directly, so it sees the cloud copy and routes correctly to
  // Home, while every widget still reads the cached null from the provider.
  //
  // The result was a signed-in user on Home with their profile sitting in
  // Firestore, greeted by the static placeholder name, and every
  // chart-dependent screen reporting "this report isn't available for your
  // chart" — until the app was restarted, which rebuilt the providers with
  // auth present. Reinstalls and new devices hit this every time.
  //
  // Sign-out already does exactly this (see `profile_settings_screen`); the
  // sign-IN path simply never did.
  ref.invalidate(birthProfileProvider);
  ref.invalidate(hasBirthProfileProvider);
  ref.invalidate(savedBirthProfilesProvider);

  if (!context.mounted) return;

  final destination = profile != null
      ? const HomeDashboardScreen()
      : const BirthDetailsScreen();

  Navigator.of(context).pushAndRemoveUntil<void>(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
    (route) => false,
  );
}
