import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import 'panchang_data.dart';

/// Festivals authored in the admin console.
///
/// BUILT 20 Sep 2026, the second half of the Quotes & Festivals CMS. The
/// console could already publish festivals into Firestore, but nothing in
/// `mobile/lib` read the collection — so the Festivals tab stored rows that
/// were displayed nowhere, while the screen's title implied otherwise.
///
/// ## Why an OVERRIDE rather than a replacement
///
/// Vedika already returns `upcoming_festivals`, and that stays the default —
/// it covers every date without anyone authoring anything. The CMS wins ONLY
/// on a date it explicitly covers. Two reasons that direction is the right
/// one:
///
///  - Vedika's festival dates are sourced from a rival panchang site (the
///    `source` field is a drikpanchang.com URL, which is why it is no longer
///    shown to users). When the client disagrees with a date or a name, the
///    console is now how they correct it, per-date, without a release.
///  - A festival is regional. "Ugadi" and "Gudi Padwa" are the same day under
///    different names, and the client's audience has a preferred one.
///
/// So: authored row present for that date → use it; otherwise Vedika's.
///
/// Mirrors `features/home/daily_quote_repository.dart` exactly — same
/// `status == 'published'` filter (the rules evaluate per document, so a
/// query that could return a draft is rejected outright), same 3-deep locale
/// fallback, same never-throw stance. Editorial content degrades to the
/// previous source rather than to an error.
class CmsFestivalsRepository {
  CmsFestivalsRepository(this._locale);

  final String _locale;

  static const String collectionName = 'festivals';

  /// Published festivals keyed by their `YYYY-MM-DD` date.
  ///
  /// Fetched as ONE read of the whole published set rather than a per-date
  /// query. A festival calendar is a handful of documents a year, and the
  /// alternative — a `where('date', isEqualTo: …)` per screen — would need a
  /// composite index with `status` and would re-read every time the Panchang
  /// date stepper moved a day.
  Future<Map<String, PanchangFestival>> fetchByDate() async {
    final snap = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('status', isEqualTo: 'published')
        .get();

    final byDate = <String, PanchangFestival>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final date = (data['date'] as String?)?.trim();
      if (date == null || date.isEmpty) continue;

      final name = _localized(data['name'], _locale);
      if (name == null || name.trim().isEmpty) continue;

      // Built as a `PanchangFestival` so both render sites keep taking the
      // type they already take — no widget changes, and the two sources
      // cannot drift into two different shapes.
      //
      // `daysFromNow` is deliberately NOT set. Vedika computes that field and
      // `isToday` reads it; computing it here would mean parsing a date and
      // comparing locally, which is exactly the timezone-boundary bug that
      // once made the whole panchang a day late. Callers look this map up BY
      // the date they are already showing, so they never need it.
      byDate[date] = PanchangFestival(
        name: name,
        date: date,
        description: _localized(data['description'], _locale),
      );
    }
    return byDate;
  }

  /// locale → `en` → any non-empty. Same contract as articles and quotes: the
  /// console requires English and leaves the other four optional.
  static String? _localized(dynamic field, String locale) {
    if (field is String) return field; // legacy flat string
    if (field is! Map) return null;
    final map = field.cast<String, dynamic>();
    for (final key in [locale, 'en']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    for (final value in map.values) {
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}

/// Published CMS festivals keyed by `YYYY-MM-DD`, empty on any failure.
///
/// Empty is the correct degraded value here, not an error: an empty map means
/// "nothing authored", which is indistinguishable from the normal case of a
/// date the client has not customised — and both correctly fall through to
/// Vedika.
final cmsFestivalsProvider = FutureProvider<Map<String, PanchangFestival>>((
  ref,
) async {
  final locale = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
  try {
    return await CmsFestivalsRepository(locale).fetchByDate();
  } catch (_) {
    // Offline, rules, malformed document — fall through to Vedika's own
    // festival data, which is what shipped before this file existed.
    return const {};
  }
});

/// `YYYY-MM-DD` for [date], matching the key the console writes.
String festivalDateKey(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

/// The festival to show for [date]: the authored one when the client has
/// covered that date, otherwise whatever Vedika returned.
///
/// ⚠️ Takes [vedikaFestival] rather than reading it, so the precedence lives
/// in ONE place. Home and Panchang both resolve a festival, and if each
/// applied its own ordering they would eventually disagree about which source
/// wins — the same class of bug as the Gun Milan select/result screens
/// reading two different profiles.
PanchangFestival? resolveFestival({
  required DateTime date,
  required Map<String, PanchangFestival> cms,
  required PanchangFestival? vedikaFestival,
}) {
  return cms[festivalDateKey(date)] ?? vedikaFestival;
}
