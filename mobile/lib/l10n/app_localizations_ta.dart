// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'உங்கள் நம்பகமான வேத துணை';

  @override
  String get introStarsTitle => 'உங்கள் நட்சத்திரங்கள், விளக்கமாக';

  @override
  String get introStarsSubtitle =>
      'தினசரி ராசிபலன், பஞ்சாங்கம் மற்றும் ஜாதகம் — உண்மையான வேத கணிப்புகளால்';

  @override
  String get introAiTitle => 'AI ஜோதிடரிடம் கேளுங்கள்';

  @override
  String get introAiSubtitle =>
      'உங்கள் ஜாதகத்தின் அடிப்படையில் தனிப்பட்ட வழிகாட்டுதல் — உங்கள் மொழியில்';

  @override
  String get getStarted => 'தொடங்குங்கள்';

  @override
  String get languageTitle => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get languageNativePrompt => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get languageSettingsHint =>
      'இதை நீங்கள் எப்போது வேண்டுமானாலும் அமைப்புகளில் மாற்றலாம்';

  @override
  String get continueLabel => 'தொடரவும்';

  @override
  String get welcomeHeroTagline =>
      'பஞ்சாங்கம் · ஜாதகம் · ராசிபலன் · AI ஜோதிடர்';

  @override
  String get welcomeGreeting => 'வணக்கம் 🙏';

  @override
  String get welcomeSubtitle =>
      'உங்கள் பிறப்பு விவரங்களைச் சேமித்து, தனிப்பயன் கணிப்புகளைத் திறக்க உள்நுழையவும்.';

  @override
  String get phoneHint => 'மொபைல் எண்';

  @override
  String get getOtp => 'OTP பெறவும்';

  @override
  String get orContinueWith => 'அல்லது இதனுடன் தொடரவும்';

  @override
  String get continueWithGoogle => 'Google உடன் தொடரவும்';

  @override
  String get exploreAsGuest => 'விருந்தினராக ஆராயவும்';

  @override
  String get termsNotice =>
      'தொடர்வதன் மூலம் நீங்கள் எங்கள் சேவை விதிமுறைகள் & தனியுரிமைக் கொள்கையை ஏற்கிறீர்கள்';

  @override
  String get otpTitle => 'உங்கள் எண்ணைச் சரிபார்க்கவும்';

  @override
  String otpSubtitle(String phone) {
    return '$phone க்கு அனுப்பப்பட்ட 6-இலக்க குறியீட்டை உள்ளிடவும்';
  }

  @override
  String get otpNoCode => 'குறியீடு கிடைக்கவில்லையா?';

  @override
  String otpResendIn(String seconds) {
    return '$secondsஇல் மீண்டும் அனுப்பவும்';
  }

  @override
  String get otpResend => 'மீண்டும் அனுப்பவும்';

  @override
  String get otpVerify => 'சரிபார்த்து தொடரவும்';

  @override
  String get otpPrivacy =>
      '🔒 உங்கள் எண் தனிப்பட்டதாகவும் பாதுகாப்பாகவும் வைக்கப்படுகிறது';

  @override
  String get otpResent => 'புதிய குறியீடு அனுப்பப்பட்டது.';

  @override
  String get authErrorNetwork =>
      'இணைய இணைப்பு இல்லை. உங்கள் நெட்வொர்க்கைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get authErrorInvalidPhone =>
      'அந்த தொலைபேசி எண் சரியாகத் தெரியவில்லை. சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get authErrorInvalidOtp =>
      'அந்த குறியீடு தவறானது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get authErrorOtpExpired =>
      'அந்த குறியீடு காலாவதியானது. புதிதாக ஒன்றைக் கோரவும்.';

  @override
  String get authErrorTooManyRequests =>
      'அதிக முயற்சிகள். மீண்டும் முயற்சிக்கும் முன் சிறிது நேரம் காத்திருக்கவும்.';

  @override
  String get authErrorProviderDisabled =>
      'இந்த உள்நுழைவு முறை இன்னும் கிடைக்கவில்லை. வேறு விருப்பத்தை முயற்சிக்கவும்.';

  @override
  String get authErrorUnknown => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';
}
