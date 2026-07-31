import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'articles_static_data.dart';

/// Article Detail, per the approved Figma "D2 · Article Detail" (node 26:2)
/// concept.
///
/// Reached by tapping any article on [ArticlesScreen] (featured card or a
/// list row) or either of Home's "Wisdom for you" cards. Pushed destination
/// with its own back button, NO bottom nav — same convention as every other
/// non-tab screen in the app.
class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  /// Independent from [ArticlesScreen]'s own saved-state — there is no
  /// shared data layer yet, so the two toggles don't stay in sync. Real
  /// persistence (and a single source of truth) lands with the Firestore
  /// CMS, same as the rest of this feature's placeholder data.
  bool _isSaved = false;

  void _toggleSaved() => setState(() => _isSaved = !_isSaved);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final article = widget.article;
    final category = ArticlesStaticData.categoryLabels[article.categoryId]!;

    return Scaffold(
      backgroundColor: AppColors.cream,
      // Hero runs under the status bar (no top SafeArea), matching the
      // Welcome/Login hero convention elsewhere in the app.
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Hero(
              article: article,
              category: category,
              l10n: l10n,
              locale: locale,
              isSaved: _isSaved,
              onToggleSaved: _toggleSaved,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AuthorRow(article: article, l10n: l10n, locale: locale),
                  const SizedBox(height: 14),
                  for (final block in article.body) ...[
                    _ArticleBlockView(block: block, locale: locale),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navy gradient hero: back/save/share row + category badge + title
/// (Figma node 26:3).
class _Hero extends StatelessWidget {
  const _Hero({
    required this.article,
    required this.category,
    required this.l10n,
    required this.locale,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Article article;
  final String category;
  final AppLocalizations l10n;
  final Locale locale;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 18),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradientDiagonal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                child: _HeroIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              _HeroIconButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                onTap: onToggleSaved,
                semanticsLabel: l10n.articleSave,
              ),
              const SizedBox(width: 8),
              _HeroIconButton(
                icon: Icons.north_east,
                // Sharing/deeplinks aren't built yet — SCOPE WATCH item.
                onTap: () {},
                semanticsLabel: l10n.articleShare,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              category.toUpperCase(),
              style: AppFonts.body(
                locale,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: AppColors.onGold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              locale,
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.onTap,
    this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final button = PressableScale(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
    if (semanticsLabel == null) return button;
    return Semantics(button: true, label: semanticsLabel, child: button);
  }
}

/// Author avatar + name/meta line + Listen pill (Figma node 26:17).
class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.article,
    required this.l10n,
    required this.locale,
  });

  final Article article;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final initial = article.author.isNotEmpty
        ? article.author[0].toUpperCase()
        : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.genderSelectedBg,
          ),
          child: Text(
            initial,
            style: AppFonts.heading(
              locale,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.genderSelectedText,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                article.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                l10n.articleMetaLine(
                  article.publishedDate,
                  article.readMinutes.toString(),
                ),
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
          label: l10n.articleListen,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            // Listen-to-article (TTS) isn't built yet — SCOPE WATCH item
            // (see projects/CLAUDE.md).
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.tileBlueBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The design's "▶" is a bare typographic symbol with no
                  // glyph in our bundled fonts — replaced with a Material
                  // icon per the project's ICON RULE.
                  const Icon(
                    Icons.play_arrow_rounded,
                    size: 14,
                    color: AppColors.tileBlueFg,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    l10n.articleListen,
                    style: AppFonts.body(
                      locale,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tileBlueFg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders one [ArticleBodyBlock] (Figma node 26:16's children).
class _ArticleBlockView extends StatelessWidget {
  const _ArticleBlockView({required this.block, required this.locale});

  final ArticleBodyBlock block;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      ArticleParagraph(:final text) => Text(
        text,
        style: AppFonts.body(
          locale,
          fontSize: 13.5,
          color: AppColors.bubbleText,
          height: 1.72,
        ),
      ),
      ArticleHeading(:final text) => Text(
        text,
        style: AppFonts.heading(
          locale,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      ArticleNumberedList(:final items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == items.length - 1 ? 0 : 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '${i + 1}.',
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        color: AppColors.bubbleText,
                        height: 1.9,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[i],
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        color: AppColors.bubbleText,
                        height: 1.9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      ArticleQuote(:final text, :final isDevanagari) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // #F6EED3 exactly matches [AppColors.mantraBg]; the left bar
          // #C9A227 exactly matches [AppColors.chartLine] — both reused
          // here despite their unrelated original naming (see "Reuse
          // existing AppColors tokens" rule).
          color: AppColors.mantraBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.chartLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style:
                      AppFonts.body(
                        isDevanagari ? const Locale('hi') : locale,
                        fontSize: 12.5,
                        color: AppColors.mantraBody,
                        height: 1.6,
                      ).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    };
  }
}
