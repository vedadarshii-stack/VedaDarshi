// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'మీ విశ్వసనీయ వేద సహచరుడు';

  @override
  String get introStarsTitle => 'మీ నక్షత్రాలు, విడమరిచి';

  @override
  String get introStarsSubtitle =>
      'దైనందిన రాశిఫలం, పంచాంగం మరియు జాతకం — ప్రామాణిక వేద గణనలతో';

  @override
  String get introAiTitle => 'AI జ్యోతిష్యుడిని అడగండి';

  @override
  String get introAiSubtitle =>
      'మీ జాతకం ఆధారంగా వ్యక్తిగత మార్గదర్శకత్వం — మీ సొంత భాషలో';

  @override
  String get getStarted => 'ప్రారంభించండి';

  @override
  String get languageTitle => 'మీ భాషను ఎంచుకోండి';

  @override
  String get languageNativePrompt => 'మీ భాషను ఎంచుకోండి';

  @override
  String get languageSettingsHint =>
      'మీరు దీన్ని ఎప్పుడైనా సెట్టింగ్‌లలో మార్చుకోవచ్చు';

  @override
  String get continueLabel => 'కొనసాగించు';

  @override
  String get welcomeHeroTagline =>
      'పంచాంగం · జాతకం · రాశిఫలం · AI జ్యోతిష్యుడు';

  @override
  String get welcomeGreeting => 'నమస్తే 🙏';

  @override
  String get welcomeSubtitle =>
      'మీ జనన వివరాలను సేవ్ చేసి, వ్యక్తిగత అంచనాలను అన్‌లాక్ చేయడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get phoneHint => 'మొబైల్ నంబర్';

  @override
  String get getOtp => 'OTP పొందండి';

  @override
  String get orContinueWith => 'లేదా దీనితో కొనసాగించండి';

  @override
  String get continueWithGoogle => 'Googleతో కొనసాగించండి';

  @override
  String get exploreAsGuest => 'అతిథిగా అన్వేషించండి';

  @override
  String get termsNotice =>
      'కొనసాగించడం ద్వారా మీరు మా సేవా నిబంధనలు & గోప్యతా విధానానికి అంగీకరిస్తున్నారు';

  @override
  String get otpTitle => 'మీ నంబర్‌ను ధృవీకరించండి';

  @override
  String otpSubtitle(String phone) {
    return '$phoneకు పంపిన 6-అంకెల కోడ్‌ను నమోదు చేయండి';
  }

  @override
  String get otpNoCode => 'కోడ్ రాలేదా?';

  @override
  String otpResendIn(String seconds) {
    return '$secondsలో మళ్లీ పంపండి';
  }

  @override
  String get otpResend => 'మళ్లీ పంపండి';

  @override
  String get otpVerify => 'ధృవీకరించి కొనసాగించండి';

  @override
  String get otpPrivacy =>
      '🔒 మీ నంబర్ ప్రైవేట్‌గా మరియు సురక్షితంగా ఉంచబడుతుంది';

  @override
  String get otpResent => 'కొత్త కోడ్ పంపబడింది.';

  @override
  String get authErrorNetwork =>
      'ఇంటర్నెట్ కనెక్షన్ లేదు. దయచేసి మీ నెట్‌వర్క్‌ని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get authErrorInvalidPhone =>
      'ఆ ఫోన్ నంబర్ సరైనదిగా కనిపించడం లేదు. దయచేసి తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get authErrorInvalidOtp => 'ఆ కోడ్ తప్పు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get authErrorOtpExpired =>
      'ఆ కోడ్ గడువు ముగిసింది. దయచేసి కొత్తదాన్ని అభ్యర్థించండి.';

  @override
  String get authErrorTooManyRequests =>
      'చాలా ప్రయత్నాలు జరిగాయి. మళ్లీ ప్రయత్నించే ముందు కొంతసేపు వేచి ఉండండి.';

  @override
  String get authErrorProviderDisabled =>
      'ఈ సైన్-ఇన్ పద్ధతి ఇంకా అందుబాటులో లేదు. దయచేసి మరొక ఎంపికను ప్రయత్నించండి.';

  @override
  String get authErrorUnknown =>
      'ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get birthTitle => 'మీ జన్మ వివరాలు';

  @override
  String get birthSubtitle =>
      'ఇవి మీ కుండలి, రాశిఫలం మరియు వ్యక్తిగత నివేదికలను శక్తివంతం చేస్తాయి. ఖచ్చితత్వం ముఖ్యం ✨';

  @override
  String get birthFullNameLabel => 'పూర్తి పేరు';

  @override
  String get birthNameHint => 'మీ పూర్తి పేరు నమోదు చేయండి';

  @override
  String get birthGenderLabel => 'లింగం';

  @override
  String get genderMale => 'పురుషుడు';

  @override
  String get genderFemale => 'స్త్రీ';

  @override
  String get genderOther => 'ఇతర';

  @override
  String get birthDobLabel => 'పుట్టిన తేదీ';

  @override
  String get birthDateHint => 'తేదీని ఎంచుకోండి';

  @override
  String get birthTobLabel => 'పుట్టిన సమయం';

  @override
  String get birthTimeHint => 'సమయాన్ని ఎంచుకోండి';

  @override
  String get birthTimeUnknownValue => 'మధ్యాహ్నం 12:00 (నూన్)';

  @override
  String get birthPlaceLabel => 'పుట్టిన స్థలం';

  @override
  String get birthPlaceHint => 'మీ జన్మ నగరాన్ని శోధించండి';

  @override
  String birthGeoDetected(String lat, String lon, String offset, String zone) {
    return '✓ స్వయంచాలకంగా గుర్తించబడింది: $lat, $lon · $offset ($zone)';
  }

  @override
  String get birthTimeUnknown => 'నాకు నా ఖచ్చితమైన జన్మ సమయం తెలియదు';

  @override
  String get birthSave => 'నా ప్రొఫైల్‌ను సృష్టించండి ✨';

  @override
  String get birthFooter =>
      'మీరు తర్వాత కుటుంబం & స్నేహితుల ప్రొఫైల్‌లను జోడించవచ్చు';

  @override
  String get placeResolveFailed =>
      'ఆ ప్రదేశాన్ని లోడ్ చేయలేకపోయాము. దయచేసి మరొకటి ఎంచుకోండి.';

  @override
  String get todaysPanchang => 'ఈరోజు పంచాంగం';

  @override
  String get nakshatra => 'నక్షత్రం';

  @override
  String get yoga => 'యోగం';

  @override
  String get karana => 'కరణం';

  @override
  String get fullPanchang => 'పూర్తి పంచాంగం';

  @override
  String get todayAtAGlance => 'ఈరోజు ఒక్క చూపులో';

  @override
  String get luckyNumber => 'అదృష్ట సంఖ్య';

  @override
  String get luckyColor => 'అదృష్ట రంగు';

  @override
  String get direction => 'దిశ';

  @override
  String get todaysPlanet => 'ఈరోజు గ్రహం';

  @override
  String get moonPhase => 'చంద్ర కళ';

  @override
  String get muhurat => 'ముహూర్తం';

  @override
  String get todaysRemedy => 'ఈరోజు పరిహారం';

  @override
  String get todaysMantra => 'ఈరోజు మంత్రం';

  @override
  String get festivalOfTheDay => 'ఈరోజు పండుగ';

  @override
  String get rituals => 'ఆచారాలు';

  @override
  String get explore => 'అన్వేషించండి';

  @override
  String get navKundli => 'కుండలి';

  @override
  String get navMatch => 'మ్యాచ్';

  @override
  String get navReports => 'నివేదికలు';

  @override
  String get navAskAi => 'AIని అడగండి';

  @override
  String get todaysHoroscope => 'ఈరోజు రాశిఫలం';

  @override
  String get allSigns => 'అన్ని రాశులు';

  @override
  String get wisdomForYou => 'మీ కోసం జ్ఞానం';

  @override
  String get seeAll => 'అన్నీ చూడండి';

  @override
  String get continueWithRishiAi => 'ఋషి AIతో కొనసాగించండి';

  @override
  String get continueAction => 'కొనసాగించు';

  @override
  String get recentReports => 'ఇటీవలి నివేదికలు';

  @override
  String get myReports => 'నా నివేదికలు';

  @override
  String get navHome => 'హోమ్';

  @override
  String get navPanchang => 'పంచాంగం';

  @override
  String get navProfile => 'ప్రొఫైల్';

  @override
  String get panchangTitle => 'పంచాంగం';

  @override
  String get panchangSunrise => 'సూర్యోదయం';

  @override
  String get panchangSunset => 'సూర్యాస్తమయం';

  @override
  String get panchangMoonrise => 'చంద్రోదయం';

  @override
  String get panchangMoonset => 'చంద్రాస్తమయం';

  @override
  String get panchangTithi => 'తిథి';

  @override
  String get panchangVaar => 'వారం';

  @override
  String get muhuratToday => 'ఈరోజు ముహూర్తం';

  @override
  String get muhuratShubh => 'శుభ';

  @override
  String get muhuratAshubh => 'అశుభ';

  @override
  String get festivalToday => 'ఈరోజు పండుగ';

  @override
  String get details => 'వివరాలు';

  @override
  String get todaysSpiritualAdvice => 'ఈరోజు ఆధ్యాత్మిక సలహా';

  @override
  String get viewAllMuhurat => 'అన్ని ముహూర్త సమయాలను చూడండి';

  @override
  String availableOffline(String time) {
    return 'ఆఫ్‌లైన్‌లో అందుబాటులో ఉంది · నవీకరించబడింది $time';
  }

  @override
  String get horoscopeTitle => 'రాశిఫలం';

  @override
  String get periodDaily => 'రోజువారీ';

  @override
  String get periodWeekly => 'వారానికి';

  @override
  String get periodMonthly => 'నెలవారీ';

  @override
  String get periodYearly => 'వార్షిక';

  @override
  String get yourSign => 'మీ రాశి';
}
