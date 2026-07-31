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

  @override
  String get todaysScores => 'నేటి స్కోర్‌లు';

  @override
  String get scoreCareer => 'కెరీర్';

  @override
  String get scoreLove => 'ప్రేమ';

  @override
  String get scoreHealth => 'ఆరోగ్యం';

  @override
  String get scoreMoney => 'డబ్బు';

  @override
  String get scoreLuck => 'అదృష్టం';

  @override
  String get luckyTime => 'శుభ సమయం';

  @override
  String get avoidTime => 'అశుభ సమయం';

  @override
  String get sectionCareerMoney => 'కెరీర్ & డబ్బు';

  @override
  String get sectionLoveRelationships => 'ప్రేమ & సంబంధాలు';

  @override
  String get sectionHealthEnergy => 'ఆరోగ్యం & శక్తి';

  @override
  String get premiumUnlockPredictions =>
      'వివరణాత్మక నెలవారీ & వార్షిక జోస్యాలను అన్‌లాక్ చేయండి';

  @override
  String get premiumCta => 'ప్రీమియం';

  @override
  String get generateKundliTitle => 'కుండలి తయారు చేయండి';

  @override
  String get selectProfile => 'ప్రొఫైల్ ఎంచుకోండి';

  @override
  String get addFamilyFriend => 'కుటుంబం లేదా స్నేహితుడిని జోడించండి';

  @override
  String get chartStyle => 'చార్ట్ శైలి';

  @override
  String get chartNorthIndian => 'ఉత్తర భారత శైలి';

  @override
  String get chartNorthLayout => 'డైమండ్ లేఅవుట్';

  @override
  String get chartSouthIndian => 'దక్షిణ భారత శైలి';

  @override
  String get chartSouthLayout => 'గ్రిడ్ లేఅవుట్';

  @override
  String get kundliCalcNote =>
      'గణనలు స్విస్ ఎఫెమెరిస్ మరియు లాహిరి అయనాంశను ఉపయోగిస్తాయి';

  @override
  String get generateKundli => 'కుండలి తయారు చేయండి';

  @override
  String get lagnaKundli => 'లగ్న కుండలి';

  @override
  String get pdf => 'PDF';

  @override
  String get tabChart => 'చార్ట్';

  @override
  String get tabPlanetPositions => 'గ్రహ స్థానాలు';

  @override
  String get tabDasha => 'వింశోత్తరి దశ';

  @override
  String get tabPredictions => 'జోస్యాలు';

  @override
  String get keyPlanets => 'ముఖ్య గ్రహాలు';

  @override
  String get lagna => 'లగ్నం';

  @override
  String get rashi => 'రాశి';

  @override
  String get southChartComingSoon =>
      'దక్షిణ భారత చార్ట్ లేఅవుట్ త్వరలో వస్తుంది.';

  @override
  String get kundliMatchingTitle => 'కుండలి మ్యాచింగ్';

  @override
  String get gunMilanIntro =>
      'అష్టకూట గుణ మిలన్ వివాహ అనుకూలత కోసం 36 గుణాలలో 8 అంశాలను పోలుస్తుంది.';

  @override
  String get groom => 'వరుడు';

  @override
  String get bride => 'వధువు';

  @override
  String get change => 'మార్చు';

  @override
  String get selectBrideProfile => 'వధువు ప్రొఫైల్ ఎంచుకోండి…';

  @override
  String get selectBrideHint =>
      'ఎంచుకోవడానికి లేదా జనన వివరాలు జోడించడానికి నొక్కండి';

  @override
  String get matchingPrivacyNote =>
      'మ్యాచింగ్ ఫలితాలు ప్రైవేట్‌గా ఉంటాయి మరియు మీ ఖాతాలో మాత్రమే సేవ్ చేయబడతాయి';

  @override
  String get matchKundlis => 'కుండలి మ్యాచ్ చేయండి';

  @override
  String get matchResult => 'మ్యాచ్ ఫలితం';

  @override
  String outOfMax(int max) {
    return '$max లో';
  }

  @override
  String percentCompatible(int percent) {
    return '$percent% అనుకూలత';
  }

  @override
  String get ashtakootaBreakdown => 'అష్టకూట వివరణ';

  @override
  String get bandStrong => 'బలమైన (75%+)';

  @override
  String get bandModerate => 'మధ్యస్థ (40–74%)';

  @override
  String get bandWeak => 'బలహీన (<40%)';

  @override
  String get gunaVarna => 'వర్ణ';

  @override
  String get gunaVashya => 'వశ్య';

  @override
  String get gunaTara => 'తార';

  @override
  String get gunaYoni => 'యోని';

  @override
  String get gunaGrahaMaitri => 'గ్రహ మైత్రి';

  @override
  String get gunaGana => 'గణ';

  @override
  String get gunaBhakoot => 'భకూట';

  @override
  String get gunaNadi => 'నాడి';

  @override
  String get rishiAiSummary => 'ఋషి AI సారాంశం';

  @override
  String get aiBadge => 'AI';

  @override
  String get detailedCompatibilityReport =>
      'వివరణాత్మక అనుకూలత నివేదిక పొందండి';

  @override
  String get tapGunaHint =>
      'ప్రతి గుణం ఏమి కొలుస్తుందో మరియు ఎందుకు ముఖ్యమో చూడటానికి నొక్కండి';

  @override
  String get rishiAi => 'ఋషి AI';

  @override
  String get onlineKnowsChart => 'ఆన్‌లైన్ · మీ జాతకం తెలుసు';

  @override
  String freeQuota(String used, String total) {
    return '$used/$total ఉచితం';
  }

  @override
  String get today => 'ఈరోజు';

  @override
  String get askAbout => 'వీటి గురించి అడగండి';

  @override
  String get topicCareer => 'కెరీర్';

  @override
  String get topicMarriage => 'వివాహం';

  @override
  String get topicHealth => 'ఆరోగ్యం';

  @override
  String get topicBusiness => 'వ్యాపారం';

  @override
  String get topicFinance => 'ఆర్థికం';

  @override
  String get topicEducation => 'విద్య';

  @override
  String get topicTravel => 'ప్రయాణం';

  @override
  String get topicGemstones => 'రత్నాలు';

  @override
  String get topicRemedies => 'పరిహారాలు';

  @override
  String get topicNumerology => 'సంఖ్యాశాస్త్రం';

  @override
  String get rishiTyping => 'ఋషి టైప్ చేస్తున్నారు…';

  @override
  String get askAboutYourStars => 'మీ నక్షత్రాల గురించి అడగండి…';

  @override
  String get upgradeUnlimited => 'అపరిమిత ప్రశ్నల కోసం అప్‌గ్రేడ్ చేయండి';

  @override
  String get aiNotConnected =>
      'AI సేవ కనెక్ట్ అయిన తర్వాత సమాధానాలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get premiumReportsTitle => 'ప్రీమియం నివేదికలు';

  @override
  String get goPremium => 'ప్రీమియం పొందండి';

  @override
  String goPremiumSubtitle(String total) {
    return 'అన్ని $total నివేదికలు + అపరిమిత AI ప్రశ్నలను అన్‌లాక్ చేయండి';
  }

  @override
  String get upgrade => 'అప్‌గ్రేడ్ చేయండి';

  @override
  String readMinutes(String minutes) {
    return '$minutes నిమి';
  }

  @override
  String get aiSummary => 'AI సారాంశం';

  @override
  String get premium => 'ప్రీమియం';

  @override
  String get free => 'ఉచితం';

  @override
  String moreReportsFooter(String remaining) {
    return '+ $remaining మరిన్ని నివేదికలు · అన్నింటిలో PDF డౌన్‌లోడ్ ఉంటుంది';
  }

  @override
  String get reportCareer => 'కెరీర్ నివేదిక';

  @override
  String get reportCareerDesc => 'వృత్తి, పదోన్నతులు & వ్యాపార సమయం';

  @override
  String get reportMarriage => 'వివాహ నివేదిక';

  @override
  String get reportMarriageDesc => 'సమయం, జీవిత భాగస్వామి లక్షణాలు & అనుకూలత';

  @override
  String get reportWealth => 'సంపద & ఆర్థికం';

  @override
  String get reportWealthDesc => 'ఆదాయ వనరులు, పెట్టుబడులు & యోగాలు';

  @override
  String get reportHealth => 'ఆరోగ్య నివేదిక';

  @override
  String get reportHealthDesc => 'సున్నితమైన కాలాలు & నివారణ ఉపాయాలు';

  @override
  String get reportSadeSati => 'సాడే సాతీ నివేదిక';

  @override
  String get reportSadeSatiDesc => 'శని దశలు & ప్రభావ విశ్లేషణ';

  @override
  String get reportGemstone => 'రత్న నివేదిక';

  @override
  String get reportGemstoneDesc => 'సిఫార్సు చేసిన రత్నాలు & ధరించే విధానం';

  @override
  String get reportNumerology => 'సంఖ్యాశాస్త్ర నివేదిక';

  @override
  String get reportNumerologyDesc => 'జీవిత మార్గం, విధి & పేరు అంకెలు';

  @override
  String get restorePurchase => 'కొనుగోలును పునరుద్ధరించండి';

  @override
  String get vedadarshiPremium => 'Vedadarshi ప్రీమియం';

  @override
  String get premiumTagline => 'అపరిమిత విశ్వ మార్గదర్శకత్వం, ఒక సరళమైన ప్లాన్';

  @override
  String benefitReports(String total) {
    return 'PDF ఎగుమతితో అన్ని $total ప్రీమియం నివేదికలు';
  }

  @override
  String get benefitUnlimitedAi => 'అపరిమిత AI జ్యోతిష్కుడు ప్రశ్నలు';

  @override
  String get benefitAdvancedKundli => 'అధునాతన కుండలి: దశ, దోష & పరిహారాలు';

  @override
  String get benefitAdFree => 'యాప్ మొత్తంలో ప్రకటనలు-లేని అనుభవం';

  @override
  String get planMonthly => 'నెలవారీ';

  @override
  String get planYearly => 'వార్షిక';

  @override
  String get planLifetime => 'జీవితకాల';

  @override
  String get perMonth => 'నెలకు';

  @override
  String get oneTimePayment => 'ఒకేసారి చెల్లింపు';

  @override
  String startPremium(String price) {
    return 'ప్రీమియం ప్రారంభించండి — $price';
  }

  @override
  String get billingFinePrint =>
      'Google Play ద్వారా బిల్ చేయబడింది · ఎప్పుడైనా రద్దు చేయండి · RevenueCatతో సురక్షితం';

  @override
  String get articlesTitle => 'జ్ఞానం & వ్యాసాలు';

  @override
  String get savedArticlesLabel => 'సేవ్ చేసిన వ్యాసాలు';

  @override
  String get articleCategoryAll => 'అన్నీ';

  @override
  String articleFeaturedBadge(String tag) {
    return 'ఫీచర్ చేయబడింది · $tag';
  }

  @override
  String get articleSave => 'సేవ్ చేయి';

  @override
  String get articleShare => 'షేర్ చేయి';

  @override
  String get articleListen => 'వినండి';

  @override
  String articleByline(String author, String minutes) {
    return '$author ద్వారా · $minutes నిమిషాల చదవడం';
  }

  @override
  String articleReadMinutes(String minutes) {
    return '$minutes నిమి';
  }

  @override
  String articleMetaLine(String date, String minutes) {
    return '$date · $minutes నిమిషాల చదవడం';
  }

  @override
  String get searchHint => 'వ్యాసాలు, నివేదికలు మరియు మరిన్ని శోధించండి';

  @override
  String get searchFilterArticles => 'వ్యాసాలు';

  @override
  String get searchRecentLabel => 'ఇటీవలివి';

  @override
  String get searchClearRecent => 'క్లియర్ చేయండి';

  @override
  String get searchClearQuery => 'శోధనను క్లియర్ చేయండి';

  @override
  String get searchTrendingLabel => 'ట్రెండింగ్';

  @override
  String get searchResultsLabel => 'ఫలితాలు';

  @override
  String searchNoResultsTitle(String query) {
    return '\"$query\" కోసం ఫలితాలు లేవు';
  }

  @override
  String get searchNoResultsHint =>
      'వేరే కీవర్డ్‌లు ప్రయత్నించండి లేదా స్పెల్లింగ్ తనిఖీ చేయండి';

  @override
  String get notificationsTitle => 'నోటిఫికేషన్‌లు';

  @override
  String get notificationsMarkAllRead => 'అన్నింటినీ చదివినట్లు గుర్తించండి';

  @override
  String get notificationsToday => 'ఈరోజు';

  @override
  String get notificationsYesterday => 'నిన్న';

  @override
  String get notificationsEmptyState => 'ఇంకా నోటిఫికేషన్‌లు లేవు';

  @override
  String get notificationsEmptyMessage =>
      'ఇక్కడ మీకు రోజువారీ రాశిఫలం, పండుగలు మరియు మ్యాచింగ్ అలర్ట్‌లు కనిపిస్తాయి.';

  @override
  String get notificationsPermissionDeniedTitle => 'నోటిఫికేషన్‌లను ఆన్ చేయండి';

  @override
  String get notificationsPermissionDeniedMessage =>
      'మీ రోజువారీ రాశిఫలం, పండుగ అలర్ట్‌లు మరియు AI రిప్లైలు పొందడానికి నోటిఫికేషన్‌లను ప్రారంభించండి.';

  @override
  String get notificationsPermissionEnableAction =>
      'నోటిఫికేషన్‌లను ప్రారంభించండి';

  @override
  String get notificationsPermissionOpenSettingsAction =>
      'సెట్టింగ్‌లను తెరవండి';

  @override
  String get profileBirthProfiles => 'జనన ప్రొఫైల్‌లు';

  @override
  String profileProfileCount(String count) {
    return '$count ప్రొఫైల్';
  }

  @override
  String get profileAppLanguageLabel => 'యాప్ భాష';

  @override
  String get profileMyActivityLabel => 'నా కార్యకలాపం';

  @override
  String get profileMyReports => 'నా నివేదికలు';

  @override
  String get profileDownloadedPdfs => 'డౌన్‌లోడ్ చేసిన PDFలు';

  @override
  String get profileAiChatHistory => 'AI చాట్ చరిత్ర';

  @override
  String get profilePaymentHistory => 'చెల్లింపు చరిత్ర';

  @override
  String get profilePreferencesLabel => 'ప్రాధాన్యతలు';

  @override
  String get profileAppearance => 'రూపం';

  @override
  String get profileAppearanceSystem => 'సిస్టమ్ · పరికరాన్ని అనుసరిస్తుంది';

  @override
  String get profileAppearanceLight => 'లైట్';

  @override
  String get profileAppearanceDark => 'డార్క్';

  @override
  String get profileNotifications => 'నోటిఫికేషన్‌లు';

  @override
  String get profileNotificationsSubtitle => 'రోజువారీ రాశిఫలం, పండుగలు';

  @override
  String get profilePanchangLocation => 'పంచాంగ స్థానం';

  @override
  String get profileManageSubscription => 'సభ్యత్వాన్ని నిర్వహించండి';

  @override
  String get profilePrivacySecurity => 'గోప్యత & భద్రత';

  @override
  String get profileHelpSupport => 'సహాయం & మద్దతు';

  @override
  String get profileRewardsLabel => 'రివార్డులు';

  @override
  String get profileReferEarn => 'రెఫర్ చేసి సంపాదించండి';

  @override
  String get profileReferEarnSubtitle =>
      'ప్రతి రెఫరల్‌కు 1 నెల ఉచితంగా పొందండి';

  @override
  String get profileInviteFriends => 'స్నేహితులను ఆహ్వానించండి';

  @override
  String get profileInviteFriendsSubtitle => 'వేదదర్శిని షేర్ చేయండి';

  @override
  String get profileMoreLabel => 'మరిన్ని';

  @override
  String get profileRateApp => 'వేదదర్శిని రేట్ చేయండి';

  @override
  String get profileSendFeedback => 'అభిప్రాయం పంపండి';

  @override
  String get profileRestorePurchases => 'కొనుగోళ్లను పునరుద్ధరించండి';

  @override
  String get profileLogOut => 'లాగ్ అవుట్';

  @override
  String get profileDeleteAccount => 'ఖాతాను తొలగించండి';

  @override
  String get profileSignOutConfirmTitle => 'లాగ్ అవుట్ చేయాలా?';

  @override
  String get profileSignOutConfirmMessage =>
      'మీ సేవ్ చేసిన ప్రొఫైల్‌లు మరియు నివేదికలను యాక్సెస్ చేయడానికి మీరు మళ్లీ సైన్ ఇన్ చేయాలి.';

  @override
  String get profileSignOutConfirmAction => 'లాగ్ అవుట్';

  @override
  String get profileCancel => 'రద్దు చేయండి';
}
