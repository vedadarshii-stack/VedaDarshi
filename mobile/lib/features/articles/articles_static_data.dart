/// Static placeholder data for the Wisdom & Articles feature, per the
/// approved Figma "D1 · Articles" (node 25:3) and "D2 · Article Detail"
/// (node 26:2) concepts.
///
/// Standing in for the real Firestore CMS article catalogue — articles are
/// authored (title, author, category, body) in the admin panel and
/// translated per locale (see `projects/CLAUDE.md`'s "Localization" section:
/// dynamic CMS content uses a `title: {en, hi, te, ta, kn}`-shaped schema).
/// Every string in this file, INCLUDING the category names, is therefore
/// CMS content rather than app UI chrome, and deliberately does NOT go
/// through the l10n layer — unlike [ReportsStaticData]'s report catalogue
/// (a fixed, compile-time set of product types resolved via ARB). Article
/// categories are editorial taxonomy a content editor can add to at any
/// time, so they belong here in one file: wiring the real CMS later should
/// only touch this file, never the widget tree.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A content block inside an article's body (Figma "D2 · Article Detail").
/// Sealed so the detail screen's rendering switch stays exhaustive as new
/// block kinds are added.
sealed class ArticleBodyBlock {
  const ArticleBodyBlock();
}

/// A plain paragraph of body text.
class ArticleParagraph extends ArticleBodyBlock {
  const ArticleParagraph(this.text);

  final String text;
}

/// A sub-heading within the article body.
class ArticleHeading extends ArticleBodyBlock {
  const ArticleHeading(this.text);

  final String text;
}

/// A numbered list of steps/points.
class ArticleNumberedList extends ArticleBodyBlock {
  const ArticleNumberedList(this.items);

  final List<String> items;
}

/// A highlighted pull-quote, e.g. a mantra. [isDevanagari] forces the quote
/// to render with the 'hi' locale font regardless of the app's active
/// locale (see the project's TYPOGRAPHY RULE) — set for Sanskrit/Devanagari
/// quotes like the Sawan Somvar mantra below.
class ArticleQuote extends ArticleBodyBlock {
  const ArticleQuote(this.text, {this.isDevanagari = false});

  final String text;
  final bool isDevanagari;
}

/// Which editorial category an article belongs to. The DISPLAY NAME for
/// each is CMS content — see [ArticlesStaticData.categoryLabels] — not an
/// ARB key, for the reason explained in this file's doc comment.
enum ArticleCategoryId {
  festivals,
  remedies,
  vastu,
  mantras,
  numerology,
  gemstones,
}

/// One article's presentation + content data.
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.readMinutes,
    required this.accentBg,
    required this.accentFg,
    required this.publishedDate,
    this.isFeatured = false,
    this.featuredTag,
    this.body = const [],
  });

  final String id;
  final String title;
  final String author;
  final ArticleCategoryId categoryId;
  final int readMinutes;

  /// Background/foreground of this article's accent tile in the list row
  /// (Figma node 25:24). Set per article rather than derived purely from
  /// [categoryId], since a real CMS may let an editor pick an accent
  /// independent of category.
  final Color accentBg;
  final Color accentFg;

  final String publishedDate;
  final bool isFeatured;

  /// Short tag shown after "FEATURED · " on the featured card's badge
  /// (Figma node 25:20/25:21) — only set when [isFeatured] is true.
  final String? featuredTag;

  /// Full article body for the Article Detail screen (Figma node 26:2).
  final List<ArticleBodyBlock> body;
}

abstract final class ArticlesStaticData {
  /// Display name for each [ArticleCategoryId] — CMS content (see this
  /// file's doc comment), used for both the filter chip row (Figma node
  /// 25:8 + 64:2) and each article row's meta line.
  static const Map<ArticleCategoryId, String> categoryLabels = {
    ArticleCategoryId.festivals: 'Festivals',
    ArticleCategoryId.remedies: 'Remedies',
    ArticleCategoryId.vastu: 'Vastu',
    ArticleCategoryId.mantras: 'Mantras',
    ArticleCategoryId.numerology: 'Numerology',
    ArticleCategoryId.gemstones: 'Gemstones',
  };

  /// Filter chip order, exactly as approved in Figma node 25:8 + 64:2 (the
  /// "All" chip itself is UI chrome, not a category, so the screen adds it
  /// rather than it being listed here).
  static const List<ArticleCategoryId> categoryOrder = [
    ArticleCategoryId.festivals,
    ArticleCategoryId.remedies,
    ArticleCategoryId.vastu,
    ArticleCategoryId.mantras,
    ArticleCategoryId.numerology,
    ArticleCategoryId.gemstones,
  ];

  /// The featured article (Figma node 25:19). Also the article whose full
  /// body (Figma "D2 · Article Detail", node 26:2) is modelled exactly.
  static final Article featured = Article(
    id: 'sawan-somvar-fasting',
    title: 'Sawan Somvar: fasting rules, rituals & significance',
    author: 'Pandit R. Sharma',
    categoryId: ArticleCategoryId.festivals,
    readMinutes: 8,
    accentBg: AppColors.tileBlueBg,
    accentFg: AppColors.tileBlueFg,
    publishedDate: '10 July 2026',
    isFeatured: true,
    featuredTag: 'SHRAVANA SPECIAL',
    body: [
      ArticleParagraph(
        'Shravana, the holiest month in the Hindu calendar, is dedicated '
        'to Lord Shiva. Mondays of this month — Sawan Somvars — carry '
        'special significance for devotees seeking blessings for health, '
        'marriage and prosperity.',
      ),
      ArticleHeading('Fasting rules for Sawan Somvar'),
      ArticleNumberedList([
        'Wake before sunrise and bathe before sankalpa',
        'Offer jal & bilva leaves to the Shivling',
        'Consume only phalahar — fruits, milk & water',
        'Break the fast after evening aarti',
      ]),
      ArticleQuote(
        'ॐ नमः शिवाय — chant 108 times each Somvar for inner calm and '
        'strength.',
        isDevanagari: true,
      ),
    ],
  );

  /// The 4 article-list rows (Figma node 25:24), in the exact order
  /// approved in Figma. Each gets a short placeholder body of its own so
  /// its detail page is never blank — only [featured]'s body is modelled
  /// to the full Figma D2 structure.
  static final List<Article> listArticles = [
    Article(
      id: 'rahu-kaal-new-beginnings',
      title: 'Why Rahu Kaal matters for new beginnings',
      author: 'Acharya Devika Rao',
      categoryId: ArticleCategoryId.remedies,
      readMinutes: 4,
      accentBg: AppColors.genderSelectedBg,
      accentFg: AppColors.remedyFg,
      publishedDate: '2 July 2026',
      body: [
        ArticleParagraph(
          'Rahu Kaal is a roughly 90-minute window that recurs daily and '
          'is traditionally avoided for starting anything new — a '
          'journey, a purchase, a ceremony.',
        ),
        ArticleParagraph(
          'Its timing shifts with sunrise and sunset, so it is calculated '
          'fresh for your location every day rather than fixed to the '
          'clock.',
        ),
      ],
    ),
    Article(
      id: 'ganesha-chaturthi-2026',
      title: 'Ganesha Chaturthi 2026: dates & muhurat',
      author: 'Pandit R. Sharma',
      categoryId: ArticleCategoryId.festivals,
      readMinutes: 6,
      accentBg: AppColors.tileBlueBg,
      accentFg: AppColors.tileBlueFg,
      publishedDate: '18 July 2026',
      body: [
        ArticleParagraph(
          'Ganesha Chaturthi marks the birth of Lord Ganesha and is '
          'celebrated with a home or public idol installation, daily '
          'aarti, and immersion (visarjan) on the final day.',
        ),
        ArticleParagraph(
          'Choosing an auspicious muhurat for the installation is '
          'considered important — check the exact timing for your city '
          'closer to the date.',
        ),
      ],
    ),
    Article(
      id: 'mantras-peaceful-sleep',
      title: '5 mantras for peaceful sleep',
      author: 'Guru Ananya Iyer',
      categoryId: ArticleCategoryId.mantras,
      readMinutes: 3,
      accentBg: AppColors.tilePurpleBg,
      accentFg: AppColors.tilePurpleFg,
      publishedDate: '25 June 2026',
      body: [
        ArticleParagraph(
          'A short mantra practice before bed can settle a racing mind. '
          'These five are simple enough to recite from memory within a '
          'few nights.',
        ),
        ArticleParagraph(
          'Keep the voice soft, the pace slow, and let each repetition '
          'grow quieter than the last.',
        ),
      ],
    ),
    Article(
      id: 'vastu-work-from-home-desk',
      title: 'Vastu tips for your work-from-home desk',
      author: 'Acharya Vikram Joshi',
      categoryId: ArticleCategoryId.vastu,
      readMinutes: 5,
      accentBg: AppColors.tileGreenBg,
      accentFg: AppColors.tileGreenFg,
      publishedDate: '9 June 2026',
      body: [
        ArticleParagraph(
          'Facing east or north while working is said to support focus '
          'and clear decision-making — small desk placement changes can '
          'make a noticeable difference.',
        ),
        ArticleParagraph(
          'Keep the space behind your chair solid (a wall, not a doorway) '
          'for a settled, supported feeling through the workday.',
        ),
      ],
    ),
  ];

  /// [featured] followed by [listArticles] — the full catalogue in display
  /// order, used to resolve an article by id from anywhere in the app
  /// (e.g. Home's "Wisdom for you" cards).
  static final List<Article> all = [featured, ...listArticles];
}
