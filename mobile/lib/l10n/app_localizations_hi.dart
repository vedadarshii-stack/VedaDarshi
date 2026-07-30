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
}
