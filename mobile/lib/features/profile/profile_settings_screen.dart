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
import '../panchang/panchang_location.dart';
import '../panchang/panchang_location_screen.dart';
import '../premium/subscription_paywall_screen.dart';
import '../reports/premium_reports_screen.dart';
import '../startup/root_gate.dart';
import 'account_deletion_error_messages.dart';
import 'account_deletion_repository.dart';
import 'birth_profile.dart';
import 'birth_profile_repository.dart';

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
///  - Delete account is REAL (24 Aug 2026): confirms with an irreversible-
///    action dialog (see [_confirmDeleteAccount]), then calls the
///    `deleteAccount` Cloud Function (`AccountDeletionRepository`, per
///    `projects/CLAUDE.md`'s "Delete Account" section — the backend
///    deletes the whole `/users/{uid}` Firestore subtree and the Auth
///    user server-side). Unlike log out, this does NOT call
///    `AuthService.signOut()` — the Firebase user no longer exists by the
///    time the callable returns — but it still clears the local profile
///    cache and invalidates both providers before resetting to
///    [RootGate], for the same stale-cache reason as log out.
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
///    Send Feedback) is an honest no-op — see each row's
///    `onTap` comment for what it will eventually do. There is no
///    "saved/bookmarked articles" row in this design to route to
///    `ArticlesScreen` — the D5 frame simply doesn't have one.
///
/// ACTIVITY COUNTS, PAYMENT AND SUBSCRIPTION SUMMARY ARE DELIBERATELY BLANK
/// (18 Aug 2026). They used to render the Figma frame's sample values —
/// "4 purchased", "3 files", "12 conversations",
/// "Last: ₹1,999 · 12 Jun 2026", "Yearly · renews 12 Jun 2027" — as if they
/// were this account's real records. On a device test they showed on an
/// account created ten minutes earlier that had purchased nothing, and
/// ₹1,999 is not even a price in the catalogue (it is the placeholder that
/// was already deleted from the paywall for the same reason).
///
/// A fabricated payment record is worse than an empty row: the user cannot
/// tell it apart from a real charge, and it is exactly what a Play reviewer
/// or a support ticket screenshots. `_MenuRow.subtitle` is nullable and the
/// row lays out cleanly without one, so the honest state costs nothing.
///
/// Restore a subtitle only when it is backed by a real source: purchased
/// reports and payments from RevenueCat's `CustomerInfo` (never a
/// client-side flag), and the AI chat count from `/users/{uid}/aiChats`,
/// which IS now written on every successful, already-charged answer.
/// The "Birth profiles" count above is already computed for real from
/// `birthProfileProvider` — that is the pattern to follow.
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  /// Guards against a double-tap firing two concurrent sign-outs.
  bool _isSigningOut = false;

  /// Guards against a double-tap firing two concurrent account deletions —
  /// mirrors [_isSigningOut].
  bool _isDeleting = false;

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
      // FCM token cleanup is BEST-EFFORT and must never be able to block
      // signing out — 24 Aug 2026, client-reported "logout is failing".
      //
      // It still runs FIRST, and for the documented reason: the Firestore
      // rules only allow writes under /users/{uid} for that uid, so deleting
      // the token after signOut() is denied and the device keeps receiving
      // the previous account's pushes.
      //
      // But it was previously awaited bare in the critical path, so ANY
      // failure here — offline, a denied write, no FCM on the device, a
      // guest with no uid — fell through to the generic `catch` below and
      // aborted the whole sign-out. The user tapped "Log out", saw
      // "Something went wrong", and stayed signed in with no way to leave
      // the account. Losing a token row is a far smaller problem than being
      // unable to sign out, so this swallows its own failure.
      try {
        await ref
            .read(pushNotificationServiceProvider)
            .removeTokenForCurrentUser();
      } catch (_) {
        // Orphaned token: it stops working on its own once Firebase rotates
        // or the install is removed, and the next sign-in overwrites it.
      }
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

  /// Confirmation dialog for the destructive, irreversible "Delete account"
  /// action — modeled on [_confirmSignOut]'s styling but deliberately
  /// harder to dismiss by accident: `barrierDismissible: false` (tapping
  /// outside does nothing; the user must explicitly choose Cancel or
  /// Delete), the body spells out exactly what is destroyed, and Cancel —
  /// not Delete — is the safe default.
  Future<void> _confirmDeleteAccount(AppLocalizations l10n, Locale locale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.profileDeleteAccountConfirmTitle,
          style: AppFonts.heading(
            locale,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          l10n.profileDeleteAccountConfirmMessage,
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
              l10n.profileDeleteAccountConfirmAction,
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
    await _deleteAccount();
  }

  /// Permanently deletes the signed-in user's account via the
  /// `deleteAccount` Cloud Function (`AccountDeletionRepository`, per
  /// `projects/CLAUDE.md`'s "Delete Account" section).
  ///
  /// Deliberately DOES NOT call `AuthService.signOut()` first, unlike
  /// [_signOut] — the callable has already deleted the Firebase Auth user
  /// server-side by the time it returns, so there is no session left to
  /// sign out of. What it MUST still do, for the exact reason documented
  /// on this class and on [_signOut], is clear the local profile cache and
  /// invalidate both providers before resetting to [RootGate] — otherwise
  /// the gate finds a stale saved profile and routes the now-deleted
  /// account straight back to Home instead of onboarding.
  Future<void> _deleteAccount() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      // FCM token cleanup is BEST-EFFORT and must never be able to block
      // account deletion — same reasoning, and the same bug class, as the
      // fix documented on `_signOut` (24 Aug 2026, client-reported "logout
      // is failing" from an unguarded await here). It still runs FIRST,
      // while the user is still authenticated: the Firestore rules only
      // allow a write under /users/{uid} for that uid, so attempting it
      // after the account is gone would fail anyway.
      try {
        await ref
            .read(pushNotificationServiceProvider)
            .removeTokenForCurrentUser();
      } catch (_) {
        // Orphaned token: harmless — the account (and its Firestore doc)
        // no longer exists to receive pushes for.
      }
      await ref.read(accountDeletionRepositoryProvider).deleteAccount();
      // The Firebase user is already gone server-side — do NOT call
      // AuthService.signOut() here (see this method's doc comment). But
      // the local cache must still be cleared, or RootGate strands the
      // user on Home off the stale cached profile.
      await ref.read(birthProfileRepositoryProvider).clearLocal();
      ref.invalidate(birthProfileProvider);
      ref.invalidate(hasBirthProfileProvider);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RootGate()),
        (route) => false,
      );
    } on AccountDeletionException catch (e) {
      // Never leave the user staring at a dialog that appeared to do
      // nothing — surface exactly why it failed.
      if (!mounted) return;
      setState(() => _isDeleting = false);
      final message = accountDeletionErrorMessage(l10n, e.code);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountDeletionErrorGeneric)),
      );
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
                  // No subtitle: a purchased-reports count has no data source.
                  // It read "4 purchased" on a brand-new account (see the
                  // note above _MyActivity).
                  locale: locale,
                  onTap: () => Navigator.of(
                    context,
                  ).push(fadeThroughRoute(const PremiumReportsScreen())),
                ),
                _MenuRow(
                  icon: Icons.file_download_outlined,
                  title: l10n.profileDownloadedPdfs,
                  // No subtitle: PDF export history isn't tracked anywhere.
                  locale: locale,
                  // PDF export/download history isn't tracked anywhere yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '🔮',
                  title: l10n.profileAiChatHistory,
                  // No subtitle for now. A REAL count is finally possible —
                  // `/users/{uid}/aiChats` is written on every successful,
                  // already-charged AI answer — but until that count is
                  // actually read, showing a number would be inventing one.
                  locale: locale,
                  // AI chat history persistence is a listed SCOPE WATCH item
                  // (projects/CLAUDE.md) — not built yet.
                  onTap: () {},
                ),
                _MenuRow(
                  emoji: '💳',
                  title: l10n.profilePaymentHistory,
                  // No subtitle. This previously read
                  // "Last: ₹1,999 · 12 Jun 2026" — a payment that never
                  // happened, at a price that isn't even in the catalogue.
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
                  // The city the panchang is ACTUALLY computed for — the
                  // saved birth city, which is what `panchang_screen.dart`
                  // and Home both send as coordinates. This row previously
                  // read the constant `PanchangStaticData.location`
                  // ('Hyderabad') and so contradicted the Panchang tab's own
                  // header for every user not born there (21 Aug 2026).
                  //
                  // Null while the profile loads or for a guest — the row
                  // then shows no subtitle rather than naming a city that
                  // isn't theirs.
                  subtitle: ref.watch(panchangLocationProvider).city.name,
                  locale: locale,
                  // Now a real destination (21 Aug 2026): panchang location
                  // IS its own setting, because a daily almanac is about
                  // where the user IS while the birth city is fixed history.
                  onTap: () => Navigator.of(context).push(
                    fadeThroughRoute(const PanchangLocationScreen()),
                  ),
                ),
                _MenuRow(
                  emoji: '👑',
                  title: l10n.profileManageSubscription,
                  // No subtitle: "Yearly · renews 12 Jun 2027" claimed an
                  // active subscription for every user, free ones included.
                  // Entitlement must come from RevenueCat's CustomerInfo and
                  // is never asserted client-side.
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
              onDeleteAccount: () => _confirmDeleteAccount(l10n, locale),
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
      // Colors are set explicitly rather than left to the Material 3
      // defaults, which derive from the saffron-seeded ColorScheme and came
      // out as a washed cream track with a grey-brown thumb — off-brand in
      // both themes, and near-invisible against a dark card.
      trailing: Switch(
        value: isDarkActive,
        onChanged: toggle,
        activeThumbColor: AppColors.surface,
        activeTrackColor: AppColors.saffron,
        inactiveThumbColor: AppColors.muted,
        inactiveTrackColor: AppColors.cream,
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.saffron
              : AppColors.cardBorder,
        ),
      ),
    );
  }
}

/// "Log out" / "Delete account" footer (Figma node 29:69).
class _FooterActions extends StatelessWidget {
  const _FooterActions({
    required this.l10n,
    required this.locale,
    required this.onLogOut,
    required this.onDeleteAccount,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onLogOut;
  final VoidCallback onDeleteAccount;

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
            // Account deletion goes through the `deleteAccount` Cloud
            // Function (24 Aug 2026) so the whole /users/{uid} subtree is
            // removed atomically — client deletes of the account doc are
            // forbidden by the deployed security rules (see
            // projects/CLAUDE.md). See `_confirmDeleteAccount`/
            // `_deleteAccount` above for the confirmation + call flow.
            onTap: onDeleteAccount,
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
