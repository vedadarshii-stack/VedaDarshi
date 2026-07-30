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

  @override
  String get birthTitle => 'Your birth details';

  @override
  String get birthSubtitle =>
      'These power your Kundli, horoscope and personalised reports. Accuracy matters ✨';

  @override
  String get birthFullNameLabel => 'Full name';

  @override
  String get birthNameHint => 'Enter your full name';

  @override
  String get birthGenderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get birthDobLabel => 'Date of birth';

  @override
  String get birthDateHint => 'Select date';

  @override
  String get birthTobLabel => 'Time of birth';

  @override
  String get birthTimeHint => 'Select time';

  @override
  String get birthTimeUnknownValue => '12:00 PM (noon)';

  @override
  String get birthPlaceLabel => 'Place of birth';

  @override
  String get birthPlaceHint => 'Search your birth city';

  @override
  String birthGeoDetected(String lat, String lon, String offset, String zone) {
    return '✓ Auto-detected: $lat, $lon · $offset ($zone)';
  }

  @override
  String get birthTimeUnknown => 'I don\'t know my exact birth time';

  @override
  String get birthSave => 'Create My Profile ✨';

  @override
  String get birthFooter => 'You can add family & friends profiles later';

  @override
  String get placeResolveFailed =>
      'Couldn\'t load that location. Please pick another.';

  @override
  String get todaysPanchang => 'TODAY\'S PANCHANG';

  @override
  String get nakshatra => 'Nakshatra';

  @override
  String get yoga => 'Yoga';

  @override
  String get karana => 'Karana';

  @override
  String get fullPanchang => 'Full Panchang';

  @override
  String get todayAtAGlance => 'Today at a glance';

  @override
  String get luckyNumber => 'Lucky Number';

  @override
  String get luckyColor => 'Lucky Color';

  @override
  String get direction => 'Direction';

  @override
  String get todaysPlanet => 'Today\'s Planet';

  @override
  String get moonPhase => 'Moon Phase';

  @override
  String get muhurat => 'Muhurat';

  @override
  String get todaysRemedy => 'TODAY\'S REMEDY';

  @override
  String get todaysMantra => 'TODAY\'S MANTRA';

  @override
  String get festivalOfTheDay => 'FESTIVAL OF THE DAY';

  @override
  String get rituals => 'Rituals';

  @override
  String get explore => 'Explore';

  @override
  String get navKundli => 'Kundli';

  @override
  String get navMatch => 'Match';

  @override
  String get navReports => 'Reports';

  @override
  String get navAskAi => 'Ask AI';

  @override
  String get todaysHoroscope => 'Today\'s Horoscope';

  @override
  String get allSigns => 'All signs';

  @override
  String get wisdomForYou => 'Wisdom for you';

  @override
  String get seeAll => 'See all';

  @override
  String get continueWithRishiAi => 'Continue with Rishi AI';

  @override
  String get continueAction => 'Continue';

  @override
  String get recentReports => 'Recent reports';

  @override
  String get myReports => 'My reports';

  @override
  String get navHome => 'Home';

  @override
  String get navPanchang => 'Panchang';

  @override
  String get navProfile => 'Profile';

  @override
  String get panchangTitle => 'Panchang';

  @override
  String get panchangSunrise => 'Sunrise';

  @override
  String get panchangSunset => 'Sunset';

  @override
  String get panchangMoonrise => 'Moonrise';

  @override
  String get panchangMoonset => 'Moonset';

  @override
  String get panchangTithi => 'Tithi';

  @override
  String get panchangVaar => 'Vaar';

  @override
  String get muhuratToday => 'Muhurat today';

  @override
  String get muhuratShubh => 'SHUBH';

  @override
  String get muhuratAshubh => 'ASHUBH';

  @override
  String get festivalToday => 'FESTIVAL TODAY';

  @override
  String get details => 'Details';

  @override
  String get todaysSpiritualAdvice => 'TODAY\'S SPIRITUAL ADVICE';

  @override
  String get viewAllMuhurat => 'View all muhurat timings';

  @override
  String availableOffline(String time) {
    return 'Available offline · Updated $time';
  }

  @override
  String get horoscopeTitle => 'Horoscope';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get yourSign => 'Your sign';
}
