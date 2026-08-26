import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'birth_profile_editor_screen.dart';
import 'birth_profile_failure_messages.dart';
import 'birth_profile_repository.dart';

/// Action offered by [_ProfileCard]'s overflow menu — a real enum (rather
/// than plumbing [VoidCallback] straight through `PopupMenuItem.value`) so
/// [PopupMenuButton.onSelected] can dispatch on it; see that call site's
/// comment for why `onSelected` is used instead of `PopupMenuItem.onTap`.
enum _ProfileMenuAction { delete }

/// "Birth profiles" management screen, reached from the Profile & Settings
/// "Birth profiles" row.
///
/// ADDED 25 Aug 2026 — before this, that row was `onTap: () {}` and the
/// Kundli screen's "Add family or friend" people lived only in an
/// in-memory, session-only Riverpod notifier that this screen's arrival
/// made obsolete and replaced entirely. Real persistence now lives in
/// [BirthProfileRepository]/[savedBirthProfilesProvider] — see
/// that file's doc comments for the offline-first/no-uid/delete-of-primary
/// rules this screen's UI enforces.
///
/// Lists every saved profile (primary first, badged "You"), lets the user
/// add a new family/friend profile, tap any card to edit it, and delete
/// any NON-primary one behind a confirmation dialog. The primary profile
/// is what `RootGate` routes on and what `birthProfileProvider` — watched
/// by Home, `user_sign_provider`, `ai_repository`, `panchang_location` and
/// Gun Milan's groom side — means; it can be EDITED here (which keeps that
/// provider's meaning intact, it's still "the user's own profile", just
/// updated) but never DELETED here. Removing it entirely is only possible
/// via the Profile screen's "Delete account" action.
class BirthProfilesScreen extends ConsumerWidget {
  const BirthProfilesScreen({super.key});

  Future<void> _addOrEdit(
    BuildContext context,
    WidgetRef ref, {
    SavedBirthProfile? editing,
  }) async {
    await Navigator.of(context).push<SavedBirthProfile>(
      fadeThroughRoute(BirthProfileEditorScreen(editing: editing)),
    );
    // No manual refresh needed: BirthProfileEditorScreen itself invalidates
    // savedBirthProfilesProvider (and birthProfileProvider/
    // hasBirthProfileProvider when the edit was the primary) on a
    // successful save, and this screen watches that provider — the list
    // rebuilds on its own via Riverpod, whether or not a profile was
    // actually saved.
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavedBirthProfile target,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.birthProfilesDeleteConfirmTitle,
          style: AppFonts.heading(
            locale,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          l10n.birthProfilesDeleteConfirmMessage(target.profile.fullName),
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
              l10n.birthProfilesDelete,
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
    if (confirmed != true) return;

    try {
      await ref.read(birthProfileRepositoryProvider).delete(target.id);
      ref.invalidate(savedBirthProfilesProvider);
    } on BirthProfileFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(birthProfileFailureMessage(l10n, e.reason))),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.birthProfilesDeleteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final profilesAsync = ref.watch(savedBirthProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          l10n.profileBirthProfiles,
          style: AppFonts.heading(
            locale,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: profilesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stack) => Center(
            child: Text(
              l10n.birthProfilesSaveFailed,
              style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
            ),
          ),
          data: (profiles) => ListView(
            padding: EdgeInsets.fromLTRB(20, isCompact ? 12 : 20, 20, 32),
            children: [
              if (profiles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      l10n.birthProfilesEmpty,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              for (final saved in profiles) ...[
                _ProfileCard(
                  saved: saved,
                  locale: locale,
                  l10n: l10n,
                  onTap: () => _addOrEdit(context, ref, editing: saved),
                  onDelete: saved.isPrimary
                      ? null
                      : () => _confirmDelete(context, ref, saved),
                ),
                const SizedBox(height: 10),
              ],
              _AddProfileButton(
                l10n: l10n,
                locale: locale,
                onTap: () => _addOrEdit(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One saved profile row — name, [SavedBirthProfile.profile.summaryLine],
/// a "You" badge on the primary, and a trailing overflow menu offering
/// Delete for every NON-primary profile (the primary's menu is simply
/// omitted, per this screen's doc comment on why it can never be deleted
/// here).
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.saved,
    required this.locale,
    required this.l10n,
    required this.onTap,
    required this.onDelete,
  });

  final SavedBirthProfile saved;
  final Locale locale;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final profile = saved.profile;
    final initial = profile.fullName.isNotEmpty
        ? profile.fullName[0].toUpperCase()
        : '?';

    return Semantics(
      button: true,
      label: profile.fullName,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.navyHeroGradient,
                ),
                child: Text(
                  initial,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              locale,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (saved.isPrimary) ...[
                          const SizedBox(width: 6),
                          _YouBadge(l10n: l10n, locale: locale),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      profile.summaryLine,
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
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                // `onSelected` rather than `PopupMenuItem.onTap` — the
                // latter fires WHILE the popup route is still on top of the
                // navigator stack, so a `showDialog` call from inside it
                // races the popup's own dismissal pop and can close the
                // just-opened confirmation dialog instead. `onSelected` is
                // only invoked once `showButtonMenu`'s route has actually
                // finished closing (see `PopupMenuButton`'s `.then(...)`),
                // so opening the delete-confirmation dialog here is safe.
                PopupMenuButton<_ProfileMenuAction>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: AppColors.hint,
                  ),
                  color: AppColors.surface,
                  onSelected: (action) {
                    if (action == _ProfileMenuAction.delete) onDelete!();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<_ProfileMenuAction>(
                      value: _ProfileMenuAction.delete,
                      child: Text(
                        l10n.birthProfilesDelete,
                        style: AppFonts.body(
                          locale,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ashubhFg,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.otpBorderFilled,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouBadge extends StatelessWidget {
  const _YouBadge({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.saffron.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.birthProfilesYouBadge,
        style: AppFonts.body(
          locale,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: AppColors.saffron,
        ),
      ),
    );
  }
}

/// "Add family or friend" dashed button — same visual recipe (and the same
/// label) as `kundli_input_screen.dart`'s `_AddFamilyFriendButton`.
class _AddProfileButton extends StatelessWidget {
  const _AddProfileButton({
    required this.l10n,
    required this.locale,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.addFamilyFriend,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(color: AppColors.otpBorderFilled),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: AppColors.saffron),
                const SizedBox(width: 6),
                Text(
                  l10n.addFamilyFriend,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.saffron,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Strokes a dashed rounded-rect outline — same painter as
/// `kundli_input_screen.dart`'s private `_DashedBorderPainter` (Flutter has
/// no built-in dashed border), duplicated per this project's screen-local-
/// widget convention rather than shared for one painter.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const double _strokeWidth = 1;
  static const double _radius = 16;
  static const double _dashWidth = 5;
  static const double _dashGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    const inset = _strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
