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
  String get orContinueWith => 'அல்லது இதனுடன் தொடரவும்';

  @override
  String get continueWithGoogle => 'Google உடன் தொடரவும்';

  @override
  String get exploreAsGuest => 'விருந்தினராக ஆராயவும்';

  @override
  String get termsNotice =>
      'தொடர்வதன் மூலம் நீங்கள் எங்கள் சேவை விதிமுறைகள் & தனியுரிமைக் கொள்கையை ஏற்கிறீர்கள்';

  @override
  String get authErrorNetwork =>
      'இணைய இணைப்பு இல்லை. உங்கள் நெட்வொர்க்கைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

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

  @override
  String get panchangTitle => 'பஞ்சாங்கம்';

  @override
  String get panchangSunrise => 'சூரிய உதயம்';

  @override
  String get panchangSunset => 'சூரிய அஸ்தமனம்';

  @override
  String get panchangMoonrise => 'சந்திர உதயம்';

  @override
  String get panchangMoonset => 'சந்திர அஸ்தமனம்';

  @override
  String get panchangTithi => 'திதி';

  @override
  String get panchangVaar => 'வாரம்';

  @override
  String get muhuratToday => 'இன்றைய முகூர்த்தம்';

  @override
  String get muhuratShubh => 'சுபம்';

  @override
  String get muhuratAshubh => 'அசுபம்';

  @override
  String get festivalToday => 'இன்றைய திருவிழா';

  @override
  String get details => 'விவரங்கள்';

  @override
  String get todaysSpiritualAdvice => 'இன்றைய ஆன்மீக அறிவுரை';

  @override
  String get viewAllMuhurat => 'அனைத்து முகூர்த்த நேரங்களையும் காண்க';

  @override
  String availableOffline(String time) {
    return 'ஆஃப்லைனில் கிடைக்கும் · புதுப்பிக்கப்பட்டது $time';
  }

  @override
  String get panchangLoading => 'இன்றைய பஞ்சாங்கம் ஏற்றப்படுகிறது…';

  @override
  String get panchangLoadErrorTitle => 'பஞ்சாங்கத்தை ஏற்ற முடியவில்லை';

  @override
  String get panchangLoadErrorMessage =>
      'உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get panchangRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get panchangSandboxBanner => 'மாதிரி தரவு — உங்கள் இடம் அல்ல';

  @override
  String panchangPercentRemaining(int percent) {
    return '$percent% மீதம்';
  }

  @override
  String panchangPada(int number) {
    return 'பாதம் $number';
  }

  @override
  String get horoscopeTitle => 'ராசிபலன்';

  @override
  String get periodDaily => 'தினசரி';

  @override
  String get periodWeekly => 'வாராந்திர';

  @override
  String get periodMonthly => 'மாதாந்திர';

  @override
  String get periodYearly => 'வருடாந்திர';

  @override
  String get yourSign => 'உங்கள் ராசி';

  @override
  String get todaysScores => 'இன்றைய மதிப்பெண்கள்';

  @override
  String get scoreCareer => 'தொழில்';

  @override
  String get scoreLove => 'காதல்';

  @override
  String get scoreHealth => 'ஆரோக்கியம்';

  @override
  String get scoreMoney => 'பணம்';

  @override
  String get scoreLuck => 'அதிர்ஷ்டம்';

  @override
  String get luckyTime => 'சுப நேரம்';

  @override
  String get avoidTime => 'தவிர்க்க வேண்டிய நேரம்';

  @override
  String get sectionCareerMoney => 'தொழில் & பணம்';

  @override
  String get sectionLoveRelationships => 'காதல் & உறவுகள்';

  @override
  String get sectionHealthEnergy => 'ஆரோக்கியம் & ஆற்றல்';

  @override
  String get premiumUnlockPredictions =>
      'விரிவான மாத & வருடாந்திர கணிப்புகளைத் திறக்கவும்';

  @override
  String get premiumCta => 'பிரீமியம்';

  @override
  String get horoscopeSandboxBanner => 'மாதிரி தரவு — சாண்ட்பாக்ஸ் பயன்முறை';

  @override
  String get horoscopeErrorTitle => 'ராசிபலனை ஏற்ற முடியவில்லை';

  @override
  String get horoscopeErrorMessage =>
      'ஜோதிட சேவையை அணுகுவதில் சிக்கல் ஏற்பட்டது. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get horoscopeRetryAction => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get weeklyAdviceTitle => 'இந்த வாரத்திற்கான அறிவுரை';

  @override
  String get weeklyOutlookTitle => '7-நாள் முன்னோட்டம்';

  @override
  String get weeklyBestDayBadge => 'சிறந்த நாள்';

  @override
  String get monthlyThemeTitle => 'இந்த மாதத்தின் கருப்பொருள்';

  @override
  String get monthlyScoresTitle => 'இந்த மாதத்தின் மதிப்பெண்கள்';

  @override
  String monthlyOverallRating(int percent) {
    return 'மொத்தம் $percent%';
  }

  @override
  String get monthlyKeyDatesTitle => 'இந்த மாதத்தின் முக்கிய தேதிகள்';

  @override
  String get yearlySummaryTitle => 'இந்த ஆண்டின் சுருக்கம்';

  @override
  String get yearlyScoresTitle => 'இந்த ஆண்டின் மதிப்பெண்கள்';

  @override
  String yearlyOverallRating(int percent) {
    return 'மொத்தம் $percent%';
  }

  @override
  String get luckyDay => 'அதிர்ஷ்ட நாள்';

  @override
  String get generateKundliTitle => 'ஜாதகம் உருவாக்கு';

  @override
  String get selectProfile => 'சுயவிவரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get addFamilyFriend => 'குடும்பம் அல்லது நண்பரைச் சேர்க்கவும்';

  @override
  String get chartStyle => 'விளக்கப்பட பாணி';

  @override
  String get chartNorthIndian => 'வட இந்திய பாணி';

  @override
  String get chartNorthLayout => 'வைர வடிவமைப்பு';

  @override
  String get chartSouthIndian => 'தென் இந்திய பாணி';

  @override
  String get chartSouthLayout => 'கட்ட வடிவமைப்பு';

  @override
  String get kundliCalcNote =>
      'லாஹிரி அயனாம்சத்துடன் வேத நிரயன ஜாதகம் — கிரக நிலைகள், விம்சோத்தரி தசை, தோஷ சோதனை மற்றும் கணிப்புகள் உட்பட';

  @override
  String get generateKundli => 'ஜாதகம் உருவாக்கு';

  @override
  String get lagnaKundli => 'லக்ன ஜாதகம்';

  @override
  String get pdf => 'PDF';

  @override
  String get tabChart => 'விளக்கப்படம்';

  @override
  String get tabPlanetPositions => 'கிரக நிலைகள்';

  @override
  String get tabDasha => 'விம்சோத்தரி தசை';

  @override
  String get tabPredictions => 'கணிப்புகள்';

  @override
  String get keyPlanets => 'முக்கிய கிரகங்கள்';

  @override
  String get lagna => 'லக்னம்';

  @override
  String get rashi => 'ராசி';

  @override
  String get southChartComingSoon =>
      'தென் இந்திய விளக்கப்பட வடிவமைப்பு விரைவில் வரும்.';

  @override
  String get kundliMatchingTitle => 'ஜாதக பொருத்தம்';

  @override
  String get gunMilanIntro =>
      'அஷ்டகூட குண மிலன் திருமண பொருத்தத்திற்காக 36 குணங்களில் 8 அம்சங்களை ஒப்பிடுகிறது.';

  @override
  String get groom => 'மணமகன்';

  @override
  String get bride => 'மணமகள்';

  @override
  String get change => 'மாற்று';

  @override
  String get selectBrideProfile => 'மணமகள் சுயவிவரத்தைத் தேர்ந்தெடுக்கவும்…';

  @override
  String get selectBrideHint =>
      'தேர்ந்தெடுக்க அல்லது பிறப்பு விவரங்களைச் சேர்க்க தட்டவும்';

  @override
  String get matchingPrivacyNote =>
      'பொருத்த முடிவுகள் தனிப்பட்டவை மற்றும் உங்கள் கணக்கில் மட்டும் சேமிக்கப்படும்';

  @override
  String get matchKundlis => 'ஜாதகங்களைப் பொருத்தவும்';

  @override
  String get matchResult => 'பொருத்த முடிவு';

  @override
  String outOfMax(int max) {
    return '$max இல்';
  }

  @override
  String percentCompatible(int percent) {
    return '$percent% பொருத்தம்';
  }

  @override
  String get ashtakootaBreakdown => 'அஷ்டகூட விவரம்';

  @override
  String get bandStrong => 'சிறந்தது (75%+)';

  @override
  String get bandModerate => 'நடுத்தரம் (40–74%)';

  @override
  String get bandWeak => 'பலவீனம் (<40%)';

  @override
  String get gunaVarna => 'வர்ணம்';

  @override
  String get gunaVashya => 'வஷ்யம்';

  @override
  String get gunaTara => 'தாரா';

  @override
  String get gunaYoni => 'யோனி';

  @override
  String get gunaGrahaMaitri => 'கிரக மைத்ரி';

  @override
  String get gunaGana => 'கணம்';

  @override
  String get gunaBhakoot => 'பகூட்';

  @override
  String get gunaNadi => 'நாடி';

  @override
  String get rishiAiSummary => 'ரிஷி AI சுருக்கம்';

  @override
  String get aiBadge => 'AI';

  @override
  String get detailedCompatibilityReport =>
      'விரிவான பொருத்த அறிக்கையைப் பெறவும்';

  @override
  String get tapGunaHint =>
      'ஒவ்வொரு குணமும் எதை அளக்கிறது, ஏன் முக்கியம் என்பதைப் பார்க்க தட்டவும்';

  @override
  String get matchLoading => 'உங்கள் பொருத்தத்தை கணக்கிடுகிறது…';

  @override
  String get matchErrorTitle => 'பொருத்தத்தை கணக்கிட முடியவில்லை';

  @override
  String get matchErrorMessage =>
      'ஏதோ தவறு நடந்தது. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get sandboxResultBanner =>
      'மாதிரி முடிவு — உள்ளிடப்பட்ட பிறப்பு விவரங்களிலிருந்து கணக்கிடப்படவில்லை';

  @override
  String get matchNoGunaData =>
      'இந்த பொருத்தத்திற்கு குண விவரம் கிடைக்கவில்லை.';

  @override
  String get rishiAi => 'ரிஷி AI';

  @override
  String get onlineKnowsChart => 'ஆன்லைன் · உங்கள் ஜாதகம் தெரியும்';

  @override
  String aiGreeting(String name) {
    return '🙏 வணக்கம் $name! நான் உங்கள் ஜாதகத்தை ஆய்வு செய்துள்ளேன். தொழில், திருமணம், ஆரோக்கியம் அல்லது சரியான முகூர்த்தம் பற்றி என்னிடம் எதுவும் கேளுங்கள்.';
  }

  @override
  String freeQuota(String used, String total) {
    return '$used/$total இலவசம்';
  }

  @override
  String get today => 'இன்று';

  @override
  String get askAbout => 'இவற்றைப் பற்றி கேளுங்கள்';

  @override
  String get topicCareer => 'தொழில்';

  @override
  String get topicMarriage => 'திருமணம்';

  @override
  String get topicHealth => 'ஆரோக்கியம்';

  @override
  String get topicBusiness => 'வணிகம்';

  @override
  String get topicFinance => 'நிதி';

  @override
  String get topicEducation => 'கல்வி';

  @override
  String get topicTravel => 'பயணம்';

  @override
  String get topicGemstones => 'ரத்தினங்கள்';

  @override
  String get topicRemedies => 'பரிகாரங்கள்';

  @override
  String get topicNumerology => 'எண் கணிதம்';

  @override
  String get rishiTyping => 'ரிஷி தட்டச்சு செய்கிறார்…';

  @override
  String get askAboutYourStars => 'உங்கள் நட்சத்திரங்களைப் பற்றி கேளுங்கள்…';

  @override
  String get upgradeUnlimited => 'கூடுதல் கேள்விகளுக்கு அப்கிரேட் செய்யவும்';

  @override
  String get aiErrorQuotaExceeded =>
      'இன்றைய இலவச கேள்வி வரம்பை எட்டிவிட்டீர்கள். ஒவ்வொரு நாளும் கூடுதல் கேள்விகளுக்கு அப்கிரேட் செய்யவும்.';

  @override
  String get aiErrorBirthDetailsMissing =>
      'ரிஷி உங்கள் ஜாதகத்தை ஆய்வு செய்ய முதலில் உங்கள் பிறப்பு விவரங்களைச் சேர்க்கவும்.';

  @override
  String get aiErrorInvalidQuestion =>
      'அந்தக் கேள்வியைச் செயலாக்க முடியவில்லை — மீண்டும் எழுதி முயற்சிக்கவும்.';

  @override
  String get aiErrorServiceUnavailable =>
      'ரிஷி தற்காலிகமாக கிடைக்கவில்லை. சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get aiErrorGeneric => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get aiMessageFailedToSend =>
      'அனுப்பப்படவில்லை — மீண்டும் முயற்சிக்கவும்.';

  @override
  String get premiumReportsTitle => 'பிரீமியம் அறிக்கைகள்';

  @override
  String get goPremium => 'பிரீமியம் பெறவும்';

  @override
  String goPremiumSubtitle(String total) {
    return 'அனைத்து $total அறிக்கைகள் + ஒவ்வொரு நாளும் கூடுதல் AI கேள்விகளைத் திறக்கவும்';
  }

  @override
  String get upgrade => 'மேம்படுத்தவும்';

  @override
  String readMinutes(String minutes) {
    return '$minutes நிமிடம்';
  }

  @override
  String get aiSummary => 'AI சுருக்கம்';

  @override
  String get premium => 'பிரீமியம்';

  @override
  String get free => 'இலவசம்';

  @override
  String moreReportsFooter(String remaining) {
    return '+ $remaining மேலும் அறிக்கைகள் · அனைத்திலும் PDF பதிவிறக்கம் உள்ளது';
  }

  @override
  String get reportCareer => 'தொழில் அறிக்கை';

  @override
  String get reportCareerDesc => 'தொழில், பதவி உயர்வுகள் & வணிக நேரம்';

  @override
  String get reportMarriage => 'திருமண அறிக்கை';

  @override
  String get reportMarriageDesc => 'நேரம், துணையின் பண்புகள் & பொருத்தம்';

  @override
  String get reportWealth => 'செல்வம் & நிதி';

  @override
  String get reportWealthDesc => 'வருமான ஆதாரங்கள், முதலீடுகள் & யோகங்கள்';

  @override
  String get reportHealth => 'உடல்நல அறிக்கை';

  @override
  String get reportHealthDesc =>
      'பாதிப்படையக்கூடிய காலங்கள் & தடுப்பு வழிமுறைகள்';

  @override
  String get reportSadeSati => 'சாடே சாதி அறிக்கை';

  @override
  String get reportSadeSatiDesc => 'சனி கட்டங்கள் & தாக்க பகுப்பாய்வு';

  @override
  String get reportGemstone => 'ரத்தின அறிக்கை';

  @override
  String get reportGemstoneDesc => 'பரிந்துரைக்கப்பட்ட கற்கள் & அணியும் முறை';

  @override
  String get reportNumerology => 'எண் கணித அறிக்கை';

  @override
  String get reportNumerologyDesc => 'வாழ்க்கைப் பாதை, விதி & பெயர் எண்கள்';

  @override
  String get restorePurchase => 'வாங்குதலை மீட்டமைக்கவும்';

  @override
  String get vedadarshiPremium => 'Vedadarshi பிரீமியம்';

  @override
  String get premiumTagline => 'ஆழமான பிரபஞ்ச வழிகாட்டுதல், ஒரே எளிய திட்டம்';

  @override
  String tierFeatureAiQuestions(int count) {
    return '$count AI ஜோதிடர் கேள்விகள் ஒரு நாளைக்கு';
  }

  @override
  String get tierFeatureHoroscopeStandard =>
      'வாராந்திர & மாதாந்திர ராசிபலன், முழு பஞ்சாங்க நாட்காட்டி';

  @override
  String get tierFeatureHoroscopeWithYearly =>
      'வாராந்திர, மாதாந்திர & வருடாந்திர ராசிபலன், முழு பஞ்சாங்க நாட்காட்டி';

  @override
  String tierFeatureKundalisLimited(int count) {
    return '$count சேமிக்கப்பட்ட ஜாதகங்கள்';
  }

  @override
  String get tierFeatureKundalisUnlimited => 'வரம்பற்ற சேமிக்கப்பட்ட ஜாதகங்கள்';

  @override
  String tierFeatureCompatibility(int count) {
    return '$count விரிவான பொருத்த அறிக்கைகள் மாதத்திற்கு';
  }

  @override
  String tierFeatureReportDiscount(int percent) {
    return 'பிரீமியம் அறிக்கைகளில் $percent% தள்ளுபடி';
  }

  @override
  String get tierFeaturePremiumArticles => 'பிரீமியம் கட்டுரைகள்';

  @override
  String tierFeatureLifeReportCredit(int count) {
    return '$count கம்ப்ளீட் லைஃப் ரிப்போர்ட் கிரெடிட் மாதத்திற்கு';
  }

  @override
  String get planMonthly => 'மாதாந்திர';

  @override
  String get planYearly => 'வருடாந்திர';

  @override
  String get planLifetime => 'வாழ்நாள்';

  @override
  String get perMonth => 'மாதத்திற்கு';

  @override
  String get oneTimePayment => 'ஒரு முறை கட்டணம்';

  @override
  String startPremium(String price) {
    return 'பிரீமியத்தைத் தொடங்கவும் — $price';
  }

  @override
  String get articlesTitle => 'ஞானம் & கட்டுரைகள்';

  @override
  String get savedArticlesLabel => 'சேமிக்கப்பட்ட கட்டுரைகள்';

  @override
  String get articleCategoryAll => 'அனைத்தும்';

  @override
  String articleFeaturedBadge(String tag) {
    return 'சிறப்பு · $tag';
  }

  @override
  String get articleSave => 'சேமி';

  @override
  String get articleShare => 'பகிர்';

  @override
  String get articleListen => 'கேளுங்கள்';

  @override
  String articleByline(String author, String minutes) {
    return '$author எழுதியது · $minutes நிமிட வாசிப்பு';
  }

  @override
  String articleReadMinutes(String minutes) {
    return '$minutes நிமி';
  }

  @override
  String articleMetaLine(String date, String minutes) {
    return '$date · $minutes நிமிட வாசிப்பு';
  }

  @override
  String get searchHint => 'கட்டுரைகள், அறிக்கைகள் மற்றும் மேலும் தேடுங்கள்';

  @override
  String get searchFilterArticles => 'கட்டுரைகள்';

  @override
  String get searchRecentLabel => 'சமீபத்தியவை';

  @override
  String get searchClearRecent => 'அழி';

  @override
  String get searchClearQuery => 'தேடலை அழி';

  @override
  String get searchTrendingLabel => 'டிரெண்டிங்';

  @override
  String get searchResultsLabel => 'முடிவுகள்';

  @override
  String searchNoResultsTitle(String query) {
    return '\"$query\" க்கு முடிவுகள் இல்லை';
  }

  @override
  String get searchNoResultsHint =>
      'வேறு வார்த்தைகளை முயற்சிக்கவும் அல்லது எழுத்துப்பிழையை சரிபார்க்கவும்';

  @override
  String get notificationsTitle => 'அறிவிப்புகள்';

  @override
  String get notificationsMarkAllRead => 'அனைத்தையும் படித்ததாக குறி';

  @override
  String get notificationsToday => 'இன்று';

  @override
  String get notificationsYesterday => 'நேற்று';

  @override
  String get notificationsEmptyState => 'இதுவரை அறிவிப்புகள் இல்லை';

  @override
  String get notificationsEmptyMessage =>
      'இங்கே உங்களுக்கு தினசரி ராசிபலன், திருவிழா மற்றும் பொருத்த விழிப்பூட்டல்கள் தெரியும்.';

  @override
  String get notificationsPermissionDeniedTitle => 'அறிவிப்புகளை இயக்கவும்';

  @override
  String get notificationsPermissionDeniedMessage =>
      'உங்கள் தினசரி ராசிபலன், திருவிழா விழிப்பூட்டல்கள் மற்றும் AI பதில்களைப் பெற அறிவிப்புகளை இயக்கவும்.';

  @override
  String get notificationsPermissionEnableAction => 'அறிவிப்புகளை இயக்கு';

  @override
  String get notificationsPermissionOpenSettingsAction => 'அமைப்புகளைத் திற';

  @override
  String get profileBirthProfiles => 'பிறப்பு சுயவிவரங்கள்';

  @override
  String profileProfileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count சுயவிவரங்கள்',
      one: '$count சுயவிவரம்',
    );
    return '$_temp0';
  }

  @override
  String get birthProfilesYouBadge => 'நீங்கள்';

  @override
  String get birthProfilesDelete => 'நீக்கு';

  @override
  String get birthProfilesDeleteConfirmTitle => 'இந்த சுயவிவரத்தை நீக்கவா?';

  @override
  String birthProfilesDeleteConfirmMessage(String name) {
    return 'இது $name இன் சேமிக்கப்பட்ட பிறப்பு சுயவிவரத்தை நிரந்தரமாக நீக்கும். இதை மீட்க முடியாது.';
  }

  @override
  String get birthProfilesPrimaryDeleteHint =>
      'உங்கள் சொந்த சுயவிவரத்தை இங்கே நீக்க முடியாது — அதற்கு பதிலாக அமைப்புகளில் கணக்கை நீக்கு-ஐப் பயன்படுத்தவும்.';

  @override
  String get birthProfilesEditorAddTitle => 'சுயவிவரத்தைச் சேர்';

  @override
  String get birthProfilesEditorEditTitle => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get birthProfilesEditorSave => 'சுயவிவரத்தைச் சேமி';

  @override
  String get birthProfilesSaveFailed =>
      'இந்த சுயவிவரத்தைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get birthProfilesDeleteFailed =>
      'இந்த சுயவிவரத்தை நீக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get birthProfilesSignInRequired =>
      'குடும்பம் & நண்பர் சுயவிவரங்களைச் சேர்க்க உள்நுழையவும்.';

  @override
  String get birthProfilesEmpty => 'இதுவரை சுயவிவரங்கள் இல்லை.';

  @override
  String get profileAppLanguageLabel => 'ஆப் மொழி';

  @override
  String get profileMyActivityLabel => 'எனது செயல்பாடு';

  @override
  String get profileMyReports => 'எனது அறிக்கைகள்';

  @override
  String get profileDownloadedPdfs => 'பதிவிறக்கிய PDFகள்';

  @override
  String get profileAiChatHistory => 'AI அரட்டை வரலாறு';

  @override
  String profileAiChatHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உரையாடல்கள்',
      one: '$count உரையாடல்',
    );
    return '$_temp0';
  }

  @override
  String get aiChatHistoryEmptyTitle => 'இதுவரை உரையாடல்கள் இல்லை';

  @override
  String get aiChatHistoryEmptyMessage =>
      'உங்கள் வேலை, திருமணம், ஆரோக்கியம் அல்லது சரியான முகூர்த்தம் பற்றி ரிஷி AI-யிடம் கேளுங்கள் — உங்கள் உரையாடல்கள் இங்கே தோன்றும்.';

  @override
  String get aiChatHistoryEmptyAction => 'ரிஷி AI-யிடம் கேளுங்கள்';

  @override
  String get profilePaymentHistory => 'பணம் செலுத்திய வரலாறு';

  @override
  String get profilePreferencesLabel => 'விருப்பத்தேர்வுகள்';

  @override
  String get profileAppearance => 'தோற்றம்';

  @override
  String get profileAppearanceSystem => 'கணினி · சாதனத்தைப் பின்பற்றும்';

  @override
  String get profileAppearanceLight => 'வெளிச்சம்';

  @override
  String get profileAppearanceDark => 'இருள்';

  @override
  String get profileNotifications => 'அறிவிப்புகள்';

  @override
  String get profileNotificationsSubtitle => 'தினசரி ராசிபலன், திருவிழாக்கள்';

  @override
  String get profilePanchangLocation => 'பஞ்சாங்க இடம்';

  @override
  String get profileManageSubscription => 'சந்தாவை நிர்வகிக்கவும்';

  @override
  String get profilePrivacySecurity => 'தனியுரிமை & பாதுகாப்பு';

  @override
  String get profileHelpSupport => 'உதவி & ஆதரவு';

  @override
  String get profileRewardsLabel => 'வெகுமதிகள்';

  @override
  String get profileReferEarn => 'பரிந்துரைத்து சம்பாதிக்கவும்';

  @override
  String get profileReferEarnSubtitle =>
      'ஒவ்வொரு பரிந்துரைக்கும் 1 மாதம் இலவசம் பெறுங்கள்';

  @override
  String get profileInviteFriends => 'நண்பர்களை அழைக்கவும்';

  @override
  String get profileInviteFriendsSubtitle => 'வேததர்ஷியை பகிரவும்';

  @override
  String get profileMoreLabel => 'மேலும்';

  @override
  String get profileRateApp => 'வேததர்ஷியை மதிப்பிடவும்';

  @override
  String get profileSendFeedback => 'கருத்து அனுப்பவும்';

  @override
  String get profileRestorePurchases => 'கொள்முதல்களை மீட்டமைக்கவும்';

  @override
  String get profileLogOut => 'வெளியேறு';

  @override
  String get profileDeleteAccount => 'கணக்கை நீக்கு';

  @override
  String get profileSignOutConfirmTitle => 'வெளியேறவா?';

  @override
  String get profileSignOutConfirmMessage =>
      'உங்கள் சேமித்த சுயவிவரங்கள் மற்றும் அறிக்கைகளை அணுக நீங்கள் மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get profileSignOutConfirmAction => 'வெளியேறு';

  @override
  String get profileCancel => 'ரத்து செய்';

  @override
  String get profileDeleteAccountConfirmTitle => 'உங்கள் கணக்கை நீக்கவா?';

  @override
  String get profileDeleteAccountConfirmMessage =>
      'இது உங்கள் பிறப்பு சுயவிவரங்கள், AI அரட்டை வரலாறு மற்றும் கணக்கை நிரந்தரமாக நீக்கும். இதை மீட்க முடியாது.';

  @override
  String get profileDeleteAccountConfirmAction => 'கணக்கை நீக்கு';

  @override
  String get accountDeletionErrorUnauthenticated =>
      'உங்கள் அமர்வு காலாவதியானது. உங்கள் கணக்கை நீக்க மீண்டும் உள்நுழையவும்.';

  @override
  String get accountDeletionErrorGeneric =>
      'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get legalPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get legalTermsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get legalRefundsCancellation => 'பணத்திரும்பப் பெறுதல் & ரத்து';

  @override
  String get legalAccountDataDeletion => 'கணக்கு & தரவு நீக்கம்';

  @override
  String get profileEmailSupport => 'எங்களுக்கு மின்னஞ்சல் அனுப்பவும்';

  @override
  String get profileEmailSupportSubtitle => 'Vedadarshii@gmail.com';

  @override
  String get supportEmailSubject => 'வேததர்ஷி ஆதரவு';

  @override
  String get feedbackEmailSubject => 'வேததர்ஷி கருத்து';

  @override
  String profileInviteFriendsMessage(String link) {
    return 'வேததர்ஷியில் சேருங்கள் — வேத ஜோதிடம், பஞ்சாங்கம் மற்றும் ராசிபலனுக்கான உங்கள் தினசரி துணை. இங்கே பதிவிறக்கவும்: $link';
  }

  @override
  String get kundliSandboxBanner =>
      'மாதிரி ஜாதகம் — உங்கள் பிறப்பு விவரங்களிலிருந்து கணக்கிடப்படவில்லை';

  @override
  String get kundliLoadErrorTitle => 'உங்கள் ஜாதகத்தை ஏற்ற முடியவில்லை';

  @override
  String get kundliLoadErrorMessage =>
      'உங்கள் ஜாதகத்தைப் பெறுவதில் ஏதோ தவறு ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get kundliRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get kundliLoadingChart => 'உங்கள் ஜாதகம் ஏற்றப்படுகிறது…';

  @override
  String get kundliValueUnavailable => '—';

  @override
  String get kundliDoshaMangalPresent => 'மங்கள தோஷம் உள்ளது';

  @override
  String get kundliDoshaMangalAbsent => 'மங்கள தோஷம் இல்லை';

  @override
  String get kundliDoshaKaalSarpPresent => 'காள சர்ப்ப தோஷம் கண்டறியப்பட்டது';

  @override
  String kundliDoshaKaalSarpPresentType(String type) {
    return 'காள சர்ப்ப தோஷம் கண்டறியப்பட்டது ($type)';
  }

  @override
  String get kundliDoshaKaalSarpAbsent => 'காள சர்ப்ப தோஷம் இல்லை';

  @override
  String kundliPlanetPositionsAyanamsa(String name) {
    return 'அயனாம்சம்: $name';
  }

  @override
  String kundliHouseNumber(int house) {
    return 'பாவம் $house';
  }

  @override
  String get kundliRetrograde => 'வக்ரம்';

  @override
  String get kundliDashaLoadErrorTitle => 'உங்கள் தசையை ஏற்ற முடியவில்லை';

  @override
  String get kundliDashaLoadErrorMessage =>
      'உங்கள் விம்சோத்தரி தசையைப் பெறும்போது சிக்கல் ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get kundliDashaLoading => 'உங்கள் தசை ஏற்றப்படுகிறது…';

  @override
  String get kundliDashaCurrentTitle => 'தற்போதைய மகாதசை';

  @override
  String get kundliDashaBalanceTitle => 'பிறப்பின்போது தசை மீதி';

  @override
  String kundliDashaBalanceValue(int years, int months, int days) {
    return '$years ஆண்டுகள், $months மாதங்கள், $days நாட்கள்';
  }

  @override
  String get kundliDashaTimelineTitle => 'தசை காலவரிசை';

  @override
  String get kundliDashaCurrentBadge => 'தற்போதைய';

  @override
  String get kundliPlanetPositionsEmpty =>
      'இந்த ஜாதகத்திற்கு கிரக நிலைகள் இன்னும் கிடைக்கவில்லை.';

  @override
  String get kundliDashaTimelineEmpty => 'இன்னும் தசை காலங்கள் இல்லை.';

  @override
  String kundliDashaRemainingYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years ஆண்டுகள்',
      one: '1 ஆண்டு',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months மாதங்கள்',
      one: '1 மாதம்',
    );
    return '$_temp0, $_temp1 மீதம் உள்ளது';
  }

  @override
  String kundliDashaRemainingYearsOnly(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years ஆண்டுகள்',
      one: '1 ஆண்டு',
    );
    return '$_temp0 மீதம் உள்ளது';
  }

  @override
  String kundliDashaRemainingMonthsOnly(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months மாதங்கள்',
      one: '1 மாதம்',
    );
    return '$_temp0 மீதம் உள்ளது';
  }

  @override
  String get kundliDashaRemainingLessThanMonth =>
      'ஒரு மாதத்திற்கும் குறைவாக மீதம் உள்ளது';

  @override
  String kundliNakshatraPada(int pada) {
    return 'பாதம் $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'பித்ரு தோஷம் உள்ளது';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get plansUnavailableTitle => 'திட்டங்கள் தற்போது கிடைக்கவில்லை';

  @override
  String get plansUnavailableMessage =>
      'சந்தா திட்டங்களை ஏற்ற முடியவில்லை. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String perMonthBilledYearly(String price) {
    return '$price/மாதம் · ஆண்டுதோறும் பில் செய்யப்படும்';
  }

  @override
  String savePercent(String percent) {
    return '$percent% சேமிப்பு';
  }

  @override
  String get currentPlanLabel => 'உங்கள் தற்போதைய திட்டம்';

  @override
  String get purchaseSuccess =>
      'உங்கள் சந்தா செயலில் உள்ளது. Vedadarshi பிரீமியத்தை அனுபவியுங்கள்.';

  @override
  String get purchasesRestored => 'கொள்முதல்கள் மீட்டமைக்கப்பட்டன.';

  @override
  String get purchasesNothingToRestore => 'முந்தைய கொள்முதல்கள் எதுவும் இல்லை.';

  @override
  String get purchaseErrorGeneric =>
      'கொள்முதலை முடிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get purchaseErrorNotAllowed =>
      'இந்தக் கணக்கிலோ சாதனத்திலோ கொள்முதல் கிடைக்கவில்லை.';

  @override
  String get purchaseErrorPending =>
      'உங்கள் கட்டணம் செயலாக்கத்தில் உள்ளது. உறுதியானதும் பிரீமியம் திறக்கப்படும்.';

  @override
  String get purchaseErrorNetwork =>
      'இணைப்பு இல்லை. உங்கள் நெட்வொர்க்கைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get purchaseErrorAlreadyOwned =>
      'இந்தத் திட்டம் ஏற்கெனவே உங்களிடம் உள்ளது — ஒத்திசைக்க \'கொள்முதலை மீட்டமை\' என்பதை அழுத்தவும்.';

  @override
  String get purchaseErrorUnavailable =>
      'இந்தத் திட்டம் தற்போது கிடைக்கவில்லை.';

  @override
  String get panchangLocationUseAutomatic =>
      'எனது தற்போதைய இருப்பிடத்தைப் பயன்படுத்து';

  @override
  String get panchangLocationSourceManual => 'நீங்கள் தேர்ந்தெடுத்தது';

  @override
  String get panchangLocationSourceDevice =>
      'உங்கள் இருப்பிடத்திலிருந்து கண்டறியப்பட்டது';

  @override
  String get panchangLocationSourceBirthProfile =>
      'உங்கள் பிறப்பு விவரங்களிலிருந்து';

  @override
  String get panchangLocationSourceFallback => 'இயல்புநிலை இருப்பிடம்';

  @override
  String get muhuratDay => 'பகல் சௌகடியா';

  @override
  String get muhuratNight => 'இரவு சௌகடியா';

  @override
  String get muhuratUnavailable => 'முகூர்த்த நேரங்கள் தற்போது கிடைக்கவில்லை.';

  @override
  String get partnerDetailsTitle => 'துணையின் பிறப்பு விவரங்கள்';

  @override
  String get partnerDetailsSave => 'விவரங்களைச் சேமி';

  @override
  String get matchNeedsPartner =>
      'பொருத்த துணையின் பிறப்பு விவரங்களைச் சேர்க்கவும்.';

  @override
  String get emailHint => 'மின்னஞ்சல் முகவரி';

  @override
  String get passwordHint => 'கடவுச்சொல்';

  @override
  String get confirmPasswordHint => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get signInAction => 'உள்நுழையவும்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get noAccountPrompt => 'Vedadarshi-க்கு புதியவரா?';

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get signUpTitle => 'உங்கள் கணக்கை உருவாக்கவும்';

  @override
  String get haveAccountPrompt => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get forgotPasswordTitle => 'உங்கள் கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get forgotPasswordSubtitle =>
      'நீங்கள் பதிவு செய்த மின்னஞ்சல் முகவரியை உள்ளிடவும், உங்கள் கடவுச்சொல்லை மீட்டமைக்க ஒரு இணைப்பை அனுப்புவோம்.';

  @override
  String get sendResetLink => 'மீட்டமைப்பு இணைப்பை அனுப்பவும்';

  @override
  String get resetLinkSent =>
      'அந்த மின்னஞ்சல் பதிவு செய்யப்பட்டிருந்தால், மீட்டமைப்பு இணைப்பு அனுப்பப்படுகிறது.';

  @override
  String get passwordTooShort =>
      'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்.';

  @override
  String get passwordsDoNotMatch => 'அந்த கடவுச்சொற்கள் பொருந்தவில்லை.';

  @override
  String get authErrorEmailInUse =>
      'அந்த மின்னஞ்சல் ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது. அதற்கு பதிலாக உள்நுழையவும்.';

  @override
  String get authErrorInvalidEmail =>
      'அந்த மின்னஞ்சல் முகவரி சரியாகத் தெரியவில்லை.';

  @override
  String get authErrorWeakPassword =>
      'தயவுசெய்து குறைந்தது 6 எழுத்துகள் கொண்ட கடவுச்சொல்லைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get authErrorWrongCredentials =>
      'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல். மீண்டும் முயற்சிக்கவும்.';

  @override
  String get authErrorUserNotFound =>
      'அந்த மின்னஞ்சல் முகவரியுடன் கணக்கு எதுவும் இல்லை.';

  @override
  String get rahuKaalLabel => 'ராகு காலம்';

  @override
  String get aiWhoseChart => 'யாருடைய ஜாதகம்?';

  @override
  String aiChartFor(String name) {
    return 'ஜாதகம்: $name';
  }

  @override
  String get matchDetailedTitle => 'ஒவ்வொரு கூடமும் உங்களுக்கு என்ன சொல்கிறது';

  @override
  String get matchDetailedSubtitle =>
      'அனைத்து 8 கூட விளக்கங்களையும் பரிகாரங்களுடன் திறக்கவும்';

  @override
  String get matchDetailedCta => 'முழு விளக்கத்தைத் திறக்கவும்';

  @override
  String get kundliHousesTitle => 'உங்கள் பாவங்கள்';

  @override
  String get kundliYogasTitle => 'உங்கள் ஜாதகத்தின் யோகங்கள்';

  @override
  String get kundliPredictionsCta => 'உங்கள் முழு விளக்கத்தைத் திறக்கவும்';

  @override
  String get kundliPredictionsSubtitle =>
      'அனைத்து 12 பாவ விளக்கங்களும் ஜாதகத்தின் அனைத்து யோகங்களும்';

  @override
  String get reportComplete => 'முழு வாழ்க்கை அறிக்கை';

  @override
  String get reportCompleteDesc =>
      'உங்கள் முழு ஜாதகமும் ஒரே வாசிப்பில் — லக்னம், யோகங்கள் மற்றும் 12 பாவங்கள்';

  @override
  String get reportSectionOverview => 'சுருக்கம்';

  @override
  String get reportSectionHighlights => 'முக்கிய கண்டுபிடிப்புகள்';

  @override
  String get reportSectionTiming => 'காலம்';

  @override
  String get reportSectionGuidance => 'வழிகாட்டுதல்';

  @override
  String get reportSectionRemedies => 'பரிகாரங்கள்';

  @override
  String get reportSectionStrengths => 'பலங்கள்';

  @override
  String get reportSectionChallenges => 'கவனிக்க வேண்டியவை';

  @override
  String get reportGlimpseCta => 'முழு அறிக்கையைத் திறக்கவும்';

  @override
  String get reportGlimpseSubtitle =>
      'உங்கள் சொந்த ஜாதகத்திற்கான ஒவ்வொரு பகுதியும், முழுமையாக';

  @override
  String get reportEmptyMessage =>
      'இந்த அறிக்கை தற்போது உங்கள் ஜாதகத்திற்குக் கிடைக்கவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String kundliDoshaMangalPresentFrom(String refs) {
    return 'செவ்வாய் தோஷம் — $refs இலிருந்து எண்ணும்போது செவ்வாய் தோஷ வீட்டில் உள்ளது';
  }

  @override
  String kundliDoshaMangalCancelledFrom(String refs) {
    return '$refs இலிருந்து செவ்வாய் தோஷம், ஆனால் உங்கள் ஜாதகத்தில் இது ரத்தாகிறது';
  }

  @override
  String get kundliDoshaRefLagna => 'லக்னம்';

  @override
  String get kundliDoshaRefMoon => 'சந்திரன்';

  @override
  String get kundliDoshaRefVenus => 'சுக்கிரன்';

  @override
  String get muhuratAbhijit => 'அபிஜித் முகூர்த்தம்';

  @override
  String get muhuratRahuKaal => 'ராகு காலம்';

  @override
  String get muhuratYamaganda => 'யமகண்டம்';

  @override
  String get muhuratGulikaKaal => 'குளிகை காலம்';

  @override
  String get muhuratBrahma => 'பிரம்ம முகூர்த்தம்';

  @override
  String get askAiButton => 'இதைப் பற்றி ரிஷி AI-யிடம் கேளுங்கள்';

  @override
  String get askAiSeedPlanets =>
      'என் ஜாதகத்தில் கிரக நிலைகளின் பொருள் என்ன என்பதை விளக்குங்கள்.';

  @override
  String get askAiSeedDasha =>
      'என் தற்போதைய விம்சோத்தரி தசை எனக்கு எதைக் குறிக்கிறது?';

  @override
  String get askAiSeedPredictions =>
      'என் ஜாதகத்தின் யோகங்கள் மற்றும் பாவ பலன்களை விளக்குங்கள்.';

  @override
  String get askAiSeedMatching =>
      'எங்கள் குண மிலன் மதிப்பெண் மற்றும் அது எங்களுக்கு எதைக் குறிக்கிறது என்பதை விளக்குங்கள்.';

  @override
  String get lblLagna => 'லக்னம்';

  @override
  String get lblRashi => 'ராசி';

  @override
  String get lblCareerHouse => 'தொழில் பாவம்';

  @override
  String get lblCareerLord => 'தொழிலதிபதி';

  @override
  String get lblPartnershipHouse => 'ஏழாம் பாவம்';

  @override
  String get lblPartnershipLord => 'ஏழாமதிபதி';

  @override
  String get lblVenus => 'சுக்கிரன்';

  @override
  String get lblMahadasha => 'மகாதசை';

  @override
  String get lblAntardasha => 'அந்தர்தசை';

  @override
  String get lblPhase => 'நிலை';

  @override
  String get lblMantra => 'மந்திரம்';

  @override
  String get lblSetting => 'உலோகம்';

  @override
  String get lblDayToWear => 'அணியும் நாள்';

  @override
  String get lblLifePath => 'வாழ்க்கைப் பாதை';

  @override
  String get lblDestiny => 'விதி';

  @override
  String get lblSoulUrge => 'ஆன்ம விருப்பம்';

  @override
  String get lblPersonality => 'ஆளுமை';

  @override
  String get lblBirthdayNumber => 'பிறந்தநாள்';

  @override
  String get lblMaturity => 'முதிர்ச்சி';

  @override
  String get lblLifeLesson => 'வாழ்க்கைப் பாடம்';

  @override
  String lblHouseN(int n) {
    return 'பாவம் $n';
  }

  @override
  String get aiFollowUpDasha => 'என் தற்போதைய தசையின் பொருள் என்ன?';

  @override
  String get aiFollowUpCareer => 'என் தொழில் வாய்ப்புகள் எப்படி உள்ளன?';

  @override
  String get aiFollowUpRemedies =>
      'என் ஜாதகத்திற்கு எந்த பரிகாரங்கள் பொருந்தும்?';

  @override
  String get aiFollowUpHealth =>
      'என் ஆரோக்கியம் குறித்து ஜாதகம் என்ன கூறுகிறது?';

  @override
  String get panchangMasaLabel => 'மாதம்';

  @override
  String get panchangPakshaLabel => 'பட்சம்';

  @override
  String dashaCurrentSentence(String planet) {
    return 'நீங்கள் $planet மகாதசையில் உள்ளீர்கள்';
  }

  @override
  String panchangAdviceComposed(
    String quality,
    String tithi,
    String paksha,
    String nakshatra,
    String yoga,
  ) {
    return 'இன்று $quality. $tithi திதி ($paksha பட்சம்), $nakshatra நட்சத்திரம் மற்றும் $yoga யோகம்.';
  }

  @override
  String get choghadiyaBestForKaal =>
      'எதிரிகளை வெல்லுதல் அல்லது தாந்த்ரீக செயல்கள் போன்ற சிறப்பு நோக்கங்களுக்கு மட்டும்';

  @override
  String get choghadiyaBestForShubh =>
      'மத சடங்குகள், கல்வி, நிதித் திட்டமிடல் மற்றும் பெரியோரைச் சந்தித்தல்';

  @override
  String get choghadiyaBestForRog =>
      'அறுவை சிகிச்சைகள், போட்டி நடவடிக்கைகள் மற்றும் சவால்களை எதிர்கொள்ளுதல்';

  @override
  String get choghadiyaBestForUdveg =>
      'அரசு பணிகள், அதிகாரிகளைச் சந்தித்தல் மற்றும் நிர்வாகப் பணிகள்';

  @override
  String get choghadiyaBestForChar =>
      'பயணங்கள், வாகனம் வாங்குதல் மற்றும் தற்காலிக ஏற்பாடுகள்';

  @override
  String get choghadiyaBestForLabh =>
      'வணிக ஒப்பந்தங்கள், நிதி பரிவர்த்தனைகள், வர்த்தகம் மற்றும் தொழில் நகர்வுகள்';

  @override
  String get choghadiyaBestForAmrit =>
      'அனைத்து சுப காரியங்கள், குறிப்பாக புதிய முயற்சிகள், திருமணங்கள் மற்றும் முக்கிய விழாக்கள்';

  @override
  String get notifDailyHoroscopeTitle => 'உங்கள் இன்றைய ராசிபலன் தயார்';

  @override
  String get notifDailyHoroscopeBody =>
      'இன்றைய பலன் காத்திருக்கிறது — பார்க்க தட்டவும்.';

  @override
  String get notifSawanSomvarTitle => 'நாளை சாவன் சோமவார்';

  @override
  String get notifSawanSomvarBody =>
      'சிவபெருமான் விரத நாள். சடங்குகள், முகூர்த்தம் மற்றும் விரத விதிகளைக் காண்க.';

  @override
  String get notifRishiAiReplyTitle => 'ரிஷி AI பதிலளித்தது';

  @override
  String get notifRishiAiReplyBody =>
      'உங்கள் கேள்விக்கான பதில் அரட்டையில் காத்திருக்கிறது.';

  @override
  String get notifRahuKaalAlertTitle => 'ராகு காலம் எச்சரிக்கை';

  @override
  String get notifRahuKaalAlertBody =>
      'இன்றைய ராகு காலத்தில் புதிதாக எதையும் தொடங்க வேண்டாம்.';

  @override
  String get notifPremiumOfferTitle => 'பிரீமியத்தைத் திறக்கவும்';

  @override
  String get notifPremiumOfferBody =>
      'திட்டங்களையும் ஒவ்வொன்றில் உள்ளதையும் காண்க.';

  @override
  String get notifNewArticleTitle => 'புதிய கட்டுரை வெளியிடப்பட்டது';

  @override
  String get notifNewArticleBody =>
      'உங்களுக்கான ஞானத்தில் புதிய கட்டுரை சேர்க்கப்பட்டுள்ளது.';

  @override
  String get chooseSavedProfile => 'சேமித்த சுயவிவரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get enterNewDetails => 'புதிய விவரங்களை உள்ளிடவும்';

  @override
  String get noSavedProfiles => 'வேறு சேமித்த சுயவிவரங்கள் இல்லை';

  @override
  String get premiumMember => 'பிரீமியம் உறுப்பினர்';

  @override
  String get upgradeToPremium => 'பிரீமியத்திற்கு மேம்படுத்தவும்';

  @override
  String get premiumUnlockHint =>
      'முழு பலன்கள் மற்றும் அறிக்கைகளைத் திறக்கவும்';

  @override
  String get aiPacksTitle => 'AI கேள்வி தொகுப்புகள்';

  @override
  String get aiPacksSubtitle =>
      'இன்றைய கேள்விகள் தீர்ந்ததும் நிரப்பிக்கொள்ளுங்கள்';

  @override
  String aiPackQuestions(String count) {
    return '$count கேள்விகள்';
  }

  @override
  String aiPackValidity(String days) {
    return '$days நாட்கள் செல்லுபடியாகும்';
  }

  @override
  String get aiPackBestValue => 'சிறந்த மதிப்பு';

  @override
  String get aiPacksUnavailable => 'தொகுப்புகள் தற்போது கிடைக்கவில்லை.';

  @override
  String get aiPackPurchased =>
      'வாங்குதல் முடிந்தது — உங்கள் கேள்விகள் சற்று நேரத்தில் தோன்றும்.';

  @override
  String aiPackBalance(String count) {
    return '$count தொகுப்பு கேள்விகள் மீதம்';
  }

  @override
  String get aiPackTopUp => 'கேள்விகளை நிரப்பு';

  @override
  String get dailyReadingTitle => 'தனிப்பட்ட தினசரி பலன்';

  @override
  String get dailyReadingDesc =>
      'உங்கள் சொந்த ஜாதகத்திலிருந்து இன்றைய பலன் — ராசி மட்டுமல்ல';

  @override
  String get dailyReadingBuy => 'இன்றைய பலனைத் திறக்கவும்';

  @override
  String dailyReadingActiveUntil(String time) {
    return '$time வரை கிடைக்கும்';
  }

  @override
  String get dailyReadingLocked =>
      'உங்கள் ஜாதகத்தில் இருந்து கணக்கிடப்பட்ட இன்றைய தனிப்பட்ட பலன்.';

  @override
  String get dailyReadingUnavailable => 'இது தற்போது கிடைக்கவில்லை.';

  @override
  String get dailyReadingLucky => 'இன்று அதிர்ஷ்டம்';

  @override
  String get dailyReadingRemedies => 'பரிகாரங்கள்';

  @override
  String get dailyReadingAreaCareer => 'தொழில்';

  @override
  String get dailyReadingAreaFinance => 'நிதி';

  @override
  String get dailyReadingAreaHealth => 'உடல்நலம்';

  @override
  String get dailyReadingAreaRelationship => 'உறவுகள்';
}
