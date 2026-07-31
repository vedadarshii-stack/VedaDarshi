import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'article_detail_screen.dart';
import 'articles_static_data.dart';

/// Wisdom & Articles, per the approved Figma "D1 · Articles" (node 25:3)
/// concept.
///
/// Reached from Home's "Wisdom for you" section (both the "See all" action
/// and, indirectly, its two article cards which push [ArticleDetailScreen]
/// directly). Like the Kundli/Match/AI/Reports screens, this has NO bottom
/// nav in the design — it's a pushed destination with its own back button
/// (the design's own export omits a back affordance on this specific frame,
/// but the project convention requires one for every pushed, non-tab
/// screen — see `projects/CLAUDE.md`).
///
/// Every article shown below is STATIC PLACEHOLDER DATA from
/// [ArticlesStaticData]; see that file's doc comment for what eventually
/// replaces it (the Firestore CMS article catalogue).
class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  ArticleCategoryId? _selectedCategory;

  /// Locally-toggled bookmark state for THIS screen only — real persistence
  /// (and syncing with the Article Detail screen's own toggle) lands with
  /// the Firestore CMS, alongside the rest of the article data layer.
  final Set<String> _savedIds = {};

  void _toggleSaved(String articleId) {
    setState(() {
      if (!_savedIds.add(articleId)) _savedIds.remove(articleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    final featured = ArticlesStaticData.featured;
    final showFeatured =
        _selectedCategory == null || featured.categoryId == _selectedCategory;
    final listArticles = ArticlesStaticData.listArticles
        .where(
          (article) =>
              _selectedCategory == null ||
              article.categoryId == _selectedCategory,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 28 : 52, 20, 24),
          children: [
            _Header(l10n: l10n, locale: locale),
            const SizedBox(height: 16),
            _CategoryChips(
              selected: _selectedCategory,
              locale: locale,
              l10n: l10n,
              onSelect: (id) => setState(() => _selectedCategory = id),
            ),
            const SizedBox(height: 16),
            if (showFeatured) ...[
              EntranceFadeSlide(
                index: 0,
                child: _FeaturedCard(
                  article: featured,
                  l10n: l10n,
                  locale: locale,
                  isSaved: _savedIds.contains(featured.id),
                  onToggleSaved: () => _toggleSaved(featured.id),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Column(
              children: [
                for (var i = 0; i < listArticles.length; i++) ...[
                  if (i != 0) const SizedBox(height: 10),
                  EntranceFadeSlide(
                    index: i + 1,
                    child: _ArticleRow(
                      article: listArticles[i],
                      l10n: l10n,
                      locale: locale,
                      isSaved: _savedIds.contains(listArticles[i].id),
                      onToggleSaved: () => _toggleSaved(listArticles[i].id),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Back button + screen title + saved-articles shortcut (Figma node 25:4).
class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            l10n.articlesTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              locale,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: l10n.savedArticlesLabel,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            // Saved-articles list isn't built yet — the bookmark toggles
            // below are real, but there is nowhere to view them as a
            // collection until the Firestore CMS data layer lands.
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              // 🔖 is a colour emoji and renders fine from the system font
              // (project ICON RULE) — kept as text, matching the design.
              child: Text('🔖', style: AppFonts.body(locale, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.locale,
    required this.l10n,
    required this.onSelect,
  });

  final ArticleCategoryId? selected;
  final Locale locale;
  final AppLocalizations l10n;
  final ValueChanged<ArticleCategoryId?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CategoryChip(
          label: l10n.articleCategoryAll,
          isSelected: selected == null,
          locale: locale,
          onTap: () => onSelect(null),
        ),
        for (final id in ArticlesStaticData.categoryOrder)
          _CategoryChip(
            label: ArticlesStaticData.categoryLabels[id]!,
            isSelected: selected == id,
            locale: locale,
            onTap: () => onSelect(id),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.locale,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.saffron : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: isSelected ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// The navy "featured" spotlight card (Figma node 25:19).
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.article,
    required this.l10n,
    required this.locale,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Article article;
  final AppLocalizations l10n;
  final Locale locale;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: PressableScale(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(ArticleDetailScreen(article: article))),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
          decoration: BoxDecoration(
            gradient: AppColors.navyGradientDiagonal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.articleFeaturedBadge(article.featuredTag ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onGold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  locale,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.articleByline(
                  article.author,
                  article.readMinutes.toString(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 11,
                  color: AppColors.mutedOnNavy,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _FeaturedActionPill(
                    label: l10n.articleSave,
                    // The Save action visibly toggles filled vs outline —
                    // the design's 🔖 emoji has no outline variant, so this
                    // one action uses a Material icon instead of the emoji,
                    // unlike Share/Listen below (see the project's ICON
                    // RULE for the general emoji-vs-icon policy).
                    leading: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 12,
                      color: Colors.white,
                    ),
                    onTap: onToggleSaved,
                    locale: locale,
                  ),
                  const SizedBox(width: 8),
                  _FeaturedActionPill(
                    label: l10n.articleShare,
                    // The design's "↗" is a bare typographic symbol with no
                    // glyph in our bundled fonts — replaced with a Material
                    // icon per the project's ICON RULE.
                    leading: const Icon(
                      Icons.north_east,
                      size: 12,
                      color: Colors.white,
                    ),
                    // Sharing/deeplinks aren't built yet — SCOPE WATCH item.
                    onTap: () {},
                    locale: locale,
                  ),
                  const SizedBox(width: 8),
                  _FeaturedActionPill(
                    label: l10n.articleListen,
                    // 🎧 is a colour emoji and renders fine from the system
                    // font (project ICON RULE) — kept as text.
                    leading: Text(
                      '🎧',
                      style: AppFonts.body(locale, fontSize: 11),
                    ),
                    // Listen-to-article (TTS) isn't built yet — SCOPE WATCH
                    // item (see projects/CLAUDE.md).
                    onTap: () {},
                    locale: locale,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedActionPill extends StatelessWidget {
  const _FeaturedActionPill({
    required this.label,
    required this.leading,
    required this.onTap,
    required this.locale,
  });

  final String label;
  final Widget leading;
  final VoidCallback onTap;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 4),
              Text(
                label,
                style: AppFonts.body(
                  locale,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One article-list row (Figma node 25:24 rows).
class _ArticleRow extends StatelessWidget {
  const _ArticleRow({
    required this.article,
    required this.l10n,
    required this.locale,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Article article;
  final AppLocalizations l10n;
  final Locale locale;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final category = ArticlesStaticData.categoryLabels[article.categoryId]!;

    return Semantics(
      button: true,
      label: article.title,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(ArticleDetailScreen(article: article))),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: article.accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                // The design's "✦" thumbnail glyph has no glyph in our
                // bundled fonts (project ICON RULE) — Icons.auto_awesome is
                // the established sparkle-icon equivalent used elsewhere
                // (e.g. the AI-summary meta chip on Premium Reports).
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: article.accentFg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$category · '
                      '${l10n.articleReadMinutes(article.readMinutes.toString())}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 10.5,
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                toggled: isSaved,
                label: l10n.articleSave,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onToggleSaved,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    // The design's 🔖 bookmark tag has no distinct "outline"
                    // emoji to represent an unsaved state, so — like the
                    // featured card's Save pill — this toggle uses a
                    // Material icon instead. #D8CFC0 exactly matches the
                    // design's muted bookmark color, reused here from
                    // [AppColors.otpBorderFilled] despite its unrelated
                    // name (see "Reuse existing AppColors tokens" rule).
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 16,
                      color: isSaved
                          ? AppColors.saffron
                          : AppColors.otpBorderFilled,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
