/// The 10 fixed "ask about" topic chips (Figma node 52:4) shown above the
/// AI Astrologer chat while no conversation has started yet.
///
/// This is purely UI navigation data — an id resolved to a localized label
/// by `_topicLabel` in `ai_astrologer_screen.dart`, plus a display emoji —
/// NOT fabricated AI content, so it stays a small static catalog even
/// though the chat itself is wired to the real `askAiAstrologer` backend.
library;

class AiTopic {
  const AiTopic({required this.id, required this.emoji});

  /// Resolved to a localized label via `_topicLabel` in the screen — never
  /// hardcode English copy for this outside l10n.
  final String id;
  final String emoji;
}

const List<AiTopic> aiTopics = [
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
