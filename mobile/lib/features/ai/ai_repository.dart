import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/data/firestore_refs.dart';

/// Region the `askAiAstrologer` Cloud Function is deployed to (see
/// `projects/CLAUDE.md`'s Vedika API integration section — the whole
/// backend, this callable included, is deployed to `asia-south1`). The
/// SDK's default region (`us-central1`) would 404 against this project.
const String _functionsRegion = 'asia-south1';

/// Failure reasons an [AiRepository.askQuestion] call can surface to the UI.
///
/// The UI never inspects a raw [FirebaseFunctionsException] or its string
/// `code` — [AiRepository.askQuestion] normalizes whatever it catches into
/// one of these so screens can `switch` on a stable enum via
/// `aiErrorMessage` (see `lib/features/ai/ai_error_messages.dart`),
/// mirroring `lib/core/auth/auth_service.dart`'s
/// `AuthErrorCode`/`AuthException` split.
enum AiAstrologerErrorCode {
  /// HttpsError code `resource-exhausted` — the signed-in user's daily free
  /// AI-question quota is used up.
  quotaExceeded,

  /// HttpsError code `failed-precondition` — no birth profile is saved yet,
  /// so the backend has no chart to answer from.
  birthDetailsMissing,

  /// HttpsError code `invalid-argument` — the question couldn't be
  /// processed as sent.
  invalidQuestion,

  /// HttpsError code `unavailable` — the backend is temporarily down.
  serviceUnavailable,

  /// HttpsError code `deadline-exceeded`, or anything else not otherwise
  /// classified.
  unknown,
}

/// The single exception type [AiRepository.askQuestion] throws.
class AiAstrologerException implements Exception {
  const AiAstrologerException(this.code);

  final AiAstrologerErrorCode code;

  @override
  String toString() => 'AiAstrologerException(${code.name})';
}

/// Parsed success response of the `askAiAstrologer` callable.
class AskAiResult {
  const AskAiResult({
    required this.answer,
    required this.followUps,
    required this.conversationId,
    required this.used,
    required this.limit,
  });

  final String answer;
  final List<String> followUps;

  /// The backend's own conversation-continuity id for THIS call. Purely
  /// session state, passed back on the next `askQuestion` call in the same
  /// screen visit — never persisted or restored across app restarts, since
  /// Vedika's conversations expire after 24h (see [AiChatHistoryEntry]'s
  /// doc comment).
  final String? conversationId;

  /// How many free questions the user has used today, and their daily
  /// limit — both are ENFORCED SERVER-SIDE; this is only for display in the
  /// header pill; never trust/derive a quota decision from client state.
  final int used;
  final int limit;
}

/// One durable AI Astrologer question/answer pair, read back from
/// `/users/{uid}/aiChats` (written by the `askAiAstrologer` Cloud Function
/// on every successful call).
///
/// This is the history shown when the chat screen re-opens. It is
/// deliberately NOT keyed by [conversationId] — Vedika's own conversation
/// tracking expires after 24h, so a `conversationId` alone cannot restore a
/// thread; Firestore is the only durable record.
class AiChatHistoryEntry {
  const AiChatHistoryEntry({
    required this.question,
    required this.answer,
    required this.followUps,
    required this.language,
    required this.conversationId,
    required this.createdAt,
  });

  final String question;
  final String answer;
  final List<String> followUps;
  final String? language;
  final String? conversationId;
  final DateTime? createdAt;

  /// Never throws for malformed/partial stored data — a bad history doc is
  /// simply skipped (see [AiRepository.loadHistory]), the same convention
  /// `BirthProfile.tryFromFirestore` uses.
  static AiChatHistoryEntry? tryFromFirestore(Map<String, dynamic>? data) {
    if (data == null) return null;
    final question = data['question'];
    final answer = data['answer'];
    if (question is! String || answer is! String) return null;

    final rawFollowUps = data['followUps'];
    final createdAtField = data['createdAt'];
    return AiChatHistoryEntry(
      question: question,
      answer: answer,
      followUps: rawFollowUps is List
          ? rawFollowUps.whereType<String>().toList()
          : const [],
      language: data['language'] as String?,
      conversationId: data['conversationId'] as String?,
      createdAt: createdAtField is Timestamp ? createdAtField.toDate() : null,
    );
  }
}

/// Talks to the `askAiAstrologer` Cloud Function and reads back the durable
/// chat history it writes to Firestore.
///
/// Both Firebase dependencies are injected as LAZY getters (not eagerly
/// resolved instances), following `BirthProfileRepository`'s pattern —
/// touching `FirebaseFunctions`/`FirebaseFirestore` before
/// `Firebase.initializeApp` completes throws, so nothing here may hold a
/// reference grabbed at provider-construction time.
class AiRepository {
  // Initializing formals — the callsite (aiRepositoryProvider) still uses
  // the public labels functions/firestore/currentUid; Dart maps them onto
  // these private fields. Matches BirthProfileRepository's style.
  AiRepository({
    required this._functions,
    required this._firestore,
    required this._currentUid,
  });

  final FirebaseFunctions Function() _functions;
  final FirebaseFirestore Function() _firestore;

  /// Returns the signed-in Firebase user's uid, or `null` when nobody is
  /// signed in — same convention as `BirthProfileRepository._currentUid`.
  final String? Function() _currentUid;

  /// Wraps [_currentUid] so a Firebase-not-ready failure is treated the
  /// same as "not signed in" rather than an uncaught exception — mirrors
  /// `BirthProfileRepository._safeUid`.
  String? _safeUid() {
    try {
      return _currentUid();
    } catch (_) {
      return null;
    }
  }

  /// Calls the `askAiAstrologer` callable and returns its parsed response.
  ///
  /// TIMEOUT IS 120 SECONDS, deliberately above the SDK's 60s default:
  /// Vedika's own AI processing sample clocks `processing_time_ms: 18420`
  /// (~18s), and the Cloud Function is configured to allow up to 120s of
  /// processing for a genuinely slow answer. The SDK's default 60s callable
  /// timeout would abort a perfectly good in-progress answer purely because
  /// it took longer than a minute — 120s here matches what the backend is
  /// actually allowed to take, not an arbitrary round number.
  Future<AskAiResult> askQuestion({
    required String question,
    required String language,
    String? conversationId,
  }) async {
    final payload = <String, dynamic>{
      'question': question,
      'language': language,
      // Omit the key entirely when null — the fixed request contract does
      // not use an explicit `null` to mean "no conversation yet".
      'conversationId': ?conversationId,
    };

    try {
      final callable = _functions().httpsCallable(
        'askAiAstrologer',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
      );
      final result = await callable.call(payload);
      final data = Map<String, dynamic>.from(result.data as Map);
      final rawFollowUps = data['followUps'];
      return AskAiResult(
        answer: data['answer'] as String,
        followUps: rawFollowUps is List
            ? rawFollowUps.whereType<String>().toList()
            : const [],
        conversationId: data['conversationId'] as String?,
        used: (data['used'] as num).toInt(),
        limit: (data['limit'] as num).toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      throw AiAstrologerException(_mapErrorCode(e.code));
    } catch (e) {
      debugPrint('AiRepository.askQuestion: unexpected failure: $e');
      throw const AiAstrologerException(AiAstrologerErrorCode.unknown);
    }
  }

  AiAstrologerErrorCode _mapErrorCode(String? code) {
    switch (code) {
      case 'resource-exhausted':
        return AiAstrologerErrorCode.quotaExceeded;
      case 'failed-precondition':
        return AiAstrologerErrorCode.birthDetailsMissing;
      case 'invalid-argument':
        return AiAstrologerErrorCode.invalidQuestion;
      case 'unavailable':
        return AiAstrologerErrorCode.serviceUnavailable;
      case 'deadline-exceeded':
      default:
        return AiAstrologerErrorCode.unknown;
    }
  }

  /// Loads the signed-in user's durable AI chat history, oldest first.
  ///
  /// Returns an empty list for a signed-out user, or if the read fails for
  /// any reason — never throws, so a Firestore hiccup degrades to "no
  /// history shown" rather than breaking the chat screen (same convention
  /// as `BirthProfileRepository.load`'s remote-fetch fallback).
  Future<List<AiChatHistoryEntry>> loadHistory() async {
    final uid = _safeUid();
    if (uid == null) return const [];

    try {
      final snapshot = await _firestore()
          .collection(usersCollection)
          .doc(uid)
          .collection(aiChatsCollection)
          .orderBy('createdAt')
          .get();
      return snapshot.docs
          .map((doc) => AiChatHistoryEntry.tryFromFirestore(doc.data()))
          .whereType<AiChatHistoryEntry>()
          .toList();
    } catch (e) {
      debugPrint('AiRepository.loadHistory: remote fetch failed: $e');
      return const [];
    }
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(
    functions: () => FirebaseFunctions.instanceFor(region: _functionsRegion),
    firestore: () => FirebaseFirestore.instance,
    currentUid: () => ref.read(authServiceProvider).currentUser?.uid,
  );
});

/// The current user's durable AI chat history, oldest first — read once per
/// provider lifetime, same `FutureProvider` style as `birthProfileProvider`.
final aiChatHistoryProvider = FutureProvider<List<AiChatHistoryEntry>>((ref) {
  return ref.watch(aiRepositoryProvider).loadHistory();
});
