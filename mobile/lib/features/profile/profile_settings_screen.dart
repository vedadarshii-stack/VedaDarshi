import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/motion/app_motion.dart';
import '../../core/notifications/push_notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../l10n/app_localizations.dart';
import '../kundli/kundli_static_data.dart';
import '../auth/auth_error_messages.dart';
import '../notifications/notifications_screen.dart';
import '../panchang/panchang_static_data.dart';
import '../premium/subscription_paywall_screen.dart';
import '../reports/premium_reports_screen.dart';
import '../startup/root_gate.dart';
import 'birth_profile.dart';
import 'birth_profile_repository.dart';
import 'profile_settings_static_data.dart';

/// Which language option is offered in the APP LANGUAGE row — mirrors
/// `language_select_screen.dart`'s private `_LanguageOption`/list. Kept as a
/// separate, screen-local copy rather than shared, matching this project's
/// existing convention of small screen-local duplicates (see e.g.
/// `search_screen.dart`'s `_reportTitle`/`_reportDescription` helpers, which
/// duplicate `premium_reports_screen.dart`'s for the same reason).
class _LanguageOption {
  const _LanguageOption(this.languageCode, this.nativeName);

  final String languageCode;
  final String nativeName;
}

const List<_LanguageOption> _languageOptions = [
  _LanguageOption('en', 'English'),
  _LanguageOption('hi', 'हिन्दी'),
  _LanguageOption('te', 'తెలుగు'),
  _LanguageOption('ta', 'தமிழ்'),
  _LanguageOption('kn', 'ಕನ್ನಡ'),
];

/// Profile & Settings, per the approved Figma "D5 · Profile & Settings"
/// (node 29:2) concept.
///
/// This is a TOP-LEVEL TAB (bottom nav Profile) — no back button, bottom nav
/// visible, matching Home/Panchang's tab-root convention exactly (see
/// `app_bottom_nav.dart`).
///
/// What's real vs placeholder on this screen:
///  - The profile header (name + birth summary + avatar initial) reads the
///    REAL saved [BirthProfile] via `birthProfileProvider`, exactly like
///    `kundli_input_screen.dart` — with the same defensive fallback to
///    [KundliStaticData] for the should-be-impossible "no profile" case.
///    The Figma design's subtitle line reads "+91 98••• ••210 · Simha rashi"
///    (masked phone + zodiac sign) — neither value exists anywhere in the
///    app (no rashi is computed from a birth chart yet, and masking a phone
///    number needs the Firebase user's phone, not the birth profile), so
///    this deliberately shows `profile.summaryLine` instead (date · time ·
///    city) — the same real field `kundli_input_screen.dart` already shows.
///  - The design's "👑 Premium" pill is NOT rendered: there is no real
///    subscription-status source anywhere in the app yet (RevenueCat isn't
///    wired up — see `subscription_paywall_screen.dart`'s doc comment), so
///    hardcoding it for every user would misrepresent their account — same
///    principle documented on `kundli_static_data.dart` for why the Kundli
///    input screen doesn't fabricate a second profile card either.
///  - The APP LANGUAGE row is REAL and fully functional (client-requested V1
///    requirement) — tapping a pill calls
///    `localeControllerProvider.notifier.setLocale`, exactly like
///    `language_select_screen.dart`'s cards.
///  - Log out is REAL: confirms with a dialog, then calls
///    `AuthService.signOut()`, `birthProfileRepository.clearLocal()`,
///    invalidates `birthProfileProvider`/`hasBirthProfileProvider`, and
///    resets navigation to [RootGate] so it re-decides. Skipping the
///    clear+invalidate step is the exact bug `projects/CLAUDE.md` warns
///    about — a signed-out user routed straight back to Home off the stale
///    cached profile.
///  - The dark-mode switch is REAL (see [_AppearanceRow]) — it reflects
///    whether dark is currently active (resolving [ThemeMode.system] via the
///    platform brightness) and toggling it sets an explicit
///    [ThemeMode.light]/[ThemeMode.dark] via `themeControllerProvider`,
///    exactly like the language pills call `localeControllerProvider`.
///  - "My Reports" routes to [PremiumReportsScreen], "Restore Purchases"
///    routes to [SubscriptionPaywallScreen] (which has its own real restore
///    action in its top bar), and "Notifications" routes to
///    [NotificationsScreen] — the three destinations that already exist.
///    Every other row (Birth profiles, Downloaded PDFs, AI Chat History,
///    Payment History, Panchang location, Manage subscription, Privacy &
///    security, Help & support, Refer & Earn, Invite Friends, Rate,
///    Send Feedback, Delete account) is an honest no-op — see each row's
///    `onTap` comment for what it will eventually do. There is no
///    "saved/bookmarked articles" row in this design to route to
///    `ArticlesScreen` — the D5 frame simply doesn't have one.
///
/// Activity counts / payment / subscription summary VALUES shown are static
/// placeholder content from [ProfileSettingsStaticData]; see that file's doc
/// comment for what eventually replaces each one.
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  /// Guards against a double-tap firing two concurrent sign-outs.
  bool _isSigningOut = false;

  Future<void> _confirmSignOut(AppLocalizations l10n, Locale locale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.profileSignOutConfirmTitle,
          style: AppFonts.heading(
            locale,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          l10n.profileSignOutConfirmMessage,
          style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.profileCancel,
              style: AppFonts.body(
                locale,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileSignOutConfirmAction,
              style: AppFonts.body(
                locale,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ashubhFg,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _signOut();
  }

  /// See this class's doc comment — every one of these steps is required, or
  /// a signed-out user gets routed straight back to Home off the stale
  /// cached profile (the exact bug `projects/CLAUDE.md` warns about).
  ///
  /// ORDER MATTERS: the push token is removed FIRST, while the user is still
  /// authenticated. The Firestore rules only permit writes under
  /// `/users/{uid}` for that uid, so deleting it after `signOut()` would be
  /// denied and this phone would keep receiving the previous account's push
  /// notifications.
  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(pushNotificationServiceProvider)
          .removeTokenForCurrentUser();
      await ref.read(authServiceProvider).signOut();
      await ref.read(birthProfileRepositoryProvider).clearLocal();
      ref.invalidate(birthProfileProvider);
      ref.invalidate(hasBirthProfileProvider);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RootGate()),
        (route) => false,
      );
    } on AuthException catch (e) {
      // Sign-out can genuinely fail (no network). Surface it instead of
      // leaving the user tapping a button that appears to do nothing.
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authErrorUnknown)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final profile = ref.watch(birthProfileProvider).valueOrNull;
    final currentLocale = ref.watch(localeControllerProvider) ?? locale;

    return Scaffold(
      backgroundColor: AppColors.cream,
      bottomNavigationBar: const AppBottomNav(currentTab: AppTab.profile),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 28 : 52, 20, 24),
          children: [
            _ProfileHeaderCard(profile: profile, locale: locale),
            const SizedBox(height: 14),
            _BirthProfilesRow(
              hasProfile: profile != null,
              l10n: l10n,
              locale: locale,
            ),
            const SizedBox(height: 18),
            _SectionLabel(l10n.profileAppLanguageLabel, locale: locale),
            const SizedBox(height: 10),
            _LanguageRow(
              selectedCode: currentLocale.languageCode,
              onSelect: (code) => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(Locale(code)),
            ),
            const SizedBox(height: 18),
            _SectionLabel(l10n.profileMyActivityLabel, locale: locale),
            const SizedBox(height: 10),
            _MenuCard(
              children: [
                _MenuRow(
                  emoji: '📜',
                  title: l10n.profileMyReports,
                  subtitle: ProfileSettingsStaticData.reportsPurchased,
                  locale: locale,
                  onTap: () => Navigator.of(
                    context,
                  ).push(fadeThroughRoute(const PremiumReportsScreen())),
                ),
                _MenuRow(
                  icon: Icons.file_download_outlined,
                  title: l10n.profileDownloadedPdfs,
                  subtitle: ProfileSettingsStaticData.downloadedPdfs,
                  locale: locale,
                  // PDF export/download history isn't tracked anywhere yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '🔮',
                  title: l10n.profileAiChatHistory,
                  subtitle: ProfileSettingsStaticData.aiChatConversations,
                  locale: locale,
                  // AI chat history persistence is a listed SCOPE WATCH item
                  // (projects/CLAUDE.md) — not built yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '💳',
                  title: l10n.profilePaymentHistory,
                  subtitle: ProfileSettingsStaticData.lastPayment,
                  locale: locale,
                  isLast: true,
                  // Payment history needs RevenueCat/Play Billing wired up
                  // first (also a listed SCOPE WATCH item).
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(l10n.profilePreferencesLabel, locale: locale),
            const SizedBox(height: 10),
            _MenuCard(
              children: [
                _AppearanceRow(l10n: l10n, locale: locale),
                _MenuRow(
                  emoji: '🔔',
                  title: l10n.profileNotifications,
                  subtitle: l10n.profileNotificationsSubtitle,
                  locale: locale,
                  onTap: () => Navigator.of(
                    context,
                  ).push(fadeThroughRoute(const NotificationsScreen())),
                ),
                _MenuRow(
                  emoji: '📍',
                  title: l10n.profilePanchangLocation,
                  subtitle: PanchangStaticData.location,
                  locale: locale,
                  // No location-settings screen exists yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '👑',
                  title: l10n.profileManageSubscription,
                  subtitle: ProfileSettingsStaticData.subscriptionSummary,
                  locale: locale,
                  // Real subscription management lives on Google Play, not
                  // in this app — this would deep-link to the Play Store
                  // subscription page once RevenueCat is wired up.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '🔒',
                  title: l10n.profilePrivacySecurity,
                  locale: locale,
                  // No privacy/security settings screen exists yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '💬',
                  title: l10n.profileHelpSupport,
                  locale: locale,
                  isLast: true,
                  // No help/support screen exists yet.
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(l10n.profileRewardsLabel, locale: locale),
            const SizedBox(height: 10),
            _MenuCard(
              children: [
                _MenuRow(
                  emoji: '🎁',
                  title: l10n.profileReferEarn,
                  subtitle: l10n.profileReferEarnSubtitle,
                  locale: locale,
                  // Referral program is a listed SCOPE WATCH item
                  // (projects/CLAUDE.md) — not built yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '👥',
                  title: l10n.profileInviteFriends,
                  subtitle: l10n.profileInviteFriendsSubtitle,
                  locale: locale,
                  isLast: true,
                  // Would open the OS share sheet with a referral link — no
                  // share integration is wired up yet.
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(l10n.profileMoreLabel, locale: locale),
            const SizedBox(height: 10),
            _MenuCard(
              children: [
                _MenuRow(
                  emoji: '⭐',
                  title: l10n.profileRateApp,
                  locale: locale,
                  // Would open the Play Store listing — no store-review
                  // integration is wired up yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '✍️',
                  title: l10n.profileSendFeedback,
                  locale: locale,
                  // No feedback form/support email flow is wired up yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '♻️',
                  title: l10n.profileRestorePurchases,
                  locale: locale,
                  isLast: true,
                  onTap: () => Navigator.of(
                    context,
                  ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FooterActions(
              l10n: l10n,
              locale: locale,
              onLogOut: () => _confirmSignOut(l10n, locale),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uppercased, letter-spaced section label ("APP LANGUAGE" / "MY ACTIVITY" /
/// etc.) — same recipe as `articles_screen.dart`'s/`notifications_screen.dart`'s
/// own private `_SectionLabel` (screen-local duplicate, per this project's
/// convention).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.locale});

  final String label;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.body(
        locale,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        letterSpacing: 0.88,
      ),
    );
  }
}

/// The navy-gradient profile header card (Figma node 29:4) — real name +
/// birth summary from [BirthProfile], with the same defensive fallback
/// `kundli_input_screen.dart` uses for the should-be-impossible "no saved
/// profile" case.
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile, required this.locale});

  final BirthProfile? profile;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final trimmedName = profile?.fullName.trim();
    final name = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : KundliStaticData.fallbackProfileName;
    final summary =
        profile?.summaryLine ?? KundliStaticData.fallbackProfileSummary;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.navyHeroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.16),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Text(
              initial,
              style: AppFonts.heading(
                locale,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11.5,
                    color: AppColors.mutedOnNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Birth profiles" menu row (Figma node 29:12) — the count reflects the
/// REAL saved-profile state (0 or 1); it never fabricates the design's
/// hardcoded "2 profiles", same honesty principle as
/// `kundli_static_data.dart`'s doc comment.
class _BirthProfilesRow extends StatelessWidget {
  const _BirthProfilesRow({
    required this.hasProfile,
    required this.l10n,
    required this.locale,
  });

  final bool hasProfile;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final count = hasProfile ? 1 : 0;

    return Semantics(
      button: true,
      label: l10n.profileBirthProfiles,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        // Multi-profile management (family/friends) isn't built yet — see
        // `BirthProfileRepository`'s doc comment.
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text('👪', style: AppFonts.body(locale, fontSize: 17)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  l10n.profileBirthProfiles,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.profileProfileCount(count.toString()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 12,
                  color: AppColors.hint,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.otpBorderFilled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// APP LANGUAGE pill row (Figma node 29:17) — REAL and functional (client-
/// requested V1 requirement), unlike the rest of this screen's inert rows.
/// Tapping a pill sets the app-wide locale immediately, the same live-
/// preview behaviour as `language_select_screen.dart`'s cards.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.selectedCode, required this.onSelect});

  final String selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in _languageOptions) ...[
          Expanded(
            child: _LanguagePill(
              option: option,
              isSelected: option.languageCode == selectedCode,
              onTap: () => onSelect(option.languageCode),
            ),
          ),
          if (option != _languageOptions.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: option.nativeName,
      child: PressableScale(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.saffron : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            // Each option renders in its OWN locale's face (Latin-only
            // Poppins has no Devanagari/Telugu/Tamil/Kannada glyphs), same
            // convention as `language_select_screen.dart`'s cards.
            option.nativeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              Locale(option.languageCode),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// White, bordered, rounded-18 card wrapping a group of [_MenuRow]s (Figma's
/// MY ACTIVITY / PREFERENCES / REWARDS / MORE containers).
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

/// One settings/menu row — a leading icon or emoji, a title (+ optional
/// subtitle), and a trailing chevron (or a custom [trailing] widget, used by
/// [_AppearanceRow] for its inert switch), with a hairline divider below
/// unless [isLast].
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    this.icon,
    this.emoji,
    required this.title,
    this.subtitle,
    required this.locale,
    required this.onTap,
    this.isLast = false,
    this.trailing,
  }) : assert(
         (icon == null) != (emoji == null),
         'Provide exactly one of icon or emoji',
       );

  final IconData? icon;
  final String? emoji;
  final String title;
  final String? subtitle;
  final Locale locale;
  final VoidCallback onTap;
  final bool isLast;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: title,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: icon != null
                          ? Icon(icon, size: 16, color: AppColors.muted)
                          : Text(
                              emoji!,
                              style: AppFonts.body(locale, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              locale,
                              fontSize: 10.5,
                              color: AppColors.hint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ??
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.otpBorderFilled,
                      ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) Container(height: 1, color: AppColors.rowDivider),
      ],
    );
  }
}

/// "Appearance" (dark mode) row (Figma node 29:30). Genuinely functional:
/// the switch reflects whether dark is currently ACTIVE (resolving
/// [ThemeMode.system] via the platform brightness, since "system" itself
/// isn't an on/off state) and both the switch and tapping the row set an
/// explicit [ThemeMode.light]/[ThemeMode.dark] via `themeControllerProvider`
/// — mirroring how the language pills elsewhere on this screen call
/// `localeControllerProvider.notifier.setLocale`.
class _AppearanceRow extends ConsumerWidget {
  const _AppearanceRow({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDarkActive = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    final subtitle = switch (themeMode) {
      ThemeMode.system => l10n.profileAppearanceSystem,
      ThemeMode.light => l10n.profileAppearanceLight,
      ThemeMode.dark => l10n.profileAppearanceDark,
    };
    void toggle(bool wantsDark) {
      ref
          .read(themeControllerProvider.notifier)
          .setThemeMode(wantsDark ? ThemeMode.dark : ThemeMode.light);
    }

    return _MenuRow(
      emoji: '🌗',
      title: l10n.profileAppearance,
      subtitle: subtitle,
      locale: locale,
      onTap: () => toggle(!isDarkActive),
      trailing: Switch(value: isDarkActive, onChanged: toggle),
    );
  }
}

/// "Log out" / "Delete account" footer (Figma node 29:69).
class _FooterActions extends StatelessWidget {
  const _FooterActions({
    required this.l10n,
    required this.locale,
    required this.onLogOut,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onLogOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                l10n.profileLogOut,
                style: AppFonts.body(
                  locale,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 21),
        Semantics(
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            // Account deletion must go through a Cloud Function so the
            // whole /users/{uid} subtree is removed atomically — client
            // deletes of the account doc are forbidden by the deployed
            // security rules (see projects/CLAUDE.md). Not built yet.
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                l10n.profileDeleteAccount,
                style: AppFonts.body(
                  locale,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ashubhFg,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
