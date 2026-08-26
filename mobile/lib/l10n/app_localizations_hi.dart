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
  String get orContinueWith => 'या इसके साथ जारी रखें';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get exploreAsGuest => 'अतिथि के रूप में देखें';

  @override
  String get termsNotice =>
      'जारी रखकर आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत होते हैं';

  @override
  String get authErrorNetwork =>
      'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें और पुनः प्रयास करें।';

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
  String get panchangLoading => 'आज का पंचांग लोड हो रहा है…';

  @override
  String get panchangLoadErrorTitle => 'पंचांग लोड नहीं हो सका';

  @override
  String get panchangLoadErrorMessage =>
      'अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get panchangRetry => 'पुनः प्रयास करें';

  @override
  String get panchangSandboxBanner => 'नमूना डेटा — आपका स्थान नहीं';

  @override
  String panchangPercentRemaining(int percent) {
    return '$percent% शेष';
  }

  @override
  String panchangPada(int number) {
    return 'पद $number';
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
  String get horoscopeSandboxBanner => 'सैंपल डेटा — सैंडबॉक्स मोड';

  @override
  String get horoscopeErrorTitle => 'राशिफल लोड नहीं हो सका';

  @override
  String get horoscopeErrorMessage =>
      'ज्योतिष सेवा से जुड़ने में समस्या हुई। कृपया अपना कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get horoscopeRetryAction => 'पुनः प्रयास करें';

  @override
  String get weeklyAdviceTitle => 'इस सप्ताह की सलाह';

  @override
  String get weeklyOutlookTitle => '7-दिन का पूर्वानुमान';

  @override
  String get weeklyBestDayBadge => 'सर्वश्रेष्ठ दिन';

  @override
  String get monthlyThemeTitle => 'इस माह का विषय';

  @override
  String get monthlyScoresTitle => 'इस माह के स्कोर';

  @override
  String monthlyOverallRating(int percent) {
    return 'कुल $percent%';
  }

  @override
  String get monthlyKeyDatesTitle => 'इस माह की महत्वपूर्ण तिथियां';

  @override
  String get yearlySummaryTitle => 'इस वर्ष का सारांश';

  @override
  String get yearlyScoresTitle => 'इस वर्ष के स्कोर';

  @override
  String yearlyOverallRating(int percent) {
    return 'कुल $percent%';
  }

  @override
  String get luckyDay => 'शुभ दिन';

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
  String get matchLoading => 'आपकी अनुकूलता की गणना की जा रही है…';

  @override
  String get matchErrorTitle => 'अनुकूलता की गणना नहीं हो सकी';

  @override
  String get matchErrorMessage =>
      'कुछ गड़बड़ हो गई। कृपया अपना कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get sandboxResultBanner =>
      'नमूना परिणाम — दर्ज की गई जन्म तिथि से गणना नहीं किया गया';

  @override
  String get matchNoGunaData => 'इस मिलान के लिए गुण विवरण उपलब्ध नहीं है।';

  @override
  String get rishiAi => 'ऋषि AI';

  @override
  String get onlineKnowsChart => 'ऑनलाइन · आपकी कुंडली जानता है';

  @override
  String aiGreeting(String name) {
    return '🙏 नमस्ते $name! मैंने आपकी कुंडली का अध्ययन किया है। करियर, विवाह, स्वास्थ्य या सही मुहूर्त के बारे में मुझसे कुछ भी पूछें।';
  }

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
  String get aiErrorQuotaExceeded =>
      'आपकी आज की मुफ़्त प्रश्न सीमा पूरी हो गई है। असीमित AI प्रश्नों के लिए अपग्रेड करें।';

  @override
  String get aiErrorBirthDetailsMissing =>
      'कृपया पहले अपना जन्म विवरण जोड़ें ताकि ऋषि आपकी कुंडली का अध्ययन कर सकें।';

  @override
  String get aiErrorInvalidQuestion =>
      'उस प्रश्न को संसाधित नहीं किया जा सका — कृपया इसे दोबारा लिखें।';

  @override
  String get aiErrorServiceUnavailable =>
      'ऋषि अभी अस्थायी रूप से अनुपलब्ध हैं। कृपया थोड़ी देर बाद पुनः प्रयास करें।';

  @override
  String get aiErrorGeneric => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get aiMessageFailedToSend => 'भेजा नहीं गया — कृपया पुनः प्रयास करें।';

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
  String tierFeatureAiQuestions(int count) {
    return '$count AI ज्योतिषी प्रश्न प्रतिदिन';
  }

  @override
  String get tierFeatureHoroscopeStandard =>
      'साप्ताहिक और मासिक राशिफल, पूर्ण पंचांग कैलेंडर';

  @override
  String get tierFeatureHoroscopeWithYearly =>
      'साप्ताहिक, मासिक और वार्षिक राशिफल, पूर्ण पंचांग कैलेंडर';

  @override
  String tierFeatureKundalisLimited(int count) {
    return '$count सहेजी गई कुंडलियाँ';
  }

  @override
  String get tierFeatureKundalisUnlimited => 'असीमित सहेजी गई कुंडलियाँ';

  @override
  String tierFeatureCompatibility(int count) {
    return '$count विस्तृत अनुकूलता रिपोर्ट प्रति माह';
  }

  @override
  String tierFeatureReportDiscount(int percent) {
    return 'प्रीमियम रिपोर्ट पर $percent% छूट';
  }

  @override
  String get tierFeaturePremiumArticles => 'प्रीमियम लेख';

  @override
  String tierFeatureLifeReportCredit(int count) {
    return '$count कम्पलीट लाइफ रिपोर्ट क्रेडिट प्रति माह';
  }

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
  String profileProfileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोफ़ाइल',
      one: '$count प्रोफ़ाइल',
    );
    return '$_temp0';
  }

  @override
  String get birthProfilesYouBadge => 'आप';

  @override
  String get birthProfilesDelete => 'हटाएं';

  @override
  String get birthProfilesDeleteConfirmTitle => 'इस प्रोफ़ाइल को हटाएं?';

  @override
  String birthProfilesDeleteConfirmMessage(String name) {
    return 'यह $name की सहेजी गई जन्म प्रोफ़ाइल स्थायी रूप से हटा देगा। इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get birthProfilesPrimaryDeleteHint =>
      'आपकी अपनी प्रोफ़ाइल यहां से नहीं हटाई जा सकती — इसके बजाय सेटिंग्स में खाता हटाएं का उपयोग करें।';

  @override
  String get birthProfilesEditorAddTitle => 'प्रोफ़ाइल जोड़ें';

  @override
  String get birthProfilesEditorEditTitle => 'प्रोफ़ाइल संपादित करें';

  @override
  String get birthProfilesEditorSave => 'प्रोफ़ाइल सहेजें';

  @override
  String get birthProfilesSaveFailed =>
      'यह प्रोफ़ाइल सहेजी नहीं जा सकी। कृपया पुनः प्रयास करें।';

  @override
  String get birthProfilesDeleteFailed =>
      'यह प्रोफ़ाइल हटाई नहीं जा सकी। कृपया पुनः प्रयास करें।';

  @override
  String get birthProfilesSignInRequired =>
      'परिवार और मित्र प्रोफ़ाइल जोड़ने के लिए साइन इन करें।';

  @override
  String get birthProfilesEmpty => 'अभी तक कोई प्रोफ़ाइल नहीं है।';

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
  String profileAiChatHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बातचीत',
      one: '$count बातचीत',
    );
    return '$_temp0';
  }

  @override
  String get aiChatHistoryEmptyTitle => 'अभी तक कोई बातचीत नहीं';

  @override
  String get aiChatHistoryEmptyMessage =>
      'करियर, विवाह, स्वास्थ्य या सही मुहूर्त के बारे में ऋषि AI से पूछें — आपकी बातचीत यहां दिखाई देगी।';

  @override
  String get aiChatHistoryEmptyAction => 'ऋषि AI से पूछें';

  @override
  String get profilePaymentHistory => 'भुगतान इतिहास';

  @override
  String get profilePreferencesLabel => 'प्राथमिकताएं';

  @override
  String get profileAppearance => 'दिखावट';

  @override
  String get profileAppearanceSystem => 'सिस्टम · डिवाइस के अनुसार';

  @override
  String get profileAppearanceLight => 'लाइट';

  @override
  String get profileAppearanceDark => 'डार्क';

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

  @override
  String get profileDeleteAccountConfirmTitle => 'खाता हटाएं?';

  @override
  String get profileDeleteAccountConfirmMessage =>
      'यह आपकी जन्म प्रोफ़ाइलें, AI चैट इतिहास और खाता स्थायी रूप से हटा देगा। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get profileDeleteAccountConfirmAction => 'खाता हटाएं';

  @override
  String get accountDeletionErrorUnauthenticated =>
      'आपका सत्र समाप्त हो गया है। कृपया अपना खाता हटाने के लिए फिर से साइन इन करें।';

  @override
  String get accountDeletionErrorGeneric =>
      'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get legalPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get legalTermsOfService => 'सेवा की शर्तें';

  @override
  String get legalRefundsCancellation => 'रिफ़ंड और रद्दीकरण';

  @override
  String get legalAccountDataDeletion => 'खाता और डेटा हटाना';

  @override
  String get profileEmailSupport => 'हमें ईमेल करें';

  @override
  String get profileEmailSupportSubtitle => 'Vedadarshii@gmail.com';

  @override
  String get supportEmailSubject => 'वेददर्शी सहायता';

  @override
  String get feedbackEmailSubject => 'वेददर्शी प्रतिक्रिया';

  @override
  String profileInviteFriendsMessage(String link) {
    return 'वेददर्शी से जुड़ें — वैदिक ज्योतिष, पंचांग और राशिफल का आपका रोज़ का साथी। यहां से डाउनलोड करें: $link';
  }

  @override
  String get kundliSandboxBanner =>
      'सैंपल कुंडली — आपके जन्म विवरण से गणना नहीं की गई है';

  @override
  String get kundliLoadErrorTitle => 'आपकी कुंडली लोड नहीं हो सकी';

  @override
  String get kundliLoadErrorMessage =>
      'आपकी कुंडली प्राप्त करने में कुछ गड़बड़ हुई। कृपया पुनः प्रयास करें।';

  @override
  String get kundliRetry => 'पुनः प्रयास करें';

  @override
  String get kundliLoadingChart => 'आपकी कुंडली लोड हो रही है…';

  @override
  String get kundliValueUnavailable => '—';

  @override
  String get kundliDoshaMangalPresent => 'मंगल दोष मौजूद है';

  @override
  String get kundliDoshaMangalAbsent => 'कोई मंगल दोष नहीं पाया गया';

  @override
  String get kundliDoshaKaalSarpPresent => 'काल सर्प दोष पाया गया';

  @override
  String kundliDoshaKaalSarpPresentType(String type) {
    return 'काल सर्प दोष पाया गया ($type)';
  }

  @override
  String get kundliDoshaKaalSarpAbsent => 'कोई काल सर्प दोष नहीं';

  @override
  String kundliPlanetPositionsAyanamsa(String name) {
    return 'अयनांश: $name';
  }

  @override
  String kundliHouseNumber(int house) {
    return 'भाव $house';
  }

  @override
  String get kundliRetrograde => 'वक्री';

  @override
  String get kundliDashaLoadErrorTitle => 'आपकी दशा लोड नहीं हो सकी';

  @override
  String get kundliDashaLoadErrorMessage =>
      'आपकी विंशोत्तरी दशा लाते समय कुछ गड़बड़ हो गई। कृपया पुनः प्रयास करें।';

  @override
  String get kundliDashaLoading => 'आपकी दशा लोड हो रही है…';

  @override
  String get kundliDashaCurrentTitle => 'वर्तमान महादशा';

  @override
  String get kundliDashaBalanceTitle => 'जन्म के समय दशा शेष';

  @override
  String kundliDashaBalanceValue(int years, int months, int days) {
    return '$years वर्ष, $months माह, $days दिन';
  }

  @override
  String get kundliDashaTimelineTitle => 'दशा समयरेखा';

  @override
  String get kundliDashaCurrentBadge => 'वर्तमान';

  @override
  String get kundliPlanetPositionsEmpty =>
      'इस कुंडली के लिए ग्रह स्थिति अभी उपलब्ध नहीं है।';

  @override
  String get kundliDashaTimelineEmpty => 'अभी कोई दशा अवधि उपलब्ध नहीं है।';

  @override
  String kundliDashaRemainingYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years वर्ष',
      one: '1 वर्ष',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months माह',
      one: '1 माह',
    );
    return '$_temp0, $_temp1 शेष';
  }

  @override
  String kundliDashaRemainingYearsOnly(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years वर्ष',
      one: '1 वर्ष',
    );
    return '$_temp0 शेष';
  }

  @override
  String kundliDashaRemainingMonthsOnly(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months माह',
      one: '1 माह',
    );
    return '$_temp0 शेष';
  }

  @override
  String get kundliDashaRemainingLessThanMonth => 'एक माह से कम शेष';

  @override
  String kundliNakshatraPada(int pada) {
    return 'पद $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'पितृ दोष मौजूद है';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get plansUnavailableTitle => 'योजनाएं अभी उपलब्ध नहीं हैं';

  @override
  String get plansUnavailableMessage =>
      'सदस्यता योजनाएं लोड नहीं हो सकीं। अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String perMonthBilledYearly(String price) {
    return '$price/माह · वार्षिक बिलिंग';
  }

  @override
  String savePercent(String percent) {
    return '$percent% बचत';
  }

  @override
  String get currentPlanLabel => 'आपकी वर्तमान योजना';

  @override
  String get purchaseSuccess =>
      'आपकी सदस्यता सक्रिय है। Vedadarshi प्रीमियम का आनंद लें।';

  @override
  String get purchasesRestored => 'खरीदारी बहाल कर दी गई।';

  @override
  String get purchasesNothingToRestore => 'कोई पिछली खरीदारी नहीं मिली।';

  @override
  String get purchaseErrorGeneric =>
      'खरीदारी पूरी नहीं हो सकी। कृपया पुनः प्रयास करें।';

  @override
  String get purchaseErrorNotAllowed =>
      'इस खाते या डिवाइस पर खरीदारी उपलब्ध नहीं है।';

  @override
  String get purchaseErrorNetwork =>
      'कोई कनेक्शन नहीं। अपना नेटवर्क जांचें और पुनः प्रयास करें।';

  @override
  String get purchaseErrorAlreadyOwned =>
      'यह योजना आपके पास पहले से है — सिंक करने के लिए \'खरीदारी बहाल करें\' दबाएं।';

  @override
  String get purchaseErrorUnavailable => 'यह योजना अभी उपलब्ध नहीं है।';

  @override
  String get panchangLocationUseAutomatic => 'मेरा वर्तमान स्थान उपयोग करें';

  @override
  String get panchangLocationSourceManual => 'आपके द्वारा चुना गया';

  @override
  String get panchangLocationSourceDevice => 'आपके स्थान से पता चला';

  @override
  String get panchangLocationSourceBirthProfile => 'आपके जन्म विवरण से';

  @override
  String get panchangLocationSourceFallback => 'डिफ़ॉल्ट स्थान';

  @override
  String get muhuratDay => 'दिन का चौघड़िया';

  @override
  String get muhuratNight => 'रात का चौघड़िया';

  @override
  String get muhuratUnavailable => 'मुहूर्त समय अभी उपलब्ध नहीं है।';

  @override
  String get partnerDetailsTitle => 'साथी का जन्म विवरण';

  @override
  String get partnerDetailsSave => 'विवरण सहेजें';

  @override
  String get matchNeedsPartner => 'मिलान के लिए साथी का जन्म विवरण जोड़ें।';

  @override
  String get emailHint => 'ईमेल पता';

  @override
  String get passwordHint => 'पासवर्ड';

  @override
  String get confirmPasswordHint => 'पासवर्ड की पुष्टि करें';

  @override
  String get signInAction => 'साइन इन करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get noAccountPrompt => 'Vedadarshi में नए हैं?';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get signUpTitle => 'अपना खाता बनाएं';

  @override
  String get haveAccountPrompt => 'पहले से खाता है?';

  @override
  String get forgotPasswordTitle => 'अपना पासवर्ड रीसेट करें';

  @override
  String get forgotPasswordSubtitle =>
      'वह ईमेल पता दर्ज करें जिससे आपने साइन अप किया था, हम आपको पासवर्ड रीसेट करने के लिए एक लिंक भेजेंगे।';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get resetLinkSent =>
      'यदि वह ईमेल पंजीकृत है, तो एक रीसेट लिंक भेजी जा रही है।';

  @override
  String get passwordTooShort => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।';

  @override
  String get passwordsDoNotMatch => 'वे पासवर्ड मेल नहीं खाते।';

  @override
  String get authErrorEmailInUse =>
      'वह ईमेल पहले से पंजीकृत है। इसके बजाय साइन इन करने का प्रयास करें।';

  @override
  String get authErrorInvalidEmail => 'वह ईमेल पता सही नहीं लगता।';

  @override
  String get authErrorWeakPassword =>
      'कृपया कम से कम 6 अक्षरों का पासवर्ड चुनें।';

  @override
  String get authErrorWrongCredentials =>
      'गलत ईमेल या पासवर्ड। कृपया पुनः प्रयास करें।';

  @override
  String get authErrorUserNotFound => 'उस ईमेल पते से कोई खाता नहीं मिला।';
}
