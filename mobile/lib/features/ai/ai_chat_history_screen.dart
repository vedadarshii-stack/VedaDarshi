import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../kundli/kundli_shimmer_block.dart';
import '../profile/birth_profile.dart';
import 'ai_astrologer_screen.dart';
import 'ai_repository.dart';

/// "AI Chat History" — reached from the Profile & Settings "AI Chat
/// History" menu row (26 Aug 2026, replacing that row's `onTap: () {}`).
///
/// There is no dedicated Figma frame for this screen — it wasn't part of
/// the original D5 · Profile & Settings concept — so the chrome (cream
/// [Scaffold], plain [AppBar] with an auto back button) matches the other
/// pushed settings destinations in this feature (`birth_profiles_screen.dart`,
/// `notifications_screen.dart`) rather than a specific approved design.
///
/// Reads [aiChatHistoryProvider], which already does all the real work —
/// this screen only reshapes it for a HISTORY LIST rather than a
/// conversation replay:
///  - The provider returns entries OLDEST-FIRST (`orderBy('createdAt')`),
///    which is correct for replaying a conversation top-to-bottom (see
///    `ai_astrologer_screen.dart`'s `_loadHistory`) but wrong for a history
///    list, where the most recent question belongs at the top. This screen
///    reverses the list for display — [AiRepository.loadHistory] and
///    [aiChatHistoryProvider] themselves are untouched.
///  - Each entry becomes a card showing the question (prominent), the
///    answer (clamped, expandable) and the date. [AiChatHistoryEntry.language]
///    and [AiChatHistoryEntry.conversationId] are deliberately NOT rendered:
///    `conversationId` is Vedika's own 24h-expiring conversation-continuity
///    id (see [AiChatHistoryEntry]'s doc comment) — meaningless to a user,
///    it names an internal session that no longer exists by the time most
///    history is read. `language` would only be interesting if a user asked
///    in more than one language, which is a rare enough case that a
///    permanent chip on every card isn't worth the clutter; a null-safe
///    place to add it (a small subtle chip, per the task) is noted on
///    [_HistoryCard] if it's ever wanted. `followUps` is UI structure for
///    continuing a LIVE conversation, not a record worth showing after the
///    fact.
class AiChatHistoryScreen extends ConsumerWidget {
  const AiChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final historyAsync = ref.watch(aiChatHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          // Reuses the menu row's own title string rather than a duplicate
          // key — the row and the screen it opens should read identically,
          // and `profileAiChatHistory` already says exactly this.
          l10n.profileAiChatHistory,
          style: AppFonts.heading(
            locale,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const _LoadingList(),
          // Unreachable in practice — `AiRepository.loadHistory` never
          // throws, it degrades to `const []` on any failure (see its doc
          // comment) — but `AsyncValue.when` still requires an error
          // branch. Rendering the same empty state rather than a bespoke
          // "something went wrong" state that can't actually occur.
          error: (error, stackTrace) => _EmptyState(l10n: l10n, locale: locale),
          data: (history) {
            if (history.isEmpty) return _EmptyState(l10n: l10n, locale: locale);

            // Newest-first for a history list — see this screen's doc
            // comment for why the provider itself stays oldest-first.
            final newestFirst = history.reversed.toList();

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: newestFirst.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => EntranceFadeSlide(
                index: index,
                child: _HistoryCard(entry: newestFirst[index], locale: locale),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One question/answer card. A [StatefulWidget] purely to hold the
/// expand/collapse flag — collapsed by default (question clamped to 2
/// lines, answer to 3) so a long answer can't blow up the list; tapping the
/// card expands it in place. Deliberately NOT an [ExpansionTile] — that
/// widget's default Material styling (blue-tinted icon/divider) doesn't
/// match this app's card treatment (per the RESPONSIVE/SURFACE conventions
/// elsewhere in this codebase), so the disclosure is a plain rotating
/// chevron over the existing bordered-card recipe instead.
class _HistoryCard extends StatefulWidget {
  const _HistoryCard({required this.entry, required this.locale});

  final AiChatHistoryEntry entry;
  final Locale locale;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final locale = widget.locale;
    // A null createdAt (malformed/legacy doc — see AiChatHistoryEntry's
    // `tryFromFirestore`) renders no date rather than a placeholder, per
    // the task spec. Formatted with BirthProfile.formatDate — the
    // project's shared non-intl date helper — never a bespoke formatter or
    // `intl`.
    final dateLabel = entry.createdAt == null
        ? null
        : BirthProfile.formatDate(entry.createdAt!);

    return Semantics(
      button: true,
      label: entry.question,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.question,
                      maxLines: _expanded ? null : 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: kPressDuration,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.hint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.answer,
                maxLines: _expanded ? null : 3,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              if (dateLabel != null) ...[
                const SizedBox(height: 8),
                Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 10,
                    color: AppColors.hint,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton list shown while [aiChatHistoryProvider] resolves. Reuses
/// [KundliShimmerBlock] — already promoted to a shared widget for exactly
/// this ("shimmer skeletons on all cards" per the app's motion spec) —
/// rather than a bespoke spinner or a new shimmer implementation.
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          KundliShimmerBlock(height: 96, borderRadius: BorderRadius.circular(16)),
    );
  }
}

/// Shown when there is no saved AI conversation — either genuinely none yet,
/// or (see [AiChatHistoryScreen]'s `error` branch) the defensive fallback
/// for a state [AiRepository.loadHistory] can't actually produce. Reuses the
/// shared [AppEmptyState] (Search/Notifications' own empty states use the
/// same widget) with an action that sends the user straight to the AI
/// Astrologer, since that's the only way this list is ever populated.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AppEmptyState(
          // Same colour-emoji avatar as the AI Astrologer header — a real
          // glyph rendered via the system emoji font, per the ICON RULE.
          emoji: '🔮',
          iconBackgroundColor: AppColors.tilePurpleBg,
          iconForegroundColor: AppColors.tilePurpleFg,
          title: l10n.aiChatHistoryEmptyTitle,
          message: l10n.aiChatHistoryEmptyMessage,
          actionLabel: l10n.aiChatHistoryEmptyAction,
          onAction: () => Navigator.of(
            context,
          ).push(fadeThroughRoute(const AiAstrologerScreen())),
        ),
      ),
    );
  }
}
