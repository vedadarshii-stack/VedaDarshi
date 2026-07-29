import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ta'),
    Locale('te'),
  ];

  /// The application name, shown in the OS task switcher, app title bar and splash wordmark. Stays in Latin script across all locales per approved brand design.
  ///
  /// In en, this message translates to:
  /// **'Vedadarshi'**
  String get appName;

  /// Short tagline shown under the wordmark on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Your trusted Vedic companion'**
  String get splashTagline;

  /// Title of the second splash/intro carousel slide, about horoscope/panchang/kundli features.
  ///
  /// In en, this message translates to:
  /// **'Your Stars, Decoded'**
  String get introStarsTitle;

  /// Subtitle of the second splash/intro carousel slide, about horoscope/panchang/kundli features.
  ///
  /// In en, this message translates to:
  /// **'Daily horoscope, Panchang & Kundli — from authentic Vedic calculations'**
  String get introStarsSubtitle;

  /// Title of the third splash/intro carousel slide, about the AI astrologer chat feature.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI Astrologer'**
  String get introAiTitle;

  /// Subtitle of the third splash/intro carousel slide, about the AI astrologer chat feature.
  ///
  /// In en, this message translates to:
  /// **'Personal guidance from your birth chart — in your own language'**
  String get introAiSubtitle;

  /// Label of the CTA button on the final splash/intro carousel slide that proceeds into the app.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Heading of the language select screen.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// Decorative subtitle phrase meaning 'choose your language', always written in that locale's own native script (per approved design, the English locale shows the Hindi/Devanagari phrase).
  ///
  /// In en, this message translates to:
  /// **'अपनी भाषा चुनें'**
  String get languageNativePrompt;

  /// Secondary hint on the language select screen reassuring the user the choice is not final.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings'**
  String get languageSettingsHint;

  /// Label of the CTA button on the language select screen that confirms the choice and proceeds into the app.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Tagline shown under the app name in the Welcome/Login screen's navy hero.
  ///
  /// In en, this message translates to:
  /// **'Panchang · Kundli · Horoscope · AI Astrologer'**
  String get welcomeHeroTagline;

  /// Greeting heading on the Welcome/Login screen. The 🙏 emoji is kept in every locale; only the greeting word is translated.
  ///
  /// In en, this message translates to:
  /// **'Namaste 🙏'**
  String get welcomeGreeting;

  /// Subtitle under the greeting on the Welcome/Login screen, explaining why the user should sign in.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your birth profiles and unlock personalised predictions.'**
  String get welcomeSubtitle;

  /// Placeholder hint text in the phone number input field on the Welcome/Login screen.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneHint;

  /// Label of the CTA button that requests an OTP for the entered phone number.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtp;

  /// Divider label between the phone sign-in section and the Google sign-in button.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// Label of the Google sign-in button on the Welcome/Login screen.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Label of the link that lets the user skip sign-in and browse the app as a guest.
  ///
  /// In en, this message translates to:
  /// **'Explore as Guest'**
  String get exploreAsGuest;

  /// Fine-print notice at the bottom of the Welcome/Login screen referencing the legal terms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms of Service & Privacy Policy'**
  String get termsNotice;

  /// Heading of the OTP verification screen.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// Subtitle of the OTP verification screen, naming the masked phone number the code was sent to.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// Prompt introducing the resend option on the OTP verification screen.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpNoCode;

  /// Countdown shown before the resend option becomes available on the OTP verification screen.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}'**
  String otpResendIn(String seconds);

  /// Tappable label to request a new OTP once the resend countdown has finished.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResend;

  /// Label of the CTA button that submits the entered OTP code.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get otpVerify;

  /// Reassurance notice at the bottom of the OTP verification screen.
  ///
  /// In en, this message translates to:
  /// **'🔒 Your number is kept private and secure'**
  String get otpPrivacy;

  /// Confirmation snackbar shown after successfully requesting a new OTP code.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get otpResent;

  /// Error message shown when an auth operation fails due to no/unstable network connectivity.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get authErrorNetwork;

  /// Error message shown when the entered phone number is not a valid, dialable number.
  ///
  /// In en, this message translates to:
  /// **'That phone number doesn\'t look right. Please check and try again.'**
  String get authErrorInvalidPhone;

  /// Error message shown when the entered OTP code does not match what was sent.
  ///
  /// In en, this message translates to:
  /// **'That code is incorrect. Please try again.'**
  String get authErrorInvalidOtp;

  /// Error message shown when the OTP session/code expired before it was verified.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Please request a new one.'**
  String get authErrorOtpExpired;

  /// Error message shown when too many auth attempts trigger Firebase's abuse protection.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a while before trying again.'**
  String get authErrorTooManyRequests;

  /// Error message shown when the requested sign-in provider isn't enabled for the app.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method isn\'t available yet. Please try another option.'**
  String get authErrorProviderDisabled;

  /// Generic fallback error message shown for any unclassified auth failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
