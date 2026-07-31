// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'आपका विश्वसनीय वैदिक साथी';

  @override
  String get introStarsTitle => 'आपके सितारे, सरल भाषा में';

  @override
  String get introStarsSubtitle =>
      'दैनिक राशिफल, पंचांग और कुंडली — प्रामाणिक वैदिक गणनाओं से';

  @override
  String get introAiTitle => 'AI ज्योतिषी से पूछें';

  @override
  String get introAiSubtitle =>
      'आपकी कुंडली पर आधारित व्यक्तिगत मार्गदर्शन — आपकी अपनी भाषा में';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get languageTitle => 'अपनी भाषा चुनें';

  @override
  String get languageNativePrompt => 'अपनी भाषा चुनें';

  @override
  String get languageSettingsHint => 'आप इसे कभी भी सेटिंग्स में बदल सकते हैं';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get welcomeHeroTagline => 'पंचांग · कुंडली · राशिफल · AI ज्योतिषी';

  @override
  String get welcomeGreeting => 'नमस्ते 🙏';

  @override
  String get welcomeSubtitle =>
      'अपनी जन्म कुंडली सहेजने और व्यक्तिगत भविष्यवाणियाँ अनलॉक करने के लिए साइन इन करें।';

  @override
  String get phoneHint => 'मोबाइल नंबर';

  @override
  String get getOtp => 'OTP प्राप्त करें';

  @override
  String get orContinueWith => 'या इसके साथ जारी रखें';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get exploreAsGuest => 'अतिथि के रूप में देखें';

  @override
  String get termsNotice =>
      'जारी रखकर आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं';

  @override
  String get otpTitle => 'अपना नंबर सत्यापित करें';

  @override
  String otpSubtitle(String phone) {
    return '$phone पर भेजा गया 6-अंकों का कोड दर्ज करें';
  }

  @override
  String get otpNoCode => 'कोड नहीं मिला?';

  @override
  String otpResendIn(String seconds) {
    return '$seconds में पुनः भेजें';
  }

  @override
  String get otpResend => 'पुनः भेजें';

  @override
  String get otpVerify => 'सत्यापित करें और जारी रखें';

  @override
  String get otpPrivacy => '🔒 आपका नंबर निजी और सुरक्षित रखा जाता है';

  @override
  String get otpResent => 'एक नया कोड भेजा गया है।';

  @override
  String get authErrorNetwork =>
      'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें और पुनः प्रयास करें।';

  @override
  String get authErrorInvalidPhone =>
      'यह फ़ोन नंबर सही नहीं लगता। कृपया जांचें और पुनः प्रयास करें।';

  @override
  String get authErrorInvalidOtp => 'यह कोड गलत है। कृपया पुनः प्रयास करें।';

  @override
  String get authErrorOtpExpired =>
      'यह कोड समाप्त हो गया है। कृपया एक नया अनुरोध करें।';

  @override
  String get authErrorTooManyRequests =>
      'बहुत अधिक प्रयास। कृपया पुनः प्रयास करने से पहले कुछ समय प्रतीक्षा करें।';

  @override
  String get authErrorProviderDisabled =>
      'यह साइन-इन विधि अभी उपलब्ध नहीं है। कृपया कोई अन्य विकल्प आज़माएं।';

  @override
  String get authErrorUnknown => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get birthTitle => 'आपका जन्म विवरण';

  @override
  String get birthSubtitle =>
      'ये आपकी कुंडली, राशिफल और व्यक्तिगत रिपोर्ट को सटीक बनाते हैं। सटीकता मायने रखती है ✨';

  @override
  String get birthFullNameLabel => 'पूरा नाम';

  @override
  String get birthNameHint => 'अपना पूरा नाम दर्ज करें';

  @override
  String get birthGenderLabel => 'लिंग';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderFemale => 'महिला';

  @override
  String get genderOther => 'अन्य';

  @override
  String get birthDobLabel => 'जन्म तिथि';

  @override
  String get birthDateHint => 'तारीख चुनें';

  @override
  String get birthTobLabel => 'जन्म समय';

  @override
  String get birthTimeHint => 'समय चुनें';

  @override
  String get birthTimeUnknownValue => 'दोपहर 12:00 बजे';

  @override
  String get birthPlaceLabel => 'जन्म स्थान';

  @override
  String get birthPlaceHint => 'अपना जन्म शहर खोजें';

  @override
  String birthGeoDetected(String lat, String lon, String offset, String zone) {
    return '✓ स्वतः पहचाना गया: $lat, $lon · $offset ($zone)';
  }

  @override
  String get birthTimeUnknown => 'मुझे अपना सटीक जन्म समय नहीं पता';

  @override
  String get birthSave => 'मेरी प्रोफ़ाइल बनाएं ✨';

  @override
  String get birthFooter =>
      'आप बाद में परिवार और दोस्तों की प्रोफ़ाइल जोड़ सकते हैं';

  @override
  String get placeResolveFailed =>
      'वह स्थान लोड नहीं हो सका। कृपया कोई और चुनें।';

  @override
  String get todaysPanchang => 'आज का पंचांग';

  @override
  String get nakshatra => 'नक्षत्र';

  @override
  String get yoga => 'योग';

  @override
  String get karana => 'करण';

  @override
  String get fullPanchang => 'पूर्ण पंचांग';

  @override
  String get todayAtAGlance => 'आज एक नज़र में';

  @override
  String get luckyNumber => 'शुभ अंक';

  @override
  String get luckyColor => 'शुभ रंग';

  @override
  String get direction => 'दिशा';

  @override
  String get todaysPlanet => 'आज का ग्रह';

  @override
  String get moonPhase => 'चंद्र कला';

  @override
  String get muhurat => 'मुहूर्त';

  @override
  String get todaysRemedy => 'आज का उपाय';

  @override
  String get todaysMantra => 'आज का मंत्र';

  @override
  String get festivalOfTheDay => 'आज का त्योहार';

  @override
  String get rituals => 'अनुष्ठान';

  @override
  String get explore => 'अन्वेषण करें';

  @override
  String get navKundli => 'कुंडली';

  @override
  String get navMatch => 'मिलान';

  @override
  String get navReports => 'रिपोर्ट';

  @override
  String get navAskAi => 'AI से पूछें';

  @override
  String get todaysHoroscope => 'आज का राशिफल';

  @override
  String get allSigns => 'सभी राशियाँ';

  @override
  String get wisdomForYou => 'आपके लिए ज्ञान';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get continueWithRishiAi => 'ऋषि AI के साथ जारी रखें';

  @override
  String get continueAction => 'जारी रखें';

  @override
  String get recentReports => 'हाल की रिपोर्ट';

  @override
  String get myReports => 'मेरी रिपोर्ट';

  @override
  String get navHome => 'होम';

  @override
  String get navPanchang => 'पंचांग';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get panchangTitle => 'पंचांग';

  @override
  String get panchangSunrise => 'सूर्योदय';

  @override
  String get panchangSunset => 'सूर्यास्त';

  @override
  String get panchangMoonrise => 'चंद्रोदय';

  @override
  String get panchangMoonset => 'चंद्रास्त';

  @override
  String get panchangTithi => 'तिथि';

  @override
  String get panchangVaar => 'वार';

  @override
  String get muhuratToday => 'आज का मुहूर्त';

  @override
  String get muhuratShubh => 'शुभ';

  @override
  String get muhuratAshubh => 'अशुभ';

  @override
  String get festivalToday => 'आज का त्योहार';

  @override
  String get details => 'विवरण';

  @override
  String get todaysSpiritualAdvice => 'आज की आध्यात्मिक सलाह';

  @override
  String get viewAllMuhurat => 'सभी मुहूर्त समय देखें';

  @override
  String availableOffline(String time) {
    return 'ऑफ़लाइन उपलब्ध · अपडेट किया गया $time';
  }

  @override
  String get horoscopeTitle => 'राशिफल';

  @override
  String get periodDaily => 'दैनिक';

  @override
  String get periodWeekly => 'साप्ताहिक';

  @override
  String get periodMonthly => 'मासिक';

  @override
  String get periodYearly => 'वार्षिक';

  @override
  String get yourSign => 'आपकी राशि';

  @override
  String get todaysScores => 'आज के स्कोर';

  @override
  String get scoreCareer => 'करियर';

  @override
  String get scoreLove => 'प्रेम';

  @override
  String get scoreHealth => 'स्वास्थ्य';

  @override
  String get scoreMoney => 'धन';

  @override
  String get scoreLuck => 'भाग्य';

  @override
  String get luckyTime => 'शुभ समय';

  @override
  String get avoidTime => 'अशुभ समय';

  @override
  String get sectionCareerMoney => 'करियर और धन';

  @override
  String get sectionLoveRelationships => 'प्रेम और रिश्ते';

  @override
  String get sectionHealthEnergy => 'स्वास्थ्य और ऊर्जा';

  @override
  String get premiumUnlockPredictions =>
      'विस्तृत मासिक और वार्षिक भविष्यवाणियां अनलॉक करें';

  @override
  String get premiumCta => 'प्रीमियम';

  @override
  String get generateKundliTitle => 'कुंडली बनाएं';

  @override
  String get selectProfile => 'प्रोफ़ाइल चुनें';

  @override
  String get addFamilyFriend => 'परिवार या मित्र जोड़ें';

  @override
  String get chartStyle => 'चार्ट शैली';

  @override
  String get chartNorthIndian => 'उत्तर भारतीय';

  @override
  String get chartNorthLayout => 'डायमंड लेआउट';

  @override
  String get chartSouthIndian => 'दक्षिण भारतीय';

  @override
  String get chartSouthLayout => 'ग्रिड लेआउट';

  @override
  String get kundliCalcNote =>
      'गणना स्विस एफेमेरिस और लाहिड़ी अयनांश का उपयोग करती है';

  @override
  String get generateKundli => 'कुंडली बनाएं';

  @override
  String get lagnaKundli => 'लग्न कुंडली';

  @override
  String get pdf => 'PDF';

  @override
  String get tabChart => 'चार्ट';

  @override
  String get tabPlanetPositions => 'ग्रह स्थिति';

  @override
  String get tabDasha => 'विंशोत्तरी दशा';

  @override
  String get tabPredictions => 'भविष्यवाणियां';

  @override
  String get keyPlanets => 'प्रमुख ग्रह';

  @override
  String get lagna => 'लग्न';

  @override
  String get rashi => 'राशि';

  @override
  String get southChartComingSoon =>
      'दक्षिण भारतीय चार्ट लेआउट जल्द ही आ रहा है।';

  @override
  String get kundliMatchingTitle => 'कुंडली मिलान';

  @override
  String get gunMilanIntro =>
      'अष्टकूट गुण मिलान विवाह अनुकूलता के लिए 36 गुणों में 8 पहलुओं की तुलना करता है।';

  @override
  String get groom => 'वर';

  @override
  String get bride => 'वधू';

  @override
  String get change => 'बदलें';

  @override
  String get selectBrideProfile => 'वधू प्रोफ़ाइल चुनें…';

  @override
  String get selectBrideHint => 'चुनने या जन्म विवरण जोड़ने के लिए टैप करें';

  @override
  String get matchingPrivacyNote =>
      'मिलान परिणाम निजी हैं और केवल आपके खाते में सहेजे जाते हैं';

  @override
  String get matchKundlis => 'कुंडली मिलाएं';

  @override
  String get matchResult => 'मिलान परिणाम';

  @override
  String outOfMax(int max) {
    return '$max में से';
  }

  @override
  String percentCompatible(int percent) {
    return '$percent% अनुकूल';
  }

  @override
  String get ashtakootaBreakdown => 'अष्टकूट विवरण';

  @override
  String get bandStrong => 'उत्तम (75%+)';

  @override
  String get bandModerate => 'मध्यम (40–74%)';

  @override
  String get bandWeak => 'कमज़ोर (<40%)';

  @override
  String get gunaVarna => 'वर्ण';

  @override
  String get gunaVashya => 'वश्य';

  @override
  String get gunaTara => 'तारा';

  @override
  String get gunaYoni => 'योनि';

  @override
  String get gunaGrahaMaitri => 'ग्रह मैत्री';

  @override
  String get gunaGana => 'गण';

  @override
  String get gunaBhakoot => 'भकूट';

  @override
  String get gunaNadi => 'नाड़ी';

  @override
  String get rishiAiSummary => 'ऋषि AI सारांश';

  @override
  String get aiBadge => 'AI';

  @override
  String get detailedCompatibilityReport =>
      'विस्तृत अनुकूलता रिपोर्ट प्राप्त करें';

  @override
  String get tapGunaHint =>
      'प्रत्येक गुण को टैप करके देखें कि वह क्या मापता है और क्यों महत्वपूर्ण है';

  @override
  String get rishiAi => 'ऋषि AI';

  @override
  String get onlineKnowsChart => 'ऑनलाइन · आपकी कुंडली जानता है';

  @override
  String freeQuota(String used, String total) {
    return '$used/$total मुफ़्त';
  }

  @override
  String get today => 'आज';

  @override
  String get askAbout => 'इनके बारे में पूछें';

  @override
  String get topicCareer => 'करियर';

  @override
  String get topicMarriage => 'विवाह';

  @override
  String get topicHealth => 'स्वास्थ्य';

  @override
  String get topicBusiness => 'व्यवसाय';

  @override
  String get topicFinance => 'वित्त';

  @override
  String get topicEducation => 'शिक्षा';

  @override
  String get topicTravel => 'यात्रा';

  @override
  String get topicGemstones => 'रत्न';

  @override
  String get topicRemedies => 'उपाय';

  @override
  String get topicNumerology => 'अंक ज्योतिष';

  @override
  String get rishiTyping => 'ऋषि टाइप कर रहे हैं…';

  @override
  String get askAboutYourStars => 'अपने सितारों के बारे में पूछें…';

  @override
  String get upgradeUnlimited => 'असीमित प्रश्नों के लिए अपग्रेड करें';

  @override
  String get aiNotConnected => 'AI सेवा जुड़ने पर यहाँ जवाब दिखाई देंगे।';

  @override
  String get premiumReportsTitle => 'प्रीमियम रिपोर्ट';

  @override
  String get goPremium => 'प्रीमियम लें';

  @override
  String goPremiumSubtitle(String total) {
    return 'सभी $total रिपोर्ट + असीमित AI प्रश्न अनलॉक करें';
  }

  @override
  String get upgrade => 'अपग्रेड करें';

  @override
  String readMinutes(String minutes) {
    return '$minutes मिनट';
  }

  @override
  String get aiSummary => 'AI सारांश';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get free => 'मुफ़्त';

  @override
  String moreReportsFooter(String remaining) {
    return '+ $remaining और रिपोर्ट · सभी में PDF डाउनलोड शामिल';
  }

  @override
  String get reportCareer => 'करियर रिपोर्ट';

  @override
  String get reportCareerDesc => 'व्यवसाय, पदोन्नति और कार्य का समय';

  @override
  String get reportMarriage => 'विवाह रिपोर्ट';

  @override
  String get reportMarriageDesc => 'समय, जीवनसाथी के गुण और अनुकूलता';

  @override
  String get reportWealth => 'धन और वित्त';

  @override
  String get reportWealthDesc => 'आय स्रोत, निवेश और योग';

  @override
  String get reportHealth => 'स्वास्थ्य रिपोर्ट';

  @override
  String get reportHealthDesc => 'संवेदनशील अवधि और निवारक उपाय';

  @override
  String get reportSadeSati => 'साढ़े साती रिपोर्ट';

  @override
  String get reportSadeSatiDesc => 'शनि के चरण और प्रभाव विश्लेषण';

  @override
  String get reportGemstone => 'रत्न रिपोर्ट';

  @override
  String get reportGemstoneDesc => 'अनुशंसित रत्न और पहनने की विधि';

  @override
  String get reportNumerology => 'अंक ज्योतिष रिपोर्ट';

  @override
  String get reportNumerologyDesc => 'जीवन पथ, भाग्य और नाम अंक';

  @override
  String get restorePurchase => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get vedadarshiPremium => 'Vedadarshi प्रीमियम';

  @override
  String get premiumTagline => 'असीमित ब्रह्मांडीय मार्गदर्शन, एक सरल योजना';

  @override
  String benefitReports(String total) {
    return 'PDF एक्सपोर्ट के साथ सभी $total प्रीमियम रिपोर्ट';
  }

  @override
  String get benefitUnlimitedAi => 'असीमित AI ज्योतिषी प्रश्न';

  @override
  String get benefitAdvancedKundli => 'उन्नत कुंडली: दशा, दोष और उपाय';

  @override
  String get benefitAdFree => 'पूरे ऐप में विज्ञापन-मुक्त अनुभव';

  @override
  String get planMonthly => 'मासिक';

  @override
  String get planYearly => 'वार्षिक';

  @override
  String get planLifetime => 'आजीवन';

  @override
  String get perMonth => 'प्रति माह';

  @override
  String get oneTimePayment => 'एकमुश्त भुगतान';

  @override
  String startPremium(String price) {
    return 'प्रीमियम शुरू करें — $price';
  }

  @override
  String get billingFinePrint =>
      'Google Play के माध्यम से बिल किया गया · कभी भी रद्द करें · RevenueCat के साथ सुरक्षित';

  @override
  String get articlesTitle => 'ज्ञान और लेख';

  @override
  String get savedArticlesLabel => 'सहेजे गए लेख';

  @override
  String get articleCategoryAll => 'सभी';

  @override
  String articleFeaturedBadge(String tag) {
    return 'विशेष रुप से प्रदर्शित · $tag';
  }

  @override
  String get articleSave => 'सहेजें';

  @override
  String get articleShare => 'शेयर करें';

  @override
  String get articleListen => 'सुनें';

  @override
  String articleByline(String author, String minutes) {
    return '$author द्वारा · $minutes मिनट पढ़ें';
  }

  @override
  String articleReadMinutes(String minutes) {
    return '$minutes मिनट';
  }

  @override
  String articleMetaLine(String date, String minutes) {
    return '$date · $minutes मिनट पढ़ें';
  }

  @override
  String get searchHint => 'लेख, रिपोर्ट और अधिक खोजें';

  @override
  String get searchFilterArticles => 'लेख';

  @override
  String get searchRecentLabel => 'हाल की खोजें';

  @override
  String get searchClearRecent => 'साफ़ करें';

  @override
  String get searchClearQuery => 'खोज साफ़ करें';

  @override
  String get searchTrendingLabel => 'ट्रेंडिंग';

  @override
  String get searchResultsLabel => 'परिणाम';

  @override
  String searchNoResultsTitle(String query) {
    return '\"$query\" के लिए कोई परिणाम नहीं';
  }

  @override
  String get searchNoResultsHint => 'अलग कीवर्ड आज़माएं या वर्तनी जांचें';

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get notificationsMarkAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get notificationsToday => 'आज';

  @override
  String get notificationsYesterday => 'कल';

  @override
  String get notificationsEmptyState => 'अभी कोई सूचना नहीं';

  @override
  String get notificationsEmptyMessage =>
      'यहां आपको दैनिक राशिफल, त्योहार और मिलान अलर्ट दिखाई देंगे।';

  @override
  String get notificationsPermissionDeniedTitle => 'सूचनाएं चालू करें';

  @override
  String get notificationsPermissionDeniedMessage =>
      'अपना दैनिक राशिफल, त्योहार अलर्ट और AI उत्तर पाने के लिए सूचनाएं सक्षम करें।';

  @override
  String get notificationsPermissionEnableAction => 'सूचनाएं सक्षम करें';

  @override
  String get notificationsPermissionOpenSettingsAction => 'सेटिंग्स खोलें';

  @override
  String get profileBirthProfiles => 'जन्म प्रोफ़ाइल';

  @override
  String profileProfileCount(String count) {
    return '$count प्रोफ़ाइल';
  }

  @override
  String get profileAppLanguageLabel => 'ऐप की भाषा';

  @override
  String get profileMyActivityLabel => 'मेरी गतिविधि';

  @override
  String get profileMyReports => 'मेरी रिपोर्ट्स';

  @override
  String get profileDownloadedPdfs => 'डाउनलोड की गई PDF';

  @override
  String get profileAiChatHistory => 'AI चैट इतिहास';

  @override
  String get profilePaymentHistory => 'भुगतान इतिहास';

  @override
  String get profilePreferencesLabel => 'प्राथमिकताएं';

  @override
  String get profileAppearance => 'दिखावट';

  @override
  String get profileDarkModeComingSoon =>
      'डार्क मोड आने वाले अपडेट में उपलब्ध होगा';

  @override
  String get profileNotifications => 'सूचनाएं';

  @override
  String get profileNotificationsSubtitle => 'दैनिक राशिफल, त्योहार';

  @override
  String get profilePanchangLocation => 'पंचांग स्थान';

  @override
  String get profileManageSubscription => 'सदस्यता प्रबंधित करें';

  @override
  String get profilePrivacySecurity => 'गोपनीयता और सुरक्षा';

  @override
  String get profileHelpSupport => 'सहायता और समर्थन';

  @override
  String get profileRewardsLabel => 'पुरस्कार';

  @override
  String get profileReferEarn => 'रेफ़र करें और कमाएं';

  @override
  String get profileReferEarnSubtitle => 'हर रेफ़रल पर 1 महीना मुफ्त पाएं';

  @override
  String get profileInviteFriends => 'मित्रों को आमंत्रित करें';

  @override
  String get profileInviteFriendsSubtitle => 'वेददर्शी साझा करें';

  @override
  String get profileMoreLabel => 'अधिक';

  @override
  String get profileRateApp => 'वेददर्शी को रेट करें';

  @override
  String get profileSendFeedback => 'प्रतिक्रिया भेजें';

  @override
  String get profileRestorePurchases => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get profileLogOut => 'लॉग आउट करें';

  @override
  String get profileDeleteAccount => 'खाता हटाएं';

  @override
  String get profileSignOutConfirmTitle => 'लॉग आउट करें?';

  @override
  String get profileSignOutConfirmMessage =>
      'अपनी सहेजी गई प्रोफ़ाइल और रिपोर्ट्स तक पहुंचने के लिए आपको फिर से साइन इन करना होगा।';

  @override
  String get profileSignOutConfirmAction => 'लॉग आउट करें';

  @override
  String get profileCancel => 'रद्द करें';
}
