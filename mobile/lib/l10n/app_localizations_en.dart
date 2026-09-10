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
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get exploreAsGuest => 'Explore as Guest';

  @override
  String get termsNotice =>
      'By continuing you agree to our Terms of Service & Privacy Policy';

  @override
  String get authErrorNetwork =>
      'No internet connection. Please check your network and try again.';

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
  String get horoscopeSandboxBanner => 'Sample data — sandbox mode';

  @override
  String get horoscopeErrorTitle => 'Couldn\'t load horoscope';

  @override
  String get horoscopeErrorMessage =>
      'Something went wrong reaching the astrology service. Check your connection and try again.';

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
  String get yearlySummaryTitle => 'This Year\'s Overview';

  @override
  String get yearlyScoresTitle => 'This Year\'s Scores';

  @override
  String yearlyOverallRating(int percent) {
    return 'Overall $percent%';
  }

  @override
  String get luckyDay => 'Lucky Day';

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
      'Vedic sidereal chart with Lahiri Ayanamsa — includes planetary positions, Vimshottari dasha, dosha checks and predictions';

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
  String get upgradeUnlimited => 'Upgrade for more questions';

  @override
  String get aiErrorQuotaExceeded =>
      'You\'ve reached today\'s free question limit. Upgrade for more daily questions.';

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
    return 'Unlock all $total reports + more daily AI questions';
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
  String get premiumTagline => 'Deeper cosmic guidance, one simple plan';

  @override
  String tierFeatureAiQuestions(int count) {
    return '$count AI Astrologer questions a day';
  }

  @override
  String get tierFeatureHoroscopeStandard =>
      'Weekly & monthly horoscope, full Panchang calendar';

  @override
  String get tierFeatureHoroscopeWithYearly =>
      'Weekly, monthly & yearly horoscope, full Panchang calendar';

  @override
  String tierFeatureKundalisLimited(int count) {
    return '$count saved Kundlis';
  }

  @override
  String get tierFeatureKundalisUnlimited => 'Unlimited saved Kundlis';

  @override
  String tierFeatureCompatibility(int count) {
    return '$count detailed compatibility reports a month';
  }

  @override
  String tierFeatureReportDiscount(int percent) {
    return '$percent% off premium reports';
  }

  @override
  String get tierFeaturePremiumArticles => 'Premium articles';

  @override
  String tierFeatureLifeReportCredit(int count) {
    return '$count Complete Life Report credit a month';
  }

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
  String profileProfileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profiles',
      one: '$count profile',
    );
    return '$_temp0';
  }

  @override
  String get birthProfilesYouBadge => 'You';

  @override
  String get birthProfilesDelete => 'Delete';

  @override
  String get birthProfilesDeleteConfirmTitle => 'Delete this profile?';

  @override
  String birthProfilesDeleteConfirmMessage(String name) {
    return 'This permanently removes $name\'s saved birth profile. This cannot be undone.';
  }

  @override
  String get birthProfilesPrimaryDeleteHint =>
      'Your own profile can\'t be deleted here — use Delete Account in Settings instead.';

  @override
  String get birthProfilesEditorAddTitle => 'Add Profile';

  @override
  String get birthProfilesEditorEditTitle => 'Edit Profile';

  @override
  String get birthProfilesEditorSave => 'Save Profile';

  @override
  String get birthProfilesSaveFailed =>
      'Couldn\'t save this profile. Please try again.';

  @override
  String get birthProfilesDeleteFailed =>
      'Couldn\'t delete this profile. Please try again.';

  @override
  String get birthProfilesSignInRequired =>
      'Sign in to add family & friend profiles.';

  @override
  String get birthProfilesEmpty => 'No profiles yet.';

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
  String profileAiChatHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations',
      one: '$count conversation',
    );
    return '$_temp0';
  }

  @override
  String get aiChatHistoryEmptyTitle => 'No conversations yet';

  @override
  String get aiChatHistoryEmptyMessage =>
      'Ask Rishi AI about your career, marriage, health or the right muhurat — your conversations will appear here.';

  @override
  String get aiChatHistoryEmptyAction => 'Ask Rishi AI';

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
  String get profileDeleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get profileDeleteAccountConfirmMessage =>
      'This permanently deletes your birth profiles, AI chat history and account. This cannot be undone.';

  @override
  String get profileDeleteAccountConfirmAction => 'Delete account';

  @override
  String get accountDeletionErrorUnauthenticated =>
      'Your session has expired. Please sign in again to delete your account.';

  @override
  String get accountDeletionErrorGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get legalPrivacyPolicy => 'Privacy Policy';

  @override
  String get legalTermsOfService => 'Terms of Service';

  @override
  String get legalRefundsCancellation => 'Refunds & Cancellation';

  @override
  String get legalAccountDataDeletion => 'Account & Data Deletion';

  @override
  String get profileEmailSupport => 'Email us';

  @override
  String get profileEmailSupportSubtitle => 'Vedadarshii@gmail.com';

  @override
  String get supportEmailSubject => 'Vedadarshi support';

  @override
  String get feedbackEmailSubject => 'Vedadarshi feedback';

  @override
  String profileInviteFriendsMessage(String link) {
    return 'Join me on Vedadarshi, your daily companion for Vedic astrology, Panchang and horoscopes. Download it here: $link';
  }

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
  String kundliDashaRemainingYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '1 year',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0, $_temp1 remaining';
  }

  @override
  String kundliDashaRemainingYearsOnly(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '1 year',
    );
    return '$_temp0 remaining';
  }

  @override
  String kundliDashaRemainingMonthsOnly(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0 remaining';
  }

  @override
  String get kundliDashaRemainingLessThanMonth => 'Less than a month remaining';

  @override
  String kundliNakshatraPada(int pada) {
    return 'Pada $pada';
  }

  @override
  String get kundliDoshaPitruPresent => 'Pitru Dosha present';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get plansUnavailableTitle => 'Plans aren\'t available right now';

  @override
  String get plansUnavailableMessage =>
      'We couldn\'t load subscription plans. Check your connection and try again.';

  @override
  String perMonthBilledYearly(String price) {
    return '$price/month · billed yearly';
  }

  @override
  String savePercent(String percent) {
    return 'SAVE $percent%';
  }

  @override
  String get currentPlanLabel => 'Your current plan';

  @override
  String get purchaseSuccess => 'You\'re subscribed. Enjoy Vedadarshi Premium.';

  @override
  String get purchasesRestored => 'Purchases restored.';

  @override
  String get purchasesNothingToRestore => 'No previous purchases found.';

  @override
  String get purchaseErrorGeneric =>
      'Purchase couldn\'t be completed. Please try again.';

  @override
  String get purchaseErrorNotAllowed =>
      'Purchases aren\'t available on this account or device.';

  @override
  String get purchaseErrorPending =>
      'Your payment is being processed. Premium unlocks as soon as it clears.';

  @override
  String get purchaseErrorNetwork =>
      'No connection. Check your network and try again.';

  @override
  String get purchaseErrorAlreadyOwned =>
      'You already own this plan — tap Restore purchase to sync it.';

  @override
  String get purchaseErrorUnavailable =>
      'This plan isn\'t available right now.';

  @override
  String get panchangLocationUseAutomatic => 'Use my current location';

  @override
  String get panchangLocationSourceManual => 'Chosen by you';

  @override
  String get panchangLocationSourceDevice => 'Detected from your location';

  @override
  String get panchangLocationSourceBirthProfile => 'From your birth details';

  @override
  String get panchangLocationSourceFallback => 'Default location';

  @override
  String get muhuratDay => 'DAY CHOGHADIYA';

  @override
  String get muhuratNight => 'NIGHT CHOGHADIYA';

  @override
  String get muhuratUnavailable =>
      'Muhurat timings aren\'t available right now.';

  @override
  String get partnerDetailsTitle => 'Partner\'s birth details';

  @override
  String get partnerDetailsSave => 'Save details';

  @override
  String get matchNeedsPartner => 'Add the partner\'s birth details to match.';

  @override
  String get emailHint => 'Email address';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get signInAction => 'Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccountPrompt => 'New to Vedadarshi?';

  @override
  String get createAccount => 'Create account';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter the email address you signed up with and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent =>
      'If that email is registered, a reset link is on its way.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Those passwords don\'t match.';

  @override
  String get authErrorEmailInUse =>
      'That email is already registered. Try signing in instead.';

  @override
  String get authErrorInvalidEmail => 'That email address doesn\'t look right.';

  @override
  String get authErrorWeakPassword =>
      'Please choose a password of at least 6 characters.';

  @override
  String get authErrorWrongCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get authErrorUserNotFound =>
      'No account found with that email address.';

  @override
  String get rahuKaalLabel => 'Rahu Kaal';

  @override
  String get aiWhoseChart => 'Whose chart?';

  @override
  String aiChartFor(String name) {
    return 'Chart: $name';
  }

  @override
  String get matchDetailedTitle => 'What each koota means for you';

  @override
  String get matchDetailedSubtitle =>
      'Unlock all 8 koota readings, with remedies';

  @override
  String get matchDetailedCta => 'Unlock the full reading';

  @override
  String get kundliHousesTitle => 'Your houses';

  @override
  String get kundliYogasTitle => 'Yogas in your chart';

  @override
  String get kundliPredictionsCta => 'Unlock your full reading';

  @override
  String get kundliPredictionsSubtitle =>
      'All 12 house readings and every yoga in your chart';

  @override
  String get reportComplete => 'Complete Life Report';

  @override
  String get reportCompleteDesc =>
      'Your whole chart in one reading — lagna, yogas and all 12 houses';

  @override
  String get reportSectionOverview => 'Overview';

  @override
  String get reportSectionHighlights => 'Key findings';

  @override
  String get reportSectionTiming => 'Timing';

  @override
  String get reportSectionGuidance => 'Guidance';

  @override
  String get reportSectionRemedies => 'Remedies';

  @override
  String get reportSectionStrengths => 'Strengths';

  @override
  String get reportSectionChallenges => 'Watch out for';

  @override
  String get reportGlimpseCta => 'Unlock the full report';

  @override
  String get reportGlimpseSubtitle =>
      'Every section, in full, for your own birth chart';

  @override
  String get reportEmptyMessage =>
      'This report isn\'t available for your chart right now. Please try again.';

  @override
  String kundliDoshaMangalPresentFrom(String refs) {
    return 'Mangal Dosha — Mars sits in a dosha house counted from $refs';
  }

  @override
  String kundliDoshaMangalCancelledFrom(String refs) {
    return 'Mangal Dosha from $refs, but cancelled in your chart';
  }

  @override
  String get kundliDoshaRefLagna => 'Lagna';

  @override
  String get kundliDoshaRefMoon => 'Moon';

  @override
  String get kundliDoshaRefVenus => 'Venus';

  @override
  String get muhuratAbhijit => 'Abhijit Muhurat';

  @override
  String get muhuratRahuKaal => 'Rahu Kaal';

  @override
  String get muhuratYamaganda => 'Yamaganda';

  @override
  String get muhuratGulikaKaal => 'Gulika Kaal';

  @override
  String get muhuratBrahma => 'Brahma Muhurta';

  @override
  String get askAiButton => 'Ask Rishi AI about this';

  @override
  String get askAiSeedPlanets =>
      'Explain what the planet positions in my birth chart mean.';

  @override
  String get askAiSeedDasha =>
      'What does my current Vimshottari dasha period mean for me?';

  @override
  String get askAiSeedPredictions =>
      'Explain the yogas and house predictions in my birth chart.';

  @override
  String get askAiSeedMatching =>
      'Explain our Gun Milan compatibility score and what it means for us.';

  @override
  String get lblLagna => 'Lagna';

  @override
  String get lblRashi => 'Rashi';

  @override
  String get lblCareerHouse => 'Career house';

  @override
  String get lblCareerLord => 'Career lord';

  @override
  String get lblPartnershipHouse => 'Partnership house';

  @override
  String get lblPartnershipLord => 'Partnership lord';

  @override
  String get lblVenus => 'Venus';

  @override
  String get lblMahadasha => 'Mahadasha';

  @override
  String get lblAntardasha => 'Antardasha';

  @override
  String get lblPhase => 'Phase';

  @override
  String get lblMantra => 'Mantra';

  @override
  String get lblSetting => 'Setting';

  @override
  String get lblDayToWear => 'Day to wear';

  @override
  String get lblLifePath => 'Life path';

  @override
  String get lblDestiny => 'Destiny';

  @override
  String get lblSoulUrge => 'Soul urge';

  @override
  String get lblPersonality => 'Personality';

  @override
  String get lblBirthdayNumber => 'Birthday';

  @override
  String get lblMaturity => 'Maturity';

  @override
  String get lblLifeLesson => 'Life lesson';

  @override
  String lblHouseN(int n) {
    return 'House $n';
  }

  @override
  String get aiFollowUpDasha => 'What does my current dasha period mean?';

  @override
  String get aiFollowUpCareer => 'What does my career outlook look like?';

  @override
  String get aiFollowUpRemedies => 'Which remedies suit my chart?';

  @override
  String get aiFollowUpHealth => 'What does my chart say about my health?';

  @override
  String get panchangMasaLabel => 'Masa';

  @override
  String get panchangPakshaLabel => 'Paksha';

  @override
  String dashaCurrentSentence(String planet) {
    return 'You are in $planet Maha Dasha';
  }

  @override
  String panchangAdviceComposed(
    String quality,
    String tithi,
    String paksha,
    String nakshatra,
    String yoga,
  ) {
    return 'Today is $quality. $tithi tithi ($paksha paksha) with $nakshatra nakshatra and $yoga yoga.';
  }

  @override
  String get choghadiyaBestForKaal =>
      'Only for specific purposes like overcoming enemies or tantric practices';

  @override
  String get choghadiyaBestForShubh =>
      'Religious ceremonies, education, financial planning, and meeting elders';

  @override
  String get choghadiyaBestForRog =>
      'Surgical procedures, competitive activities, and confronting challenges';

  @override
  String get choghadiyaBestForUdveg =>
      'Government work, meeting officials, and administrative tasks';

  @override
  String get choghadiyaBestForChar =>
      'Travel, journeys, buying vehicles, and temporary arrangements';

  @override
  String get choghadiyaBestForLabh =>
      'Business deals, financial transactions, trade, and career moves';

  @override
  String get choghadiyaBestForAmrit =>
      'All auspicious activities, especially new ventures, marriages, and important ceremonies';

  @override
  String get notifDailyHoroscopeTitle => 'Your daily horoscope is ready';

  @override
  String get notifDailyHoroscopeBody =>
      'Your reading for today is waiting — tap to see it.';

  @override
  String get notifSawanSomvarTitle => 'Sawan Somvar tomorrow';

  @override
  String get notifSawanSomvarBody =>
      'Fasting day for Lord Shiva. See rituals, muhurat & vrat rules.';

  @override
  String get notifRishiAiReplyTitle => 'Rishi AI replied';

  @override
  String get notifRishiAiReplyBody =>
      'Your question has an answer waiting in the chat.';

  @override
  String get notifRahuKaalAlertTitle => 'Rahu Kaal alert';

  @override
  String get notifRahuKaalAlertBody =>
      'Avoid starting anything new during today\'s Rahu Kaal.';

  @override
  String get notifPremiumOfferTitle => 'Unlock premium';

  @override
  String get notifPremiumOfferBody =>
      'See the plans and what each one includes.';

  @override
  String get notifNewArticleTitle => 'New article published';

  @override
  String get notifNewArticleBody =>
      'A new reading has been added to Wisdom for you.';

  @override
  String get chooseSavedProfile => 'Choose a saved profile';

  @override
  String get enterNewDetails => 'Enter new details';

  @override
  String get noSavedProfiles => 'No other saved profiles yet';

  @override
  String get premiumMember => 'Premium member';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumUnlockHint => 'Unlock full readings and reports';

  @override
  String get aiPacksTitle => 'AI question packs';

  @override
  String get aiPacksSubtitle => 'Top up when today\'s questions run out';

  @override
  String aiPackQuestions(String count) {
    return '$count questions';
  }

  @override
  String aiPackValidity(String days) {
    return 'Valid $days days';
  }

  @override
  String get aiPackBestValue => 'Best value';

  @override
  String get aiPacksUnavailable => 'Packs aren\'t available right now.';

  @override
  String get aiPackPurchased =>
      'Purchase complete — your questions will appear in a moment.';

  @override
  String aiPackBalance(String count) {
    return '$count pack questions left';
  }

  @override
  String get aiPackTopUp => 'Top up questions';

  @override
  String get dailyReadingTitle => 'Personalized Daily Reading';

  @override
  String get dailyReadingDesc =>
      'Today read from your own chart — not your sun sign';

  @override
  String get dailyReadingBuy => 'Unlock today\'s reading';

  @override
  String dailyReadingActiveUntil(String time) {
    return 'Unlocked until $time';
  }

  @override
  String get dailyReadingLocked =>
      'Your personal reading for today, computed from your birth chart.';

  @override
  String get dailyReadingUnavailable => 'This isn\'t available right now.';

  @override
  String get dailyReadingLucky => 'Lucky today';

  @override
  String get dailyReadingRemedies => 'Remedies';

  @override
  String get dailyReadingAreaCareer => 'Career';

  @override
  String get dailyReadingAreaFinance => 'Finance';

  @override
  String get dailyReadingAreaHealth => 'Health';

  @override
  String get dailyReadingAreaRelationship => 'Relationships';

  @override
  String get reportBuyOnce => 'Unlock this report';

  @override
  String get reportOwned => 'You own this report';

  @override
  String get reportBuyOrSubscribe => 'Or subscribe for all reports';

  @override
  String get reportDownloadPdf => 'Download PDF';

  @override
  String get reportPdfFailed => 'Couldn\'t create the PDF.';

  @override
  String get lblOverallScore => 'Overall score';

  @override
  String get lblFifthHouse => 'Children house';

  @override
  String get lblFifthLord => 'Children lord';

  @override
  String get lblJupiter => 'Jupiter';

  @override
  String get reportRemedies => 'Lal Kitab Remedies';

  @override
  String get reportRemediesDesc => 'Per-planet remedies from your chart';

  @override
  String get reportRudraksha => 'Rudraksha Guide';

  @override
  String get reportRudrakshaDesc => 'Which mukhi suits your planets';

  @override
  String get reportProperty => 'Property Report';

  @override
  String get reportPropertyDesc => 'Timing for land, home & vehicles';

  @override
  String get reportChildFamily => 'Child & Family Report';

  @override
  String get reportChildFamilyDesc => 'Progeny indicators & timing';

  @override
  String get reportBusiness => 'Business Report';

  @override
  String get reportBusinessDesc => 'Venture timing & partnership';

  @override
  String get allReportsFooter => 'All reports include PDF download';

  @override
  String get storeTitle => 'Store';

  @override
  String get storeSubtitle => 'One-time purchases — no subscription needed';

  @override
  String get storeTabPacks => 'AI packs';

  @override
  String get storeTabReports => 'Reports';

  @override
  String get storeTabDaily => 'Daily reading';

  @override
  String get storeOwned => 'Owned';

  @override
  String get storeIncluded => 'Included';

  @override
  String get storeUnavailable => 'Not available right now.';

  @override
  String get storeSubscribeHint => 'Subscribing unlocks every report instead';

  @override
  String get storeSubscriptionOnly => 'Subscription only';
}
