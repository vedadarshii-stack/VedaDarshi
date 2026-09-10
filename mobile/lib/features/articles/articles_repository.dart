import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import 'articles_static_data.dart';

/// Articles from the CMS.
///
/// BUILT 10 Sep 2026, the second half of the Articles CMS. The console could
/// already create and publish articles into Firestore, but the app read only
/// `ArticlesStaticData` — a hardcoded file — so publishing changed nothing a
/// user could see.
///
/// ## Published only, and enforced twice
///
/// The query filters `status == 'published'` because the security rules
/// evaluate per document: a query that would return a draft is rejected
/// outright for a non-admin, so this is not merely tidy, it is what makes the
/// read succeed at all. The rules are the real guarantee; the filter is what
/// keeps the client honest about it.
///
/// ## Falls back to the bundled catalogue
///
/// On any failure — offline, rules, an empty collection — the app shows
/// [ArticlesStaticData.articles] rather than an empty screen. Articles are
/// editorial filler, not user data: showing last-known content beats showing
/// nothing, and unlike a birth chart there is no risk of presenting one
/// person's information to another.
class ArticlesRepository {
  ArticlesRepository(this._locale);

  /// The reader's language, used to pick the right title/body and to fall
  /// back to English when a translation is missing.
  final String _locale;

  static const String collectionName = 'articles';

  Future<List<Article>> fetch() async {
    final snap = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('status', isEqualTo: 'published')
        .get();

    final articles = <Article>[];
    final sortKeys = <String, int>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final article = _fromDoc(doc.id, data, _locale);
      if (article == null) continue;
      articles.add(article);
      sortKeys[doc.id] =
          (data['publishedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
    }

    // Newest first, sorted on the real Timestamp (NOT the display string,
    // which would sort "10 July" before "9 May" alphabetically). Done
    // client-side rather than with `orderBy` so a document missing
    // `publishedAt` is still returned — Firestore silently DROPS documents
    // lacking the ordered field, which would hide content with no error.
    articles.sort((a, b) => (sortKeys[b.id] ?? 0).compareTo(sortKeys[a.id] ?? 0));
    return articles;
  }

  /// `null` when the document cannot produce something worth rendering.
  static Article? _fromDoc(
    String id,
    Map<String, dynamic> data,
    String locale,
  ) {
    // English is the documented fallback for every locale, and the console
    // refuses to publish without it — so its absence means a document
    // written by something other than the console.
    final title = _localized(data['title'], locale);
    if (title == null || title.trim().isEmpty) return null;

    final body = _localized(data['body'], locale) ?? '';
    final categoryId = _category(data['categoryId'] as String?);

    return Article(
      id: id,
      title: title,
      author: (data['author'] as String?)?.trim().isNotEmpty == true
          ? data['author'] as String
          : 'Vedadarshi',
      categoryId: categoryId,
      readMinutes: (data['readMinutes'] as num?)?.toInt() ?? 5,
      // Category-derived colours, so a new article looks native without an
      // editor having to pick hex values in the console.
      accentBg: _accentBg(categoryId),
      accentFg: _accentFg(categoryId),
      // ⚠️ `publishedDate` is a DISPLAY STRING in this model, not a
      // DateTime — the static catalogue stores "10 July 2026". Formatted
      // here so the sort below can still use the real timestamp.
      publishedDate: _formatDate((data['publishedAt'] as Timestamp?)?.toDate()),
      isFeatured: data['isFeatured'] as bool? ?? false,
      body: parseBody(body),
    );
  }

  /// Picks `locale`, falling back to English, then to any language present.
  ///
  /// That last step is deliberate: an article translated only into Telugu is
  /// better shown to a Hindi reader than hidden entirely — they can at least
  /// see it exists. Returning null would silently shrink the catalogue by
  /// language.
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

  /// Turns the console's plain text into the app's block model.
  ///
  /// The editor is a plain textarea — asking a content editor to write JSON
  /// blocks would be a worse tool. So structure is inferred from shape, which
  /// is the same convention Markdown uses and needs no explaining:
  ///
  ///  - blank line          → new block
  ///  - `## text`           → heading
  ///  - `> text`            → quote
  ///  - `1. ` / `- ` lines  → numbered list
  ///  - anything else       → paragraph
  @visibleForTesting
  static List<ArticleBodyBlock> parseBody(String raw) {
    final blocks = <ArticleBodyBlock>[];
    for (final chunk in raw.split(RegExp(r'\n\s*\n'))) {
      final text = chunk.trim();
      if (text.isEmpty) continue;

      if (text.startsWith('##')) {
        blocks.add(ArticleHeading(text.replaceFirst(RegExp(r'^#+\s*'), '')));
        continue;
      }
      if (text.startsWith('>')) {
        final quote = text.replaceFirst(RegExp(r'^>\s*'), '');
        // Devanagari gets the Devanagari face regardless of app locale, the
        // same rule the mantra lines follow elsewhere.
        blocks.add(
          ArticleQuote(quote, isDevanagari: _hasDevanagari(quote)),
        );
        continue;
      }

      final lines = text.split('\n').map((l) => l.trim()).toList();
      final isList =
          lines.length > 1 &&
          lines.every((l) => RegExp(r'^(\d+[.)]|[-*•])\s+').hasMatch(l));
      if (isList) {
        blocks.add(
          ArticleNumberedList([
            for (final line in lines)
              line.replaceFirst(RegExp(r'^(\d+[.)]|[-*•])\s+'), ''),
          ]),
        );
        continue;
      }

      blocks.add(ArticleParagraph(text.replaceAll('\n', ' ')));
    }
    return blocks;
  }

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Matches the bundled catalogue's format ("10 July 2026") so live and
  /// fallback articles never look like two different systems.
  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static bool _hasDevanagari(String value) =>
      RegExp(r'[ऀ-ॿ]').hasMatch(value);

  static ArticleCategoryId _category(String? raw) {
    for (final id in ArticleCategoryId.values) {
      if (id.name == raw) return id;
    }
    return ArticleCategoryId.festivals;
  }

  static Color _accentBg(ArticleCategoryId id) => switch (id) {
    ArticleCategoryId.festivals => AppColors.tileGoldBg,
    ArticleCategoryId.remedies => AppColors.tileGreenBg,
    ArticleCategoryId.vastu => AppColors.tilePurpleBg,
    ArticleCategoryId.mantras => AppColors.tileCyanBg,
    ArticleCategoryId.numerology => AppColors.terracottaBg,
    ArticleCategoryId.gemstones => AppColors.tilePinkBg,
  };

  static Color _accentFg(ArticleCategoryId id) => switch (id) {
    ArticleCategoryId.festivals => AppColors.tileGoldFg,
    ArticleCategoryId.remedies => AppColors.tileGreenFg,
    ArticleCategoryId.vastu => AppColors.tilePurpleFg,
    ArticleCategoryId.mantras => AppColors.tileCyanFg,
    ArticleCategoryId.numerology => AppColors.terracottaFg,
    ArticleCategoryId.gemstones => AppColors.tilePinkFg,
  };
}

/// The live article catalogue, or the bundled one if the CMS is unreachable.
///
/// Watches the locale so switching language re-reads the right translation.
final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final locale = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
  try {
    final live = await ArticlesRepository(locale).fetch();
    // An EMPTY published collection falls back too. Today that is the normal
    // state — the CMS shipped hours ago with nothing in it — and an empty
    // Articles tab would read as a broken screen rather than an empty CMS.
    if (live.isNotEmpty) return live;
  } catch (_) {
    // Offline, rules, malformed document — fall through.
  }
  return ArticlesStaticData.all;
});

/// One article by id, from whichever source [articlesProvider] resolved.
final articleByIdProvider = FutureProvider.family<Article?, String>((
  ref,
  id,
) async {
  final articles = await ref.watch(articlesProvider.future);
  for (final article in articles) {
    if (article.id == id) return article;
  }
  return null;
});
