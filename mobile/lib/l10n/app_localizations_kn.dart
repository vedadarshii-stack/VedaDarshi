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
}
