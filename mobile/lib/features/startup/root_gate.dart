import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../home/home_dashboard_screen.dart';
import '../profile/birth_details_screen.dart';
import '../profile/birth_profile_repository.dart';
import '../splash/splash_screen.dart';

/// The app's root route — decides, on every cold start, whether the user
/// resumes where they left off or has to go through onboarding.
///
/// Firebase persists a signed-in session across app restarts, and the birth
/// profile is persisted locally, so a returning user must NOT be shown the
/// intro carousel / language / login screens again. The decision is:
///
/// 1. A saved [BirthProfile] exists  → [HomeDashboardScreen].
///    (Checked FIRST, on purpose: it also covers GUEST users, who finished
///    onboarding but have no Firebase account — anonymous auth is currently
///    disabled in the Firebase console, so a guest's only durable trace is
///    their saved profile.)
/// 2. Otherwise signed in, but no profile yet → [BirthDetailsScreen], so an
///    interrupted sign-up resumes at the step it stopped on instead of
///    restarting from the carousel.
/// 3. Otherwise → [SplashScreen] (the full onboarding flow).
///
/// While auth state and the stored profile are still resolving, a static
/// brand screen is shown that matches the native splash, so startup reads as
/// one continuous screen rather than a flash of the wrong UI.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final hasProfile = ref.watch(hasBirthProfileProvider);

    // Only the very first resolution should block. Once both are known, an
    // AsyncValue that goes back into a loading state (e.g. the profile being
    // re-read) keeps showing the last decision instead of flashing the
    // loader again.
    if (!authState.hasValue || !hasProfile.hasValue) {
      return const _StartupScreen();
    }

    if (hasProfile.requireValue) {
      return const HomeDashboardScreen();
    }
    if (authState.requireValue != null) {
      return const BirthDetailsScreen();
    }
    return const SplashScreen();
  }
}

/// Static brand screen shown for the few frames it takes to read auth state
/// and the stored profile. Deliberately matches the native splash (navy +
/// logo) and has NO animation, so it is invisible when the decision is fast.
class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.navyGradient),
        child: Center(child: AppLogo(size: 148)),
      ),
    );
  }
}
