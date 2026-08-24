import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Failure reasons an [AuthService] call can surface to the UI layer.
///
/// The UI never inspects a raw [FirebaseAuthException] or
/// [GoogleSignInException] — every public [AuthService] method normalizes
/// whatever it catches into one of these codes (wrapped in an
/// [AuthException]) so screens can map it to a localized message via
/// `authErrorMessage` (see `lib/features/auth/auth_error_messages.dart`)
/// without knowing anything about Firebase or Google Sign-In internals.
enum AuthErrorCode {
  /// No/unstable network connection.
  network,

  /// Too many attempts in a short window (Firebase abuse protection).
  tooManyRequests,

  /// The requested sign-in provider isn't enabled for this Firebase project.
  providerDisabled,

  /// The user backed out of an interactive flow (e.g. closed the Google
  /// account picker) — not a real failure, callers typically ignore this.
  cancelled,

  /// Anything else / not otherwise classified.
  unknown,

  /// The email address entered on sign-up is already registered.
  emailInUse,

  /// The email address is not validly formatted.
  invalidEmail,

  /// The chosen password doesn't meet Firebase's minimum strength.
  weakPassword,

  /// The email/password combination was rejected.
  wrongCredentials,

  /// No account exists for the entered email address.
  userNotFound,
}

/// The single exception type every [AuthService] method throws.
///
/// Wraps an [AuthErrorCode] so callers can `switch` on a small, stable enum
/// instead of parsing platform-specific error strings.
class AuthException implements Exception {
  const AuthException(this.code);

  final AuthErrorCode code;

  @override
  String toString() => 'AuthException(${code.name})';
}

/// Thin wrapper around `firebase_auth` (email/password and anonymous
/// sign-in) and `google_sign_in` (Google OAuth), giving the rest of the app
/// a single, Firebase-agnostic surface for authentication.
///
/// This is a plain class, not a Riverpod provider itself — see
/// `lib/core/auth/auth_providers.dart` for the `authServiceProvider` /
/// `authStateProvider` that expose it (and the live [User]) to the widget
/// tree, following the same pattern as `LocaleController`.
///
/// Every public method converts any error it encounters — whether a
/// [FirebaseAuthException], a [GoogleSignInException], or anything else —
/// into an [AuthException] with a stable [AuthErrorCode]. Callers should
/// never need to catch a raw Firebase/Google exception type.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  /// `google_sign_in` 7.x requires [GoogleSignIn.initialize] to complete
  /// exactly once before any other instance method is called. This guards
  /// that so repeated Google sign-in attempts within the same app session
  /// don't re-initialize (which is undefined behaviour per the package
  /// docs).
  bool _googleInitialised = false;

  /// Fires whenever the signed-in [User] changes (sign-in, sign-out, token
  /// refresh producing a different user).
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// The currently signed-in user, or `null` if nobody is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// The OAuth **web** client id (type 3) from `google-services.json`.
  ///
  /// PASSED EXPLICITLY, and it has to be — 18 Aug 2026. The previous code
  /// called `GoogleSignIn.initialize()` with no arguments, on the documented
  /// assumption that the google-services Gradle plugin compiles this value
  /// into the APK as the `default_web_client_id` string resource and that
  /// google_sign_in picks it up from there. **That resource is not in the
  /// built APK.** Verified with
  /// `aapt2 dump resources app-release.apk`: the plugin emits
  /// `google_api_key`, `google_app_id`, `project_id`, `gcm_default` and
  /// `google_storage_bucket`, but NOT `default_web_client_id` — even though
  /// the type 3 client is present in `google-services.json`.
  ///
  /// Without it, google_sign_in 7.x on Android has no web client id to
  /// request an `idToken` with, and `authenticate()` throws a
  /// `GoogleSignInException` with `clientConfigurationError`. That maps to
  /// [AuthErrorCode.providerDisabled] below, which is why every Google
  /// sign-in surfaced the misleading "This sign-in method isn't available
  /// yet" — the provider IS enabled (verified via the Identity Platform
  /// admin API: `google.com enabled=true`) and the release keystore's SHA-1
  /// IS registered. The failure was purely this missing id.
  ///
  /// NOT a secret: an OAuth *client id* is a public identifier that ships in
  /// every build anyway, which is why it is a plain constant here rather
  /// than a `.env` value — `.env` is gitignored, so a required-for-sign-in
  /// value living there would break a fresh clone.
  ///
  /// If the Firebase project's web app is ever recreated, re-read this from
  /// `android/app/google-services.json` (the `client_type: 3` entry).
  static const String _googleServerClientId =
      '1029956122-p8j1kq5kj6li995h81t69tspv6e2vvtn.apps.googleusercontent.com';

  /// Signs the user in with a Google account via an interactive picker.
  Future<void> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialised) {
        await signIn.initialize(serverClientId: _googleServerClientId);
        _googleInitialised = true;
      }
      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException(AuthErrorCode.unknown);
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      throw _mapGoogleSignIn(e);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebase(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(AuthErrorCode.unknown);
    }
  }

  /// Signs in anonymously, for "Explore as Guest" browsing.
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebase(e);
    } catch (_) {
      throw const AuthException(AuthErrorCode.unknown);
    }
  }

  /// Signs the user in with an existing email/password account.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebase(e);
    } catch (_) {
      throw const AuthException(AuthErrorCode.unknown);
    }
  }

  /// Creates a new email/password account and signs the user into it.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebase(e);
    } catch (_) {
      throw const AuthException(AuthErrorCode.unknown);
    }
  }

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebase(e);
    } catch (_) {
      throw const AuthException(AuthErrorCode.unknown);
    }
  }

  /// Signs out of both Firebase and Google, so a subsequent Google sign-in
  /// shows the account picker again instead of silently reusing the same
  /// account.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_googleInitialised) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {
      throw const AuthException(AuthErrorCode.unknown);
    }
  }

  AuthException _mapFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException(AuthErrorCode.emailInUse);
      case 'invalid-email':
        return const AuthException(AuthErrorCode.invalidEmail);
      case 'weak-password':
        return const AuthException(AuthErrorCode.weakPassword);
      case 'wrong-password':
        return const AuthException(AuthErrorCode.wrongCredentials);
      // Modern Firebase projects with email-enumeration protection enabled
      // return the generic 'invalid-credential' code for both a wrong
      // password AND an unrecognized email, rather than distinguishing
      // 'wrong-password'/'user-not-found' — so both collapse to the same
      // generic "incorrect email or password" message here.
      case 'invalid-credential':
        return const AuthException(AuthErrorCode.wrongCredentials);
      case 'user-not-found':
        return const AuthException(AuthErrorCode.userNotFound);
      case 'user-disabled':
        return const AuthException(AuthErrorCode.wrongCredentials);
      case 'too-many-requests':
      case 'quota-exceeded':
        return const AuthException(AuthErrorCode.tooManyRequests);
      case 'operation-not-allowed':
        return const AuthException(AuthErrorCode.providerDisabled);
      case 'network-request-failed':
        return const AuthException(AuthErrorCode.network);
      default:
        return const AuthException(AuthErrorCode.unknown);
    }
  }

  AuthException _mapGoogleSignIn(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return const AuthException(AuthErrorCode.cancelled);
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return const AuthException(AuthErrorCode.providerDisabled);
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.uiUnavailable:
      case GoogleSignInExceptionCode.userMismatch:
      case GoogleSignInExceptionCode.unknownError:
        return const AuthException(AuthErrorCode.unknown);
    }
  }
}
