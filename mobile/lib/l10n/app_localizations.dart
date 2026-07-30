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
