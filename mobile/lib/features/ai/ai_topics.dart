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
  // 🌺 not 🪷 — the lotus (U+1FAB7) is a Unicode 14 (2021) character and
  // Android 12 has no glyph for it, so it rendered as an empty tofu box on
  // a real device. Same class of bug as the bare typographic symbols the
  // ICON RULE in projects/CLAUDE.md warns about; only the source differs
  // (there: a font we bundle lacks the glyph, here: the OS emoji font is
  // older than the codepoint). Keep new emoji at Unicode 13 or below until
  // minSdk rises. 🌺 is Unicode 6.0 and safe on every supported device.
  AiTopic(id: 'remedies', emoji: '🌺'),
  AiTopic(id: 'numerology', emoji: '🔢'),
];
