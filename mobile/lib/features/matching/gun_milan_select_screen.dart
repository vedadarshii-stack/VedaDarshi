import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../core/data/firestore_refs.dart';
import '../profile/birth_profile.dart';
import '../profile/birth_profile_repository.dart';
import '../profile/birth_details_screen.dart';
import 'gun_milan_result_screen.dart';
import 'partner_details_screen.dart';
import 'partner_profile.dart';
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
    // The profile filling the account-holder's side. Defaults to their own
    // primary profile; `ownMatchProfileProvider` overrides it when they pick
    // a different saved profile via "Change" (8 Sep 2026).
    final profile =
        ref.watch(ownMatchProfileProvider) ??
        ref.watch(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final ownName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : GunMilanStaticData.fallbackGroomName;
    final ownSummary = profile != null
        ? profile.summaryLine
        : GunMilanStaticData.fallbackGroomSummary;

    // WHICH SIDE THE USER'S OWN PROFILE FILLS (fixed 4 Sep 2026,
    // client-reported: "even if for female details it's automatically coming
    // to groom profile").
    //
    // This screen used to hardcode the signed-in user as the GROOM, so a
    // woman running a match saw herself labelled 🤵 Groom and was asked to
    // pick a bride. Gun Milan is asymmetric — the koota scoring genuinely
    // depends on which chart is male and which is female — so this is not
    // only an insulting label, it feeds the WRONG chart into the male slot
    // and produces a wrong score.
    //
    // `Gender.other` keeps the groom slot: the API takes exactly `male` and
    // `female` (`boy`/`girl` are rejected), so a third option has to map to
    // one of them, and defaulting to the existing behaviour is the least
    // surprising choice. Worth revisiting with the client — the honest fix
    // is letting the user choose which side they occupy.
    final userIsBride = profile?.gender == Gender.female;

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
                    // Each card keeps its own JOB — one shows the signed-in
                    // user, the other picks a partner — and only the ROLE
                    // LABEL swaps. Swapping the widgets instead would move
                    // the partner-picker's tap handler onto the user's own
                    // profile, which is not what "she is the bride" means.
                    _OwnProfileCard(
                      l10n: l10n,
                      locale: locale,
                      name: ownName,
                      summary: ownSummary,
                      isBride: userIsBride,
                    ),
                    const SizedBox(height: 18),
                    _HeartDivider(locale: locale),
                    const SizedBox(height: 18),
                    _PartnerCard(
                      l10n: l10n,
                      locale: locale,
                      // The partner takes whichever role the user does not.
                      isBride: !userIsBride,
                    ),
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

/// The signed-in user's own saved profile (Figma node 19:9).
///
/// RENAMED from `_GroomCard` 4 Sep 2026: it was never really "the groom
/// card", it was "the user card" that happened to always say Groom. A woman
/// running a match was labelled 🤵 Groom, which the client reported.
class _OwnProfileCard extends ConsumerWidget {
  const _OwnProfileCard({
    required this.l10n,
    required this.locale,
    required this.name,
    required this.summary,
    required this.isBride,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String name;
  final String summary;
  final bool isBride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return _ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoleBadge(
            text: isBride ? '👰 ${l10n.bride}' : '🤵 ${l10n.groom}',
            background: isBride ? AppColors.tilePinkBg : AppColors.tileBlueBg,
            foreground: isBride ? AppColors.tilePinkFg : AppColors.tileBlueFg,
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
                  // "Change" now means CHANGE — pick a different saved
                  // profile (8 Sep 2026).
                  //
                  // It used to push `BirthDetailsScreen`, the edit form for
                  // the account's one profile. The comment here used to say
                  // that picking a saved profile "isn't built"; it has been
                  // since `savedBirthProfilesProvider` landed, and leaving
                  // this pointing at a create/edit form made the button look
                  // like it was making a new profile — exactly what the
                  // client reported.
                  //
                  // Editing is still reachable through "Enter new details"
                  // in the sheet, so the old behaviour is not lost.
                  onTap: () async {
                    final chosen = await showProfilePicker(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      locale: locale,
                      title: l10n.chooseSavedProfile,
                      onCreateNew: () => Navigator.of(context)
                          .push<BirthProfile>(
                            fadeThroughRoute(const BirthDetailsScreen()),
                          ),
                    );
                    if (chosen != null) {
                      ref.read(ownMatchProfileProvider.notifier).set(chosen);
                    }
                  },
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
class _PartnerCard extends ConsumerWidget {
  const _PartnerCard({
    required this.l10n,
    required this.locale,
    required this.isBride,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool isBride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The REAL partner once entered (21 Aug 2026); the empty state below is
    // shown only while there genuinely isn't one.
    final partner = ref.watch(partnerProfileProvider);
    return Semantics(
      button: true,
      label: l10n.selectBrideProfile,
      child: PressableScale(
        borderRadius: BorderRadius.circular(18),
        // Collects the partner's birth details (21 Aug 2026). Previously a
        // no-op, which is why the Result screen had nothing to match
        // against and fell back to a fabricated bride.
        // Offers SAVED profiles first, falling back to the details form
        // (8 Sep 2026). It used to open the form directly, so a user with
        // profiles already saved had to retype details they had entered
        // before.
        onTap: () async {
          final chosen = await showProfilePicker(
            context: context,
            ref: ref,
            l10n: l10n,
            locale: locale,
            title: l10n.chooseSavedProfile,
            // The account owner's own profile fills the other card, so
            // offering it here would let someone match a chart against
            // itself.
            excludeId: primaryProfileId,
            onCreateNew: () => Navigator.of(context).push<BirthProfile>(
              fadeThroughRoute(PartnerDetailsScreen(initial: partner)),
            ),
          );
          if (chosen != null) {
            ref.read(partnerProfileProvider.notifier).set(chosen);
          }
        },
        child: _ProfileCardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoleBadge(
                text: isBride ? '👰 ${l10n.bride}' : '🤵 ${l10n.groom}',
                background: isBride
                    ? AppColors.tilePinkBg
                    : AppColors.tileBlueBg,
                foreground: isBride
                    ? AppColors.tilePinkFg
                    : AppColors.tileBlueFg,
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
                          partner?.fullName ?? l10n.selectBrideProfile,
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
                          partner?.summaryLine ?? l10n.selectBrideHint,
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
class _MatchKundlisButton extends ConsumerWidget {
  const _MatchKundlisButton({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GATED ON A REAL PARTNER — 21 Aug 2026.
    //
    // This button used to be permanently enabled, "per the design". Tapping
    // it with no partner selected did not fail: the Result screen filled the
    // gap with a hardcoded chart and produced a complete, specific verdict —
    // "13.5 out of 36 · Not recommended for marriage" — for a bride named
    // "Ananya" who does not exist, with a download button beside it.
    //
    // A marriage-compatibility verdict is not a placeholder that a user can
    // recognise as fake. Disabling the button until there is a second real
    // chart is the fix; the Result screen refuses the fallback as well, so
    // neither path can produce a fabricated reading.
    final partner = ref.watch(partnerProfileProvider);
    final isEnabled = partner != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: l10n.matchKundlis,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: isEnabled ? 0.35 : 0),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: PressableScale(
          borderRadius: BorderRadius.circular(999),
          // Both charts are read independently by the Result screen from
          // `birthProfileProvider` (groom) and `partnerProfileProvider`
          // (partner), so nothing needs threading through this call.
          // PressableScale.onTap is non-nullable, so "disabled" is a no-op
          // callback plus the flattened styling below — the button reads as
          // inert and cannot navigate.
          onTap: () {
            if (!isEnabled) return;
            Navigator.of(
              context,
            ).push(fadeThroughRoute(const GunMilanResultScreen()));
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              gradient: isEnabled ? AppColors.saffronGradient : null,
              color: isEnabled ? null : AppColors.cardBorder,
            ),
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

/// Lets the user pick one of their SAVED birth profiles, or enter a new one.
///
/// BUILT 8 Sep 2026, client-reported: *"if we saved profile we can allow
/// select from there option also"* and *"when click groom its going create
/// new profile that is wrong"*.
///
/// Both cards on this screen used to jump STRAIGHT into a details form:
/// "Change" on the user's own card opened `BirthDetailsScreen`, and the
/// partner card opened `PartnerDetailsScreen`. So a user with three saved
/// profiles was still made to retype birth details they had already entered,
/// and tapping "Change" looked like it was creating a new profile rather than
/// switching to an existing one.
///
/// The stale comment those handlers carried — *"multi-profile isn't built"* —
/// stopped being true when `savedBirthProfilesProvider` landed. This is the
/// catch-up.
///
/// Returns the chosen [BirthProfile], or null if dismissed. `onCreateNew` is
/// invoked instead when the user picks "Enter new details", so the caller
/// keeps control of WHICH form to open — the two cards need different ones
/// (own profile vs partner, and different default genders).
Future<BirthProfile?> showProfilePicker({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
  required Locale locale,
  required String title,
  String? excludeId,
  required Future<BirthProfile?> Function() onCreateNew,
}) async {
  final saved = ref.read(savedBirthProfilesProvider).valueOrNull ?? const [];
  // Exclude whichever profile already fills the OTHER side — matching a chart
  // against itself is not a meaningful reading, and offering it invites the
  // mistake.
  final options = saved.where((e) => e.id != excludeId).toList();

  if (!context.mounted) return null;
  return showModalBottomSheet<BirthProfile>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.heading(
                  locale,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              if (options.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.noSavedProfiles,
                    style: AppFonts.body(
                      locale,
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              for (final entry in options)
                _PickerRow(
                  entry: entry,
                  locale: locale,
                  onTap: () => Navigator.of(sheetContext).pop(entry.profile),
                ),
              const SizedBox(height: 6),
              // Always offered, even when saved profiles exist — a partner
              // who is not already a saved profile is the common case.
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final created = await onCreateNew();
                    if (created != null && context.mounted) {
                      // The sheet is already gone, so the caller cannot get
                      // this through the sheet's own pop value.
                      _pendingCreated = created;
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.saffron),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        l10n.enterNewDetails,
                        style: AppFonts.body(
                          locale,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.saffron,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((picked) {
    final created = _pendingCreated;
    _pendingCreated = null;
    return picked ?? created;
  });
}

/// Holds a profile created through the picker's "Enter new details" path.
///
/// The sheet must close BEFORE the details form opens (a form pushed under a
/// modal sheet is unreachable), so the created profile cannot travel back as
/// the sheet's pop value. This hands it to the `.then` above instead.
BirthProfile? _pendingCreated;

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.entry,
    required this.locale,
    required this.onTap,
  });

  final SavedBirthProfile entry;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = entry.profile.fullName.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PressableScale(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tileBlueBg,
                ),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: AppFonts.heading(
                    locale,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tileBlueFg,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      entry.profile.summaryLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
