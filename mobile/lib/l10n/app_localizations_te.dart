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
  String get orContinueWith => 'లేదా దీనితో కొనసాగించండి';

  @override
  String get continueWithGoogle => 'Googleతో కొనసాగించండి';

  @override
  String get exploreAsGuest => 'అతిథిగా అన్వేషించండి';

  @override
  String get termsNotice =>
      'కొనసాగించడం ద్వారా మీరు మా సేవా నిబంధనలు & గోప్యతా విధానానికి అంగీకరిస్తున్నారు';

  @override
  String get authErrorNetwork =>
      'ఇంటర్నెట్ కనెక్షన్ లేదు. దయచేసి మీ నెట్‌వర్క్‌ని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

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
  String get panchangLoading => 'ఈరోజు పంచాంగం లోడ్ అవుతోంది…';

  @override
  String get panchangLoadErrorTitle => 'పంచాంగం లోడ్ కాలేదు';

  @override
  String get panchangLoadErrorMessage =>
      'మీ కనెక్షన్‌ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get panchangRetry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get panchangSandboxBanner => 'నమూనా డేటా — మీ స్థానం కాదు';

  @override
  String panchangPercentRemaining(int percent) {
    return '$percent% మిగిలింది';
  }

  @override
  String panchangPada(int number) {
    return 'పాదం $number';
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
  String get horoscopeSandboxBanner => 'నమూనా డేటా — సాండ్‌బాక్స్ మోడ్';

  @override
  String get horoscopeErrorTitle => 'జాతకం లోడ్ కాలేదు';

  @override
  String get horoscopeErrorMessage =>
      'జ్యోతిష సేవను చేరుకోవడంలో సమస్య వచ్చింది. దయచేసి మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get horoscopeRetryAction => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get weeklyAdviceTitle => 'ఈ వారం సలహా';

  @override
  String get weeklyOutlookTitle => '7-రోజుల అంచనా';

  @override
  String get weeklyBestDayBadge => 'ఉత్తమ రోజు';

  @override
  String get monthlyThemeTitle => 'ఈ నెల థీమ్';

  @override
  String get monthlyScoresTitle => 'ఈ నెల స్కోర్‌లు';

  @override
  String monthlyOverallRating(int percent) {
    return 'మొత్తం $percent%';
  }

  @override
  String get monthlyKeyDatesTitle => 'ఈ నెలలో ముఖ్యమైన తేదీలు';

  @override
  String get yearlySummaryTitle => 'ఈ సంవత్సర సారాంశం';

  @override
  String get yearlyScoresTitle => 'ఈ సంవత్సరం స్కోర్‌లు';

  @override
  String yearlyOverallRating(int percent) {
    return 'మొత్తం $percent%';
  }

  @override
  String get luckyDay => 'అదృష్ట రోజు';

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
      'లాహిరి అయనాంశంతో వైదిక నిరయన జాతకం — గ్రహ స్థానాలు, వింశోత్తరి దశ, దోష పరిశీలన మరియు అంచనాలతో';

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
  String get matchLoading => 'మీ అనుకూలతను గణిస్తోంది…';

  @override
  String get matchErrorTitle => 'అనుకూలతను గణించలేకపోయాము';

  @override
  String get matchErrorMessage =>
      'ఏదో తప్పు జరిగింది. దయచేసి మీ కనెక్షన్‌ని తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get sandboxResultBanner =>
      'నమూనా ఫలితం — నమోదు చేసిన జనన వివరాల నుండి లెక్కించబడలేదు';

  @override
  String get matchNoGunaData => 'ఈ మ్యాచ్‌కి గుణ వివరాలు అందుబాటులో లేవు.';

  @override
  String get rishiAi => 'ఋషి AI';

  @override
  String get onlineKnowsChart => 'ఆన్‌లైన్ · మీ జాతకం తెలుసు';

  @override
  String aiGreeting(String name) {
    return '🙏 నమస్తే $name! నేను మీ జాతకాన్ని అధ్యయనం చేశాను. కెరీర్, వివాహం, ఆరోగ్యం లేదా సరైన ముహూర్తం గురించి నన్ను ఏదైనా అడగండి.';
  }

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
  String get upgradeUnlimited => 'మరిన్ని ప్రశ్నల కోసం అప్‌గ్రేడ్ చేయండి';

  @override
  String get aiErrorQuotaExceeded =>
      'మీ ఈరోజు ఉచిత ప్రశ్నల పరిమితి పూర్తయింది. ప్రతిరోజూ మరిన్ని ప్రశ్నల కోసం అప్‌గ్రేడ్ చేయండి.';

  @override
  String get aiErrorBirthDetailsMissing =>
      'ఋషి మీ జాతకాన్ని అధ్యయనం చేయడానికి ముందుగా మీ జనన వివరాలను జోడించండి.';

  @override
  String get aiErrorInvalidQuestion =>
      'ఆ ప్రశ్నను ప్రాసెస్ చేయలేకపోయాము — దయచేసి దాన్ని మళ్లీ రాయండి.';

  @override
  String get aiErrorServiceUnavailable =>
      'ఋషి తాత్కాలికంగా అందుబాటులో లేరు. దయచేసి కొద్ది సేపటి తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String get aiErrorGeneric =>
      'ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get aiMessageFailedToSend => 'పంపబడలేదు — దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get premiumReportsTitle => 'ప్రీమియం నివేదికలు';

  @override
  String get goPremium => 'ప్రీమియం పొందండి';

  @override
  String goPremiumSubtitle(String total) {
    return 'అన్ని $total నివేదికలు + ప్రతిరోజూ మరిన్ని AI ప్రశ్నలను అన్‌లాక్ చేయండి';
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
  String get premiumTagline => 'లోతైన విశ్వ మార్గదర్శకత్వం, ఒక సరళమైన ప్లాన్';

  @override
  String tierFeatureAiQuestions(int count) {
    return '$count AI జ్యోతిష్కుడు ప్రశ్నలు రోజుకు';
  }

  @override
  String get tierFeatureHoroscopeStandard =>
      'వారానికి & నెలవారీ రాశిఫలం, పూర్తి పంచాంగం క్యాలెండర్';

  @override
  String get tierFeatureHoroscopeWithYearly =>
      'వారానికి, నెలవారీ & వార్షిక రాశిఫలం, పూర్తి పంచాంగం క్యాలెండర్';

  @override
  String tierFeatureKundalisLimited(int count) {
    return '$count సేవ్ చేసిన కుండలీలు';
  }

  @override
  String get tierFeatureKundalisUnlimited => 'అపరిమిత సేవ్ చేసిన కుండలీలు';

  @override
  String tierFeatureCompatibility(int count) {
    return '$count వివరణాత్మక అనుకూలత నివేదికలు నెలకు';
  }

  @override
  String tierFeatureReportDiscount(int percent) {
    return 'ప్రీమియం నివేదికలపై $percent% తగ్గింపు';
  }

  @override
  String get tierFeaturePremiumArticles => 'ప్రీమియం వ్యాసాలు';

  @override
  String tierFeatureLifeReportCredit(int count) {
    return '$count కంప్లీట్ లైఫ్ రిపోర్ట్ క్రెడిట్ నెలకు';
  }

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
  String profileProfileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రొఫైల్‌లు',
      one: '$count ప్రొఫైల్',
    );
    return '$_temp0';
  }

  @override
  String get birthProfilesYouBadge => 'మీరు';

  @override
  String get birthProfilesDelete => 'తొలగించండి';

  @override
  String get birthProfilesDeleteConfirmTitle => 'ఈ ప్రొఫైల్‌ను తొలగించాలా?';

  @override
  String birthProfilesDeleteConfirmMessage(String name) {
    return 'ఇది $name యొక్క సేవ్ చేసిన జనన ప్రొఫైల్‌ను శాశ్వతంగా తొలగిస్తుంది. దీన్ని రద్దు చేయలేరు.';
  }

  @override
  String get birthProfilesPrimaryDeleteHint =>
      'మీ స్వంత ప్రొఫైల్‌ను ఇక్కడ నుండి తొలగించలేరు — బదులుగా సెట్టింగ్‌లలో ఖాతాను తొలగించండి ఉపయోగించండి.';

  @override
  String get birthProfilesEditorAddTitle => 'ప్రొఫైల్ జోడించండి';

  @override
  String get birthProfilesEditorEditTitle => 'ప్రొఫైల్ సవరించండి';

  @override
  String get birthProfilesEditorSave => 'ప్రొఫైల్ సేవ్ చేయండి';

  @override
  String get birthProfilesSaveFailed =>
      'ఈ ప్రొఫైల్‌ను సేవ్ చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get birthProfilesDeleteFailed =>
      'ఈ ప్రొఫైల్‌ను తొలగించలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get birthProfilesSignInRequired =>
      'కుటుంబం & స్నేహితుల ప్రొఫైల్‌లను జోడించడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get birthProfilesEmpty => 'ఇంకా ప్రొఫైల్‌లు లేవు.';

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
  String profileAiChatHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సంభాషణలు',
      one: '$count సంభాషణ',
    );
    return '$_temp0';
  }

  @override
  String get aiChatHistoryEmptyTitle => 'ఇంకా సంభాషణలు లేవు';

  @override
  String get aiChatHistoryEmptyMessage =>
      'కెరీర్, వివాహం, ఆరోగ్యం లేదా సరైన ముహూర్తం గురించి ఋషి AIని అడగండి — మీ సంభాషణలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get aiChatHistoryEmptyAction => 'ఋషి AIని అడగండి';

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

  @override
  String get profileDeleteAccountConfirmTitle => 'మీ ఖాతాను తొలగించాలా?';

  @override
  String get profileDeleteAccountConfirmMessage =>
      'ఇది మీ జననం ప్రొఫైల్‌లు, AI చాట్ చరిత్ర మరియు ఖాతాను శాశ్వతంగా తొలగిస్తుంది. దీన్ని రద్దు చేయలేరు.';

  @override
  String get profileDeleteAccountConfirmAction => 'ఖాతాను తొలగించండి';

  @override
  String get accountDeletionErrorUnauthenticated =>
      'మీ సెషన్ ముగిసింది. మీ ఖాతాను తొలగించడానికి దయచేసి మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get accountDeletionErrorGeneric =>
      'ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get legalPrivacyPolicy => 'గోప్యతా విధానం';

  @override
  String get legalTermsOfService => 'సేవా నిబంధనలు';

  @override
  String get legalRefundsCancellation => 'వాపసు & రద్దు';

  @override
  String get legalAccountDataDeletion => 'ఖాతా & డేటా తొలగింపు';

  @override
  String get profileEmailSupport => 'మాకు ఇమెయిల్ చేయండి';

  @override
  String get profileEmailSupportSubtitle => 'Vedadarshii@gmail.com';

  @override
  String get supportEmailSubject => 'వేదదర్శి మద్దతు';

  @override
  String get feedbackEmailSubject => 'వేదదర్శి అభిప్రాయం';

  @override
  String profileInviteFriendsMessage(String link) {
    return 'వేదదర్శిలో చేరండి — వేద జ్యోతిష్యం, పంచాంగం మరియు జాతకాలకు మీ రోజువారీ తోడు. ఇక్కడ డౌన్‌లోడ్ చేసుకోండి: $link';
  }

  @override
  String get kundliSandboxBanner =>
      'నమూనా జాతకం — మీ జనన వివరాల నుండి లెక్కించబడలేదు';

  @override
  String get kundliLoadErrorTitle => 'మీ జాతకం లోడ్ కాలేదు';

  @override
  String get kundliLoadErrorMessage =>
      'మీ కుండలిని పొందడంలో ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get kundliRetry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get kundliLoadingChart => 'మీ జాతకం లోడ్ అవుతోంది…';

  @override
  String get kundliValueUnavailable => '—';

  @override
  String get kundliDoshaMangalPresent => 'మంగళ దోషం ఉంది';

  @override
  String get kundliDoshaMangalAbsent => 'మంగళ దోషం కనుగొనబడలేదు';

  @override
  String get kundliDoshaKaalSarpPresent => 'కాల సర్ప దోషం కనుగొనబడింది';

  @override
  String kundliDoshaKaalSarpPresentType(String type) {
    return 'కాల సర్ప దోషం కనుగొనబడింది ($type)';
  }

  @override
  String get kundliDoshaKaalSarpAbsent => 'కాల సర్ప దోషం లేదు';

  @override
  String kundliPlanetPositionsAyanamsa(String name) {
    return 'అయనాంశ: $name';
  }

  @override
  String kundliHouseNumber(int house) {
    return 'భావం $house';
  }

  @override
  String get kundliRetrograde => 'వక్రగతి';

  @override
  String get kundliDashaLoadErrorTitle => 'మీ దశ లోడ్ కాలేదు';

  @override
  String get kundliDashaLoadErrorMessage =>
      'మీ విమ్శోత్తరి దశను పొందడంలో సమస్య వచ్చింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get kundliDashaLoading => 'మీ దశ లోడ్ అవుతోంది…';

  @override
  String get kundliDashaCurrentTitle => 'ప్రస్తుత మహాదశ';

  @override
  String get kundliDashaBalanceTitle => 'జననం వద్ద దశ శేషం';

  @override
  String kundliDashaBalanceValue(int years, int months, int days) {
    return '$years సంవత్సరాలు, $months నెలలు, $days రోజులు';
  }

  @override
  String get kundliDashaTimelineTitle => 'దశ కాలరేఖ';

  @override
  String get kundliDashaCurrentBadge => 'ప్రస్తుతం';

  @override
  String get kundliPlanetPositionsEmpty =>
      'ఈ జాతకానికి గ్రహ స్థానాలు ఇంకా అందుబాటులో లేవు.';

  @override
  String get kundliDashaTimelineEmpty => 'ఇంకా దశ కాలాలు అందుబాటులో లేవు.';

  @override
  String kundliDashaRemainingYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years సంవత్సరాలు',
      one: '1 సంవత్సరం',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months నెలలు',
      one: '1 నెల',
    );
    return '$_temp0, $_temp1 మిగిలి ఉంది';
  }

  @override
  String kundliDashaRemainingYearsOnly(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years సంవత్సరాలు',
      one: '1 సంవత్సరం',
    );
    return '$_temp0 మిగిలి ఉంది';
  }

  @override
  String kundliDashaRemainingMonthsOnly(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months నెలలు',
      one: '1 నెల',
    );
    return '$_temp0 మిగిలి ఉంది';
  }

  @override
  String get kundliDashaRemainingLessThanMonth =>
      'ఒక నెల కంటే తక్కువ మిగిలి ఉంది';

  @override
  String kundliNakshatraPada(int pada) {
    return 'పాద $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'పితృ దోషం ఉంది';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get plansUnavailableTitle => 'ప్రణాళికలు ప్రస్తుతం అందుబాటులో లేవు';

  @override
  String get plansUnavailableMessage =>
      'సబ్‌స్క్రిప్షన్ ప్రణాళికలను లోడ్ చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String perMonthBilledYearly(String price) {
    return '$price/నెల · వార్షికంగా బిల్ చేయబడుతుంది';
  }

  @override
  String savePercent(String percent) {
    return '$percent% ఆదా';
  }

  @override
  String get currentPlanLabel => 'మీ ప్రస్తుత ప్రణాళిక';

  @override
  String get purchaseSuccess =>
      'మీ సబ్‌స్క్రిప్షన్ సక్రియంగా ఉంది. Vedadarshi ప్రీమియంను ఆస్వాదించండి.';

  @override
  String get purchasesRestored => 'కొనుగోళ్లు పునరుద్ధరించబడ్డాయి.';

  @override
  String get purchasesNothingToRestore => 'గత కొనుగోళ్లు ఏవీ కనుగొనబడలేదు.';

  @override
  String get purchaseErrorGeneric =>
      'కొనుగోలు పూర్తి కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get purchaseErrorNotAllowed =>
      'ఈ ఖాతా లేదా పరికరంలో కొనుగోళ్లు అందుబాటులో లేవు.';

  @override
  String get purchaseErrorNetwork =>
      'కనెక్షన్ లేదు. మీ నెట్‌వర్క్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get purchaseErrorAlreadyOwned =>
      'ఈ ప్రణాళిక ఇప్పటికే మీ వద్ద ఉంది — సమకాలీకరించడానికి \'కొనుగోళ్లను పునరుద్ధరించు\' నొక్కండి.';

  @override
  String get purchaseErrorUnavailable =>
      'ఈ ప్రణాళిక ప్రస్తుతం అందుబాటులో లేదు.';

  @override
  String get panchangLocationUseAutomatic =>
      'నా ప్రస్తుత స్థానాన్ని ఉపయోగించండి';

  @override
  String get panchangLocationSourceManual => 'మీరు ఎంచుకున్నది';

  @override
  String get panchangLocationSourceDevice => 'మీ స్థానం నుండి గుర్తించబడింది';

  @override
  String get panchangLocationSourceBirthProfile => 'మీ జనన వివరాల నుండి';

  @override
  String get panchangLocationSourceFallback => 'డిఫాల్ట్ స్థానం';

  @override
  String get muhuratDay => 'పగటి చౌఘడియా';

  @override
  String get muhuratNight => 'రాత్రి చౌఘడియా';

  @override
  String get muhuratUnavailable => 'ముహూర్త సమయాలు ప్రస్తుతం అందుబాటులో లేవు.';

  @override
  String get partnerDetailsTitle => 'భాగస్వామి జనన వివరాలు';

  @override
  String get partnerDetailsSave => 'వివరాలు సేవ్ చేయండి';

  @override
  String get matchNeedsPartner =>
      'సరిపోల్చడానికి భాగస్వామి జనన వివరాలను జోడించండి.';

  @override
  String get emailHint => 'ఇమెయిల్ చిరునామా';

  @override
  String get passwordHint => 'పాస్‌వర్డ్';

  @override
  String get confirmPasswordHint => 'పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get signInAction => 'సైన్ ఇన్ చేయండి';

  @override
  String get forgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get noAccountPrompt => 'Vedadarshiకి కొత్తా?';

  @override
  String get createAccount => 'ఖాతా సృష్టించండి';

  @override
  String get signUpTitle => 'మీ ఖాతాను సృష్టించండి';

  @override
  String get haveAccountPrompt => 'ఇప్పటికే ఖాతా ఉందా?';

  @override
  String get forgotPasswordTitle => 'మీ పాస్‌వర్డ్‌ను రీసెట్ చేయండి';

  @override
  String get forgotPasswordSubtitle =>
      'మీరు సైన్ అప్ చేసిన ఇమెయిల్ చిరునామాను నమోదు చేయండి, మేము మీకు పాస్‌వర్డ్‌ను రీసెట్ చేయడానికి లింక్‌ను పంపుతాము.';

  @override
  String get sendResetLink => 'రీసెట్ లింక్ పంపండి';

  @override
  String get resetLinkSent =>
      'ఆ ఇమెయిల్ నమోదైనట్లయితే, రీసెట్ లింక్ పంపబడుతోంది.';

  @override
  String get passwordTooShort => 'పాస్‌వర్డ్ కనీసం 6 అక్షరాలు ఉండాలి.';

  @override
  String get passwordsDoNotMatch => 'ఆ పాస్‌వర్డ్‌లు సరిపోలడం లేదు.';

  @override
  String get authErrorEmailInUse =>
      'ఆ ఇమెయిల్ ఇప్పటికే నమోదైంది. బదులుగా సైన్ ఇన్ చేయడానికి ప్రయత్నించండి.';

  @override
  String get authErrorInvalidEmail =>
      'ఆ ఇమెయిల్ చిరునామా సరిగ్గా కనిపించడం లేదు.';

  @override
  String get authErrorWeakPassword =>
      'దయచేసి కనీసం 6 అక్షరాల పాస్‌వర్డ్‌ను ఎంచుకోండి.';

  @override
  String get authErrorWrongCredentials =>
      'తప్పు ఇమెయిల్ లేదా పాస్‌వర్డ్. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get authErrorUserNotFound => 'ఆ ఇమెయిల్ చిరునామాతో ఖాతా కనుగొనబడలేదు.';

  @override
  String get rahuKaalLabel => 'రాహు కాలం';

  @override
  String get aiWhoseChart => 'ఎవరి జాతకం?';

  @override
  String aiChartFor(String name) {
    return 'జాతకం: $name';
  }

  @override
  String get matchDetailedTitle => 'ప్రతి కూటం మీకు ఏమి సూచిస్తుంది';

  @override
  String get matchDetailedSubtitle =>
      'మొత్తం 8 కూట విశ్లేషణలు, పరిహారాలతో అన్‌లాక్ చేయండి';

  @override
  String get matchDetailedCta => 'పూర్తి విశ్లేషణను అన్‌లాక్ చేయండి';

  @override
  String get kundliHousesTitle => 'మీ భావాలు';

  @override
  String get kundliYogasTitle => 'మీ జాతకంలోని యోగాలు';

  @override
  String get kundliPredictionsCta => 'మీ పూర్తి విశ్లేషణను అన్‌లాక్ చేయండి';

  @override
  String get kundliPredictionsSubtitle =>
      'మొత్తం 12 భావాల విశ్లేషణ మరియు జాతకంలోని అన్ని యోగాలు';

  @override
  String get reportComplete => 'సంపూర్ణ జీవిత నివేదిక';

  @override
  String get reportCompleteDesc =>
      'మీ మొత్తం జాతకం ఒకే పఠనంలో — లగ్నం, యోగాలు మరియు 12 భావాలు';

  @override
  String get reportSectionOverview => 'సారాంశం';

  @override
  String get reportSectionHighlights => 'ముఖ్య అంశాలు';

  @override
  String get reportSectionTiming => 'సమయం';

  @override
  String get reportSectionGuidance => 'మార్గదర్శకం';

  @override
  String get reportSectionRemedies => 'పరిహారాలు';

  @override
  String get reportSectionStrengths => 'బలాలు';

  @override
  String get reportSectionChallenges => 'జాగ్రత్త వహించండి';

  @override
  String get reportGlimpseCta => 'పూర్తి నివేదికను తెరవండి';

  @override
  String get reportGlimpseSubtitle =>
      'మీ స్వంత జన్మ జాతకానికి ప్రతి విభాగం, పూర్తిగా';

  @override
  String get reportEmptyMessage =>
      'ఈ నివేదిక ప్రస్తుతం మీ జాతకానికి అందుబాటులో లేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String kundliDoshaMangalPresentFrom(String refs) {
    return 'మంగళ దోషం — $refs నుండి లెక్కించగా కుజుడు దోష భావంలో ఉన్నాడు';
  }

  @override
  String kundliDoshaMangalCancelledFrom(String refs) {
    return '$refs నుండి మంగళ దోషం, కానీ మీ జాతకంలో ఇది రద్దైంది';
  }

  @override
  String get kundliDoshaRefLagna => 'లగ్నం';

  @override
  String get kundliDoshaRefMoon => 'చంద్రుడు';

  @override
  String get kundliDoshaRefVenus => 'శుక్రుడు';

  @override
  String get muhuratAbhijit => 'అభిజిత్ ముహూర్తం';

  @override
  String get muhuratRahuKaal => 'రాహు కాలం';

  @override
  String get muhuratYamaganda => 'యమగండం';

  @override
  String get muhuratGulikaKaal => 'గుళిక కాలం';

  @override
  String get muhuratBrahma => 'బ్రహ్మ ముహూర్తం';

  @override
  String get askAiButton => 'దీని గురించి ఋషి AIని అడగండి';

  @override
  String get askAiSeedPlanets =>
      'నా జన్మ జాతకంలో గ్రహ స్థానాల అర్థం ఏమిటో వివరించండి.';

  @override
  String get askAiSeedDasha =>
      'నా ప్రస్తుత వింశోత్తరి దశ నాకు ఏమి సూచిస్తుంది?';

  @override
  String get askAiSeedPredictions =>
      'నా జాతకంలోని యోగాలు మరియు భావ ఫలితాలను వివరించండి.';

  @override
  String get askAiSeedMatching =>
      'మా గుణ మిలన్ స్కోరు మరియు అది మాకు ఏమి సూచిస్తుందో వివరించండి.';

  @override
  String get lblLagna => 'లగ్నం';

  @override
  String get lblRashi => 'రాశి';

  @override
  String get lblCareerHouse => 'కర్మ భావం';

  @override
  String get lblCareerLord => 'కర్మాధిపతి';

  @override
  String get lblPartnershipHouse => 'సప్తమ భావం';

  @override
  String get lblPartnershipLord => 'సప్తమాధిపతి';

  @override
  String get lblVenus => 'శుక్రుడు';

  @override
  String get lblMahadasha => 'మహాదశ';

  @override
  String get lblAntardasha => 'అంతర్దశ';

  @override
  String get lblPhase => 'దశ';

  @override
  String get lblMantra => 'మంత్రం';

  @override
  String get lblSetting => 'లోహం';

  @override
  String get lblDayToWear => 'ధరించే రోజు';

  @override
  String get lblLifePath => 'జీవన మార్గం';

  @override
  String get lblDestiny => 'విధి';

  @override
  String get lblSoulUrge => 'ఆత్మ కోరిక';

  @override
  String get lblPersonality => 'వ్యక్తిత్వం';

  @override
  String lblHouseN(int n) {
    return 'భావం $n';
  }

  @override
  String get aiFollowUpDasha => 'నా ప్రస్తుత దశ అర్థం ఏమిటి?';

  @override
  String get aiFollowUpCareer => 'నా వృత్తి అవకాశాలు ఎలా ఉన్నాయి?';

  @override
  String get aiFollowUpRemedies => 'నా జాతకానికి ఏ పరిహారాలు సరిపోతాయి?';

  @override
  String get aiFollowUpHealth => 'నా ఆరోగ్యం గురించి నా జాతకం ఏమి చెబుతుంది?';

  @override
  String get panchangMasaLabel => 'మాసం';

  @override
  String get panchangPakshaLabel => 'పక్షం';

  @override
  String dashaCurrentSentence(String planet) {
    return 'మీరు $planet మహాదశలో ఉన్నారు';
  }

  @override
  String panchangAdviceComposed(
    String quality,
    String tithi,
    String paksha,
    String nakshatra,
    String yoga,
  ) {
    return 'ఈరోజు $quality. $tithi తిథి ($paksha పక్షం), $nakshatra నక్షత్రం మరియు $yoga యోగం.';
  }

  @override
  String get choghadiyaBestForKaal =>
      'శత్రు నివారణ లేదా తాంత్రిక కార్యాల వంటి ప్రత్యేక ప్రయోజనాలకు మాత్రమే';

  @override
  String get choghadiyaBestForShubh =>
      'మత కార్యక్రమాలు, విద్య, ఆర్థిక ప్రణాళిక మరియు పెద్దలను కలవడం';

  @override
  String get choghadiyaBestForRog =>
      'శస్త్రచికిత్సలు, పోటీ కార్యకలాపాలు మరియు సవాళ్లను ఎదుర్కోవడం';

  @override
  String get choghadiyaBestForUdveg =>
      'ప్రభుత్వ పనులు, అధికారులను కలవడం మరియు పరిపాలనా కార్యాలు';

  @override
  String get choghadiyaBestForChar =>
      'ప్రయాణాలు, వాహన కొనుగోలు మరియు తాత్కాలిక ఏర్పాట్లు';

  @override
  String get choghadiyaBestForLabh =>
      'వ్యాపార ఒప్పందాలు, ఆర్థిక లావాదేవీలు, వాణిజ్యం మరియు వృత్తి నిర్ణయాలు';

  @override
  String get choghadiyaBestForAmrit =>
      'అన్ని శుభ కార్యాలు, ముఖ్యంగా కొత్త ప్రారంభాలు, వివాహాలు మరియు ముఖ్య వేడుకలు';

  @override
  String get notifDailyHoroscopeTitle => 'మీ ఈరోజు రాశిఫలం సిద్ధంగా ఉంది';

  @override
  String get notifDailyHoroscopeBody =>
      'ఈరోజు మీ ఫలితం సిద్ధంగా ఉంది — చూడటానికి నొక్కండి.';

  @override
  String get notifSawanSomvarTitle => 'రేపు శ్రావణ సోమవారం';

  @override
  String get notifSawanSomvarBody =>
      'శివుని ఉపవాస దినం. ఆచారాలు, ముహూర్తం మరియు వ్రత నియమాలు చూడండి.';

  @override
  String get notifRishiAiReplyTitle => 'ఋషి AI బదులిచ్చింది';

  @override
  String get notifRishiAiReplyBody =>
      'మీ ప్రశ్నకు సమాధానం చాట్‌లో సిద్ధంగా ఉంది.';

  @override
  String get notifRahuKaalAlertTitle => 'రాహు కాలం హెచ్చరిక';

  @override
  String get notifRahuKaalAlertBody =>
      'ఈరోజు రాహు కాలంలో కొత్త పనులు ప్రారంభించవద్దు.';

  @override
  String get notifPremiumOfferTitle => 'ప్రీమియం అన్‌లాక్ చేయండి';

  @override
  String get notifPremiumOfferBody =>
      'ప్లాన్‌లు మరియు ప్రతిదానిలో ఏమి ఉందో చూడండి.';

  @override
  String get notifNewArticleTitle => 'కొత్త వ్యాసం ప్రచురితమైంది';

  @override
  String get notifNewArticleBody =>
      'మీ కోసం జ్ఞానంలో కొత్త వ్యాసం చేర్చబడింది.';
}
