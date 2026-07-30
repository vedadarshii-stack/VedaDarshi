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

  @override
  String get birthTitle => 'உங்கள் பிறப்பு விவரங்கள்';

  @override
  String get birthSubtitle =>
      'இவை உங்கள் ஜாதகம், ராசிபலன் மற்றும் தனிப்பயன் அறிக்கைகளுக்கு ஆதாரம். துல்லியம் முக்கியம் ✨';

  @override
  String get birthFullNameLabel => 'முழுப் பெயர்';

  @override
  String get birthNameHint => 'உங்கள் முழுப் பெயரை உள்ளிடவும்';

  @override
  String get birthGenderLabel => 'பாலினம்';

  @override
  String get genderMale => 'ஆண்';

  @override
  String get genderFemale => 'பெண்';

  @override
  String get genderOther => 'மற்றவை';

  @override
  String get birthDobLabel => 'பிறந்த தேதி';

  @override
  String get birthDateHint => 'தேதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get birthTobLabel => 'பிறந்த நேரம்';

  @override
  String get birthTimeHint => 'நேரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get birthTimeUnknownValue => 'மதியம் 12:00 (நண்பகல்)';

  @override
  String get birthPlaceLabel => 'பிறந்த இடம்';

  @override
  String get birthPlaceHint => 'உங்கள் பிறந்த நகரத்தைத் தேடுங்கள்';

  @override
  String birthGeoDetected(String lat, String lon, String offset, String zone) {
    return '✓ தானாக கண்டறியப்பட்டது: $lat, $lon · $offset ($zone)';
  }

  @override
  String get birthTimeUnknown => 'எனது சரியான பிறந்த நேரம் எனக்குத் தெரியாது';

  @override
  String get birthSave => 'எனது சுயவிவரத்தை உருவாக்கு ✨';

  @override
  String get birthFooter =>
      'நீங்கள் பின்னர் குடும்பம் & நண்பர்களின் சுயவிவரங்களைச் சேர்க்கலாம்';

  @override
  String get placeResolveFailed =>
      'அந்த இடத்தை ஏற்ற முடியவில்லை. வேறு ஒன்றைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get todaysPanchang => 'இன்றைய பஞ்சாங்கம்';

  @override
  String get nakshatra => 'நட்சத்திரம்';

  @override
  String get yoga => 'யோகம்';

  @override
  String get karana => 'கரணம்';

  @override
  String get fullPanchang => 'முழு பஞ்சாங்கம்';

  @override
  String get todayAtAGlance => 'இன்று ஒரு பார்வையில்';

  @override
  String get luckyNumber => 'அதிர்ஷ்ட எண்';

  @override
  String get luckyColor => 'அதிர்ஷ்ட நிறம்';

  @override
  String get direction => 'திசை';

  @override
  String get todaysPlanet => 'இன்றைய கிரகம்';

  @override
  String get moonPhase => 'நிலவு நிலை';

  @override
  String get muhurat => 'முகூர்த்தம்';

  @override
  String get todaysRemedy => 'இன்றைய பரிகாரம்';

  @override
  String get todaysMantra => 'இன்றைய மந்திரம்';

  @override
  String get festivalOfTheDay => 'இன்றைய திருவிழா';

  @override
  String get rituals => 'சடங்குகள்';

  @override
  String get explore => 'ஆராயுங்கள்';

  @override
  String get navKundli => 'ஜாதகம்';

  @override
  String get navMatch => 'பொருத்தம்';

  @override
  String get navReports => 'அறிக்கைகள்';

  @override
  String get navAskAi => 'AI-யிடம் கேளுங்கள்';

  @override
  String get todaysHoroscope => 'இன்றைய ராசிபலன்';

  @override
  String get allSigns => 'அனைத்து ராசிகள்';

  @override
  String get wisdomForYou => 'உங்களுக்கான ஞானம்';

  @override
  String get seeAll => 'அனைத்தையும் காண்க';

  @override
  String get continueWithRishiAi => 'ரிஷி AI உடன் தொடரவும்';

  @override
  String get continueAction => 'தொடரவும்';

  @override
  String get recentReports => 'சமீபத்திய அறிக்கைகள்';

  @override
  String get myReports => 'எனது அறிக்கைகள்';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navPanchang => 'பஞ்சாங்கம்';

  @override
  String get navProfile => 'சுயவிவரம்';
}
