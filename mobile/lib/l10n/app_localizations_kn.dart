// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'ನಿಮ್ಮ ವಿಶ್ವಾಸಾರ್ಹ ವೇದ ಸಂಗಾತಿ';

  @override
  String get introStarsTitle => 'ನಿಮ್ಮ ನಕ್ಷತ್ರಗಳು, ಸರಳವಾಗಿ';

  @override
  String get introStarsSubtitle =>
      'ದೈನಂದಿನ ರಾಶಿಫಲ, ಪಂಚಾಂಗ ಮತ್ತು ಕುಂಡಲಿ — ಪ್ರಾಮಾಣಿಕ ವೇದ ಗಣನೆಗಳಿಂದ';

  @override
  String get introAiTitle => 'AI ಜ್ಯೋತಿಷಿಯನ್ನು ಕೇಳಿ';

  @override
  String get introAiSubtitle =>
      'ನಿಮ್ಮ ಕುಂಡಲಿಯ ಆಧಾರದಲ್ಲಿ ವೈಯಕ್ತಿಕ ಮಾರ್ಗದರ್ಶನ — ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ';

  @override
  String get getStarted => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get languageTitle => 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆರಿಸಿ';

  @override
  String get languageNativePrompt => 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆರಿಸಿ';

  @override
  String get languageSettingsHint =>
      'ನೀವು ಇದನ್ನು ಯಾವಾಗ ಬೇಕಾದರೂ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಬದಲಾಯಿಸಬಹುದು';

  @override
  String get continueLabel => 'ಮುಂದುವರಿಸಿ';

  @override
  String get welcomeHeroTagline => 'ಪಂಚಾಂಗ · ಕುಂಡಲಿ · ರಾಶಿಫಲ · AI ಜ್ಯೋತಿಷಿ';

  @override
  String get welcomeGreeting => 'ನಮಸ್ತೆ 🙏';

  @override
  String get welcomeSubtitle =>
      'ನಿಮ್ಮ ಜನ್ಮ ವಿವರಗಳನ್ನು ಉಳಿಸಲು ಮತ್ತು ವೈಯಕ್ತಿಕ ಭವಿಷ್ಯವಾಣಿಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get phoneHint => 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get getOtp => 'OTP ಪಡೆಯಿರಿ';

  @override
  String get orContinueWith => 'ಅಥವಾ ಇದರೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get continueWithGoogle => 'Google ನೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get exploreAsGuest => 'ಅತಿಥಿಯಾಗಿ ಅನ್ವೇಷಿಸಿ';

  @override
  String get termsNotice =>
      'ಮುಂದುವರಿಸುವ ಮೂಲಕ ನೀವು ನಮ್ಮ ಸೇವಾ ನಿಯಮಗಳು ಮತ್ತು ಗೌಪ್ಯತಾ ನೀತಿಗೆ ಒಪ್ಪುತ್ತೀರಿ';

  @override
  String get otpTitle => 'ನಿಮ್ಮ ಸಂಖ್ಯೆಯನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String otpSubtitle(String phone) {
    return '$phoneಗೆ ಕಳುಹಿಸಲಾದ 6-ಅಂಕಿಯ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ';
  }

  @override
  String get otpNoCode => 'ಕೋಡ್ ಸಿಗಲಿಲ್ಲವೇ?';

  @override
  String otpResendIn(String seconds) {
    return '$secondsರಲ್ಲಿ ಮರುಕಳುಹಿಸಿ';
  }

  @override
  String get otpResend => 'ಮರುಕಳುಹಿಸಿ';

  @override
  String get otpVerify => 'ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮುಂದುವರಿಸಿ';

  @override
  String get otpPrivacy =>
      '🔒 ನಿಮ್ಮ ಸಂಖ್ಯೆಯನ್ನು ಖಾಸಗಿ ಮತ್ತು ಸುರಕ್ಷಿತವಾಗಿ ಇರಿಸಲಾಗುತ್ತದೆ';

  @override
  String get otpResent => 'ಹೊಸ ಕೋಡ್ ಕಳುಹಿಸಲಾಗಿದೆ.';

  @override
  String get authErrorNetwork =>
      'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ನೆಟ್‌ವರ್ಕ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get authErrorInvalidPhone =>
      'ಆ ಫೋನ್ ಸಂಖ್ಯೆ ಸರಿಯಾಗಿ ಕಾಣುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get authErrorInvalidOtp =>
      'ಆ ಕೋಡ್ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get authErrorOtpExpired =>
      'ಆ ಕೋಡ್ ಅವಧಿ ಮುಗಿದಿದೆ. ದಯವಿಟ್ಟು ಹೊಸದನ್ನು ವಿನಂತಿಸಿ.';

  @override
  String get authErrorTooManyRequests =>
      'ಹಲವು ಪ್ರಯತ್ನಗಳು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸುವ ಮೊದಲು ಸ್ವಲ್ಪ ಸಮಯ ಕಾಯಿರಿ.';

  @override
  String get authErrorProviderDisabled =>
      'ಈ ಸೈನ್-ಇನ್ ವಿಧಾನ ಇನ್ನೂ ಲಭ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ಬೇರೆ ಆಯ್ಕೆಯನ್ನು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get authErrorUnknown => 'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get birthTitle => 'ನಿಮ್ಮ ಜನ್ಮ ವಿವರಗಳು';

  @override
  String get birthSubtitle =>
      'ಇವು ನಿಮ್ಮ ಕುಂಡಲಿ, ರಾಶಿಫಲ ಮತ್ತು ವೈಯಕ್ತಿಕ ವರದಿಗಳನ್ನು ಬಲಪಡಿಸುತ್ತವೆ. ನಿಖರತೆ ಮುಖ್ಯ ✨';

  @override
  String get birthFullNameLabel => 'ಪೂರ್ಣ ಹೆಸರು';

  @override
  String get birthNameHint => 'ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರನ್ನು ನಮೂದಿಸಿ';

  @override
  String get birthGenderLabel => 'ಲಿಂಗ';

  @override
  String get genderMale => 'ಪುರುಷ';

  @override
  String get genderFemale => 'ಸ್ತ್ರೀ';

  @override
  String get genderOther => 'ಇತರೆ';

  @override
  String get birthDobLabel => 'ಜನ್ಮ ದಿನಾಂಕ';

  @override
  String get birthDateHint => 'ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get birthTobLabel => 'ಜನ್ಮ ಸಮಯ';

  @override
  String get birthTimeHint => 'ಸಮಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get birthTimeUnknownValue => 'ಮಧ್ಯಾಹ್ನ 12:00 (ನೂನ್)';

  @override
  String get birthPlaceLabel => 'ಜನ್ಮ ಸ್ಥಳ';

  @override
  String get birthPlaceHint => 'ನಿಮ್ಮ ಜನ್ಮ ನಗರವನ್ನು ಹುಡುಕಿ';

  @override
  String birthGeoDetected(String lat, String lon, String offset, String zone) {
    return '✓ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಪತ್ತೆಯಾಗಿದೆ: $lat, $lon · $offset ($zone)';
  }

  @override
  String get birthTimeUnknown => 'ನನ್ನ ನಿಖರವಾದ ಜನ್ಮ ಸಮಯ ನನಗೆ ತಿಳಿದಿಲ್ಲ';

  @override
  String get birthSave => 'ನನ್ನ ಪ್ರೊಫೈಲ್ ರಚಿಸಿ ✨';

  @override
  String get birthFooter =>
      'ನೀವು ನಂತರ ಕುಟುಂಬ ಮತ್ತು ಸ್ನೇಹಿತರ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಸೇರಿಸಬಹುದು';

  @override
  String get placeResolveFailed =>
      'ಆ ಸ್ಥಳವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಇನ್ನೊಂದನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get todaysPanchang => 'ಇಂದಿನ ಪಂಚಾಂಗ';

  @override
  String get nakshatra => 'ನಕ್ಷತ್ರ';

  @override
  String get yoga => 'ಯೋಗ';

  @override
  String get karana => 'ಕರಣ';

  @override
  String get fullPanchang => 'ಪೂರ್ಣ ಪಂಚಾಂಗ';

  @override
  String get todayAtAGlance => 'ಇಂದು ಒಂದು ನೋಟದಲ್ಲಿ';

  @override
  String get luckyNumber => 'ಅದೃಷ್ಟ ಸಂಖ್ಯೆ';

  @override
  String get luckyColor => 'ಅದೃಷ್ಟ ಬಣ್ಣ';

  @override
  String get direction => 'ದಿಕ್ಕು';

  @override
  String get todaysPlanet => 'ಇಂದಿನ ಗ್ರಹ';

  @override
  String get moonPhase => 'ಚಂದ್ರ ಕಲೆ';

  @override
  String get muhurat => 'ಮುಹೂರ್ತ';

  @override
  String get todaysRemedy => 'ಇಂದಿನ ಪರಿಹಾರ';

  @override
  String get todaysMantra => 'ಇಂದಿನ ಮಂತ್ರ';

  @override
  String get festivalOfTheDay => 'ಇಂದಿನ ಹಬ್ಬ';

  @override
  String get rituals => 'ಆಚರಣೆಗಳು';

  @override
  String get explore => 'ಅನ್ವೇಷಿಸಿ';

  @override
  String get navKundli => 'ಕುಂಡಲಿ';

  @override
  String get navMatch => 'ಹೊಂದಾಣಿಕೆ';

  @override
  String get navReports => 'ವರದಿಗಳು';

  @override
  String get navAskAi => 'AI ಅನ್ನು ಕೇಳಿ';

  @override
  String get todaysHoroscope => 'ಇಂದಿನ ರಾಶಿಫಲ';

  @override
  String get allSigns => 'ಎಲ್ಲಾ ರಾಶಿಗಳು';

  @override
  String get wisdomForYou => 'ನಿಮಗಾಗಿ ಜ್ಞಾನ';

  @override
  String get seeAll => 'ಎಲ್ಲಾ ನೋಡಿ';

  @override
  String get continueWithRishiAi => 'ಋಷಿ AI ಜೊತೆ ಮುಂದುವರಿಸಿ';

  @override
  String get continueAction => 'ಮುಂದುವರಿಸಿ';

  @override
  String get recentReports => 'ಇತ್ತೀಚಿನ ವರದಿಗಳು';

  @override
  String get myReports => 'ನನ್ನ ವರದಿಗಳು';

  @override
  String get navHome => 'ಹೋಮ್';

  @override
  String get navPanchang => 'ಪಂಚಾಂಗ';

  @override
  String get navProfile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get panchangTitle => 'ಪಂಚಾಂಗ';

  @override
  String get panchangSunrise => 'ಸೂರ್ಯೋದಯ';

  @override
  String get panchangSunset => 'ಸೂರ್ಯಾಸ್ತ';

  @override
  String get panchangMoonrise => 'ಚಂದ್ರೋದಯ';

  @override
  String get panchangMoonset => 'ಚಂದ್ರಾಸ್ತ';

  @override
  String get panchangTithi => 'ತಿಥಿ';

  @override
  String get panchangVaar => 'ವಾರ';

  @override
  String get muhuratToday => 'ಇಂದಿನ ಮುಹೂರ್ತ';

  @override
  String get muhuratShubh => 'ಶುಭ';

  @override
  String get muhuratAshubh => 'ಅಶುಭ';

  @override
  String get festivalToday => 'ಇಂದಿನ ಹಬ್ಬ';

  @override
  String get details => 'ವಿವರಗಳು';

  @override
  String get todaysSpiritualAdvice => 'ಇಂದಿನ ಆಧ್ಯಾತ್ಮಿಕ ಸಲಹೆ';

  @override
  String get viewAllMuhurat => 'ಎಲ್ಲಾ ಮುಹೂರ್ತ ಸಮಯಗಳನ್ನು ವೀಕ್ಷಿಸಿ';

  @override
  String availableOffline(String time) {
    return 'ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಲಭ್ಯವಿದೆ · ನವೀಕರಿಸಲಾಗಿದೆ $time';
  }

  @override
  String get panchangLoading => 'ಇಂದಿನ ಪಂಚಾಂಗ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get panchangLoadErrorTitle => 'ಪಂಚಾಂಗ ಲೋಡ್ ಆಗಲಿಲ್ಲ';

  @override
  String get panchangLoadErrorMessage =>
      'ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get panchangRetry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get panchangSandboxBanner => 'ಮಾದರಿ ಡೇಟಾ — ನಿಮ್ಮ ಸ್ಥಳ ಅಲ್ಲ';

  @override
  String panchangPercentRemaining(int percent) {
    return '$percent% ಉಳಿದಿದೆ';
  }

  @override
  String panchangPada(int number) {
    return 'ಪಾದ $number';
  }

  @override
  String get horoscopeTitle => 'ರಾಶಿಫಲ';

  @override
  String get periodDaily => 'ದೈನಂದಿನ';

  @override
  String get periodWeekly => 'ಸಾಪ್ತಾಹಿಕ';

  @override
  String get periodMonthly => 'ಮಾಸಿಕ';

  @override
  String get periodYearly => 'ವಾರ್ಷಿಕ';

  @override
  String get yourSign => 'ನಿಮ್ಮ ರಾಶಿ';

  @override
  String get todaysScores => 'ಇಂದಿನ ಸ್ಕೋರ್‌ಗಳು';

  @override
  String get scoreCareer => 'ವೃತ್ತಿ';

  @override
  String get scoreLove => 'ಪ್ರೀತಿ';

  @override
  String get scoreHealth => 'ಆರೋಗ್ಯ';

  @override
  String get scoreMoney => 'ಹಣ';

  @override
  String get scoreLuck => 'ಅದೃಷ್ಟ';

  @override
  String get luckyTime => 'ಶುಭ ಸಮಯ';

  @override
  String get avoidTime => 'ಅಶುಭ ಸಮಯ';

  @override
  String get sectionCareerMoney => 'ವೃತ್ತಿ & ಹಣ';

  @override
  String get sectionLoveRelationships => 'ಪ್ರೀತಿ & ಸಂಬಂಧಗಳು';

  @override
  String get sectionHealthEnergy => 'ಆರೋಗ್ಯ & ಶಕ್ತಿ';

  @override
  String get premiumUnlockPredictions =>
      'ವಿವರವಾದ ಮಾಸಿಕ ಮತ್ತು ವಾರ್ಷಿಕ ಭವಿಷ್ಯವಾಣಿಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get premiumCta => 'ಪ್ರೀಮಿಯಂ';

  @override
  String get horoscopeSandboxBanner =>
      'ಮಾದರಿ ಡೇಟಾ — ವೇದಿಕಾ ಸ್ಯಾಂಡ್‌ಬಾಕ್ಸ್ ಮೋಡ್';

  @override
  String get horoscopeErrorTitle => 'ರಾಶಿಫಲ ಲೋಡ್ ಆಗಲಿಲ್ಲ';

  @override
  String get horoscopeErrorMessage =>
      'ವೇದಿಕಾವನ್ನು ತಲುಪುವಲ್ಲಿ ಸಮಸ್ಯೆ ಉಂಟಾಯಿತು. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get horoscopeRetryAction => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get weeklyAdviceTitle => 'ಈ ವಾರದ ಸಲಹೆ';

  @override
  String get weeklyOutlookTitle => '7-ದಿನಗಳ ಮುನ್ನೋಟ';

  @override
  String get weeklyBestDayBadge => 'ಅತ್ಯುತ್ತಮ ದಿನ';

  @override
  String get monthlyThemeTitle => 'ಈ ತಿಂಗಳ ವಿಷಯ';

  @override
  String get monthlyScoresTitle => 'ಈ ತಿಂಗಳ ಸ್ಕೋರ್‌ಗಳು';

  @override
  String monthlyOverallRating(int percent) {
    return 'ಒಟ್ಟು $percent%';
  }

  @override
  String get monthlyKeyDatesTitle => 'ಈ ತಿಂಗಳ ಪ್ರಮುಖ ದಿನಾಂಕಗಳು';

  @override
  String get generateKundliTitle => 'ಕುಂಡಲಿ ರಚಿಸಿ';

  @override
  String get selectProfile => 'ಪ್ರೊಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get addFamilyFriend => 'ಕುಟುಂಬ ಅಥವಾ ಸ್ನೇಹಿತರನ್ನು ಸೇರಿಸಿ';

  @override
  String get chartStyle => 'ಚಾರ್ಟ್ ಶೈಲಿ';

  @override
  String get chartNorthIndian => 'ಉತ್ತರ ಭಾರತೀಯ';

  @override
  String get chartNorthLayout => 'ಡೈಮಂಡ್ ವಿನ್ಯಾಸ';

  @override
  String get chartSouthIndian => 'ದಕ್ಷಿಣ ಭಾರತೀಯ';

  @override
  String get chartSouthLayout => 'ಗ್ರಿಡ್ ವಿನ್ಯಾಸ';

  @override
  String get kundliCalcNote =>
      'ಲೆಕ್ಕಾಚಾರಗಳು ಸ್ವಿಸ್ ಎಫೆಮೆರಿಸ್ ಮತ್ತು ಲಾಹಿರಿ ಅಯನಾಂಶವನ್ನು ಬಳಸುತ್ತವೆ';

  @override
  String get generateKundli => 'ಕುಂಡಲಿ ರಚಿಸಿ';

  @override
  String get lagnaKundli => 'ಲಗ್ನ ಕುಂಡಲಿ';

  @override
  String get pdf => 'PDF';

  @override
  String get tabChart => 'ಚಾರ್ಟ್';

  @override
  String get tabPlanetPositions => 'ಗ್ರಹ ಸ್ಥಾನಗಳು';

  @override
  String get tabDasha => 'ವಿಂಶೋತ್ತರಿ ದಶಾ';

  @override
  String get tabPredictions => 'ಭವಿಷ್ಯವಾಣಿಗಳು';

  @override
  String get keyPlanets => 'ಪ್ರಮುಖ ಗ್ರಹಗಳು';

  @override
  String get lagna => 'ಲಗ್ನ';

  @override
  String get rashi => 'ರಾಶಿ';

  @override
  String get southChartComingSoon =>
      'ದಕ್ಷಿಣ ಭಾರತೀಯ ಚಾರ್ಟ್ ವಿನ್ಯಾಸ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ.';

  @override
  String get kundliMatchingTitle => 'ಕುಂಡಲಿ ಮ್ಯಾಚಿಂಗ್';

  @override
  String get gunMilanIntro =>
      'ಅಷ್ಟಕೂಟ ಗುಣ ಮಿಲನ್ ವಿವಾಹ ಹೊಂದಾಣಿಕೆಗಾಗಿ 36 ಗುಣಗಳಲ್ಲಿ 8 ಅಂಶಗಳನ್ನು ಹೋಲಿಸುತ್ತದೆ.';

  @override
  String get groom => 'ವರ';

  @override
  String get bride => 'ವಧು';

  @override
  String get change => 'ಬದಲಿಸಿ';

  @override
  String get selectBrideProfile => 'ವಧುವಿನ ಪ್ರೊಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ…';

  @override
  String get selectBrideHint =>
      'ಆಯ್ಕೆ ಮಾಡಲು ಅಥವಾ ಜನನ ವಿವರಗಳನ್ನು ಸೇರಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get matchingPrivacyNote =>
      'ಹೊಂದಾಣಿಕೆ ಫಲಿತಾಂಶಗಳು ಖಾಸಗಿಯಾಗಿದ್ದು ನಿಮ್ಮ ಖಾತೆಯಲ್ಲಿ ಮಾತ್ರ ಉಳಿಸಲಾಗುತ್ತದೆ';

  @override
  String get matchKundlis => 'ಕುಂಡಲಿಗಳನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get matchResult => 'ಹೊಂದಾಣಿಕೆ ಫಲಿತಾಂಶ';

  @override
  String outOfMax(int max) {
    return '$max ರಲ್ಲಿ';
  }

  @override
  String percentCompatible(int percent) {
    return '$percent% ಹೊಂದಾಣಿಕೆ';
  }

  @override
  String get ashtakootaBreakdown => 'ಅಷ್ಟಕೂಟ ವಿವರಣೆ';

  @override
  String get bandStrong => 'ಬಲಶಾಲಿ (75%+)';

  @override
  String get bandModerate => 'ಮಧ್ಯಮ (40–74%)';

  @override
  String get bandWeak => 'ದುರ್ಬಲ (<40%)';

  @override
  String get gunaVarna => 'ವರ್ಣ';

  @override
  String get gunaVashya => 'ವಶ್ಯ';

  @override
  String get gunaTara => 'ತಾರಾ';

  @override
  String get gunaYoni => 'ಯೋನಿ';

  @override
  String get gunaGrahaMaitri => 'ಗ್ರಹ ಮೈತ್ರಿ';

  @override
  String get gunaGana => 'ಗಣ';

  @override
  String get gunaBhakoot => 'ಭಕೂಟ';

  @override
  String get gunaNadi => 'ನಾಡಿ';

  @override
  String get rishiAiSummary => 'ಋಷಿ AI ಸಾರಾಂಶ';

  @override
  String get aiBadge => 'AI';

  @override
  String get detailedCompatibilityReport => 'ವಿವರವಾದ ಹೊಂದಾಣಿಕೆ ವರದಿ ಪಡೆಯಿರಿ';

  @override
  String get tapGunaHint =>
      'ಪ್ರತಿ ಗುಣ ಏನನ್ನು ಅಳೆಯುತ್ತದೆ ಮತ್ತು ಏಕೆ ಮುಖ್ಯ ಎಂದು ನೋಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get matchLoading => 'ನಿಮ್ಮ ಹೊಂದಾಣಿಕೆಯನ್ನು ಲೆಕ್ಕಾಚಾರ ಮಾಡಲಾಗುತ್ತಿದೆ…';

  @override
  String get matchErrorTitle => 'ಹೊಂದಾಣಿಕೆಯನ್ನು ಲೆಕ್ಕಾಚಾರ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get matchErrorMessage =>
      'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get sandboxResultBanner =>
      'ಮಾದರಿ ಫಲಿತಾಂಶ — ನಮೂದಿಸಿದ ಜನ್ಮ ವಿವರಗಳಿಂದ ಲೆಕ್ಕಹಾಕಲಾಗಿಲ್ಲ';

  @override
  String get matchNoGunaData => 'ಈ ಹೊಂದಾಣಿಕೆಗೆ ಗುಣ ವಿವರಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get rishiAi => 'ಋಷಿ AI';

  @override
  String get onlineKnowsChart => 'ಆನ್‌ಲೈನ್ · ನಿಮ್ಮ ಜಾತಕ ತಿಳಿದಿದೆ';

  @override
  String freeQuota(String used, String total) {
    return '$used/$total ಉಚಿತ';
  }

  @override
  String get today => 'ಇಂದು';

  @override
  String get askAbout => 'ಇವುಗಳ ಬಗ್ಗೆ ಕೇಳಿ';

  @override
  String get topicCareer => 'ವೃತ್ತಿ';

  @override
  String get topicMarriage => 'ವಿವಾಹ';

  @override
  String get topicHealth => 'ಆರೋಗ್ಯ';

  @override
  String get topicBusiness => 'ವ್ಯಾಪಾರ';

  @override
  String get topicFinance => 'ಹಣಕಾಸು';

  @override
  String get topicEducation => 'ಶಿಕ್ಷಣ';

  @override
  String get topicTravel => 'ಪ್ರಯಾಣ';

  @override
  String get topicGemstones => 'ರತ್ನಗಳು';

  @override
  String get topicRemedies => 'ಪರಿಹಾರಗಳು';

  @override
  String get topicNumerology => 'ಅಂಕ ಶಾಸ್ತ್ರ';

  @override
  String get rishiTyping => 'ಋಷಿ ಟೈಪ್ ಮಾಡುತ್ತಿದ್ದಾರೆ…';

  @override
  String get askAboutYourStars => 'ನಿಮ್ಮ ನಕ್ಷತ್ರಗಳ ಬಗ್ಗೆ ಕೇಳಿ…';

  @override
  String get upgradeUnlimited => 'ಅಪರಿಮಿತ ಪ್ರಶ್ನೆಗಳಿಗಾಗಿ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get aiNotConnected =>
      'AI ಸೇವೆ ಸಂಪರ್ಕಗೊಂಡ ನಂತರ ಉತ್ತರಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ.';

  @override
  String get premiumReportsTitle => 'ಪ್ರೀಮಿಯಂ ವರದಿಗಳು';

  @override
  String get goPremium => 'ಪ್ರೀಮಿಯಂ ಪಡೆಯಿರಿ';

  @override
  String goPremiumSubtitle(String total) {
    return 'ಎಲ್ಲಾ $total ವರದಿಗಳು + ಅಪರಿಮಿತ AI ಪ್ರಶ್ನೆಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ';
  }

  @override
  String get upgrade => 'ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String readMinutes(String minutes) {
    return '$minutes ನಿಮಿ';
  }

  @override
  String get aiSummary => 'AI ಸಾರಾಂಶ';

  @override
  String get premium => 'ಪ್ರೀಮಿಯಂ';

  @override
  String get free => 'ಉಚಿತ';

  @override
  String moreReportsFooter(String remaining) {
    return '+ $remaining ಹೆಚ್ಚಿನ ವರದಿಗಳು · ಎಲ್ಲದರಲ್ಲೂ PDF ಡೌನ್‌ಲೋಡ್ ಸೇರಿದೆ';
  }

  @override
  String get reportCareer => 'ವೃತ್ತಿ ವರದಿ';

  @override
  String get reportCareerDesc => 'ವೃತ್ತಿ, ಬಡ್ತಿಗಳು & ವ್ಯಾಪಾರ ಸಮಯ';

  @override
  String get reportMarriage => 'ವಿವಾಹ ವರದಿ';

  @override
  String get reportMarriageDesc => 'ಸಮಯ, ಸಂಗಾತಿಯ ಗುಣಗಳು & ಹೊಂದಾಣಿಕೆ';

  @override
  String get reportWealth => 'ಸಂಪತ್ತು & ಹಣಕಾಸು';

  @override
  String get reportWealthDesc => 'ಆದಾಯ ಮೂಲಗಳು, ಹೂಡಿಕೆಗಳು & ಯೋಗಗಳು';

  @override
  String get reportHealth => 'ಆರೋಗ್ಯ ವರದಿ';

  @override
  String get reportHealthDesc => 'ದುರ್ಬಲ ಅವಧಿಗಳು & ತಡೆಗಟ್ಟುವ ಪರಿಹಾರಗಳು';

  @override
  String get reportSadeSati => 'ಸಾಡೇ ಸಾತಿ ವರದಿ';

  @override
  String get reportSadeSatiDesc => 'ಶನಿ ಹಂತಗಳು & ಪ್ರಭಾವ ವಿಶ್ಲೇಷಣೆ';

  @override
  String get reportGemstone => 'ರತ್ನ ವರದಿ';

  @override
  String get reportGemstoneDesc => 'ಶಿಫಾರಸು ಮಾಡಿದ ಕಲ್ಲುಗಳು & ಧರಿಸುವ ವಿಧಾನ';

  @override
  String get reportNumerology => 'ಅಂಕಶಾಸ್ತ್ರ ವರದಿ';

  @override
  String get reportNumerologyDesc => 'ಜೀವನ ಮಾರ್ಗ, ಹಣೆಬರಹ & ಹೆಸರು ಅಂಕೆಗಳು';

  @override
  String get restorePurchase => 'ಖರೀದಿಯನ್ನು ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get vedadarshiPremium => 'Vedadarshi ಪ್ರೀಮಿಯಂ';

  @override
  String get premiumTagline => 'ಅಪರಿಮಿತ ವಿಶ್ವ ಮಾರ್ಗದರ್ಶನ, ಒಂದೇ ಸರಳ ಯೋಜನೆ';

  @override
  String benefitReports(String total) {
    return 'PDF ರಫ್ತಿನೊಂದಿಗೆ ಎಲ್ಲಾ $total ಪ್ರೀಮಿಯಂ ವರದಿಗಳು';
  }

  @override
  String get benefitUnlimitedAi => 'ಅಪರಿಮಿತ AI ಜ್ಯೋತಿಷಿ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get benefitAdvancedKundli =>
      'ಸುಧಾರಿತ ಕುಂಡಲಿ: ದಶಾ, ದೋಷ ಮತ್ತು ಪರಿಹಾರಗಳು';

  @override
  String get benefitAdFree => 'ಆ್ಯಪ್ ಉದ್ದಕ್ಕೂ ಜಾಹೀರಾತು-ಮುಕ್ತ ಅನುಭವ';

  @override
  String get planMonthly => 'ಮಾಸಿಕ';

  @override
  String get planYearly => 'ವಾರ್ಷಿಕ';

  @override
  String get planLifetime => 'ಜೀವಮಾನ';

  @override
  String get perMonth => 'ಪ್ರತಿ ತಿಂಗಳು';

  @override
  String get oneTimePayment => 'ಒಂದು ಬಾರಿ ಪಾವತಿ';

  @override
  String startPremium(String price) {
    return 'ಪ್ರೀಮಿಯಂ ಪ್ರಾರಂಭಿಸಿ — $price';
  }

  @override
  String get billingFinePrint =>
      'Google Play ಮೂಲಕ ಬಿಲ್ ಮಾಡಲಾಗಿದೆ · ಯಾವಾಗ ಬೇಕಾದರೂ ರದ್ದುಮಾಡಿ · RevenueCat ನೊಂದಿಗೆ ಸುರಕ್ಷಿತ';

  @override
  String get articlesTitle => 'ಜ್ಞಾನ ಮತ್ತು ಲೇಖನಗಳು';

  @override
  String get savedArticlesLabel => 'ಉಳಿಸಿದ ಲೇಖನಗಳು';

  @override
  String get articleCategoryAll => 'ಎಲ್ಲಾ';

  @override
  String articleFeaturedBadge(String tag) {
    return 'ವಿಶೇಷ · $tag';
  }

  @override
  String get articleSave => 'ಉಳಿಸಿ';

  @override
  String get articleShare => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get articleListen => 'ಆಲಿಸಿ';

  @override
  String articleByline(String author, String minutes) {
    return '$author ಬರೆದಿದ್ದಾರೆ · $minutes ನಿಮಿಷ ಓದು';
  }

  @override
  String articleReadMinutes(String minutes) {
    return '$minutes ನಿಮಿ';
  }

  @override
  String articleMetaLine(String date, String minutes) {
    return '$date · $minutes ನಿಮಿಷ ಓದು';
  }

  @override
  String get searchHint => 'ಲೇಖನಗಳು, ವರದಿಗಳು ಮತ್ತು ಇನ್ನಷ್ಟು ಹುಡುಕಿ';

  @override
  String get searchFilterArticles => 'ಲೇಖನಗಳು';

  @override
  String get searchRecentLabel => 'ಇತ್ತೀಚಿನವು';

  @override
  String get searchClearRecent => 'ಅಳಿಸಿ';

  @override
  String get searchClearQuery => 'ಹುಡುಕಾಟ ತೆರವುಗೊಳಿಸಿ';

  @override
  String get searchTrendingLabel => 'ಟ್ರೆಂಡಿಂಗ್';

  @override
  String get searchResultsLabel => 'ಫಲಿತಾಂಶಗಳು';

  @override
  String searchNoResultsTitle(String query) {
    return '\"$query\" ಗಾಗಿ ಫಲಿತಾಂಶಗಳಿಲ್ಲ';
  }

  @override
  String get searchNoResultsHint =>
      'ಬೇರೆ ಪದಗಳನ್ನು ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ ಕಾಗುಣಿತ ಪರಿಶೀಲಿಸಿ';

  @override
  String get notificationsTitle => 'ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get notificationsMarkAllRead => 'ಎಲ್ಲವನ್ನೂ ಓದಿದಂತೆ ಗುರುತಿಸಿ';

  @override
  String get notificationsToday => 'ಇಂದು';

  @override
  String get notificationsYesterday => 'ನಿನ್ನೆ';

  @override
  String get notificationsEmptyState => 'ಇನ್ನೂ ಯಾವುದೇ ಅಧಿಸೂಚನೆಗಳಿಲ್ಲ';

  @override
  String get notificationsEmptyMessage =>
      'ಇಲ್ಲಿ ನಿಮಗೆ ದೈನಂದಿನ ರಾಶಿಫಲ, ಹಬ್ಬ ಮತ್ತು ಹೊಂದಾಣಿಕೆ ಎಚ್ಚರಿಕೆಗಳು ಕಾಣಿಸುತ್ತವೆ.';

  @override
  String get notificationsPermissionDeniedTitle => 'ಅಧಿಸೂಚನೆಗಳನ್ನು ಆನ್ ಮಾಡಿ';

  @override
  String get notificationsPermissionDeniedMessage =>
      'ನಿಮ್ಮ ದೈನಂದಿನ ರಾಶಿಫಲ, ಹಬ್ಬದ ಎಚ್ಚರಿಕೆಗಳು ಮತ್ತು AI ಪ್ರತ್ಯುತ್ತರಗಳನ್ನು ಪಡೆಯಲು ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.';

  @override
  String get notificationsPermissionEnableAction =>
      'ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get notificationsPermissionOpenSettingsAction =>
      'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get profileBirthProfiles => 'ಜನ್ಮ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String profileProfileCount(String count) {
    return '$count ಪ್ರೊಫೈಲ್';
  }

  @override
  String get profileAppLanguageLabel => 'ಆ್ಯಪ್ ಭಾಷೆ';

  @override
  String get profileMyActivityLabel => 'ನನ್ನ ಚಟುವಟಿಕೆ';

  @override
  String get profileMyReports => 'ನನ್ನ ವರದಿಗಳು';

  @override
  String get profileDownloadedPdfs => 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿದ PDFಗಳು';

  @override
  String get profileAiChatHistory => 'AI ಚಾಟ್ ಇತಿಹಾಸ';

  @override
  String get profilePaymentHistory => 'ಪಾವತಿ ಇತಿಹಾಸ';

  @override
  String get profilePreferencesLabel => 'ಆದ್ಯತೆಗಳು';

  @override
  String get profileAppearance => 'ಗೋಚರತೆ';

  @override
  String get profileAppearanceSystem => 'ಸಿಸ್ಟಂ · ಸಾಧನವನ್ನು ಅನುಸರಿಸುತ್ತದೆ';

  @override
  String get profileAppearanceLight => 'ಬೆಳಕು';

  @override
  String get profileAppearanceDark => 'ಕತ್ತಲು';

  @override
  String get profileNotifications => 'ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get profileNotificationsSubtitle => 'ದೈನಂದಿನ ರಾಶಿಫಲ, ಹಬ್ಬಗಳು';

  @override
  String get profilePanchangLocation => 'ಪಂಚಾಂಗ ಸ್ಥಳ';

  @override
  String get profileManageSubscription => 'ಚಂದಾದಾರಿಕೆ ನಿರ್ವಹಿಸಿ';

  @override
  String get profilePrivacySecurity => 'ಗೌಪ್ಯತೆ ಮತ್ತು ಭದ್ರತೆ';

  @override
  String get profileHelpSupport => 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ';

  @override
  String get profileRewardsLabel => 'ಬಹುಮಾನಗಳು';

  @override
  String get profileReferEarn => 'ರೆಫರ್ ಮಾಡಿ ಗಳಿಸಿ';

  @override
  String get profileReferEarnSubtitle =>
      'ಪ್ರತಿ ರೆಫರಲ್‌ಗೆ 1 ತಿಂಗಳು ಉಚಿತವಾಗಿ ಪಡೆಯಿರಿ';

  @override
  String get profileInviteFriends => 'ಸ್ನೇಹಿತರನ್ನು ಆಹ್ವಾನಿಸಿ';

  @override
  String get profileInviteFriendsSubtitle => 'ವೇದದರ್ಶಿಯನ್ನು ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get profileMoreLabel => 'ಇನ್ನಷ್ಟು';

  @override
  String get profileRateApp => 'ವೇದದರ್ಶಿಯನ್ನು ರೇಟ್ ಮಾಡಿ';

  @override
  String get profileSendFeedback => 'ಪ್ರತಿಕ್ರಿಯೆ ಕಳುಹಿಸಿ';

  @override
  String get profileRestorePurchases => 'ಖರೀದಿಗಳನ್ನು ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get profileLogOut => 'ಲಾಗ್ ಔಟ್';

  @override
  String get profileDeleteAccount => 'ಖಾತೆ ಅಳಿಸಿ';

  @override
  String get profileSignOutConfirmTitle => 'ಲಾಗ್ ಔಟ್ ಮಾಡಬೇಕೆ?';

  @override
  String get profileSignOutConfirmMessage =>
      'ನಿಮ್ಮ ಉಳಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳು ಮತ್ತು ವರದಿಗಳನ್ನು ಪ್ರವೇಶಿಸಲು ನೀವು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಬೇಕಾಗುತ್ತದೆ.';

  @override
  String get profileSignOutConfirmAction => 'ಲಾಗ್ ಔಟ್';

  @override
  String get profileCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get kundliSandboxBanner =>
      'ಮಾದರಿ ಜಾತಕ — ನಿಮ್ಮ ಜನನ ವಿವರಗಳಿಂದ ಲೆಕ್ಕಹಾಕಲಾಗಿಲ್ಲ';

  @override
  String get kundliLoadErrorTitle => 'ನಿಮ್ಮ ಜಾತಕ ಲೋಡ್ ಆಗಲಿಲ್ಲ';

  @override
  String get kundliLoadErrorMessage =>
      'ನಿಮ್ಮ ಕುಂಡಲಿಯನ್ನು ಪಡೆಯುವಲ್ಲಿ ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get kundliRetry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get kundliLoadingChart => 'ನಿಮ್ಮ ಜಾತಕ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get kundliValueUnavailable => '—';

  @override
  String get kundliDoshaMangalPresent => 'ಮಂಗಳ ದೋಷ ಇದೆ';

  @override
  String get kundliDoshaMangalAbsent => 'ಮಂಗಳ ದೋಷ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get kundliDoshaKaalSarpPresent => 'ಕಾಲ ಸರ್ಪ ದೋಷ ಕಂಡುಬಂದಿದೆ';

  @override
  String kundliDoshaKaalSarpPresentType(String type) {
    return 'ಕಾಲ ಸರ್ಪ ದೋಷ ಕಂಡುಬಂದಿದೆ ($type)';
  }

  @override
  String get kundliDoshaKaalSarpAbsent => 'ಕಾಲ ಸರ್ಪ ದೋಷ ಇಲ್ಲ';

  @override
  String kundliPlanetPositionsAyanamsa(String name) {
    return 'ಅಯನಾಂಶ: $name';
  }

  @override
  String kundliHouseNumber(int house) {
    return 'ಭಾವ $house';
  }

  @override
  String get kundliRetrograde => 'ವಕ್ರಿ';

  @override
  String get kundliDashaLoadErrorTitle => 'ನಿಮ್ಮ ದಶೆಯನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ';

  @override
  String get kundliDashaLoadErrorMessage =>
      'ನಿಮ್ಮ ವಿಂಶೋತ್ತರಿ ದಶೆಯನ್ನು ಪಡೆಯುವಾಗ ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get kundliDashaLoading => 'ನಿಮ್ಮ ದಶೆ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get kundliDashaCurrentTitle => 'ಪ್ರಸ್ತುತ ಮಹಾದಶೆ';

  @override
  String get kundliDashaBalanceTitle => 'ಜನನದ ಸಮಯದ ದಶಾ ಬಾಕಿ';

  @override
  String kundliDashaBalanceValue(int years, int months, int days) {
    return '$years ವರ್ಷಗಳು, $months ತಿಂಗಳುಗಳು, $days ದಿನಗಳು';
  }

  @override
  String get kundliDashaTimelineTitle => 'ದಶಾ ಕಾಲರೇಖೆ';

  @override
  String get kundliDashaCurrentBadge => 'ಪ್ರಸ್ತುತ';

  @override
  String get kundliPlanetPositionsEmpty =>
      'ಈ ಜಾತಕಕ್ಕೆ ಗ್ರಹ ಸ್ಥಾನಗಳು ಇನ್ನೂ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get kundliDashaTimelineEmpty => 'ಇನ್ನೂ ಯಾವುದೇ ದಶಾ ಅವಧಿಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String kundliNakshatraPada(int pada) {
    return 'ಪಾದ $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'ಪಿತೃ ದೋಷವಿದೆ';
}
