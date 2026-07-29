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
}
