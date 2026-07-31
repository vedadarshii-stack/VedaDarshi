import 'dart:async';

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

  /// The phone number the user entered is not a valid, dialable number.
  invalidPhone,

  /// The 6-digit code the user entered does not match what was sent.
  invalidOtp,

  /// The OTP session/code expired before it was verified.
  otpExpired,

  /// Too many attempts in a short window (Firebase abuse protection).
  tooManyRequests,

  /// The requested sign-in provider isn't enabled for this Firebase project.
  providerDisabled,

  /// The user backed out of an interactive flow (e.g. closed the Google
  /// account picker) — not a real failure, callers typically ignore this.
  cancelled,

  /// Anything else / not otherwise classified.
  unknown,
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

/// Result of a successful `sendOtp` call — the bookkeeping the UI needs to
/// either show the OTP entry screen or (on Android instant verification)
/// skip straight past it.
class PhoneCodeSent {
  const PhoneCodeSent({
    required this.verificationId,
    required this.resendToken,
    this.autoVerified = false,
  });

  /// Opaque id identifying this OTP session; must be passed back to
  /// [AuthService.verifyOtp].
  final String verificationId;

  /// Token to pass to a follow-up [AuthService.sendOtp] call when the user
  /// taps "Resend", so Firebase can route the retry through the same SMS
  /// session instead of starting a fresh one.
  final int? resendToken;

  /// `true` when Android's instant SMS-retrieval verified the device and
  /// completed sign-in automatically — the caller should skip the OTP entry
  /// screen entirely and proceed straight to the signed-in state.
  final bool autoVerified;
}

/// Thin wrapper around `firebase_auth` (phone/anonymous/credential sign-in)
/// and `google_sign_in` (Google OAuth), giving the rest of the app a single,
/// Firebase-agnostic surface for authentication.
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

  /// Signs the user in with a Google account via an interactive picker.
  ///
  /// On Android, the OAuth web client id is read from
  /// `android/app/google-services.json` (`default_web_client_id`) — no
  /// explicit `serverClientId` is passed to [GoogleSignIn.initialize].
  Future<void> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialised) {
        await signIn.initialize();
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

  /// Starts phone-number verification, sending an SMS OTP to [phoneE164].
  ///
  /// [resendToken] should be the token from a previous [PhoneCodeSent] when
  /// this is a "Resend" retry, so Firebase reuses the same SMS session.
  ///
  /// Completes with a [PhoneCodeSent] once the SMS has been dispatched
  /// (`codeSent`), OR — on Android, when the device can auto-read the SMS —
  /// once [verificationCompleted] has already signed the user in, in which
  /// case [PhoneCodeSent.autoVerified] is `true` and the caller should skip
  /// the OTP entry screen.
  Future<PhoneCodeSent> sendOtp({required String phoneE164, int? resendToken}) {
    final completer = Completer<PhoneCodeSent>();

    void completeError(AuthException exception) {
      if (!completer.isCompleted) completer.completeError(exception);
    }

    unawaited(
      _firebaseAuth
          .verifyPhoneNumber(
            phoneNumber: phoneE164,
            forceResendingToken: resendToken,
            timeout: const Duration(seconds: 60),
            verificationCompleted: (PhoneAuthCredential credential) async {
              // Android instant verification: the device auto-detected and
              // validated the SMS, so sign in immediately without ever
              // showing the OTP entry screen.
              try {
                await _firebaseAuth.signInWithCredential(credential);
                if (!completer.isCompleted) {
                  completer.complete(
                    const PhoneCodeSent(
                      verificationId: '',
                      resendToken: null,
                      autoVerified: true,
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                completeError(_mapFirebase(e));
              } catch (_) {
                completeError(const AuthException(AuthErrorCode.unknown));
              }
            },
            verificationFailed: (FirebaseAuthException e) {
              completeError(_mapFirebase(e));
            },
            codeSent: (String verificationId, int? newResendToken) {
              if (!completer.isCompleted) {
                completer.complete(
                  PhoneCodeSent(
                    verificationId: verificationId,
                    resendToken: newResendToken,
                  ),
                );
              }
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              // If codeSent already resolved the completer, this is just
              // notifying us that auto-retrieval gave up — nothing to do.
              if (!completer.isCompleted) {
                completer.complete(
                  PhoneCodeSent(
                    verificationId: verificationId,
                    resendToken: resendToken,
                  ),
                );
              }
            },
          )
          .catchError((Object e) {
            if (e is FirebaseAuthException) {
              completeError(_mapFirebase(e));
            } else {
              completeError(const AuthException(AuthErrorCode.unknown));
            }
          }),
    );

    return completer.future;
  }

  /// Completes phone sign-in using the OTP the user typed in.
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
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
      case 'invalid-phone-number':
        return const AuthException(AuthErrorCode.invalidPhone);
      case 'invalid-verification-code':
        return const AuthException(AuthErrorCode.invalidOtp);
      case 'session-expired':
      case 'code-expired':
        return const AuthException(AuthErrorCode.otpExpired);
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
