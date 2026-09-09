import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/vedika/vedika_client.dart';
import '../kundli/kundli_repository.dart';
import 'daily_reading_data.dart';

/// Fetches the Personalized Daily Reading.
///
/// `POST /v2/astrology/prediction/daily` — found in Vedika's contract on
/// 9 Sep 2026 while checking whether the `vedadarshi_daily_reading` Play
/// product could actually be delivered. It can: the endpoint takes birth
/// details and returns a chart-based reading, unlike the sun-sign horoscope.
class DailyReadingRepository {
  DailyReadingRepository(this._client);

  final VedikaClient _client;

  static const String path = '/v2/astrology/prediction/daily';

  /// Keyed by birth details AND day. The reading genuinely changes daily, so
  /// unlike a natal report this must not be cached across days — but within
  /// one day it is a pure function of the chart, so re-opening the screen
  /// must not re-bill the client's Vedika wallet.
  final Map<String, DailyReading> _cache = {};

  Future<DailyReading> fetch(KundliRequest request) async {
    final today = DateTime.now();
    final dayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final key = '$dayKey|$request';
    if (_cache[key] case final cached?) return cached;

    final data = await _client.post(
      path,
      body: {
        'datetime': _isoLocal(request.datetime),
        'latitude': request.latitude,
        'longitude': request.longitude,
        'timezone': request.tzOffset,
        if (request.name case final name? when name.trim().isNotEmpty)
          'name': name.trim(),
      },
    );
    final parsed = DailyReading.fromJson(data);
    _cache[key] = parsed;
    return parsed;
  }

  static String _isoLocal(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}'
        'T${two(value.hour)}:${two(value.minute)}:00';
  }
}

final dailyReadingRepositoryProvider = Provider<DailyReadingRepository>((ref) {
  return DailyReadingRepository(ref.watch(vedikaClientProvider));
});

final dailyReadingProvider =
    FutureProvider.family<DailyReading, KundliRequest>((ref, request) {
      return ref.watch(dailyReadingRepositoryProvider).fetch(request);
    });

/// Whether the user currently holds an unexpired Daily Reading window.
///
/// ⚠️ Read from **Firestore**, written only by the RevenueCat webhook
/// (`/users/{uid}/dailyReadings/{txId}`, `allow write: if false`). The store
/// confirms the purchase; the 24-hour window is our own accounting, so asking
/// RevenueCat "do I still have access" would be asking the wrong system.
///
/// This is a client-side READ of a server-written value — trustworthy because
/// the user cannot forge it, but the reading content itself is still fetched
/// client-side, so this gates presentation rather than enforcing delivery.
final dailyReadingAccessProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('dailyReadings')
      .snapshots()
      .map((snap) {
        // Expiry is evaluated here rather than in the query: a `where` clause
        // would need an index and, worse, would not re-evaluate as the window
        // closes while the screen is open.
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        return snap.docs.any(
          (d) => ((d.data()['expiresAtMs'] as num?)?.toInt() ?? 0) > nowMs,
        );
      })
      .handleError((_) => false);
});
