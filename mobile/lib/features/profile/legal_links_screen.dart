import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';

/// One published legal/policy document — title + the external URL it opens.
class _LegalLink {
  const _LegalLink({
    required this.icon,
    required this.title,
    required this.uri,
  });

  final IconData icon;
  final String title;
  final Uri uri;
}

/// "Privacy & security" destination (26 Aug 2026) — reached from the
/// Profile & Settings screen's "Privacy & security" row.
///
/// Lists the FOUR published legal documents rather than a single link,
/// because the account-deletion page in particular needs to be easy to
/// find (Google Play policy requires an in-app path to it, not just a
/// support-page mention). Every document is hosted externally at
/// `vedadarshi-legal.web.app` and opened in the browser, exactly like
/// `profile_settings_screen.dart`'s `_openPlayOrderHistory` — this screen
/// owns none of the legal text itself, so there is nothing here to keep in
/// sync with the hosted pages, and no `flutter build`/store review is
/// needed to fix a typo in the Refunds policy.
class LegalLinksScreen extends StatelessWidget {
  const LegalLinksScreen({super.key});

  /// Same "open externally, tell the user if it silently fails" pattern as
  /// `profile_settings_screen.dart`'s `_launchExternal`: `LaunchMode
  /// .externalApplication` so this opens in the real browser rather than an
  /// in-app webview, and both a `false` return and a thrown exception are
  /// real failure modes worth surfacing rather than leaving a row that
  /// looks like it did nothing.
  Future<void> _open(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.authErrorUnknown)));
      }
    } catch (_) {
      if (!context.mounted) return;
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

    final links = <_LegalLink>[
      _LegalLink(
        icon: Icons.privacy_tip_outlined,
        title: l10n.legalPrivacyPolicy,
        uri: Uri.parse('https://vedadarshi-legal.web.app/privacy'),
      ),
      _LegalLink(
        icon: Icons.description_outlined,
        title: l10n.legalTermsOfService,
        uri: Uri.parse('https://vedadarshi-legal.web.app/terms'),
      ),
      _LegalLink(
        icon: Icons.receipt_long_outlined,
        title: l10n.legalRefundsCancellation,
        uri: Uri.parse('https://vedadarshi-legal.web.app/refunds'),
      ),
      _LegalLink(
        icon: Icons.delete_outline,
        title: l10n.legalAccountDataDeletion,
        uri: Uri.parse('https://vedadarshi-legal.web.app/delete-account'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          l10n.profilePrivacySecurity,
          style: AppFonts.heading(
            locale,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 12 : 20, 20, 32),
          children: [
            _LegalCard(
              locale: locale,
              links: links,
              onTap: (uri) => _open(context, uri),
            ),
          ],
        ),
      ),
    );
  }
}

/// White, bordered, rounded-18 card wrapping the four [_LegalRow]s — same
/// visual recipe as `profile_settings_screen.dart`'s private `_MenuCard`,
/// duplicated locally rather than shared because that class is file-private,
/// per this project's screen-local-widget convention (see e.g.
/// `birth_profiles_screen.dart`'s own private row/card widgets).
class _LegalCard extends StatelessWidget {
  const _LegalCard({
    required this.locale,
    required this.links,
    required this.onTap,
  });

  final Locale locale;
  final List<_LegalLink> links;
  final ValueChanged<Uri> onTap;

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
      child: Column(
        children: [
          for (var i = 0; i < links.length; i++)
            _LegalRow(
              link: links[i],
              locale: locale,
              isLast: i == links.length - 1,
              onTap: () => onTap(links[i].uri),
            ),
        ],
      ),
    );
  }
}

/// One legal-document row — leading Material icon, title, and a trailing
/// "opens externally" icon (rather than the in-app chevron the rest of the
/// Profile screen's rows use) so it's clear tapping leaves the app.
class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.link,
    required this.locale,
    required this.isLast,
    required this.onTap,
  });

  final _LegalLink link;
  final Locale locale;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: link.title,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: Icon(link.icon, size: 18, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      link.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new,
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
