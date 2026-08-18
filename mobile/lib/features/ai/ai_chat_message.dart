/// Chat message model for the AI Astrologer screen — shared by the screen
/// (rendering bubbles, tracking optimistic send state) and, indirectly, by
/// `ai_repository.dart`'s `AiChatHistoryEntry` (a Firestore history doc is
/// converted into a user/assistant [ChatMessage] pair by the screen).
library;

import 'ai_repository.dart' show AiAstrologerErrorCode;

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
    this.failureCode,
  });

  final ChatRole role;
  final String text;
  final ChatMessageStatus status;

  /// WHY a [ChatMessageStatus.failed] message failed. Added 18 Aug 2026.
  ///
  /// The bubble used to label every failure "Not delivered — please try
  /// again." That is actively wrong for the most common failure of all:
  /// running out of daily AI questions. The server refuses those with
  /// `resource-exhausted` (see `functions/src/aiCredits.ts` — the limit
  /// check inside the reserve transaction), retrying cannot succeed until
  /// tomorrow, and telling the user to try again wastes the one moment they
  /// are most likely to upgrade.
  ///
  /// The correctly-mapped copy already existed and was already shown — but
  /// only in a SnackBar, which is gone in a few seconds. The bubble is what
  /// stays on screen, so it carries the reason too. Null for a message that
  /// hasn't failed.
  final AiAstrologerErrorCode? failureCode;

  ChatMessage copyWith({
    ChatMessageStatus? status,
    AiAstrologerErrorCode? failureCode,
  }) {
    return ChatMessage(
      role: role,
      text: text,
      status: status ?? this.status,
      failureCode: failureCode ?? this.failureCode,
    );
  }
}
