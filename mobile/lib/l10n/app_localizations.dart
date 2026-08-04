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

  /// Heading of the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Your birth details'**
  String get birthTitle;

  /// Subtitle under the heading on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'These power your Kundli, horoscope and personalised reports. Accuracy matters ✨'**
  String get birthSubtitle;

  /// Uppercased section label above the full name field on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get birthFullNameLabel;

  /// Placeholder hint text in the full name field on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get birthNameHint;

  /// Uppercased section label above the gender picker on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get birthGenderLabel;

  /// Label of the male option in the gender picker on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// Label of the female option in the gender picker on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// Label of the third, non-binary option in the gender picker on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// Uppercased section label above the date-of-birth field on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDobLabel;

  /// Placeholder hint shown in the date-of-birth field before a date is picked.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get birthDateHint;

  /// Uppercased section label above the time-of-birth field on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Time of birth'**
  String get birthTobLabel;

  /// Placeholder hint shown in the time-of-birth field before a time is picked.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get birthTimeHint;

  /// Value shown in the time-of-birth field when the user has checked 'I don't know my exact birth time'.
  ///
  /// In en, this message translates to:
  /// **'12:00 PM (noon)'**
  String get birthTimeUnknownValue;

  /// Uppercased section label above the birth-place search field on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get birthPlaceLabel;

  /// Placeholder hint text in the birth-city search field on the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'Search your birth city'**
  String get birthPlaceHint;

  /// Chip shown once a birth city is selected, confirming the auto-detected coordinates, UTC offset and timezone.
  ///
  /// In en, this message translates to:
  /// **'✓ Auto-detected: {lat}, {lon} · {offset} ({zone})'**
  String birthGeoDetected(String lat, String lon, String offset, String zone);

  /// Label of the checkbox that lets the user skip entering an exact birth time.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know my exact birth time'**
  String get birthTimeUnknown;

  /// Label of the CTA button that saves the entered birth details and proceeds into the app.
  ///
  /// In en, this message translates to:
  /// **'Create My Profile ✨'**
  String get birthSave;

  /// Reassurance footnote at the bottom of the Birth Details Setup screen.
  ///
  /// In en, this message translates to:
  /// **'You can add family & friends profiles later'**
  String get birthFooter;

  /// Snackbar shown when resolving a selected place-of-birth suggestion into full coordinates fails (e.g. network error), so the user can pick a different suggestion or retry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load that location. Please pick another.'**
  String get placeResolveFailed;

  /// Uppercased eyebrow label above the date in the Home Dashboard's Panchang hero card.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S PANCHANG'**
  String get todaysPanchang;

  /// Label of the Nakshatra stat chip in the Home Dashboard's Panchang hero card.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get nakshatra;

  /// Label of the Yoga stat chip in the Home Dashboard's Panchang hero card.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// Label of the Karana stat chip in the Home Dashboard's Panchang hero card.
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get karana;

  /// Trailing link label in the Home Dashboard's Panchang hero card, leading to the full Panchang screen.
  ///
  /// In en, this message translates to:
  /// **'Full Panchang'**
  String get fullPanchang;

  /// Section heading on the Home Dashboard above the grid of quick-fact tiles (lucky number, color, direction, etc.).
  ///
  /// In en, this message translates to:
  /// **'Today at a glance'**
  String get todayAtAGlance;

  /// Label of the lucky-number tile in the Home Dashboard's 'Today at a glance' grid.
  ///
  /// In en, this message translates to:
  /// **'Lucky Number'**
  String get luckyNumber;

  /// Label of the lucky-color tile in the Home Dashboard's 'Today at a glance' grid.
  ///
  /// In en, this message translates to:
  /// **'Lucky Color'**
  String get luckyColor;

  /// Label of the favourable-direction tile in the Home Dashboard's 'Today at a glance' grid.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// Label of the ruling-planet tile in the Home Dashboard's 'Today at a glance' grid.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Planet'**
  String get todaysPlanet;

  /// Label of the moon-phase tile in the Home Dashboard's 'Today at a glance' grid.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase'**
  String get moonPhase;

  /// Label of the auspicious-time tile in the Home Dashboard's 'Today at a glance' grid.
  ///
  /// In en, this message translates to:
  /// **'Muhurat'**
  String get muhurat;

  /// Uppercased label above today's remedy text on the Home Dashboard.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S REMEDY'**
  String get todaysRemedy;

  /// Uppercased label above today's mantra text on the Home Dashboard.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S MANTRA'**
  String get todaysMantra;

  /// Uppercased label above the festival name on the Home Dashboard's festival strip.
  ///
  /// In en, this message translates to:
  /// **'FESTIVAL OF THE DAY'**
  String get festivalOfTheDay;

  /// Trailing link label on the Home Dashboard's festival strip, leading to festival ritual details.
  ///
  /// In en, this message translates to:
  /// **'Rituals'**
  String get rituals;

  /// Section heading on the Home Dashboard above the Kundli/Match/Reports/Ask AI shortcut tiles.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Label of the Kundli shortcut tile/nav item (birth chart feature).
  ///
  /// In en, this message translates to:
  /// **'Kundli'**
  String get navKundli;

  /// Label of the Match shortcut tile (Gun Milan compatibility matching feature).
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get navMatch;

  /// Label of the Reports shortcut tile (premium astrology reports).
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Label of the Ask AI shortcut tile/nav item (AI Astrologer chat feature).
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get navAskAi;

  /// Section heading on the Home Dashboard above the daily horoscope teaser card.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Horoscope'**
  String get todaysHoroscope;

  /// Action link next to 'Today's Horoscope' on the Home Dashboard, leading to the full horoscope grid.
  ///
  /// In en, this message translates to:
  /// **'All signs'**
  String get allSigns;

  /// Section heading on the Home Dashboard above the recommended-articles cards.
  ///
  /// In en, this message translates to:
  /// **'Wisdom for you'**
  String get wisdomForYou;

  /// Action link next to 'Wisdom for you' on the Home Dashboard, leading to the full articles list.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Title of the Home Dashboard's card inviting the user to resume their AI Astrologer conversation.
  ///
  /// In en, this message translates to:
  /// **'Continue with Rishi AI'**
  String get continueWithRishiAi;

  /// Label of the CTA pill on the Home Dashboard's Rishi AI card.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Section heading on the Home Dashboard above the recently viewed/generated report cards.
  ///
  /// In en, this message translates to:
  /// **'Recent reports'**
  String get recentReports;

  /// Action link next to 'Recent reports' on the Home Dashboard, leading to the full reports list.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myReports;

  /// Label of the Home tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Label of the Panchang tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get navPanchang;

  /// Label of the Profile tab in the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Heading of the Panchang screen.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get panchangTitle;

  /// Label of the sunrise stat in the Panchang screen's sun/moon card.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get panchangSunrise;

  /// Label of the sunset stat in the Panchang screen's sun/moon card.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get panchangSunset;

  /// Label of the moonrise stat in the Panchang screen's sun/moon card.
  ///
  /// In en, this message translates to:
  /// **'Moonrise'**
  String get panchangMoonrise;

  /// Label of the moonset stat in the Panchang screen's sun/moon card.
  ///
  /// In en, this message translates to:
  /// **'Moonset'**
  String get panchangMoonset;

  /// Label of the Tithi row in the Panchang screen's elements card.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get panchangTithi;

  /// Label of the Vaar (weekday) row in the Panchang screen's elements card.
  ///
  /// In en, this message translates to:
  /// **'Vaar'**
  String get panchangVaar;

  /// Section heading on the Panchang screen above the muhurat grid.
  ///
  /// In en, this message translates to:
  /// **'Muhurat today'**
  String get muhuratToday;

  /// Badge label on an auspicious (shubh) muhurat card.
  ///
  /// In en, this message translates to:
  /// **'SHUBH'**
  String get muhuratShubh;

  /// Badge label on an inauspicious (ashubh) or caution muhurat card.
  ///
  /// In en, this message translates to:
  /// **'ASHUBH'**
  String get muhuratAshubh;

  /// Uppercased label above the festival name on the Panchang screen's festival card.
  ///
  /// In en, this message translates to:
  /// **'FESTIVAL TODAY'**
  String get festivalToday;

  /// Trailing link label on the Panchang screen's festival card, leading to festival details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Uppercased label above the advice text on the Panchang screen's spiritual advice card.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SPIRITUAL ADVICE'**
  String get todaysSpiritualAdvice;

  /// Link at the bottom of the Panchang screen leading to the full list of muhurat timings.
  ///
  /// In en, this message translates to:
  /// **'View all muhurat timings'**
  String get viewAllMuhurat;

  /// Badge at the bottom of the Panchang screen indicating the panchang data is cached for offline use.
  ///
  /// In en, this message translates to:
  /// **'Available offline · Updated {time}'**
  String availableOffline(String time);

  /// Loading-state label shown on the Panchang screen while the Vedika API request is in flight.
  ///
  /// In en, this message translates to:
  /// **'Loading today\'s panchang…'**
  String get panchangLoading;

  /// Title of the Panchang screen's error state when the Vedika API request fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load Panchang'**
  String get panchangLoadErrorTitle;

  /// Message of the Panchang screen's error state when the Vedika API request fails.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get panchangLoadErrorMessage;

  /// Action button on the Panchang screen's error state that re-attempts the failed request.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get panchangRetry;

  /// Small banner shown on the Panchang screen while the app is pointed at Vedika's sandbox, which always returns the same fixed sample location rather than the user's own.
  ///
  /// In en, this message translates to:
  /// **'Sample data — not your location'**
  String get panchangSandboxBanner;

  /// Trailing qualifier on the Tithi row of the Panchang screen's elements card, showing how much of the current tithi remains.
  ///
  /// In en, this message translates to:
  /// **'{percent}% left'**
  String panchangPercentRemaining(int percent);

  /// Trailing qualifier on the Nakshatra row of the Panchang screen's elements card, showing the current nakshatra's pada (quarter).
  ///
  /// In en, this message translates to:
  /// **'Pada {number}'**
  String panchangPada(int number);

  /// Heading of the Horoscope — All Signs screen.
  ///
  /// In en, this message translates to:
  /// **'Horoscope'**
  String get horoscopeTitle;

  /// Label of the Daily period chip on the Horoscope screen.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodDaily;

  /// Label of the Weekly period chip on the Horoscope screen.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// Label of the Monthly period chip on the Horoscope screen.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// Label of the Yearly period chip on the Horoscope screen.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodYearly;

  /// Badge label on the user's own zodiac sign card in the Horoscope — All Signs grid.
  ///
  /// In en, this message translates to:
  /// **'Your sign'**
  String get yourSign;

  /// Heading of the score-bars card on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Today\'s scores'**
  String get todaysScores;

  /// Label of the career score bar on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get scoreCareer;

  /// Label of the love score bar on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get scoreLove;

  /// Label of the health score bar on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get scoreHealth;

  /// Label of the money score bar on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get scoreMoney;

  /// Label of the luck score bar on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Luck'**
  String get scoreLuck;

  /// Uppercased badge label on the lucky-time card of the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'LUCKY TIME'**
  String get luckyTime;

  /// Uppercased badge label on the avoid-time card of the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'AVOID TIME'**
  String get avoidTime;

  /// Title of the Career & Money prediction card on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Career & Money'**
  String get sectionCareerMoney;

  /// Title of the Love & Relationships prediction card on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Love & Relationships'**
  String get sectionLoveRelationships;

  /// Title of the Health & Energy prediction card on the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Health & Energy'**
  String get sectionHealthEnergy;

  /// Copy on the premium teaser card of the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Unlock detailed monthly & yearly predictions'**
  String get premiumUnlockPredictions;

  /// Call-to-action label on the premium teaser card of the Horoscope Detail screen.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumCta;

  /// Banner shown on the Horoscope Detail screen when the app is pointed at Vedika's sandbox, warning that the reading is fixed sample data, not the user's own.
  ///
  /// In en, this message translates to:
  /// **'Sample data — Vedika sandbox mode'**
  String get horoscopeSandboxBanner;

  /// Title of the error state shown on the Horoscope Detail screen when the Vedika API call fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load horoscope'**
  String get horoscopeErrorTitle;

  /// Message of the error state shown on the Horoscope Detail screen when the Vedika API call fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reaching Vedika. Check your connection and try again.'**
  String get horoscopeErrorMessage;

  /// Retry button label on the Horoscope Detail screen's error state.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get horoscopeRetryAction;

  /// Title of the advice card on the Horoscope Detail screen's Weekly period, sourced from Vedika's weekly `advice` field.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Advice'**
  String get weeklyAdviceTitle;

  /// Title of the per-day list card on the Horoscope Detail screen's Weekly period.
  ///
  /// In en, this message translates to:
  /// **'7-Day Outlook'**
  String get weeklyOutlookTitle;

  /// Small badge marking the week's best day in the Horoscope Detail screen's Weekly 7-day outlook.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get weeklyBestDayBadge;

  /// Title of the theme card on the Horoscope Detail screen's Monthly period, sourced from Vedika's monthly `monthlyTheme` field.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Theme'**
  String get monthlyThemeTitle;

  /// Title of the score-bars card on the Horoscope Detail screen's Monthly period (the Daily period's equivalent card uses todaysScores instead).
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Scores'**
  String get monthlyScoresTitle;

  /// Badge next to the scores card title on the Horoscope Detail screen's Monthly period, showing Vedika's monthly overallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall {percent}%'**
  String monthlyOverallRating(int percent);

  /// Title of the key-dates chip card on the Horoscope Detail screen's Monthly period, sourced from Vedika's monthly keyDates field.
  ///
  /// In en, this message translates to:
  /// **'Key Dates This Month'**
  String get monthlyKeyDatesTitle;

  /// Heading of the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundli'**
  String get generateKundliTitle;

  /// Uppercased section label above the profile list on the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'SELECT PROFILE'**
  String get selectProfile;

  /// Label of the dashed placeholder button on the Kundli — New Chart screen for the not-yet-built multi-profile (family/friends) feature.
  ///
  /// In en, this message translates to:
  /// **'Add family or friend'**
  String get addFamilyFriend;

  /// Uppercased section label above the chart-layout cards on the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'CHART STYLE'**
  String get chartStyle;

  /// Title of the North Indian chart-style card on the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'North Indian'**
  String get chartNorthIndian;

  /// Subtitle of the North Indian chart-style card on the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'Diamond layout'**
  String get chartNorthLayout;

  /// Title of the South Indian chart-style card on the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'South Indian'**
  String get chartSouthIndian;

  /// Subtitle of the South Indian chart-style card on the Kundli — New Chart screen.
  ///
  /// In en, this message translates to:
  /// **'Grid layout'**
  String get chartSouthLayout;

  /// Info note on the Kundli — New Chart screen explaining the calculation engine used.
  ///
  /// In en, this message translates to:
  /// **'Calculations use Swiss Ephemeris with Lahiri Ayanamsa'**
  String get kundliCalcNote;

  /// Label of the CTA button on the Kundli — New Chart screen that generates the chart. The 🪔 emoji suffix is appended in code, not stored in this string.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundli'**
  String get generateKundli;

  /// Subtitle prefix on the Kundli Chart screen header, e.g. "Lagna Kundli · North Indian".
  ///
  /// In en, this message translates to:
  /// **'Lagna Kundli'**
  String get lagnaKundli;

  /// Label of the PDF export pill on the Kundli Chart screen header.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// Label of the (selected) Chart section tab on the Kundli Chart screen.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get tabChart;

  /// Label of the Planet Positions section tab on the Kundli Chart screen — inert until the Vedika API is wired up.
  ///
  /// In en, this message translates to:
  /// **'Planet Positions'**
  String get tabPlanetPositions;

  /// Label of the Vimshottari Dasha section tab on the Kundli Chart screen — premium-gated, a 👑 emoji suffix is appended in code.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari Dasha'**
  String get tabDasha;

  /// Label of the Predictions section tab on the Kundli Chart screen — premium-gated, a 👑 emoji suffix is appended in code.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get tabPredictions;

  /// Uppercased eyebrow label above the planet-color legend row on the Kundli Chart screen.
  ///
  /// In en, this message translates to:
  /// **'KEY PLANETS'**
  String get keyPlanets;

  /// Label of the Lagna stat card on the Kundli Chart screen.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get lagna;

  /// Label of the Rashi stat card on the Kundli Chart screen.
  ///
  /// In en, this message translates to:
  /// **'Rashi'**
  String get rashi;

  /// Note shown inside the chart card on the Kundli Chart screen when the South Indian layout toggle is selected — only the North Indian layout is implemented so far.
  ///
  /// In en, this message translates to:
  /// **'South Indian chart layout is coming soon.'**
  String get southChartComingSoon;

  /// Heading of the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'Kundli Matching'**
  String get kundliMatchingTitle;

  /// Explainer copy under the heading on the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'Ashtakoota Gun Milan compares 8 aspects across 36 gunas for marriage compatibility.'**
  String get gunMilanIntro;

  /// Uppercased badge label on the groom profile card on the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'GROOM'**
  String get groom;

  /// Uppercased badge label on the bride profile card on the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'BRIDE'**
  String get bride;

  /// Label of the inline text button on a profile card that lets the user switch to a different saved profile — currently a no-op pending multi-profile support.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Title of the bride card's empty state on the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'Select bride profile…'**
  String get selectBrideProfile;

  /// Subtitle of the bride card's empty state on the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose or add birth details'**
  String get selectBrideHint;

  /// Privacy reassurance note near the bottom of the Gun Milan — Select screen.
  ///
  /// In en, this message translates to:
  /// **'Matching results are private and saved to your account only'**
  String get matchingPrivacyNote;

  /// Label of the CTA button on the Gun Milan — Select screen that runs the Gun Milan calculation. The 💞 emoji suffix is appended in code, not stored in this string.
  ///
  /// In en, this message translates to:
  /// **'Match Kundlis'**
  String get matchKundlis;

  /// Header title of the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'Match Result'**
  String get matchResult;

  /// Small caption under the compatibility ring's total score on the Gun Milan — Result screen, naming the maximum possible score.
  ///
  /// In en, this message translates to:
  /// **'out of {max}'**
  String outOfMax(int max);

  /// Caption under the compatibility ring on the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Compatible'**
  String percentCompatible(int percent);

  /// Section heading above the guna score grid on the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'Ashtakoota breakdown'**
  String get ashtakootaBreakdown;

  /// Legend chip label for the strong-band guna colour on the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'Strong (75%+)'**
  String get bandStrong;

  /// Legend chip label for the moderate-band guna colour on the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'Moderate (40–74%)'**
  String get bandModerate;

  /// Legend chip label for the weak-band guna colour on the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'Weak (<40%)'**
  String get bandWeak;

  /// Name of the Varna guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Varna'**
  String get gunaVarna;

  /// Name of the Vashya guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Vashya'**
  String get gunaVashya;

  /// Name of the Tara guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Tara'**
  String get gunaTara;

  /// Name of the Yoni guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Yoni'**
  String get gunaYoni;

  /// Name of the Graha Maitri guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Graha Maitri'**
  String get gunaGrahaMaitri;

  /// Name of the Gana guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Gana'**
  String get gunaGana;

  /// Name of the Bhakoot guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Bhakoot'**
  String get gunaBhakoot;

  /// Name of the Nadi guna in the Ashtakoota breakdown grid.
  ///
  /// In en, this message translates to:
  /// **'Nadi'**
  String get gunaNadi;

  /// Title of the AI summary card on the Gun Milan — Result screen.
  ///
  /// In en, this message translates to:
  /// **'Rishi AI Summary'**
  String get rishiAiSummary;

  /// Short badge label on the Rishi AI summary card. A ✨ emoji prefix is appended in code, not stored in this string.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiBadge;

  /// Label of the CTA button at the bottom of the Gun Milan — Result screen, leading to the (not yet built) Premium Reports flow.
  ///
  /// In en, this message translates to:
  /// **'Get Detailed Compatibility Report'**
  String get detailedCompatibilityReport;

  /// Footer hint at the bottom of the Gun Milan — Result screen, under the CTA.
  ///
  /// In en, this message translates to:
  /// **'Tap any guna to see what it measures & why it matters'**
  String get tapGunaHint;

  /// Loading message shown on the Gun Milan — Result screen while the match is being calculated.
  ///
  /// In en, this message translates to:
  /// **'Calculating your compatibility…'**
  String get matchLoading;

  /// Error state title on the Gun Milan — Result screen when the match calculation fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t calculate compatibility'**
  String get matchErrorTitle;

  /// Error state message on the Gun Milan — Result screen when the match calculation fails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please check your connection and try again.'**
  String get matchErrorMessage;

  /// Generic retry action label, used on the Gun Milan — Result screen's error state.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Banner shown on the Gun Milan — Result screen while the app is pointed at Vedika's sandbox, which always returns one fixed sample match regardless of the birth details submitted.
  ///
  /// In en, this message translates to:
  /// **'Sample result — not calculated from the entered birth details'**
  String get sandboxResultBanner;

  /// Fallback message shown in place of the guna grid on the Gun Milan — Result screen if the API returns no guna breakdown at all.
  ///
  /// In en, this message translates to:
  /// **'Guna breakdown isn\'t available for this match.'**
  String get matchNoGunaData;

  /// Header title of the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Rishi AI'**
  String get rishiAi;

  /// Header subtitle of the AI Astrologer chat screen, confirming the assistant has the user's birth chart.
  ///
  /// In en, this message translates to:
  /// **'Online · knows your chart'**
  String get onlineKnowsChart;

  /// Header pill on the AI Astrologer chat screen showing how many free questions have been used today.
  ///
  /// In en, this message translates to:
  /// **'{used}/{total} free'**
  String freeQuota(String used, String total);

  /// Centred date divider above today's messages on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Uppercased label above the topic chips on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'ASK ABOUT'**
  String get askAbout;

  /// Label of the Career topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get topicCareer;

  /// Label of the Marriage topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get topicMarriage;

  /// Label of the Health topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get topicHealth;

  /// Label of the Business topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get topicBusiness;

  /// Label of the Finance topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get topicFinance;

  /// Label of the Education topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get topicEducation;

  /// Label of the Travel topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get topicTravel;

  /// Label of the Gemstones topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Gemstones'**
  String get topicGemstones;

  /// Label of the Remedies topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get topicRemedies;

  /// Label of the Numerology topic chip on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Numerology'**
  String get topicNumerology;

  /// Label next to the animated typing-indicator dots on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Rishi is typing…'**
  String get rishiTyping;

  /// Placeholder hint text in the message input field on the AI Astrologer chat screen.
  ///
  /// In en, this message translates to:
  /// **'Ask about your stars…'**
  String get askAboutYourStars;

  /// Label of the upgrade link under the input bar on the AI Astrologer chat screen. A ✨ emoji prefix is appended in code, not stored in this string.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for unlimited questions'**
  String get upgradeUnlimited;

  /// Snackbar shown after sending a chat message, since no AI backend is wired up yet (provider decision still open per CLAUDE.md).
  ///
  /// In en, this message translates to:
  /// **'AI replies will appear here once the AI service is connected.'**
  String get aiNotConnected;

  /// Header title on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Premium Reports'**
  String get premiumReportsTitle;

  /// Bold headline inside the Go Premium banner on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// Subtitle inside the Go Premium banner on the Premium Reports screen, naming the total number of reports in the full catalogue.
  ///
  /// In en, this message translates to:
  /// **'Unlock all {total} reports + unlimited AI questions'**
  String goPremiumSubtitle(String total);

  /// Label of the pill CTA inside the Go Premium banner on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Reading-time meta chip on a report card on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String readMinutes(String minutes);

  /// AI-summary meta chip label on a report card on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// Access badge label on a locked report card on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Access badge label on an unlocked report card on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Footer note under the report list on the Premium Reports screen, naming how many additional reports are not yet listed.
  ///
  /// In en, this message translates to:
  /// **'+ {remaining} more reports · All include PDF download'**
  String moreReportsFooter(String remaining);

  /// Title of the Career report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Career Report'**
  String get reportCareer;

  /// Description of the Career report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Profession, promotions & business timing'**
  String get reportCareerDesc;

  /// Title of the Marriage report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Marriage Report'**
  String get reportMarriage;

  /// Description of the Marriage report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Timing, spouse traits & compatibility'**
  String get reportMarriageDesc;

  /// Title of the Wealth & Finance report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Wealth & Finance'**
  String get reportWealth;

  /// Description of the Wealth & Finance report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Income sources, investments & yogas'**
  String get reportWealthDesc;

  /// Title of the Health report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Health Report'**
  String get reportHealth;

  /// Description of the Health report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Vulnerable periods & preventive remedies'**
  String get reportHealthDesc;

  /// Title of the Sade Sati report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati Report'**
  String get reportSadeSati;

  /// Description of the Sade Sati report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Saturn phases & impact analysis'**
  String get reportSadeSatiDesc;

  /// Title of the Gemstone report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Gemstone Report'**
  String get reportGemstone;

  /// Description of the Gemstone report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Recommended stones & wearing method'**
  String get reportGemstoneDesc;

  /// Title of the Numerology report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Numerology Report'**
  String get reportNumerology;

  /// Description of the Numerology report on the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Life path, destiny & name numbers'**
  String get reportNumerologyDesc;

  /// Label of the tappable 'restore purchase' link in the Subscription Paywall's top bar.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restorePurchase;

  /// Heading of the Subscription Paywall's hero section, naming the premium product.
  ///
  /// In en, this message translates to:
  /// **'Vedadarshi Premium'**
  String get vedadarshiPremium;

  /// Subtitle under the heading in the Subscription Paywall's hero section.
  ///
  /// In en, this message translates to:
  /// **'Unlimited cosmic guidance, one simple plan'**
  String get premiumTagline;

  /// First benefit line item on the Subscription Paywall, naming the total number of reports in the full catalogue.
  ///
  /// In en, this message translates to:
  /// **'All {total} premium reports with PDF export'**
  String benefitReports(String total);

  /// Second benefit line item on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Astrologer questions'**
  String get benefitUnlimitedAi;

  /// Third benefit line item on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Advanced Kundli: dasha, dosha & remedies'**
  String get benefitAdvancedKundli;

  /// Fourth benefit line item on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience across the app'**
  String get benefitAdFree;

  /// Name of the monthly subscription plan card on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// Name of the yearly subscription plan card on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// Name of the lifetime subscription plan card on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get planLifetime;

  /// Subtitle on the monthly plan card on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// Subtitle on the lifetime plan card on the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'one-time payment'**
  String get oneTimePayment;

  /// Label of the main CTA button on the Subscription Paywall, naming the price of the currently selected plan.
  ///
  /// In en, this message translates to:
  /// **'Start Premium — {price}'**
  String startPremium(String price);

  /// Fine-print notice at the bottom of the Subscription Paywall.
  ///
  /// In en, this message translates to:
  /// **'Billed via Google Play · Cancel anytime · Secure with RevenueCat'**
  String get billingFinePrint;

  /// Header title on the Articles screen.
  ///
  /// In en, this message translates to:
  /// **'Wisdom & Articles'**
  String get articlesTitle;

  /// Accessibility label of the bookmark icon button in the Articles screen's title row, leading to the (not yet built) saved-articles list.
  ///
  /// In en, this message translates to:
  /// **'Saved articles'**
  String get savedArticlesLabel;

  /// Label of the 'All' filter chip on the Articles screen, which clears the category filter. Unlike the other category chip labels, this one is UI chrome rather than CMS content.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get articleCategoryAll;

  /// Badge label on the featured article card on the Articles screen, naming the featured article's special tag.
  ///
  /// In en, this message translates to:
  /// **'FEATURED · {tag}'**
  String articleFeaturedBadge(String tag);

  /// Label/accessibility label of the bookmark save action on an article (featured card action pill, list row bookmark icon, and Article Detail header icon).
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get articleSave;

  /// Label/accessibility label of the share action on an article (featured card action pill and Article Detail header icon) — not yet wired to real sharing/deeplinks.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get articleShare;

  /// Label of the listen-to-article (text-to-speech) action on an article (featured card action pill and Article Detail's Listen pill) — not yet wired to a real TTS service.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get articleListen;

  /// Byline under the featured article's title on the Articles screen, naming the author and reading time.
  ///
  /// In en, this message translates to:
  /// **'By {author} · {minutes} min read'**
  String articleByline(String author, String minutes);

  /// Short reading-time meta text on an article list row on the Articles screen.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String articleReadMinutes(String minutes);

  /// Meta line under the author name on the Article Detail screen, naming the publish date and reading time.
  ///
  /// In en, this message translates to:
  /// **'{date} · {minutes} min read'**
  String articleMetaLine(String date, String minutes);

  /// Placeholder text in the empty search field on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'Search articles, reports & more'**
  String get searchHint;

  /// Label of the Articles filter chip on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get searchFilterArticles;

  /// Section label above the recent-searches chip row on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get searchRecentLabel;

  /// Action label that clears the recent-searches list on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearRecent;

  /// Accessibility label of the ✕ icon button that clears the typed text in the Search screen's search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearQuery;

  /// Section label above the trending-searches chip row on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'TRENDING'**
  String get searchTrendingLabel;

  /// Section label above the search results list on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'RESULTS'**
  String get searchResultsLabel;

  /// Empty-state title shown when a search query on the Search screen matches nothing, naming the query.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResultsTitle(String query);

  /// Empty-state hint shown under searchNoResultsTitle on the Search screen.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check the spelling'**
  String get searchNoResultsHint;

  /// Title of the Notifications screen.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Action label on the Notifications screen that marks every notification as read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// Section label above today's notifications on the Notifications screen.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get notificationsToday;

  /// Section label above yesterday's notifications on the Notifications screen.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get notificationsYesterday;

  /// Empty-state message shown on the Notifications screen when there are no notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyState;

  /// Empty-state supporting message under notificationsEmptyState on the Notifications screen.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see daily horoscope, festival and match alerts here.'**
  String get notificationsEmptyMessage;

  /// Title of the prompt shown on the Notifications screen when push notification permission has not been granted.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get notificationsPermissionDeniedTitle;

  /// Supporting message under notificationsPermissionDeniedTitle explaining why to enable notifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to get your daily horoscope, festival alerts and AI replies.'**
  String get notificationsPermissionDeniedMessage;

  /// Action button label that requests notification permission, shown when it hasn't been permanently denied.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsPermissionEnableAction;

  /// Action button label that opens the OS app-settings page, shown when notification permission was permanently denied (a further in-app request would no longer show a system prompt).
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notificationsPermissionOpenSettingsAction;

  /// Title of the birth-profiles menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Birth profiles'**
  String get profileBirthProfiles;

  /// Subtitle of the birth-profiles menu row on the Profile & Settings screen, naming how many saved profiles exist.
  ///
  /// In en, this message translates to:
  /// **'{count} profile'**
  String profileProfileCount(String count);

  /// Uppercased section label above the language chip row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'APP LANGUAGE'**
  String get profileAppLanguageLabel;

  /// Uppercased section label above the activity menu card on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVITY'**
  String get profileMyActivityLabel;

  /// Title of the My Reports menu row on the Profile & Settings screen, leading to the Premium Reports screen.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get profileMyReports;

  /// Title of the Downloaded PDFs menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Downloaded PDFs'**
  String get profileDownloadedPdfs;

  /// Title of the AI Chat History menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'AI Chat History'**
  String get profileAiChatHistory;

  /// Title of the Payment History menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get profilePaymentHistory;

  /// Uppercased section label above the preferences menu card on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get profilePreferencesLabel;

  /// Title of the Appearance (dark mode) menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// Appearance row subtitle on the Profile & Settings screen when the theme mode is set to follow the system/device setting.
  ///
  /// In en, this message translates to:
  /// **'System · follows device'**
  String get profileAppearanceSystem;

  /// Appearance row subtitle on the Profile & Settings screen when the theme mode is explicitly set to light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileAppearanceLight;

  /// Appearance row subtitle on the Profile & Settings screen when the theme mode is explicitly set to dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileAppearanceDark;

  /// Title of the Notifications menu row on the Profile & Settings screen, leading to the Notifications screen.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// Subtitle of the Notifications menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Daily horoscope, festivals'**
  String get profileNotificationsSubtitle;

  /// Title of the Panchang location menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Panchang location'**
  String get profilePanchangLocation;

  /// Title of the Manage subscription menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get profileManageSubscription;

  /// Title of the Privacy & security menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get profilePrivacySecurity;

  /// Title of the Help & support menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileHelpSupport;

  /// Uppercased section label above the rewards menu card on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'REWARDS'**
  String get profileRewardsLabel;

  /// Title of the Refer & Earn menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get profileReferEarn;

  /// Subtitle of the Refer & Earn menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Get 1 month free per referral'**
  String get profileReferEarnSubtitle;

  /// Title of the Invite Friends menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get profileInviteFriends;

  /// Subtitle of the Invite Friends menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Share Vedadarshi'**
  String get profileInviteFriendsSubtitle;

  /// Uppercased section label above the More menu card on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get profileMoreLabel;

  /// Title of the Rate Vedadarshi menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Rate Vedadarshi'**
  String get profileRateApp;

  /// Title of the Send Feedback menu row on the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get profileSendFeedback;

  /// Title of the Restore Purchases menu row on the Profile & Settings screen, leading to the Subscription Paywall screen.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get profileRestorePurchases;

  /// Label of the Log out action at the bottom of the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// Label of the Delete account action at the bottom of the Profile & Settings screen — not yet wired up (must go through a Cloud Function per projects/CLAUDE.md).
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// Title of the confirmation dialog shown before signing out from the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileSignOutConfirmTitle;

  /// Body message of the confirmation dialog shown before signing out from the Profile & Settings screen.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your saved profiles and reports.'**
  String get profileSignOutConfirmMessage;

  /// Label of the confirming action button in the sign-out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileSignOutConfirmAction;

  /// Label of the dismissing action button in the sign-out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// Non-negotiable banner on the Kundli Chart screen shown whenever the app is pointed at Vedika's sandbox, which always returns one fixed sample chart regardless of the birth details sent.
  ///
  /// In en, this message translates to:
  /// **'Sample chart — not calculated from your birth details'**
  String get kundliSandboxBanner;

  /// Title of the error state on the Kundli Chart screen when the Vedika API call fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your chart'**
  String get kundliLoadErrorTitle;

  /// Fallback message of the error state on the Kundli Chart screen, used when the failure has no more specific Vedika-provided message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while fetching your Kundli. Please try again.'**
  String get kundliLoadErrorMessage;

  /// Label of the retry action button on the Kundli Chart screen's error state.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get kundliRetry;

  /// Accessibility label announced while the Kundli Chart screen's shimmer loading placeholder is shown.
  ///
  /// In en, this message translates to:
  /// **'Loading your chart…'**
  String get kundliLoadingChart;

  /// Placeholder shown in a Kundli Chart stat card (Lagna/Rashi/Nakshatra) when the Vedika API response omits that specific value.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get kundliValueUnavailable;

  /// Kundli Chart dosha banner: fallback verdict text for Mangal Dosha when Vedika's own personalized description sentence isn't available, and the all-doshas response says the dosha IS present.
  ///
  /// In en, this message translates to:
  /// **'Mangal Dosha present'**
  String get kundliDoshaMangalPresent;

  /// Kundli Chart dosha banner: fallback verdict text for Mangal Dosha when Vedika's own personalized description sentence isn't available, and the all-doshas response says the dosha is absent.
  ///
  /// In en, this message translates to:
  /// **'No Mangal Dosha detected'**
  String get kundliDoshaMangalAbsent;

  /// Kundli Chart dosha banner verdict for Kaal Sarp Dosha when present and Vedika didn't return a specific type name.
  ///
  /// In en, this message translates to:
  /// **'Kaal Sarp Dosha detected'**
  String get kundliDoshaKaalSarpPresent;

  /// Kundli Chart dosha banner verdict for Kaal Sarp Dosha when present, naming Vedika's specific type (e.g. 'Ananta') — the type name itself is Vedika's own English text, rendered as-is regardless of app locale.
  ///
  /// In en, this message translates to:
  /// **'Kaal Sarp Dosha detected ({type})'**
  String kundliDoshaKaalSarpPresentType(String type);

  /// Kundli Chart dosha banner verdict for Kaal Sarp Dosha when absent.
  ///
  /// In en, this message translates to:
  /// **'No Kaal Sarp Dosha detected'**
  String get kundliDoshaKaalSarpAbsent;

  /// Ayanamsa (sidereal calculation system) label shown atop the Kundli Chart screen's Planet Positions tab.
  ///
  /// In en, this message translates to:
  /// **'Ayanamsa: {name}'**
  String kundliPlanetPositionsAyanamsa(String name);

  /// House-number chip on a planet row in the Kundli Chart screen's Planet Positions tab.
  ///
  /// In en, this message translates to:
  /// **'House {house}'**
  String kundliHouseNumber(int house);

  /// Badge shown on a planet row in the Kundli Chart screen's Planet Positions tab when that planet is retrograde.
  ///
  /// In en, this message translates to:
  /// **'Retrograde'**
  String get kundliRetrograde;

  /// Error-state title on the Kundli Chart screen's Vimshottari Dasha tab.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dasha'**
  String get kundliDashaLoadErrorTitle;

  /// Error-state message on the Kundli Chart screen's Vimshottari Dasha tab.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while fetching your Vimshottari Dasha. Please try again.'**
  String get kundliDashaLoadErrorMessage;

  /// Accessibility label announced while the Kundli Chart screen's Vimshottari Dasha tab is loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your dasha…'**
  String get kundliDashaLoading;

  /// Heading of the 'currently running maha-dasha' card on the Vimshottari Dasha tab.
  ///
  /// In en, this message translates to:
  /// **'Current Mahadasha'**
  String get kundliDashaCurrentTitle;

  /// Heading of the 'balance of the first maha-dasha remaining at birth' card on the Vimshottari Dasha tab — a standard Vimshottari concept, not 'time remaining in the CURRENT dasha now'.
  ///
  /// In en, this message translates to:
  /// **'Dasha Balance at Birth'**
  String get kundliDashaBalanceTitle;

  /// Formatted dasha-balance duration on the Vimshottari Dasha tab.
  ///
  /// In en, this message translates to:
  /// **'{years} years, {months} months, {days} days'**
  String kundliDashaBalanceValue(int years, int months, int days);

  /// Heading over the full list of maha-dasha periods on the Vimshottari Dasha tab.
  ///
  /// In en, this message translates to:
  /// **'Dasha Timeline'**
  String get kundliDashaTimelineTitle;

  /// Small badge marking the currently-running period in the Vimshottari Dasha tab's period list.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get kundliDashaCurrentBadge;

  /// Shown on the Planet Positions tab when the Kundli response loaded successfully but returned an empty planets list.
  ///
  /// In en, this message translates to:
  /// **'Planet positions aren\'t available for this chart yet.'**
  String get kundliPlanetPositionsEmpty;

  /// Shown on the Vimshottari Dasha tab when the response loaded successfully but returned an empty maha_dasha list.
  ///
  /// In en, this message translates to:
  /// **'No dasha periods available yet.'**
  String get kundliDashaTimelineEmpty;

  /// A nakshatra's quarter/pada (1-4), shown next to a planet's nakshatra on the Planet Positions tab.
  ///
  /// In en, this message translates to:
  /// **'Pada {pada}'**
  String kundliNakshatraPada(int pada);

  /// Shown in the Kundli dosha banner when Vedika reports Pitru Dosha present. Its presence also forces the banner off the 'clear' checkmark.
  ///
  /// In en, this message translates to:
  /// **'Pitru Dosha present'**
  String get kundliDoshaPitruPresent;
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
