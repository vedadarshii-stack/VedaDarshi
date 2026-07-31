/// Static placeholder data for the AI Astrologer chat screen, per the
/// approved Figma "C3 · AI Astrologer" (node 21:2) concept.
///
/// Standing in for the real AI backend — per `projects/CLAUDE.md`'s
/// "Confirmed stack decisions" section, WHICH provider answers these
/// questions is still an OPEN DECISION (OpenAI vs Vedika's chart-grounded
/// AI endpoint), to be settled before M3. Nothing here is a real AI reply.
///
/// [freeUsed]/[freeTotal] are placeholder quota numbers for the header pill
/// only — the real free-question quota MUST be enforced SERVER-SIDE (see
/// CLAUDE.md's AI Astrologer note), never trusted from client-held state.
library;

/// Who sent a [ChatMessage].
enum ChatRole { assistant, user }

/// A single message in the seeded conversation.
class ChatMessage {
  const ChatMessage({required this.role, required this.text});

  final ChatRole role;
  final String text;
}

/// One of the 10 "ask about" topic chips (Figma node 52:4).
class AiTopic {
  const AiTopic({required this.id, required this.emoji});

  /// Resolved to a localized label via `aiTopicLabel` in the screen — never
  /// hardcode English copy for this outside l10n.
  final String id;
  final String emoji;
}

abstract final class AiChatStaticData {
  /// The seeded assistant greeting, with a `{name}` placeholder substituted
  /// at render time with the signed-in user's real profile name (falling
  /// back the same way every other screen does when no profile is saved
  /// yet).
  static const String greetingTemplate =
      '🙏 Namaste {name}! I have studied your birth chart. Ask me anything '
      'about career, marriage, health or the right muhurat.';

  /// The rest of the seeded conversation, verbatim from the design.
  static const List<ChatMessage> seedConversation = [
    ChatMessage(
      role: ChatRole.user,
      text: 'When is a good time to change my job this year?',
    ),
    ChatMessage(
      role: ChatRole.assistant,
      text:
          'With Jupiter transiting your 10th house from mid-September, '
          'Sep–Nov 2026 is highly favourable for a career move. Avoid the '
          'Mercury retrograde window of Oct 9–29 for signing offers.',
    ),
  ];

  static const List<String> suggestionChips = [
    'Marriage timing?',
    'This week for me',
    'Lucky gemstone',
  ];

  /// Placeholder free-question quota shown in the header pill — see this
  /// file's doc comment: the real limit is enforced server-side, never
  /// trusted from here.
  static const int freeUsed = 2;
  static const int freeTotal = 3;

  static const List<AiTopic> topics = [
    AiTopic(id: 'career', emoji: '💼'),
    AiTopic(id: 'marriage', emoji: '💍'),
    AiTopic(id: 'health', emoji: '🌿'),
    AiTopic(id: 'business', emoji: '🏬'),
    AiTopic(id: 'finance', emoji: '💰'),
    AiTopic(id: 'education', emoji: '🎓'),
    AiTopic(id: 'travel', emoji: '✈️'),
    AiTopic(id: 'gemstones', emoji: '💎'),
    AiTopic(id: 'remedies', emoji: '🪷'),
    AiTopic(id: 'numerology', emoji: '🔢'),
  ];
}
