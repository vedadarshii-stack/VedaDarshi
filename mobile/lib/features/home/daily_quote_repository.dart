import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import 'home_static_data.dart';

/// The Home screen's daily quote, from the CMS.
///
/// BUILT 12 Sep 2026 alongside the Quotes & Festivals console screen. The
/// header comment in [HomeStaticData] has promised since July that quotes come
/// from "the Firestore CMS"; until now they did not — `HomeStaticData.quote`
/// was one hardcoded English sentence every user saw forever.
///
/// Mirrors `features/articles/articles_repository.dart` deliberately: same
/// `status == 'published'` filter (the rules evaluate per document, so a query
/// that could return a draft is rejected outright — the filter is what makes
/// the read succeed at all), same 3-deep locale fallback, same
/// fall-back-to-bundled-content-on-any-failure stance. Editorial filler is the
/// one category where showing last-known content beats showing nothing; that
/// reasoning does NOT extend to anything derived from birth details.
class DailyQuoteRepository {
  DailyQuoteRepository(this._locale);

  final String _locale;

  static const String collectionName = 'quotes';

  Future<DailyQuote?> fetchForDay(DateTime day) async {
    final snap = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('status', isEqualTo: 'published')
        .get();
    if (snap.docs.isEmpty) return null;

    // Sorted by document id so the rotation is STABLE: Firestore does not
    // promise an order without an orderBy, and an unordered list would shuffle
    // between calls, so the "quote of the day" could change on a pull to
    // refresh. Sorting client-side avoids requiring a composite index for
    // what is a handful of documents.
    final docs = [...snap.docs]..sort((a, b) => a.id.compareTo(b.id));

    // ⚠️ Chosen by DAY, not at random. Two properties that both matter:
    // every user opening the app on the same day sees the same quote (so it
    // can be talked about, and a screenshot matches what someone else sees),
    // and it genuinely changes at midnight rather than on every rebuild —
    // `Random()` in a `build()` would reshuffle on every scroll.
    final index = _daysSinceEpoch(day) % docs.length;
    final data = docs[index].data();

    final text = _localized(data['text'], _locale);
    if (text == null || text.trim().isEmpty) return null;

    final author = (data['author'] as String?)?.trim();
    return DailyQuote(
      text: text,
      // Rebuilt into the exact shape the existing card expects: it keys the
      // share affordance off a trailing '↗' (see `_QuoteCard`). Emitting a
      // bare author here would silently drop the share button.
      attribution: author == null || author.isEmpty
          ? HomeStaticData.quote.attribution
          : '— $author · Share ↗',
    );
  }

  static int _daysSinceEpoch(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// locale → `en` → any non-empty value. Identical to the articles reader:
  /// the console requires English and leaves the other four optional, so a
  /// missing translation must degrade to English rather than to a blank card.
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

/// Today's quote — the CMS one when there is a published, readable one, and
/// the bundled sentence otherwise.
///
/// ⚠️ The day is TRUNCATED to a calendar date before it reaches the family
/// key. A raw `DateTime.now()` changes on every frame, which would mint a new
/// provider instance and a new Firestore read per rebuild — the same trap
/// documented for the panchang and muhurat providers.
final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  final locale = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  try {
    final quote = await DailyQuoteRepository(locale).fetchForDay(today);
    if (quote != null) return quote;
  } catch (_) {
    // Offline, rules, malformed document — fall through to the bundled one.
  }
  return HomeStaticData.quote;
});
