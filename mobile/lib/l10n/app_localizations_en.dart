// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'Your trusted Vedic companion';

  @override
  String get introStarsTitle => 'Your Stars, Decoded';

  @override
  String get introStarsSubtitle =>
      'Daily horoscope, Panchang & Kundli — from authentic Vedic calculations';

  @override
  String get introAiTitle => 'Ask the AI Astrologer';

  @override
  String get introAiSubtitle =>
      'Personal guidance from your birth chart — in your own language';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageNativePrompt => 'अपनी भाषा चुनें';

  @override
  String get languageSettingsHint => 'You can change this anytime in Settings';

  @override
  String get continueLabel => 'Continue';

  @override
  String get welcomeHeroTagline =>
      'Panchang · Kundli · Horoscope · AI Astrologer';

  @override
  String get welcomeGreeting => 'Namaste 🙏';

  @override
  String get welcomeSubtitle =>
      'Sign in to save your birth profiles and unlock personalised predictions.';

  @override
  String get phoneHint => 'Mobile number';

  @override
  String get getOtp => 'Get OTP';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get exploreAsGuest => 'Explore as Guest';

  @override
  String get termsNotice =>
      'By continuing you agree to our Terms of Service & Privacy Policy';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpNoCode => 'Didn\'t receive the code?';

  @override
  String otpResendIn(String seconds) {
    return 'Resend in $seconds';
  }

  @override
  String get otpResend => 'Resend';

  @override
  String get otpVerify => 'Verify & Continue';

  @override
  String get otpPrivacy => '🔒 Your number is kept private and secure';

  @override
  String get otpResent => 'A new code has been sent.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Please check your network and try again.';

  @override
  String get authErrorInvalidPhone =>
      'That phone number doesn\'t look right. Please check and try again.';

  @override
  String get authErrorInvalidOtp => 'That code is incorrect. Please try again.';

  @override
  String get authErrorOtpExpired =>
      'That code has expired. Please request a new one.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a while before trying again.';

  @override
  String get authErrorProviderDisabled =>
      'This sign-in method isn\'t available yet. Please try another option.';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';
}
