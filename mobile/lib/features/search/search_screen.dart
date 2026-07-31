import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../articles/article_detail_screen.dart';
import '../articles/articles_static_data.dart';
import '../reports/premium_reports_screen.dart';
import '../reports/reports_static_data.dart';
import 'search_static_data.dart';

/// Search, per the approved Figma "D3 · Search" (node 27:2) concept.
///
/// Reached from the Home top bar's search icon. Like the Articles/Reports/
/// Notifications screens, this has NO bottom nav in the design — it's a
/// pushed destination whose header IS the search field itself (no separate
/// title text), with its own back button.
///
/// Searches across the two REAL static content catalogues the app already
/// has — [ArticlesStaticData] and [ReportsStaticData] — never fabricated
/// results. See [_SearchFilter]'s doc comment for why the design's 7 filter
/// chips (All/Articles/Horoscope/Panchang/Reports/AI/Remedies) are
/// deliberately reduced to 3 here.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

/// Which content bucket the RESULTS section is filtered to.
///
/// Only 3 values, not the Figma design's 7 chips (All/Articles/Horoscope/
/// Panchang/Reports/AI/Remedies). This is a deliberate, documented scope
/// reduction: Horoscope/Panchang/AI/Remedies have no real backing
/// SEARCHABLE data source in this app yet — only the Articles and Reports
/// catalogues exist as real static data ([ArticlesStaticData],
/// [ReportsStaticData]). Inventing fake result buckets for the other 4
/// would violate "search across what the app actually has"; they can be
/// added for real once each has its own data layer.
enum _SearchFilter { all, articles, reports }

sealed class _SearchHit {
  const _SearchHit();
}

class _ArticleHit extends _SearchHit {
  const _ArticleHit(this.article);
  final Article article;
}

class _ReportHit extends _SearchHit {
  const _ReportHit(this.report);
  final AstrologyReport report;
}

/// Resolves the l10n title for an [AstrologyReport.id].
///
/// Mirrors `premium_reports_screen.dart`'s private `_reportTitle` helper —
/// duplicated rather than imported/shared because it's a small, screen-local
/// switch and the two screens shouldn't take on a coupling just for this.
String _reportTitle(String id, AppLocalizations l10n) {
  switch (id) {
    case 'career':
      return l10n.reportCareer;
    case 'marriage':
      return l10n.reportMarriage;
    case 'wealth':
      return l10n.reportWealth;
    case 'health':
      return l10n.reportHealth;
    case 'sadeSati':
      return l10n.reportSadeSati;
    case 'gemstone':
      return l10n.reportGemstone;
    case 'numerology':
      return l10n.reportNumerology;
    default:
      return id;
  }
}

/// Resolves the l10n description for an [AstrologyReport.id]. Mirrors
/// `premium_reports_screen.dart`'s private `_reportDescription` helper — see
/// [_reportTitle]'s doc comment for why it's duplicated, not shared.
String _reportDescription(String id, AppLocalizations l10n) {
  switch (id) {
    case 'career':
      return l10n.reportCareerDesc;
    case 'marriage':
      return l10n.reportMarriageDesc;
    case 'wealth':
      return l10n.reportWealthDesc;
    case 'health':
      return l10n.reportHealthDesc;
    case 'sadeSati':
      return l10n.reportSadeSatiDesc;
    case 'gemstone':
      return l10n.reportGemstoneDesc;
    case 'numerology':
      return l10n.reportNumerologyDesc;
    default:
      return '';
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  _SearchFilter _filter = _SearchFilter.all;

  /// Real local, mutable recent-search state, seeded from
  /// [SearchStaticData.recentSeed] — not persisted, same "real local state,
  /// persistence lands later" convention as the Articles bookmark toggles.
  late final List<String> _recentSearches = List.of(
    SearchStaticData.recentSeed,
  );

  @override
  void initState() {
    super.initState();
    // Re-filter on every keystroke — the controller is the single source of
    // truth for the query, so listening to it keeps the RESULTS section
    // genuinely reactive without a separate query field to keep in sync.
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  void _clearQuery() => _controller.clear();

  void _applyTerm(String term) {
    _controller.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
  }

  void _clearRecent() => setState(() => _recentSearches.clear());

  List<_SearchHit> _filteredHits(String query, AppLocalizations l10n) {
    final q = query.toLowerCase();
    final hits = <_SearchHit>[];

    if (_filter != _SearchFilter.reports) {
      for (final article in ArticlesStaticData.all) {
        final category = ArticlesStaticData.categoryLabels[article
            .categoryId]!;
        final haystack = '${article.title} ${article.author} $category'
            .toLowerCase();
        if (haystack.contains(q)) hits.add(_ArticleHit(article));
      }
    }

    if (_filter != _SearchFilter.articles) {
      for (final report in ReportsStaticData.reports) {
        final haystack =
            '${_reportTitle(report.id, l10n)} '
                    '${_reportDescription(report.id, l10n)}'
                .toLowerCase();
        if (haystack.contains(q)) hits.add(_ReportHit(report));
      }
    }

    return hits;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final query = _controller.text.trim();
    final hasQuery = query.isNotEmpty;
    final hits = hasQuery ? _filteredHits(query, l10n) : const <_SearchHit>[];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 28 : 52, 20, 24),
          children: [
            _SearchHeader(
              controller: _controller,
              l10n: l10n,
              locale: locale,
              onClear: _clearQuery,
            ),
            const SizedBox(height: 16),
            _FilterChips(
              selected: _filter,
              locale: locale,
              l10n: l10n,
              onSelect: (filter) => setState(() => _filter = filter),
            ),
            const SizedBox(height: 20),
            if (!hasQuery) ...[
              _RecentSection(
                terms: _recentSearches,
                l10n: l10n,
                locale: locale,
                onTapTerm: _applyTerm,
                onClear: _clearRecent,
              ),
              const SizedBox(height: 20),
              _TrendingSection(
                l10n: l10n,
                locale: locale,
                onTapTerm: _applyTerm,
              ),
            ] else ...[
              _SectionLabel(l10n.searchResultsLabel, locale: locale),
              const SizedBox(height: 8),
              if (hits.isEmpty)
                _NoResults(query: query, l10n: l10n)
              else
                Column(
                  children: [
                    for (var i = 0; i < hits.length; i++) ...[
                      if (i != 0) const SizedBox(height: 9),
                      EntranceFadeSlide(
                        index: i,
                        child: _ResultRow(
                          hit: hits[i],
                          l10n: l10n,
                          locale: locale,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Back button + the search pill itself (Figma node 27:2) — this screen's
/// header IS the search bar, there's no separate title text.
class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.l10n,
    required this.locale,
    required this.onClear,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

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
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.saffron, width: 1.5),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.saffron.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text('🔍', style: AppFonts.body(locale, fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: false,
                    style: AppFonts.body(
                      locale,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: l10n.searchHint,
                      hintStyle: AppFonts.body(
                        locale,
                        fontSize: 14,
                        color: AppColors.hint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Semantics(
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    // Voice search is a listed SCOPE WATCH item (see
                    // projects/CLAUDE.md) — intentionally a no-op.
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '🎙',
                        style: AppFonts.body(locale, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                if (hasText) ...[
                  const SizedBox(width: 6),
                  Container(width: 2, height: 18, color: AppColors.saffron),
                  const SizedBox(width: 6),
                  Semantics(
                    button: true,
                    label: l10n.searchClearQuery,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      // The design's ✕ has no glyph in our bundled fonts
                      // (ICON RULE) — Icons.close is the safe equivalent.
                      onTap: onClear,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.hint,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.locale,
    required this.l10n,
    required this.onSelect,
  });

  final _SearchFilter selected;
  final Locale locale;
  final AppLocalizations l10n;
  final ValueChanged<_SearchFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: l10n.articleCategoryAll,
          isSelected: selected == _SearchFilter.all,
          locale: locale,
          onTap: () => onSelect(_SearchFilter.all),
        ),
        _FilterChip(
          label: l10n.searchFilterArticles,
          isSelected: selected == _SearchFilter.articles,
          locale: locale,
          onTap: () => onSelect(_SearchFilter.articles),
        ),
        _FilterChip(
          label: l10n.navReports,
          isSelected: selected == _SearchFilter.reports,
          locale: locale,
          onTap: () => onSelect(_SearchFilter.reports),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
            border: isSelected
                ? null
                : Border.all(color: AppColors.cardBorder),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.locale});

  final String label;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.body(
        locale,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        letterSpacing: 0.88,
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.terms,
    required this.l10n,
    required this.locale,
    required this.onTapTerm,
    required this.onClear,
  });

  final List<String> terms;
  final AppLocalizations l10n;
  final Locale locale;
  final ValueChanged<String> onTapTerm;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionLabel(l10n.searchRecentLabel, locale: locale),
            ),
            Semantics(
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                  child: Text(
                    l10n.searchClearRecent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      locale,
                      fontSize: 10.5,
                      color: AppColors.hint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final term in terms)
              _TermChip(
                label: term,
                // The design's "◷" recent-search clock has no glyph in our
                // bundled fonts (ICON RULE) — Icons.history is the safe
                // equivalent.
                icon: Icons.history,
                locale: locale,
                onTap: () => onTapTerm(term),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendingSection extends StatelessWidget {
  const _TrendingSection({
    required this.l10n,
    required this.locale,
    required this.onTapTerm,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final ValueChanged<String> onTapTerm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.searchTrendingLabel, locale: locale),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final term in SearchStaticData.trending)
              _TermChip(
                label: term,
                // The design's "↗" has no glyph in our bundled fonts (ICON
                // RULE) — Icons.north_east is the same equivalent already
                // used for this glyph on `articles_screen.dart`'s Share
                // pill and `home_dashboard_screen.dart`'s quote-card
                // attribution.
                icon: Icons.north_east,
                locale: locale,
                onTap: () => onTapTerm(term),
              ),
          ],
        ),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({
    required this.label,
    required this.icon,
    required this.locale,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: AppColors.muted),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11,
                    color: AppColors.muted,
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

/// One RESULTS row — routes to the article- or report-flavoured tile/
/// subtitle/destination depending on the underlying [_SearchHit].
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.hit, required this.l10n, required this.locale});

  final _SearchHit hit;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return switch (hit) {
      _ArticleHit(:final article) => _buildRow(
        context,
        tileBg: article.accentBg,
        tileFg: article.accentFg,
        // Same convention as `articles_screen.dart`'s _ArticleRow: the
        // design's "✦" thumbnail glyph has no glyph in our bundled fonts
        // (ICON RULE) — Icons.auto_awesome is the established equivalent.
        leading: Icon(Icons.auto_awesome, size: 18, color: article.accentFg),
        title: article.title,
        subtitle:
            '${ArticlesStaticData.categoryLabels[article.categoryId]!} · '
            '${l10n.articleReadMinutes(article.readMinutes.toString())}',
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(ArticleDetailScreen(article: article))),
      ),
      _ReportHit(:final report) => _buildRow(
        context,
        tileBg: report.tileBg,
        tileFg: report.tileFg,
        leading: Text(report.emoji, style: AppFonts.body(locale, fontSize: 17)),
        title: _reportTitle(report.id, l10n),
        subtitle: l10n.readMinutes(report.readMinutes.toString()),
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(const PremiumReportsScreen())),
      ),
    };
  }

  Widget _buildRow(
    BuildContext context, {
    required Color tileBg,
    required Color tileFg,
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: PressableScale(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: leading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
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
                      subtitle,
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
              const SizedBox(width: 6),
              // The design's "›" chevron has no glyph in our bundled fonts
              // (ICON RULE) — Icons.arrow_forward_ios is the same icon
              // already used for this purpose elsewhere (e.g. Home's
              // "Full Panchang"/"Rituals" trailing chevrons).
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.otpBorderFilled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uses the shared [AppEmptyState] (Figma "F1 · Empty States" gallery, node
/// 56:3, "No Results" card) instead of a hand-rolled column, so this and
/// [NotificationsScreen]'s empty state share one implementation.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.l10n});

  final String query;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      // The design's 🔍 magnifying glass is a colour emoji (ICON RULE).
      emoji: '🔍',
      iconBackgroundColor: AppColors.rowDivider,
      iconForegroundColor: AppColors.muted,
      title: l10n.searchNoResultsTitle(query),
      message: l10n.searchNoResultsHint,
    );
  }
}
