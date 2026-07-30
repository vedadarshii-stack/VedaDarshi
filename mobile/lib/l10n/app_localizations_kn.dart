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
}
