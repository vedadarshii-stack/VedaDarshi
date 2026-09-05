import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Day-scoped, on-device store for Vedika responses that are the same for
/// everyone on a given day.
///
/// BUILT 4 Sep 2026, completing the caching work. The backend proxy already
/// makes these calls cost nothing after the first user of the day — this
/// layer removes the remaining cost, which is the user's TIME: without it
/// every cold start waits on a network round trip before Home can render
/// anything, and an offline launch renders nothing at all.
///
/// ## What belongs here, and what does not
///
/// Only responses that are **identical for every user on a given day** —
/// panchang for a location, and the daily horoscope for a sign. Both are
/// already public, shared data on the server side.
///
/// **Nothing derived from birth details goes in here.** A kundli or a report
/// is personal, and this store is unencrypted `SharedPreferences` on a device
/// that may be shared or backed up. The in-memory repository caches already
/// cover those for the life of a session, which is the right trade.
///
/// ## Why day-scoped keys rather than a timestamp + TTL
///
/// Same reasoning as the server's `dayScope`: a stored entry is stamped with
/// the calendar day it describes, so yesterday's panchang can never be shown
/// as today's no matter how the clock behaves. A TTL would have to be checked
/// against a clock the user can change; a date in the key cannot be fooled.
///
/// ## Failure policy: never break the screen
///
/// Every method swallows its errors and degrades to "no cached value".
/// Storage can be full, corrupt, or unavailable, and none of that is a reason
/// to fail a screen that could simply fetch instead.
class VedikaResponseStore {
  VedikaResponseStore._();

  static final VedikaResponseStore instance = VedikaResponseStore._();

  static const _prefix = 'vedika_day_';

  /// Reads a stored response for [key] on [day], or null.
  ///
  /// [day] must be the calendar day the DATA describes, not the day it was
  /// written — those differ for a user stepping the Panchang date forward.
  Future<Map<String, dynamic>?> read(String key, String day) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix${day}_$key');
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      debugPrint('VedikaResponseStore: read failed ($e)');
      return null;
    }
  }

  Future<void> write(String key, String day, Map<String, dynamic> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix${day}_$key', jsonEncode(value));
      // Opportunistic: sweeping on write means there is no background job to
      // schedule and no way for the store to grow unboundedly if the app is
      // used daily. Cheap because the key list is small.
      await _sweep(prefs, keepDay: day);
    } catch (e) {
      debugPrint('VedikaResponseStore: write failed ($e)');
    }
  }

  /// Drops entries for any day other than [keepDay] and today.
  ///
  /// Keeping BOTH matters: a user browsing a future date on the Panchang
  /// screen would otherwise evict today's entry, and Home would go back to
  /// hitting the network on every launch.
  Future<void> _sweep(
    SharedPreferences prefs, {
    required String keepDay,
  }) async {
    final today = dayKeyFor(DateTime.now());
    for (final k in prefs.getKeys()) {
      if (!k.startsWith(_prefix)) continue;
      final rest = k.substring(_prefix.length);
      if (rest.startsWith(today) || rest.startsWith(keepDay)) continue;
      await prefs.remove(k);
    }
  }
}

/// `yyyy-MM-dd` for [date] in LOCAL time.
///
/// Local, not IST: this keys what THIS user sees on THIS device, so it must
/// roll over at their midnight. (The server's own cache key is IST because it
/// must agree with the prewarm job — a different question with a different
/// right answer.)
String dayKeyFor(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}
