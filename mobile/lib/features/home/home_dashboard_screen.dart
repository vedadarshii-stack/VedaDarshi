import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../l10n/app_localizations.dart';
import '../horoscope/horoscope_detail_screen.dart';
import '../horoscope/horoscope_signs_screen.dart';
import '../horoscope/horoscope_static_data.dart';
import '../horoscope/zodiac_sign.dart';
import '../kundli/kundli_input_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'home_static_data.dart';

/// Home Dashboard — the app's real post-onboarding home screen, per the
/// approved Figma "B1 · Home Dashboard" (node 10:3) concept.
///
/// Reached once a [BirthProfile] exists (see `RootGate` and
/// `post_sign_in_route.dart`) — replaces the temporary
/// `HomePlaceholderScreen`. Every astrology/content value shown below is
/// STATIC PLACEHOLDER DATA from [HomeStaticData]; see that file's doc
/// comment for what eventually replaces it (the Vedika API + Firestore CMS).
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    // Prefer the real saved profile's name/initial over the static
    // placeholder greeting, once one is available.
    final savedProfile = ref.watch(birthProfileProvider).valueOrNull;
    final savedName = savedProfile?.fullName.trim();
    final userName = (savedName != null && savedName.isNotEmpty)
        ? savedName
        : HomeStaticData.fallbackUserName;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 24 : 44, 20, 8),
          children: [
            _TopBar(l10n: l10n, locale: locale, userName: userName),
            const SizedBox(height: 14),
            _PanchangHeroCard(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _GlanceSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _RemedyMantraCard(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _FestivalCard(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _ExploreSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _HoroscopeSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _WisdomSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _ContinueAiCard(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _RecentReportsSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _DailyQuoteCard(locale: locale),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentTab: AppTab.home),
    );
  }
}

/// Section title with an optional trailing "See all"-style action link.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
    this.title, {
    required this.locale,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Locale locale;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppFonts.heading(
              locale,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        if (actionLabel != null)
          Semantics(
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onAction ?? () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppFonts.body(
                        locale,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.saffron,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.saffron,
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

/// Round tinted badge shared by the glance-tile and explore-tile grids.
class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.child,
    required this.size,
    required this.background,
  });

  final Widget child;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      child: child,
    );
  }
}

/// Greeting row: avatar initial, greeting + name, search/notification
/// buttons.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.l10n,
    required this.locale,
    required this.userName,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.navyHeroGradient,
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Text(
            initial,
            style: AppFonts.heading(
              locale,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                HomeStaticData.greeting,
                style: AppFonts.body(
                  locale,
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _TopBarIconButton(emoji: '🔍', locale: locale),
        const SizedBox(width: 8),
        _TopBarIconButton(emoji: '🔔', locale: locale),
      ],
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({required this.emoji, required this.locale});

  final String emoji;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.white,
        shape: CircleBorder(side: BorderSide(color: AppColors.cardBorder)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Text(emoji, style: AppFonts.body(locale, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width gradient card summarising today's panchang.
class _PanchangHeroCard extends StatelessWidget {
  const _PanchangHeroCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final panchang = HomeStaticData.panchang;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              gradient: AppColors.panchangGradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFF2C94C).withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.panchangOrange2.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.todaysPanchang,
                            style: AppFonts.body(
                              locale,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.creamText,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            panchang.date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              locale,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                      // ॐ needs the 'hi' locale font regardless of the app's
                      // active locale — Poppins/Playfair/the other Noto Sans
                      // faces have no Devanagari glyphs (TYPOGRAPHY RULE).
                      child: Text(
                        'ॐ',
                        style: AppFonts.body(
                          const Locale('hi'),
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  panchang.tithi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PanchangStatChip(
                        label: l10n.nakshatra,
                        value: panchang.nakshatra,
                        locale: locale,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PanchangStatChip(
                        label: l10n.yoga,
                        value: panchang.yoga,
                        locale: locale,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PanchangStatChip(
                        label: l10n.karana,
                        value: panchang.karana,
                        locale: locale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.wb_sunny_outlined,
                      size: 14,
                      color: AppColors.creamTextSoft,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      panchang.sunrise,
                      style: AppFonts.body(
                        locale,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.creamTextSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.nightlight_round,
                      size: 14,
                      color: AppColors.creamTextSoft,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      panchang.sunset,
                      style: AppFonts.body(
                        locale,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.creamTextSoft,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.fullPanchang,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                locale,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanchangStatChip extends StatelessWidget {
  const _PanchangStatChip({
    required this.label,
    required this.value,
    required this.locale,
  });

  final String label;
  final String value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 9.5,
              color: AppColors.creamText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Presentation metadata (l10n label, emoji, tile colors) for a
/// [GlanceTile], resolved from its [GlanceTileId].
class _GlanceTileMeta {
  const _GlanceTileMeta(this.label, this.emoji, this.background);

  final String label;
  final String emoji;
  final Color background;
}

_GlanceTileMeta _glanceMeta(GlanceTileId id, AppLocalizations l10n) {
  switch (id) {
    case GlanceTileId.luckyNumber:
      return _GlanceTileMeta(l10n.luckyNumber, '🔢', AppColors.tileBlueBg);
    case GlanceTileId.luckyColor:
      return _GlanceTileMeta(l10n.luckyColor, '🎨', AppColors.tileGoldBg);
    case GlanceTileId.direction:
      return _GlanceTileMeta(l10n.direction, '🧭', AppColors.tileGreenBg);
    case GlanceTileId.todaysPlanet:
      return _GlanceTileMeta(l10n.todaysPlanet, '🪐', AppColors.tilePurpleBg);
    case GlanceTileId.moonPhase:
      return _GlanceTileMeta(l10n.moonPhase, '🌔', AppColors.tileCyanBg);
    case GlanceTileId.muhurat:
      return _GlanceTileMeta(l10n.muhurat, '⏰', AppColors.genderSelectedBg);
  }
}

/// "Today at a glance" — two rows of three quick-fact tiles.
class _GlanceSection extends StatelessWidget {
  const _GlanceSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final tiles = HomeStaticData.glanceTiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.todayAtAGlance, locale: locale),
        const SizedBox(height: 10),
        _glanceRow(tiles.sublist(0, 3)),
        const SizedBox(height: 10),
        _glanceRow(tiles.sublist(3, 6)),
      ],
    );
  }

  Widget _glanceRow(List<GlanceTile> rowTiles) {
    return Row(
      children: [
        for (var i = 0; i < rowTiles.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: _GlanceTileCard(
              tile: rowTiles[i],
              l10n: l10n,
              locale: locale,
            ),
          ),
        ],
      ],
    );
  }
}

class _GlanceTileCard extends StatelessWidget {
  const _GlanceTileCard({
    required this.tile,
    required this.l10n,
    required this.locale,
  });

  final GlanceTile tile;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final meta = _glanceMeta(tile.id, l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glanceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBadge(
            size: 32,
            background: meta.background,
            child: Text(meta.emoji, style: AppFonts.body(locale, fontSize: 13)),
          ),
          const SizedBox(height: 6),
          Text(
            meta.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(locale, fontSize: 9, color: AppColors.hint),
          ),
          const SizedBox(height: 2),
          Text(
            tile.value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's remedy + mantra card.
class _RemedyMantraCard extends StatelessWidget {
  const _RemedyMantraCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mantraBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MantraRow(
            emoji: '🪷',
            label: l10n.todaysRemedy,
            body: Text(
              HomeStaticData.remedy,
              style: AppFonts.body(
                locale,
                fontSize: 12,
                color: AppColors.mantraBody,
              ),
            ),
            locale: locale,
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.mantraBorder),
          const SizedBox(height: 10),
          _MantraRow(
            emoji: '📿',
            label: l10n.todaysMantra,
            // Devanagari mantra — forced to the 'hi' font regardless of the
            // app's active locale (see TYPOGRAPHY RULE).
            body: Text(
              HomeStaticData.mantra,
              style: AppFonts.body(
                const Locale('hi'),
                fontSize: 12,
                color: AppColors.mantraBody,
              ),
            ),
            locale: locale,
          ),
        ],
      ),
    );
  }
}

class _MantraRow extends StatelessWidget {
  const _MantraRow({
    required this.emoji,
    required this.label,
    required this.body,
    required this.locale,
  });

  final String emoji;
  final String label;
  final Widget body;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: AppFonts.body(
            locale,
            fontSize: 16,
            color: AppColors.mantraIcon,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppFonts.body(
                  locale,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mantraLabel,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 3),
              body,
            ],
          ),
        ),
      ],
    );
  }
}

/// Festival-of-the-day navy strip.
class _FestivalCard extends StatelessWidget {
  const _FestivalCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.navyTop, AppColors.navyHeroBottom],
              ),
            ),
            child: Row(
              children: [
                Text('🛕', style: AppFonts.body(locale, fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.festivalOfTheDay,
                        style: AppFonts.body(
                          locale,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        HomeStaticData.festival,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.rituals,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Presentation metadata for one Explore shortcut tile.
class _ExploreTileMeta {
  const _ExploreTileMeta(
    this.label,
    this.emoji,
    this.background, {
    this.onTap,
  });

  final String label;
  final String emoji;
  final Color background;

  /// Tap handler — `null` (the default) renders as a no-op, same as before
  /// this field existed. Only the Kundli tile passes a real callback today;
  /// Match/Reports/Ask AI stay inert until those screens exist.
  final VoidCallback? onTap;
}

/// "Explore" — Kundli / Match / Reports / Ask AI shortcut tiles.
class _ExploreSection extends StatelessWidget {
  const _ExploreSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _ExploreTileMeta(
        l10n.navKundli,
        '🪐',
        AppColors.genderSelectedBg,
        // Same fadeThroughRoute push used by the bottom nav's Kundli tab
        // (see app_bottom_nav.dart) — this screen has no bottom nav of its
        // own in the Figma design, so both entry points push it as a
        // destination rather than switching to it as a tab root.
        onTap: () => Navigator.of(
          context,
        ).push<void>(fadeThroughRoute(const KundliInputScreen())),
      ),
      _ExploreTileMeta(l10n.navMatch, '💍', AppColors.tilePinkBg),
      _ExploreTileMeta(l10n.navReports, '📜', AppColors.tileBlueBg),
      _ExploreTileMeta(l10n.navAskAi, '🔮', AppColors.tilePurpleBg),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.explore, locale: locale),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i != 0) const SizedBox(width: 12),
              Expanded(
                child: _ExploreTile(meta: tiles[i], locale: locale),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.meta, required this.locale});

  final _ExploreTileMeta meta;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: meta.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: meta.onTap ?? () {},
          child: Container(
            padding: const EdgeInsets.only(
              top: 14,
              bottom: 12,
              left: 6,
              right: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBadge(
                  size: 44,
                  background: meta.background,
                  child: Text(
                    meta.emoji,
                    style: AppFonts.body(locale, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meta.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the full "Horoscope — All Signs" grid (see [HoroscopeSignsScreen]).
///
/// A plain `push` (not `pushReplacement`) — unlike the bottom-nav tab
/// switches elsewhere on this screen, the user must be able to come back to
/// Home with the back button. Uses the shared [fadeThroughRoute] (motion
/// spec item 2) instead of a bespoke fade transition.
void _openAllSigns(BuildContext context) {
  Navigator.of(
    context,
  ).push<void>(fadeThroughRoute(const HoroscopeSignsScreen()));
}

/// Opens "B4 · Horoscope Detail" for the user's own sign, resolved from
/// [kZodiacSigns] by [HoroscopeStaticData.userSignId] (falls back to the
/// first sign if the id is ever missing, so this can never throw).
void _openHoroscopeDetail(BuildContext context) {
  final sign = kZodiacSigns.firstWhere(
    (sign) => sign.id == HoroscopeStaticData.userSignId,
    orElse: () => kZodiacSigns.first,
  );
  Navigator.of(
    context,
  ).push<void>(fadeThroughRoute(HoroscopeDetailScreen(sign: sign)));
}

/// "Today's Horoscope" teaser card.
class _HoroscopeSection extends StatelessWidget {
  const _HoroscopeSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final horoscope = HomeStaticData.horoscope;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          l10n.todaysHoroscope,
          locale: locale,
          actionLabel: l10n.allSigns,
          onAction: () => _openAllSigns(context),
        ),
        const SizedBox(height: 10),
        Semantics(
          button: true,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openHoroscopeDetail(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.navyGradient,
                      ),
                      // ♌ (zodiac glyph) is safe to keep as plain text —
                      // Android renders zodiac signs via the system emoji
                      // font, unlike the bare typographic symbols elsewhere
                      // in this design.
                      child: Text(
                        '♌',
                        style: AppFonts.body(
                          locale,
                          fontSize: 24,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  horoscope.sign,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(
                                    locale,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.tileGoldBg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 10,
                                      color: AppColors.tileGoldFg,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      horoscope.rating,
                                      style: AppFonts.body(
                                        locale,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.tileGoldFg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            horoscope.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              locale,
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Wisdom for you" — two recommended-article cards.
class _WisdomSection extends StatelessWidget {
  const _WisdomSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final articles = HomeStaticData.articles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          l10n.wisdomForYou,
          locale: locale,
          actionLabel: l10n.seeAll,
          onAction: () {},
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ArticleCard(
                article: articles[0],
                locale: locale,
                headerGradient: AppColors.navyGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ArticleCard(
                article: articles[1],
                locale: locale,
                headerGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7A3E12), AppColors.navyBottom],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.locale,
    required this.headerGradient,
  });

  final ArticleTeaser article;
  final Locale locale;
  final Gradient headerGradient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: headerGradient),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: AppColors.gold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        article.readTime,
                        style: AppFonts.body(
                          locale,
                          fontSize: 10.5,
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Continue with Rishi AI" teaser card.
class _ContinueAiCard extends StatelessWidget {
  const _ContinueAiCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glanceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.tilePurpleFg, AppColors.navyTop],
                    ),
                  ),
                  child: Text('🔮', style: AppFonts.body(locale, fontSize: 17)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.continueWithRishiAi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        HomeStaticData.aiTeaserQuestion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tilePurpleBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.continueAction,
                        style: AppFonts.body(
                          locale,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tilePurpleFg,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward,
                        size: 11,
                        color: AppColors.tilePurpleFg,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Recent reports" — two report teaser cards.
class _RecentReportsSection extends StatelessWidget {
  const _RecentReportsSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final reports = HomeStaticData.reports;
    const backgrounds = [AppColors.tileBlueBg, AppColors.tilePinkBg];
    const emojis = ['💼', '💍'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          l10n.recentReports,
          locale: locale,
          actionLabel: l10n.myReports,
          onAction: () {},
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < reports.length; i++) ...[
              if (i != 0) const SizedBox(width: 12),
              Expanded(
                child: _ReportCard(
                  report: reports[i],
                  locale: locale,
                  background: backgrounds[i],
                  emoji: emojis[i],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.locale,
    required this.background,
    required this.emoji,
  });

  final ReportTeaser report;
  final Locale locale;
  final Color background;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: report.title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    emoji,
                    style: AppFonts.body(locale, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        report.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.meta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 9.5,
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark gold-bordered daily quote card, closing out the dashboard.
class _DailyQuoteCard extends StatelessWidget {
  const _DailyQuoteCard({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final quote = HomeStaticData.quote;
    // The design's attribution ends in a typographic "↗" glyph that isn't in
    // any bundled font (see TYPOGRAPHY RULE) and would render as a tofu box
    // on-device. Split it off the data string and render it as a Material
    // icon instead, same as every other bare symbol in this design.
    final hasArrow = quote.attribution.endsWith('↗');
    final attributionText = hasArrow
        ? quote.attribution
              .substring(0, quote.attribution.length - 1)
              .trimRight()
        : quote.attribution;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: AppColors.premiumDarkGradient,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 22,
            color: AppColors.gold,
          ),
          const SizedBox(height: 8),
          Text(
            quote.text,
            textAlign: TextAlign.center,
            // Only Playfair SemiBold/Bold are bundled — there is no italic
            // Playfair TTF, so fontStyle.italic below synthesises a slant.
            // That's expected here, not a missing asset.
            style: AppFonts.heading(
              locale,
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: AppColors.quoteGold,
            ).copyWith(fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  attributionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 10.5,
                    color: AppColors.quoteMuted,
                  ),
                ),
              ),
              if (hasArrow) ...[
                const SizedBox(width: 3),
                const Icon(
                  Icons.north_east,
                  size: 11,
                  color: AppColors.quoteMuted,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
