import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_static_data.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'ai_chat_static_data.dart';

/// AI Astrologer chat, per the approved Figma "C3 · AI Astrologer"
/// (node 21:2) concept.
///
/// Reached from the bottom nav's Ask AI tab and Home's "Ask AI" explore
/// tile / "Continue with Rishi AI" card. Like the Kundli/Match screens, this
/// has NO bottom nav in the design — it's a pushed destination with its own
/// back button.
///
/// The seeded conversation, topic chips and suggestion chips are all STATIC
/// PLACEHOLDER DATA from [AiChatStaticData]; see that file's doc comment for
/// what eventually replaces it. There is deliberately NO simulated AI reply
/// here — sending a message shows an honest "not connected yet" notice
/// instead of fabricating one (see [_AiAstrologerScreenState._handleSend]).
class AiAstrologerScreen extends ConsumerStatefulWidget {
  const AiAstrologerScreen({super.key});

  @override
  ConsumerState<AiAstrologerScreen> createState() =>
      _AiAstrologerScreenState();
}

class _AiAstrologerScreenState extends ConsumerState<AiAstrologerScreen> {
  final List<ChatMessage> _messages = [];
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  /// How many messages the conversation starts with (the greeting +
  /// [AiChatStaticData.seedConversation]) — the topics block is only shown
  /// while the conversation is still at exactly this length.
  final int _seedMessageCount = AiChatStaticData.seedConversation.length + 1;

  @override
  void initState() {
    super.initState();
    // Same fallback convention as Home/Gun Milan Result — see those
    // screens' own comments on why `valueOrNull` alone (no loading flash)
    // is correct here. Read once at construction time to seed the greeting;
    // this chat's message list is mutable app state from this point on, not
    // something that should re-derive itself from the profile on every
    // rebuild.
    final profile = ref.read(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final userName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : HomeStaticData.fallbackUserName;
    _messages.addAll([
      ChatMessage(
        role: ChatRole.assistant,
        text: AiChatStaticData.greetingTemplate.replaceFirst(
          '{name}',
          userName,
        ),
      ),
      ...AiChatStaticData.seedConversation,
    ]);
    _inputController.addListener(_onInputChanged);
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

  /// Prefills the input with a topic/suggestion label and focuses it — the
  /// user still has to tap Send, nothing is auto-sent.
  void _prefillInput(String text) {
    _inputController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _inputFocusNode.requestFocus();
  }

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

  /// Sends the user's message. There is NO AI backend wired up yet — the
  /// real implementation will call it (provider decision still open per
  /// `projects/CLAUDE.md`: OpenAI vs Vedika's chart-grounded endpoint), and
  /// the free-question quota shown in the header is enforced SERVER-SIDE,
  /// never trusted from this screen's local state. So instead of fabricating
  /// a reply, this briefly shows the typing indicator then an honest
  /// "not connected yet" snackbar.
  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, text: text));
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _isTyping = false);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.aiNotConnected)));
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
          _Header(l10n: l10n, locale: locale),
          Expanded(
            child: _ChatArea(
              l10n: l10n,
              locale: locale,
              messages: _messages,
              showTopics: _messages.length <= _seedMessageCount,
              isTyping: _isTyping,
              scrollController: _scrollController,
              onSuggestionTap: _prefillInput,
            ),
          ),
          _InputBar(
            l10n: l10n,
            locale: locale,
            controller: _inputController,
            focusNode: _inputFocusNode,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

/// Header (Figma node 21:3): back, avatar, name/status, history, quota pill.
class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 12 > 52 ? statusBarInset + 12 : 52.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: AppColors.ink,
                ),
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
                      decoration: const BoxDecoration(
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
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Text('🕘', style: AppFonts.body(locale, fontSize: 14)),
              ),
            ),
          ),
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
                l10n.freeQuota(
                  AiChatStaticData.freeUsed.toString(),
                  AiChatStaticData.freeTotal.toString(),
                ),
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
    required this.isTyping,
    required this.scrollController,
    required this.onSuggestionTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final List<ChatMessage> messages;
  final bool showTopics;
  final bool isTyping;
  final ScrollController scrollController;
  final ValueChanged<String> onSuggestionTap;

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
        _TopicsBlock(l10n: l10n, locale: locale, onTap: onSuggestionTap),
      for (final message in messages)
        _MessageBubble(message: message, locale: locale),
      _SuggestionChips(locale: locale, onTap: onSuggestionTap),
      if (isTyping) _TypingIndicator(l10n: l10n, locale: locale),
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
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final topics = AiChatStaticData.topics;
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
        _row(topics.sublist(0, 5)),
        const SizedBox(height: 6),
        _row(topics.sublist(5, 10)),
      ],
    );
  }

  Widget _row(List<AiTopic> rowTopics) {
    return Row(
      children: [
        for (var i = 0; i < rowTopics.length; i++) ...[
          if (i != 0) const SizedBox(width: 6),
          Expanded(
            child: _TopicTile(topic: rowTopics[i], locale: locale, l10n: l10n, onTap: onTap),
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
    required this.onTap,
  });

  final AiTopic topic;
  final Locale locale;
  final AppLocalizations l10n;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final label = _topicLabel(topic.id, l10n);
    return Semantics(
      button: true,
      label: label,
      child: PressableScale(
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
            color: Colors.white,
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
    );
  }
}

/// One chat bubble, styled per role (Figma node 21:2 message list).
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.locale});

  final ChatMessage message;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final isAssistant = message.role == ChatRole.assistant;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isAssistant ? Colors.white : null,
          gradient: isAssistant ? null : AppColors.saffronGradient,
          border: isAssistant ? Border.all(color: AppColors.cardBorder) : null,
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
    );
  }
}

/// Horizontally scrollable suggestion chip row (Figma node 21:30) — the
/// chips are deliberately allowed to overflow the screen edge, same as the
/// design.
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.locale, required this.onTap});

  final Locale locale;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final chips = AiChatStaticData.suggestionChips;
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
            child: PressableScale(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onTap(chip),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
          color: Colors.white,
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
        child: const DecoratedBox(
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
    required this.onSend,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
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
                    enabled: hasText,
                    child: PressableScale(
                      enabled: hasText,
                      borderRadius: BorderRadius.circular(999),
                      onTap: hasText ? onSend : () {},
                      child: Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: hasText ? AppColors.saffronGradient : null,
                          color: hasText
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
                  onTap: () => Navigator.of(context).push(
                    fadeThroughRoute(const SubscriptionPaywallScreen()),
                  ),
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
