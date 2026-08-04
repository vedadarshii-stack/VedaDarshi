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
  String get horoscopeSandboxBanner =>
      'மாதிரி தரவு — வேதிகா சாண்ட்பாக்ஸ் பயன்முறை';

  @override
  String get horoscopeErrorTitle => 'ராசிபலனை ஏற்ற முடியவில்லை';

  @override
  String get horoscopeErrorMessage =>
      'வேதிகாவை அணுகுவதில் சிக்கல் ஏற்பட்டது. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

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
      'கணக்கீடுகள் ஸ்விஸ் எஃபெமெரிஸ் மற்றும் லாஹிரி அயனாம்சத்தைப் பயன்படுத்துகின்றன';

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
  String get upgradeUnlimited => 'வரம்பற்ற கேள்விகளுக்கு அப்கிரேட் செய்யவும்';

  @override
  String get aiNotConnected =>
      'AI சேவை இணைக்கப்பட்டதும் பதில்கள் இங்கே தோன்றும்.';

  @override
  String get premiumReportsTitle => 'பிரீமியம் அறிக்கைகள்';

  @override
  String get goPremium => 'பிரீமியம் பெறவும்';

  @override
  String goPremiumSubtitle(String total) {
    return 'அனைத்து $total அறிக்கைகள் + வரம்பற்ற AI கேள்விகளை திறக்கவும்';
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
  String get premiumTagline =>
      'வரம்பற்ற பிரபஞ்ச வழிகாட்டுதல், ஒரே எளிய திட்டம்';

  @override
  String benefitReports(String total) {
    return 'PDF ஏற்றுமதியுடன் அனைத்து $total பிரீமியம் அறிக்கைகள்';
  }

  @override
  String get benefitUnlimitedAi => 'வரம்பற்ற AI ஜோதிடர் கேள்விகள்';

  @override
  String get benefitAdvancedKundli =>
      'மேம்பட்ட ஜாதகம்: தசை, தோஷம் & பரிகாரங்கள்';

  @override
  String get benefitAdFree => 'ஆப் முழுவதும் விளம்பரமற்ற அனுபவம்';

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
  String get billingFinePrint =>
      'Google Play வழியாக பில் செய்யப்படுகிறது · எப்போது வேண்டுமானாலும் ரத்து செய்யலாம் · RevenueCat மூலம் பாதுகாப்பானது';

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
  String profileProfileCount(String count) {
    return '$count சுயவிவரம்';
  }

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
  String kundliNakshatraPada(int pada) {
    return 'பாதம் $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'பித்ரு தோஷம் உள்ளது';
}
