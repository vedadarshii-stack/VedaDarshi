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
}
