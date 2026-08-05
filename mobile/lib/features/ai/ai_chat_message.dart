/// Chat message model for the AI Astrologer screen — shared by the screen
/// (rendering bubbles, tracking optimistic send state) and, indirectly, by
/// `ai_repository.dart`'s `AiChatHistoryEntry` (a Firestore history doc is
/// converted into a user/assistant [ChatMessage] pair by the screen).
library;

/// Who sent a [ChatMessage].
enum ChatRole { assistant, user }

/// Delivery state of a [ChatMessage]. Only USER messages sent in the
/// current session move through [sending]/[failed] — assistant messages
/// (a live answer or loaded history) are always [sent].
enum ChatMessageStatus {
  /// Delivered — either a successful assistant reply, or an assistant/user
  /// message that isn't in flight.
  sent,

  /// A user message currently awaiting the `askAiAstrologer` callable.
  sending,

  /// The callable failed for this user message. Rendered with a distinct
  /// style (see `_MessageBubble` in `ai_astrologer_screen.dart`) so a failed
  /// send never LOOKS like it went through.
  failed,
}

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.status = ChatMessageStatus.sent,
  });

  final ChatRole role;
  final String text;
  final ChatMessageStatus status;

  ChatMessage copyWith({ChatMessageStatus? status}) {
    return ChatMessage(role: role, text: text, status: status ?? this.status);
  }
}
