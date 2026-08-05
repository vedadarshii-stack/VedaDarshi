// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vedadarshi';

  @override
  String get splashTagline => 'Your trusted Vedic companion';

  @override
  String get introStarsTitle => 'Your Stars, Decoded';

  @override
  String get introStarsSubtitle =>
      'Daily horoscope, Panchang & Kundli — from authentic Vedic calculations';

  @override
  String get introAiTitle => 'Ask the AI Astrologer';

  @override
  String get introAiSubtitle =>
      'Personal guidance from your birth chart — in your own language';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageNativePrompt => 'अपनी भाषा चुनें';

  @override
  String get languageSettingsHint => 'You can change this anytime in Settings';

  @override
  String get continueLabel => 'Continue';

  @override
  String get welcomeHeroTagline =>
      'Panchang · Kundli · Horoscope · AI Astrologer';

  @override
  String get welcomeGreeting => 'Namaste 🙏';

  @override
  String get welcomeSubtitle =>
      'Sign in to save your birth profiles and unlock personalised predictions.';

  @override
  String get phoneHint => 'Mobile number';

  @override
  String get getOtp => 'Get OTP';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get exploreAsGuest => 'Explore as Guest';

  @override
  String get termsNotice =>
      'By continuing you agree to our Terms of Service & Privacy Policy';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpNoCode => 'Didn\'t receive the code?';

  @override
  String otpResendIn(String seconds) {
    return 'Resend in $seconds';
  }

  @override
  String get otpResend => 'Resend';

  @override
  String get otpVerify => 'Verify & Continue';

  @override
  String get otpPrivacy => '🔒 Your number is kept private and secure';

  @override
  String get otpResent => 'A new code has been sent.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Please check your network and try again.';

  @override
  String get authErrorInvalidPhone =>
      'That phone number doesn\'t look right. Please check and try again.';

  @override
  String get authErrorInvalidOtp => 'That code is incorrect. Please try again.';

  @override
  String get authErrorOtpExpired =>
      'That code has expired. Please request a new one.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a while before trying again.';

  @override
  String get authErrorProviderDisabled =>
      'This sign-in method isn\'t available yet. Please try another option.';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get birthTitle => 'Your birth details';

  @override
  String get birthSubtitle =>
      'These power your Kundli, horoscope and personalised reports. Accuracy matters ✨';

  @override
  String get birthFullNameLabel => 'Full name';

  @override
  String get birthNameHint => 'Enter your full name';

  @override
  String get birthGenderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get birthDobLabel => 'Date of birth';

  @override
  String get birthDateHint => 'Select date';

  @override
  String get birthTobLabel => 'Time of birth';

  @override
  String get birthTimeHint => 'Select time';

  @override
  String get birthTimeUnknownValue => '12:00 PM (noon)';

  @override
  String get birthPlaceLabel => 'Place of birth';

  @override
  String get birthPlaceHint => 'Search your birth city';

  @override
  String birthGeoDetected(String lat, String lon, String offset, String zone) {
    return '✓ Auto-detected: $lat, $lon · $offset ($zone)';
  }

  @override
  String get birthTimeUnknown => 'I don\'t know my exact birth time';

  @override
  String get birthSave => 'Create My Profile ✨';

  @override
  String get birthFooter => 'You can add family & friends profiles later';

  @override
  String get placeResolveFailed =>
      'Couldn\'t load that location. Please pick another.';

  @override
  String get todaysPanchang => 'TODAY\'S PANCHANG';

  @override
  String get nakshatra => 'Nakshatra';

  @override
  String get yoga => 'Yoga';

  @override
  String get karana => 'Karana';

  @override
  String get fullPanchang => 'Full Panchang';

  @override
  String get todayAtAGlance => 'Today at a glance';

  @override
  String get luckyNumber => 'Lucky Number';

  @override
  String get luckyColor => 'Lucky Color';

  @override
  String get direction => 'Direction';

  @override
  String get todaysPlanet => 'Today\'s Planet';

  @override
  String get moonPhase => 'Moon Phase';

  @override
  String get muhurat => 'Muhurat';

  @override
  String get todaysRemedy => 'TODAY\'S REMEDY';

  @override
  String get todaysMantra => 'TODAY\'S MANTRA';

  @override
  String get festivalOfTheDay => 'FESTIVAL OF THE DAY';

  @override
  String get rituals => 'Rituals';

  @override
  String get explore => 'Explore';

  @override
  String get navKundli => 'Kundli';

  @override
  String get navMatch => 'Match';

  @override
  String get navReports => 'Reports';

  @override
  String get navAskAi => 'Ask AI';

  @override
  String get todaysHoroscope => 'Today\'s Horoscope';

  @override
  String get allSigns => 'All signs';

  @override
  String get wisdomForYou => 'Wisdom for you';

  @override
  String get seeAll => 'See all';

  @override
  String get continueWithRishiAi => 'Continue with Rishi AI';

  @override
  String get continueAction => 'Continue';

  @override
  String get recentReports => 'Recent reports';

  @override
  String get myReports => 'My reports';

  @override
  String get navHome => 'Home';

  @override
  String get navPanchang => 'Panchang';

  @override
  String get navProfile => 'Profile';

  @override
  String get panchangTitle => 'Panchang';

  @override
  String get panchangSunrise => 'Sunrise';

  @override
  String get panchangSunset => 'Sunset';

  @override
  String get panchangMoonrise => 'Moonrise';

  @override
  String get panchangMoonset => 'Moonset';

  @override
  String get panchangTithi => 'Tithi';

  @override
  String get panchangVaar => 'Vaar';

  @override
  String get muhuratToday => 'Muhurat today';

  @override
  String get muhuratShubh => 'SHUBH';

  @override
  String get muhuratAshubh => 'ASHUBH';

  @override
  String get festivalToday => 'FESTIVAL TODAY';

  @override
  String get details => 'Details';

  @override
  String get todaysSpiritualAdvice => 'TODAY\'S SPIRITUAL ADVICE';

  @override
  String get viewAllMuhurat => 'View all muhurat timings';

  @override
  String availableOffline(String time) {
    return 'Available offline · Updated $time';
  }

  @override
  String get panchangLoading => 'Loading today\'s panchang…';

  @override
  String get panchangLoadErrorTitle => 'Couldn\'t load Panchang';

  @override
  String get panchangLoadErrorMessage => 'Check your connection and try again.';

  @override
  String get panchangRetry => 'Retry';

  @override
  String get panchangSandboxBanner => 'Sample data — not your location';

  @override
  String panchangPercentRemaining(int percent) {
    return '$percent% left';
  }

  @override
  String panchangPada(int number) {
    return 'Pada $number';
  }

  @override
  String get horoscopeTitle => 'Horoscope';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get yourSign => 'Your sign';

  @override
  String get todaysScores => 'Today\'s scores';

  @override
  String get scoreCareer => 'Career';

  @override
  String get scoreLove => 'Love';

  @override
  String get scoreHealth => 'Health';

  @override
  String get scoreMoney => 'Money';

  @override
  String get scoreLuck => 'Luck';

  @override
  String get luckyTime => 'LUCKY TIME';

  @override
  String get avoidTime => 'AVOID TIME';

  @override
  String get sectionCareerMoney => 'Career & Money';

  @override
  String get sectionLoveRelationships => 'Love & Relationships';

  @override
  String get sectionHealthEnergy => 'Health & Energy';

  @override
  String get premiumUnlockPredictions =>
      'Unlock detailed monthly & yearly predictions';

  @override
  String get premiumCta => 'Premium';

  @override
  String get horoscopeSandboxBanner => 'Sample data — Vedika sandbox mode';

  @override
  String get horoscopeErrorTitle => 'Couldn\'t load horoscope';

  @override
  String get horoscopeErrorMessage =>
      'Something went wrong reaching Vedika. Check your connection and try again.';

  @override
  String get horoscopeRetryAction => 'Retry';

  @override
  String get weeklyAdviceTitle => 'This Week\'s Advice';

  @override
  String get weeklyOutlookTitle => '7-Day Outlook';

  @override
  String get weeklyBestDayBadge => 'Best Day';

  @override
  String get monthlyThemeTitle => 'This Month\'s Theme';

  @override
  String get monthlyScoresTitle => 'This Month\'s Scores';

  @override
  String monthlyOverallRating(int percent) {
    return 'Overall $percent%';
  }

  @override
  String get monthlyKeyDatesTitle => 'Key Dates This Month';

  @override
  String get generateKundliTitle => 'Generate Kundli';

  @override
  String get selectProfile => 'SELECT PROFILE';

  @override
  String get addFamilyFriend => 'Add family or friend';

  @override
  String get chartStyle => 'CHART STYLE';

  @override
  String get chartNorthIndian => 'North Indian';

  @override
  String get chartNorthLayout => 'Diamond layout';

  @override
  String get chartSouthIndian => 'South Indian';

  @override
  String get chartSouthLayout => 'Grid layout';

  @override
  String get kundliCalcNote =>
      'Calculations use Swiss Ephemeris with Lahiri Ayanamsa';

  @override
  String get generateKundli => 'Generate Kundli';

  @override
  String get lagnaKundli => 'Lagna Kundli';

  @override
  String get pdf => 'PDF';

  @override
  String get tabChart => 'Chart';

  @override
  String get tabPlanetPositions => 'Planet Positions';

  @override
  String get tabDasha => 'Vimshottari Dasha';

  @override
  String get tabPredictions => 'Predictions';

  @override
  String get keyPlanets => 'KEY PLANETS';

  @override
  String get lagna => 'Lagna';

  @override
  String get rashi => 'Rashi';

  @override
  String get southChartComingSoon =>
      'South Indian chart layout is coming soon.';

  @override
  String get kundliMatchingTitle => 'Kundli Matching';

  @override
  String get gunMilanIntro =>
      'Ashtakoota Gun Milan compares 8 aspects across 36 gunas for marriage compatibility.';

  @override
  String get groom => 'GROOM';

  @override
  String get bride => 'BRIDE';

  @override
  String get change => 'Change';

  @override
  String get selectBrideProfile => 'Select bride profile…';

  @override
  String get selectBrideHint => 'Tap to choose or add birth details';

  @override
  String get matchingPrivacyNote =>
      'Matching results are private and saved to your account only';

  @override
  String get matchKundlis => 'Match Kundlis';

  @override
  String get matchResult => 'Match Result';

  @override
  String outOfMax(int max) {
    return 'out of $max';
  }

  @override
  String percentCompatible(int percent) {
    return '$percent% Compatible';
  }

  @override
  String get ashtakootaBreakdown => 'Ashtakoota breakdown';

  @override
  String get bandStrong => 'Strong (75%+)';

  @override
  String get bandModerate => 'Moderate (40–74%)';

  @override
  String get bandWeak => 'Weak (<40%)';

  @override
  String get gunaVarna => 'Varna';

  @override
  String get gunaVashya => 'Vashya';

  @override
  String get gunaTara => 'Tara';

  @override
  String get gunaYoni => 'Yoni';

  @override
  String get gunaGrahaMaitri => 'Graha Maitri';

  @override
  String get gunaGana => 'Gana';

  @override
  String get gunaBhakoot => 'Bhakoot';

  @override
  String get gunaNadi => 'Nadi';

  @override
  String get rishiAiSummary => 'Rishi AI Summary';

  @override
  String get aiBadge => 'AI';

  @override
  String get detailedCompatibilityReport => 'Get Detailed Compatibility Report';

  @override
  String get tapGunaHint =>
      'Tap any guna to see what it measures & why it matters';

  @override
  String get matchLoading => 'Calculating your compatibility…';

  @override
  String get matchErrorTitle => 'Couldn\'t calculate compatibility';

  @override
  String get matchErrorMessage =>
      'Something went wrong. Please check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get sandboxResultBanner =>
      'Sample result — not calculated from the entered birth details';

  @override
  String get matchNoGunaData =>
      'Guna breakdown isn\'t available for this match.';

  @override
  String get rishiAi => 'Rishi AI';

  @override
  String get onlineKnowsChart => 'Online · knows your chart';

  @override
  String aiGreeting(String name) {
    return '🙏 Namaste $name! I have studied your birth chart. Ask me anything about career, marriage, health or the right muhurat.';
  }

  @override
  String freeQuota(String used, String total) {
    return '$used/$total free';
  }

  @override
  String get today => 'Today';

  @override
  String get askAbout => 'ASK ABOUT';

  @override
  String get topicCareer => 'Career';

  @override
  String get topicMarriage => 'Marriage';

  @override
  String get topicHealth => 'Health';

  @override
  String get topicBusiness => 'Business';

  @override
  String get topicFinance => 'Finance';

  @override
  String get topicEducation => 'Education';

  @override
  String get topicTravel => 'Travel';

  @override
  String get topicGemstones => 'Gemstones';

  @override
  String get topicRemedies => 'Remedies';

  @override
  String get topicNumerology => 'Numerology';

  @override
  String get rishiTyping => 'Rishi is typing…';

  @override
  String get askAboutYourStars => 'Ask about your stars…';

  @override
  String get upgradeUnlimited => 'Upgrade for unlimited questions';

  @override
  String get aiErrorQuotaExceeded =>
      'You\'ve reached today\'s free question limit. Upgrade for unlimited AI questions.';

  @override
  String get aiErrorBirthDetailsMissing =>
      'Add your birth details first so Rishi can study your chart.';

  @override
  String get aiErrorInvalidQuestion =>
      'That question couldn\'t be processed — try rephrasing it.';

  @override
  String get aiErrorServiceUnavailable =>
      'Rishi is temporarily unavailable. Please try again in a moment.';

  @override
  String get aiErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get aiMessageFailedToSend => 'Not delivered — please try again.';

  @override
  String get premiumReportsTitle => 'Premium Reports';

  @override
  String get goPremium => 'Go Premium';

  @override
  String goPremiumSubtitle(String total) {
    return 'Unlock all $total reports + unlimited AI questions';
  }

  @override
  String get upgrade => 'Upgrade';

  @override
  String readMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get aiSummary => 'AI Summary';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Free';

  @override
  String moreReportsFooter(String remaining) {
    return '+ $remaining more reports · All include PDF download';
  }

  @override
  String get reportCareer => 'Career Report';

  @override
  String get reportCareerDesc => 'Profession, promotions & business timing';

  @override
  String get reportMarriage => 'Marriage Report';

  @override
  String get reportMarriageDesc => 'Timing, spouse traits & compatibility';

  @override
  String get reportWealth => 'Wealth & Finance';

  @override
  String get reportWealthDesc => 'Income sources, investments & yogas';

  @override
  String get reportHealth => 'Health Report';

  @override
  String get reportHealthDesc => 'Vulnerable periods & preventive remedies';

  @override
  String get reportSadeSati => 'Sade Sati Report';

  @override
  String get reportSadeSatiDesc => 'Saturn phases & impact analysis';

  @override
  String get reportGemstone => 'Gemstone Report';

  @override
  String get reportGemstoneDesc => 'Recommended stones & wearing method';

  @override
  String get reportNumerology => 'Numerology Report';

  @override
  String get reportNumerologyDesc => 'Life path, destiny & name numbers';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get vedadarshiPremium => 'Vedadarshi Premium';

  @override
  String get premiumTagline => 'Unlimited cosmic guidance, one simple plan';

  @override
  String benefitReports(String total) {
    return 'All $total premium reports with PDF export';
  }

  @override
  String get benefitUnlimitedAi => 'Unlimited AI Astrologer questions';

  @override
  String get benefitAdvancedKundli =>
      'Advanced Kundli: dasha, dosha & remedies';

  @override
  String get benefitAdFree => 'Ad-free experience across the app';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planLifetime => 'Lifetime';

  @override
  String get perMonth => 'per month';

  @override
  String get oneTimePayment => 'one-time payment';

  @override
  String startPremium(String price) {
    return 'Start Premium — $price';
  }

  @override
  String get billingFinePrint =>
      'Billed via Google Play · Cancel anytime · Secure with RevenueCat';

  @override
  String get articlesTitle => 'Wisdom & Articles';

  @override
  String get savedArticlesLabel => 'Saved articles';

  @override
  String get articleCategoryAll => 'All';

  @override
  String articleFeaturedBadge(String tag) {
    return 'FEATURED · $tag';
  }

  @override
  String get articleSave => 'Save';

  @override
  String get articleShare => 'Share';

  @override
  String get articleListen => 'Listen';

  @override
  String articleByline(String author, String minutes) {
    return 'By $author · $minutes min read';
  }

  @override
  String articleReadMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String articleMetaLine(String date, String minutes) {
    return '$date · $minutes min read';
  }

  @override
  String get searchHint => 'Search articles, reports & more';

  @override
  String get searchFilterArticles => 'Articles';

  @override
  String get searchRecentLabel => 'RECENT';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get searchClearQuery => 'Clear search';

  @override
  String get searchTrendingLabel => 'TRENDING';

  @override
  String get searchResultsLabel => 'RESULTS';

  @override
  String searchNoResultsTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchNoResultsHint =>
      'Try different keywords or check the spelling';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsToday => 'TODAY';

  @override
  String get notificationsYesterday => 'YESTERDAY';

  @override
  String get notificationsEmptyState => 'No notifications yet';

  @override
  String get notificationsEmptyMessage =>
      'You\'ll see daily horoscope, festival and match alerts here.';

  @override
  String get notificationsPermissionDeniedTitle => 'Turn on notifications';

  @override
  String get notificationsPermissionDeniedMessage =>
      'Enable notifications to get your daily horoscope, festival alerts and AI replies.';

  @override
  String get notificationsPermissionEnableAction => 'Enable notifications';

  @override
  String get notificationsPermissionOpenSettingsAction => 'Open settings';

  @override
  String get profileBirthProfiles => 'Birth profiles';

  @override
  String profileProfileCount(String count) {
    return '$count profile';
  }

  @override
  String get profileAppLanguageLabel => 'APP LANGUAGE';

  @override
  String get profileMyActivityLabel => 'MY ACTIVITY';

  @override
  String get profileMyReports => 'My Reports';

  @override
  String get profileDownloadedPdfs => 'Downloaded PDFs';

  @override
  String get profileAiChatHistory => 'AI Chat History';

  @override
  String get profilePaymentHistory => 'Payment History';

  @override
  String get profilePreferencesLabel => 'PREFERENCES';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileAppearanceSystem => 'System · follows device';

  @override
  String get profileAppearanceLight => 'Light';

  @override
  String get profileAppearanceDark => 'Dark';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileNotificationsSubtitle => 'Daily horoscope, festivals';

  @override
  String get profilePanchangLocation => 'Panchang location';

  @override
  String get profileManageSubscription => 'Manage subscription';

  @override
  String get profilePrivacySecurity => 'Privacy & security';

  @override
  String get profileHelpSupport => 'Help & support';

  @override
  String get profileRewardsLabel => 'REWARDS';

  @override
  String get profileReferEarn => 'Refer & Earn';

  @override
  String get profileReferEarnSubtitle => 'Get 1 month free per referral';

  @override
  String get profileInviteFriends => 'Invite Friends';

  @override
  String get profileInviteFriendsSubtitle => 'Share Vedadarshi';

  @override
  String get profileMoreLabel => 'MORE';

  @override
  String get profileRateApp => 'Rate Vedadarshi';

  @override
  String get profileSendFeedback => 'Send Feedback';

  @override
  String get profileRestorePurchases => 'Restore Purchases';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileSignOutConfirmTitle => 'Log out?';

  @override
  String get profileSignOutConfirmMessage =>
      'You\'ll need to sign in again to access your saved profiles and reports.';

  @override
  String get profileSignOutConfirmAction => 'Log out';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get kundliSandboxBanner =>
      'Sample chart — not calculated from your birth details';

  @override
  String get kundliLoadErrorTitle => 'Couldn\'t load your chart';

  @override
  String get kundliLoadErrorMessage =>
      'Something went wrong while fetching your Kundli. Please try again.';

  @override
  String get kundliRetry => 'Retry';

  @override
  String get kundliLoadingChart => 'Loading your chart…';

  @override
  String get kundliValueUnavailable => '—';

  @override
  String get kundliDoshaMangalPresent => 'Mangal Dosha present';

  @override
  String get kundliDoshaMangalAbsent => 'No Mangal Dosha detected';

  @override
  String get kundliDoshaKaalSarpPresent => 'Kaal Sarp Dosha detected';

  @override
  String kundliDoshaKaalSarpPresentType(String type) {
    return 'Kaal Sarp Dosha detected ($type)';
  }

  @override
  String get kundliDoshaKaalSarpAbsent => 'No Kaal Sarp Dosha detected';

  @override
  String kundliPlanetPositionsAyanamsa(String name) {
    return 'Ayanamsa: $name';
  }

  @override
  String kundliHouseNumber(int house) {
    return 'House $house';
  }

  @override
  String get kundliRetrograde => 'Retrograde';

  @override
  String get kundliDashaLoadErrorTitle => 'Couldn\'t load your dasha';

  @override
  String get kundliDashaLoadErrorMessage =>
      'Something went wrong while fetching your Vimshottari Dasha. Please try again.';

  @override
  String get kundliDashaLoading => 'Loading your dasha…';

  @override
  String get kundliDashaCurrentTitle => 'Current Mahadasha';

  @override
  String get kundliDashaBalanceTitle => 'Dasha Balance at Birth';

  @override
  String kundliDashaBalanceValue(int years, int months, int days) {
    return '$years years, $months months, $days days';
  }

  @override
  String get kundliDashaTimelineTitle => 'Dasha Timeline';

  @override
  String get kundliDashaCurrentBadge => 'Current';

  @override
  String get kundliPlanetPositionsEmpty =>
      'Planet positions aren\'t available for this chart yet.';

  @override
  String get kundliDashaTimelineEmpty => 'No dasha periods available yet.';

  @override
  String kundliNakshatraPada(int pada) {
    return 'Pada $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'Pitru Dosha present';
}
