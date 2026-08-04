import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../profile/birth_profile_repository.dart';
import 'gun_milan_result_screen.dart';
import 'gun_milan_static_data.dart';

/// Gun Milan — Select, per the approved Figma "C1 · Gun Milan — Select"
/// (node 19:3) concept.
///
/// Lets the user confirm the groom (their own saved profile) and pick a
/// bride profile before running the Ashtakoota Gun Milan compatibility
/// calculation, which opens [GunMilanResultScreen] ("C2 · Gun Milan —
/// Result"). Like the Kundli input screen, this has NO bottom nav in the
/// design — it's reached as a pushed destination with its own back button
/// (see Home's Explore "Match" tile wiring in `home_dashboard_screen.dart`).
///
/// The GROOM card is the real signed-in user's [BirthProfile]. The BRIDE
/// card is an intentional EMPTY STATE — see [GunMilanStaticData]'s doc
/// comment for why this screen never fabricates a second profile.
class GunMilanSelectScreen extends ConsumerStatefulWidget {
  const GunMilanSelectScreen({super.key});

  @override
  ConsumerState<GunMilanSelectScreen> createState() =>
      _GunMilanSelectScreenState();
}

class _GunMilanSelectScreenState extends ConsumerState<GunMilanSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    // Prefer the real saved profile; fall back to static placeholder values
    // only for the should-be-impossible "no profile yet" case (see
    // GunMilanStaticData's doc comment) — this screen must never flash a
    // loading state, so `valueOrNull` covers loading/error/null with the
    // same fallback (same pattern as the Kundli input screen).
    final profile = ref.watch(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final groomName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : GunMilanStaticData.fallbackGroomName;
    final groomSummary = profile != null
        ? profile.summaryLine
        : GunMilanStaticData.fallbackGroomSummary;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // The design (Figma node 19:32) has a flexible spacer pushing
            // the privacy note + CTA to the bottom of the screen. A bare
            // Spacer() needs a bounded-height ancestor to resolve — a plain
            // ListView/SingleChildScrollView does NOT provide one, which bit
            // the Welcome/Login screen once already (see
            // kundli_input_screen.dart's own comment on this same pattern).
            // SliverFillRemaining(hasScrollBody: false) is what gives the
            // inner Column bounded height instead.
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, isCompact ? 32 : 56, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(l10n: l10n, locale: locale),
                    const SizedBox(height: 18),
                    _IntroText(l10n: l10n, locale: locale),
                    const SizedBox(height: 18),
                    _GroomCard(
                      l10n: l10n,
                      locale: locale,
                      name: groomName,
                      summary: groomSummary,
                    ),
                    const SizedBox(height: 18),
                    _HeartDivider(locale: locale),
                    const SizedBox(height: 18),
                    _BrideCard(l10n: l10n, locale: locale),
                    const Spacer(),
                    _PrivacyNote(l10n: l10n, locale: locale),
                    const SizedBox(height: 12),
                    _MatchKundlisButton(l10n: l10n, locale: locale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back button + screen title (Figma node 19:4).
class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            l10n.kundliMatchingTitle,
            style: AppFonts.heading(
              locale,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Explainer copy under the header (Figma node 19:8).
class _IntroText extends StatelessWidget {
  const _IntroText({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        l10n.gunMilanIntro,
        style: AppFonts.body(locale, fontSize: 12.5, color: AppColors.muted),
      ),
    );
  }
}

/// Shared card shell for the groom/bride profile cards (Figma nodes 19:9 and
/// 19:22) — same white card shape and neutral [AppColors.cardBorder] outline
/// for both; only the badge/avatar accent colors inside differ per role.
class _ProfileCardShell extends StatelessWidget {
  const _ProfileCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child],
      ),
    );
  }
}

/// Small uppercase tinted pill badge shared by both profile cards.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.text,
    required this.background,
    required this.foreground,
    required this.locale,
  });

  final String text;
  final Color background;
  final Color foreground;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppFonts.body(
          locale,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

/// GROOM card (Figma node 19:9) — the signed-in user's own saved profile.
class _GroomCard extends StatelessWidget {
  const _GroomCard({
    required this.l10n,
    required this.locale,
    required this.name,
    required this.summary,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String name;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return _ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoleBadge(
            text: '🤵 ${l10n.groom}',
            background: AppColors.tileBlueBg,
            foreground: AppColors.tileBlueFg,
            locale: locale,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tileBlueBg,
                ),
                child: Text(
                  initial,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tileBlueFg,
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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: l10n.change,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(8),
                  // Switching the groom to a different saved profile needs
                  // multi-profile support, which isn't built — see
                  // GunMilanStaticData's doc comment. No-op for now.
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      l10n.change,
                      style: AppFonts.body(
                        locale,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.saffron,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Centred heart divider between the groom and bride cards (Figma node
/// 19:19).
class _HeartDivider extends StatelessWidget {
  const _HeartDivider({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.tilePinkBg,
          border: Border.all(color: AppColors.bridePinkBorder),
        ),
        child: Text('💞', style: AppFonts.body(locale, fontSize: 18)),
      ),
    );
  }
}

/// BRIDE card (Figma node 19:22) — an intentional EMPTY STATE, since
/// multi-profile support (family/friends) isn't built yet. The whole card is
/// tappable, but currently a no-op — see [GunMilanStaticData]'s doc comment.
class _BrideCard extends StatelessWidget {
  const _BrideCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.selectBrideProfile,
      child: PressableScale(
        borderRadius: BorderRadius.circular(18),
        // Choosing/adding a bride profile requires multi-profile support —
        // the same follow-up the Kundli input screen's "Add family or
        // friend" button is the honest entry point for. No-op for now.
        onTap: () {},
        child: _ProfileCardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoleBadge(
                text: '👰 ${l10n.bride}',
                background: AppColors.tilePinkBg,
                foreground: AppColors.tilePinkFg,
                locale: locale,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tilePinkBg,
                    ),
                    // Literal 'S' matching the Figma placeholder text's
                    // first letter — becomes the selected bride's real
                    // initial once multi-profile support exists.
                    child: Text(
                      'S',
                      style: AppFonts.heading(
                        locale,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tilePinkFg,
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
                          l10n.selectBrideProfile,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.selectBrideHint,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.change,
                    style: AppFonts.body(
                      locale,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.saffron,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Privacy reassurance note (Figma node 19:33).
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The design's 🔒 is a colour emoji; using the Material lock icon
          // instead lets it take the gold tint and sit on the text baseline,
          // per this project's ICON RULE.
          Icon(Icons.lock_outline, size: 13, color: AppColors.tileGoldFg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.matchingPrivacyNote,
              style: AppFonts.body(
                locale,
                fontSize: 11,
                color: AppColors.tileGoldFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width "Match Kundlis 💞" CTA (Figma node 19:35). Shares the
/// saffron-gradient pill recipe of the Kundli input screen's Generate
/// button.
class _MatchKundlisButton extends StatelessWidget {
  const _MatchKundlisButton({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.matchKundlis,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: PressableScale(
          borderRadius: BorderRadius.circular(999),
          // Kept enabled per the design rather than gated on a selected
          // bride — becomes conditional once multi-profile support lands.
          //
          // No profile data is threaded through this navigation call: the
          // Result screen independently re-reads the same
          // `birthProfileProvider` for the groom (exactly like this screen
          // does above) and falls back to
          // `GunMilanStaticData.placeholderBridePartnerParams` for the
          // bride, since there is still no second saved profile to select
          // here — see that constant's doc comment for the multi-profile
          // gap this stands in for. Once multi-profile support exists, a
          // real selected bride profile needs to be passed forward from
          // here instead.
          onTap: () => Navigator.of(
            context,
          ).push(fadeThroughRoute(const GunMilanResultScreen())),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(gradient: AppColors.saffronGradient),
            child: Center(
              child: Text(
                '${l10n.matchKundlis} 💞',
                style: AppFonts.body(
                  locale,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
