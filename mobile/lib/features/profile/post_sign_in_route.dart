import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/user_repository.dart';
import '../../core/locale/locale_controller.dart';
import '../home/home_dashboard_screen.dart';
import 'birth_details_screen.dart';
import 'birth_profile_repository.dart';

/// Navigates to the correct screen after a SUCCESSFUL sign-in — Google,
/// phone OTP (manual or Android auto-verification), or guest — clearing the
/// nav stack so back never returns to the auth screens.
///
/// Shared by [WelcomeLoginScreen] (Google + guest + OTP auto-verification)
/// and [OtpVerifyScreen] (manual OTP + resend auto-verification) so the
/// "does this identity already have a birth profile?" decision lives in one
/// place instead of being duplicated across both screens.
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

  final profile = await ref.read(birthProfileRepositoryProvider).load();
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
