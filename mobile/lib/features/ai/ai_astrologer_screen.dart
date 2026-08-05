import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_static_data.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'ai_chat_message.dart';
import 'ai_error_messages.dart';
import 'ai_repository.dart';
import 'ai_topics.dart';

/// AI Astrologer chat, per the approved Figma "C3 · AI Astrologer"
/// (node 21:2) concept.
///
/// Reached from the bottom nav's Ask AI tab and Home's "Ask AI" explore
/// tile / "Continue with Rishi AI" card. Like the Kundli/Match screens, this
/// has NO bottom nav in the design — it's a pushed destination with its own
/// back button.
///
/// Wired to the real `askAiAstrologer` Cloud Function (see
/// `ai_repository.dart`) — the topic chips and the follow-up chip row are
/// still small pieces of local UI structure ([aiTopics], the seeded
/// greeting), but every actual answer, the free-question counter and the
/// follow-up suggestions now come from the backend, and the durable
/// question/answer history is read back from Firestore on open.
class AiAstrologerScreen extends ConsumerStatefulWidget {
  const AiAstrologerScreen({super.key});

  @override
  ConsumerState<AiAstrologerScreen> createState() => _AiAstrologerScreenState();
}

class _AiAstrologerScreenState extends ConsumerState<AiAstrologerScreen> {
  final List<ChatMessage> _messages = [];
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  final _scrollController = ScrollController();

  /// Guards BOTH the send button and the topic/follow-up chips against a
  /// double-tap firing two requests — the explicit client requirement (see
  /// the task's TASK 5). Set the instant a send starts, cleared only once
  /// the callable settles (success or error).
  bool _isSending = false;

  /// Backend-returned follow-up suggestions for the most recent answer —
  /// empty until the first response arrives, since these are never
  /// fabricated client-side.
  List<String> _followUps = const [];

  /// The backend's own conversation-continuity id for the CURRENT screen
  /// visit only. Deliberately never seeded from Firestore history —
  /// Vedika's conversations expire after 24h, so an old id from a previous
  /// visit is not safe to resume (see `ai_repository.dart`'s
  /// `AiChatHistoryEntry` doc comment).
  String? _conversationId;

  /// Free-question usage/limit from the most recent `askQuestion` response.
  /// `null` until the first response of this session — the header pill is
  /// hidden rather than showing a guessed or stale number, since the quota
  /// is enforced (and only known) server-side.
  int? _used;
  int? _limit;

  /// Whether [didChangeDependencies] has already seeded the conversation.
  ///
  /// Required because that method runs again on EVERY dependency change —
  /// an app-language switch, a theme flip — and re-running the seed would
  /// append a second greeting (and a duplicate copy of the history) to a
  /// live conversation.
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    // Only context-free setup belongs here. The greeting needs
    // AppLocalizations, which is an INHERITED widget and therefore not
    // available yet — see didChangeDependencies below.
    _inputController.addListener(_onInputChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Seeds the conversation exactly once.
    //
    // This cannot live in initState: `AppLocalizations.of(context)` walks
    // up to an inherited widget, and Flutter asserts if that happens
    // before initState completes ("dependOnInheritedWidgetOfExactType<
    // _LocalizationsScope>() ... was called before initState() completed").
    // didChangeDependencies is the framework's designated place for
    // inherited-widget-dependent initialization, and is guarded by
    // [_seeded] for the reason documented on that field.
    if (_seeded) return;
    _seeded = true;

    // Same fallback convention as Home/Gun Milan Result — see those
    // screens' own comments on why `valueOrNull` alone (no loading flash)
    // is correct here. Read once to seed the greeting; this chat's message
    // list is mutable app state from this point on, not something that
    // re-derives itself from the profile on every rebuild.
    final profile = ref.read(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final userName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : HomeStaticData.fallbackUserName;
    final l10n = AppLocalizations.of(context)!;
    _messages.add(
      ChatMessage(role: ChatRole.assistant, text: l10n.aiGreeting(userName)),
    );

    // Kept with the greeting (rather than in initState) so ordering is
    // explicit: the greeting is in `_messages` before the awaited history
    // is appended after it.
    _loadHistory();
  }

  /// Loads the signed-in user's durable AI chat history and inserts it
  /// after the greeting — this is what makes the conversation persist
  /// across app restarts, distinct from the backend's own 24h-expiring
  /// `conversationId` (see `_conversationId`'s doc comment).
  Future<void> _loadHistory() async {
    final history = await ref.read(aiChatHistoryProvider.future);
    if (!mounted || history.isEmpty) return;
    setState(() {
      for (final entry in history) {
        _messages.add(ChatMessage(role: ChatRole.user, text: entry.question));
        _messages.add(
          ChatMessage(role: ChatRole.assistant, text: entry.answer),
        );
      }
      _followUps = history.last.followUps;
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: kPageTransition,
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Sends the message bar's current text.
  Future<void> _handleSend() => _sendText(_inputController.text);

  /// Tapping a topic tile or a follow-up chip sends that question directly
  /// (no separate "prefill, then tap Send" step) — guarded by [_isSending]
  /// exactly like the Send button, so a rapid double-tap on a chip can't
  /// fire two requests either.
  void _handleChipTap(String text) {
    if (_isSending) return;
    _sendText(text);
  }

  /// Topic chip tapped — seed the input box and focus it, WITHOUT sending.
  ///
  /// See the `onTopicTap` call site for why topics must not auto-send: the
  /// label is one word, and a send costs a real, scarce credit.
  void _handleTopicTap(String topicLabel) {
    if (_isSending) return;
    _inputController.text = topicLabel;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
    _inputFocusNode.requestFocus();
  }

  /// Sends [text] to `askAiAstrologer`: appends the user's bubble
  /// immediately, shows the typing indicator while awaiting, then either
  /// appends the answer bubble and refreshes the header/follow-ups, or
  /// marks the user's own bubble as failed and shows the mapped error — a
  /// failed send never looks like it went through.
  Future<void> _sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;
    final messageIndex = _messages.length;

    setState(() {
      _messages.add(
        ChatMessage(
          role: ChatRole.user,
          text: trimmed,
          status: ChatMessageStatus.sending,
        ),
      );
      _inputController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final result = await ref
          .read(aiRepositoryProvider)
          .askQuestion(
            question: trimmed,
            language: locale.languageCode,
            conversationId: _conversationId,
          );
      if (!mounted) return;
      setState(() {
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          status: ChatMessageStatus.sent,
        );
        _messages.add(
          ChatMessage(role: ChatRole.assistant, text: result.answer),
        );
        _followUps = result.followUps;
        _conversationId = result.conversationId;
        _used = result.used;
        _limit = result.limit;
        _isSending = false;
      });
      _scrollToBottom();
    } on AiAstrologerException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          status: ChatMessageStatus.failed,
        );
        _isSending = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aiErrorMessage(l10n, e.code))));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          status: ChatMessageStatus.failed,
        );
        _isSending = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.aiErrorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _Header(l10n: l10n, locale: locale, used: _used, limit: _limit),
          Expanded(
            child: _ChatArea(
              l10n: l10n,
              locale: locale,
              messages: _messages,
              // Topics are only useful before any real conversation exists
              // — once history has loaded or the user has sent a message,
              // showing them alongside real answers would be clutter.
              showTopics: _messages.length <= 1,
              followUps: _followUps,
              isSending: _isSending,
              scrollController: _scrollController,
              onChipTap: _handleChipTap,
              onTopicTap: _handleTopicTap,
            ),
          ),
          _InputBar(
            l10n: l10n,
            locale: locale,
            controller: _inputController,
            focusNode: _inputFocusNode,
            isSending: _isSending,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

/// Header (Figma node 21:3): back, avatar, name/status, history, quota pill.
class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.locale,
    required this.used,
    required this.limit,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// `null` until the first `askQuestion` response of this session — see
  /// `_AiAstrologerScreenState._used`'s doc comment for why the pill is
  /// hidden rather than guessed.
  final int? used;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 12 > 52 ? statusBarInset + 12 : 52.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            child: PressableScale(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, size: 16, color: AppColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.aiAvatarGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Text('🔮', style: AppFonts.body(locale, fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.rishiAi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.tileGreenFg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        l10n.onlineKnowsChart,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Semantics(
            button: true,
            child: PressableScale(
              borderRadius: BorderRadius.circular(999),
              // No-op for now: chat history persistence is a listed scope
              // item (see projects/CLAUDE.md's SCOPE WATCH note), not built.
              onTap: () {},
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Text('🕘', style: AppFonts.body(locale, fontSize: 14)),
              ),
            ),
          ),
          if (used != null && limit != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.genderSelectedBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.freeQuota(used.toString(), limit.toString()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.genderSelectedText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Scrolling chat area: today divider, topics block, message bubbles,
/// suggestion chips and the typing indicator.
class _ChatArea extends StatelessWidget {
  const _ChatArea({
    required this.l10n,
    required this.locale,
    required this.messages,
    required this.showTopics,
    required this.followUps,
    required this.isSending,
    required this.scrollController,
    required this.onChipTap,
    required this.onTopicTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final List<ChatMessage> messages;
  final bool showTopics;
  final List<String> followUps;
  final bool isSending;
  final ScrollController scrollController;

  /// Follow-up chips — complete questions, sent immediately.
  final ValueChanged<String> onChipTap;

  /// Topic chips — single words, prefilled into the input instead of sent.
  final ValueChanged<String> onTopicTap;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[
      Center(
        child: Text(
          '— ${l10n.today} —',
          style: AppFonts.body(locale, fontSize: 10.5, color: AppColors.hint),
        ),
      ),
      if (showTopics)
        _TopicsBlock(
          l10n: l10n,
          locale: locale,
          enabled: !isSending,
          // PREFILL, not send — deliberately different from the follow-up
          // chips below. A topic chip's label is a single word ("Career",
          // "Marriage"); sending it verbatim would both ask Vedika a
          // one-word question AND spend a credit. Credits are scarce and
          // real money (Free tier is ONE question per day, and each call
          // bills the client's Vedika wallet), so a stray tap on a topic
          // must never be able to consume the user's whole daily
          // allowance. Topics seed the input box; the user still writes an
          // actual question and presses Send.
          onTap: onTopicTap,
        ),
      for (final message in messages)
        _MessageBubble(message: message, locale: locale, l10n: l10n),
      if (followUps.isNotEmpty)
        _SuggestionChips(
          locale: locale,
          chips: followUps,
          enabled: !isSending,
          // SEND immediately — unlike the topic chips above. These come
          // back from Vedika as complete, well-formed questions
          // ("Which months this year are most favourable for a job
          // change?"), so there is nothing for the user to fill in.
          onTap: onChipTap,
        ),
      if (isSending) _TypingIndicator(l10n: l10n, locale: locale),
    ];

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      itemCount: blocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => blocks[index],
    );
  }
}

/// Resolves the l10n label for an [AiTopic.id].
String _topicLabel(String id, AppLocalizations l10n) {
  switch (id) {
    case 'career':
      return l10n.topicCareer;
    case 'marriage':
      return l10n.topicMarriage;
    case 'health':
      return l10n.topicHealth;
    case 'business':
      return l10n.topicBusiness;
    case 'finance':
      return l10n.topicFinance;
    case 'education':
      return l10n.topicEducation;
    case 'travel':
      return l10n.topicTravel;
    case 'gemstones':
      return l10n.topicGemstones;
    case 'remedies':
      return l10n.topicRemedies;
    case 'numerology':
      return l10n.topicNumerology;
    default:
      return id;
  }
}

/// "ASK ABOUT" topic chip grid (Figma node 52:4) — two rows of five.
class _TopicsBlock extends StatelessWidget {
  const _TopicsBlock({
    required this.l10n,
    required this.locale,
    required this.enabled,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool enabled;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.askAbout,
          style: AppFonts.body(
            locale,
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: AppColors.hint,
            letterSpacing: 0.95,
          ),
        ),
        const SizedBox(height: 8),
        _row(aiTopics.sublist(0, 5)),
        const SizedBox(height: 6),
        _row(aiTopics.sublist(5, 10)),
      ],
    );
  }

  Widget _row(List<AiTopic> rowTopics) {
    return Row(
      children: [
        for (var i = 0; i < rowTopics.length; i++) ...[
          if (i != 0) const SizedBox(width: 6),
          Expanded(
            child: _TopicTile(
              topic: rowTopics[i],
              locale: locale,
              l10n: l10n,
              enabled: enabled,
              onTap: onTap,
            ),
          ),
        ],
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.locale,
    required this.l10n,
    required this.enabled,
    required this.onTap,
  });

  final AiTopic topic;
  final Locale locale;
  final AppLocalizations l10n;
  final bool enabled;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final label = _topicLabel(topic.id, l10n);
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: PressableScale(
          enabled: enabled,
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(label),
          child: Container(
            padding: const EdgeInsets.only(
              top: 9,
              bottom: 8,
              left: 2,
              right: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(topic.emoji, style: AppFonts.body(locale, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
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

/// One chat bubble, styled per role (Figma node 21:2 message list).
///
/// A [ChatMessageStatus.failed] user bubble gets an added red-tinted border
/// and a caption underneath — a deliberate departure from the pure Figma
/// styling, since the design has no failed-send state to draw from and a
/// failed send must never look identical to a delivered one.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.locale,
    required this.l10n,
  });

  final ChatMessage message;
  final Locale locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isAssistant = message.role == ChatRole.assistant;
    final isFailed = message.status == ChatMessageStatus.failed;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isAssistant
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: isAssistant ? AppColors.surface : null,
              gradient: isAssistant ? null : AppColors.saffronGradient,
              border: isAssistant
                  ? Border.all(color: AppColors.cardBorder)
                  : (isFailed
                        ? Border.all(color: AppColors.avoidText, width: 1.5)
                        : null),
              borderRadius: isAssistant
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(6),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(6),
                    ),
            ),
            child: Text(
              message.text,
              style: AppFonts.body(
                locale,
                fontSize: 13,
                color: isAssistant ? AppColors.bubbleText : Colors.white,
                height: 1.5,
              ),
            ),
          ),
          if (isFailed) ...[
            const SizedBox(height: 4),
            Text(
              l10n.aiMessageFailedToSend,
              style: AppFonts.body(
                locale,
                fontSize: 10,
                color: AppColors.avoidText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontally scrollable suggestion chip row (Figma node 21:30), now
/// populated from the backend's `followUps` for the most recent answer
/// rather than a fixed placeholder list — the chips are deliberately
/// allowed to overflow the screen edge, same as the design.
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({
    required this.locale,
    required this.chips,
    required this.enabled,
    required this.onTap,
  });

  final Locale locale;
  final List<String> chips;
  final bool enabled;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return Semantics(
            button: true,
            label: chip,
            enabled: enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: PressableScale(
                enabled: enabled,
                borderRadius: BorderRadius.circular(999),
                onTap: () => onTap(chip),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.chipBorderWarm),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    chip,
                    style: AppFonts.body(
                      locale,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.genderSelectedText,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated "Rishi is typing…" indicator (Figma node 52:38) — a real
/// staggered dot pulse driven by one [AnimationController], NOT the
/// design's exported PNG dots (those can't animate).
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  static const Duration _loopDuration = Duration(milliseconds: 1200);

  /// Fraction of the loop each dot is offset from the next (~150ms of a
  /// 1200ms loop), so the three dots pulse in a staggered wave.
  static const double _stagger = 0.125;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _loopDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A single 0→1→0 triangular pulse per loop, offset by [index] * [_stagger].
  double _pulse(int index) {
    final phase = (_controller.value - index * _stagger) % 1.0;
    return phase < 0.5 ? phase / 0.5 : 1 - (phase - 0.5) / 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i != 0) const SizedBox(width: 4),
                      _TypingDot(pulse: _pulse(i)),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              widget.l10n.rishiTyping,
              style: AppFonts.body(
                widget.locale,
                fontSize: 10,
                color: AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.pulse});

  /// 0 (resting) → 1 (peak) → 0, driving both opacity and scale.
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4 + 0.6 * pulse,
      child: Transform.scale(
        scale: 0.6 + 0.4 * pulse,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.tilePurpleFg,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 7, height: 7),
        ),
      ),
    );
  }
}

/// Pinned input bar (Figma node 21:37): text field pill, mic (no-op), send
/// button and the upgrade link.
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.l10n,
    required this.locale,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    // Disabled the instant a send starts (TASK 5's double-tap protection),
    // not just while the text field happens to be empty.
    final canSend = controller.text.trim().isNotEmpty && !isSending;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              maxLines: 1,
                              enabled: !isSending,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => onSend(),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: l10n.askAboutYourStars,
                                hintStyle: AppFonts.body(
                                  locale,
                                  fontSize: 13,
                                  color: AppColors.hint,
                                ),
                              ),
                              style: AppFonts.body(
                                locale,
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Semantics(
                            button: true,
                            // No-op for now: voice input is a listed V2
                            // scope item (see projects/CLAUDE.md's SCOPE
                            // WATCH note), not built.
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                '🎙',
                                style: AppFonts.body(locale, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    enabled: canSend,
                    // `onPressed`-style disabling, not just an ignored tap:
                    // when `canSend` is false the button's own callback is
                    // never invoked (see PressableScale.enabled) AND it is
                    // visually dimmed below, so it genuinely LOOKS disabled
                    // during a send, not merely inert.
                    child: PressableScale(
                      enabled: canSend,
                      borderRadius: BorderRadius.circular(999),
                      onTap: canSend ? onSend : () {},
                      child: Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: canSend ? AppColors.saffronGradient : null,
                          color: canSend
                              ? null
                              : AppColors.saffron.withValues(alpha: 0.35),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.of(
                    context,
                  ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
                  child: Text(
                    '✨ ${l10n.upgradeUnlimited}',
                    textAlign: TextAlign.center,
                    style: AppFonts.body(
                      locale,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mantraLabel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
