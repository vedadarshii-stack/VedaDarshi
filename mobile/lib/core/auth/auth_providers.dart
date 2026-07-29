import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

/// App-wide [AuthService] instance, following the same "plain service class
/// behind a `Provider`" pattern used across the app (see
/// `lib/core/locale/locale_controller.dart` for the equivalent
/// `Notifier`-based pattern for stateful providers).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Live stream of the signed-in [User] (or `null` when signed out), for
/// screens/routing that need to react to auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});
