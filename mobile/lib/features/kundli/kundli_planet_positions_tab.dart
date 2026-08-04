import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_client.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import 'kundli_data.dart';
import 'kundli_sandbox_banner.dart';
import 'kundli_shimmer_block.dart';

/// "Planet Positions" tab of the Kundli Chart screen (tab pill Figma node
/// 18:11) — previously permanently inert with a code comment saying it
/// "arrives once the Vedika API is wired up". It has now arrived, but with
/// **no second network call**: Vedika's `/v2/astrology/kundli` response
/// (already fetched for the Chart tab — see `kundli_chart_screen.dart`) and
/// its dedicated `/v2/astrology/planet-positions` response were compared
/// field-by-field against the live sandbox 1 Aug 2026 and carry the exact
/// same planet fields needed here (sign, house, degree, nakshatra,
/// retrograde, dignity) — `/kundli`'s `planets[]` is missing only the
/// `challenging`/`positive` free-text trait lists, which nothing on this
/// tab renders. Making a second billed call for data already in hand would
/// be a redundant `/planet-positions` request, so this tab is driven by the
/// SAME [KundliData] the Chart tab already loaded.
///
/// Because of that, this widget's loading/error states are literally the
/// Chart tab's own — there is nothing tab-specific to fail independently.
class KundliPlanetPositionsTab extends StatelessWidget {
  const KundliPlanetPositionsTab({
    super.key,
    required this.l10n,
    required this.locale,
    required this.kundliAsync,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// `null` only in the practically-impossible "no birth profile" case —
  /// see `KundliChartScreen.build`'s `request` comment.
  final AsyncValue<KundliData>? kundliAsync;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final async = kundliAsync;
    if (async == null) {
      return _PlanetPositionsErrorState(
        l10n: l10n,
        message: l10n.kundliLoadErrorMessage,
        onRetry: null,
      );
    }
    return async.when(
      loading: () => const _PlanetPositionsLoadingState(),
      error: (error, stackTrace) => _PlanetPositionsErrorState(
        l10n: l10n,
        message: error is VedikaException
            ? error.message
            : l10n.kundliLoadErrorMessage,
        onRetry: onRetry,
      ),
      data: (data) => _PlanetPositionsLoadedList(
        l10n: l10n,
        locale: locale,
        data: data,
      ),
    );
  }
}

/// Shimmer placeholder shaped like a short run of [_PlanetPositionRow]
/// cards — same shimmer vocabulary as the Chart tab's loading state
/// ([KundliShimmerBlock]), per the app's "no bare spinners" motion rule.
class _PlanetPositionsLoadingState extends StatelessWidget {
  const _PlanetPositionsLoadingState();

  static const _placeholderCount = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _placeholderCount; i++) ...[
          if (i != 0) const SizedBox(height: 10),
          KundliShimmerBlock(height: 66, borderRadius: BorderRadius.circular(16)),
        ],
      ],
    );
  }
}

class _PlanetPositionsErrorState extends StatelessWidget {
  const _PlanetPositionsErrorState({
    required this.l10n,
    required this.message,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      iconBackgroundColor: AppColors.ashubhBg,
      iconForegroundColor: AppColors.ashubhFg,
      title: l10n.kundliLoadErrorTitle,
      message: message,
      actionLabel: onRetry == null ? null : l10n.kundliRetry,
      onAction: onRetry,
    );
  }
}

class _PlanetPositionsLoadedList extends StatelessWidget {
  const _PlanetPositionsLoadedList({
    required this.l10n,
    required this.locale,
    required this.data,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliData data;

  @override
  Widget build(BuildContext context) {
    final planets = data.planets;
    if (planets.isEmpty) {
      // Loaded successfully but Vedika sent an empty list — an honest
      // empty state rather than silently rendering nothing.
      return AppEmptyState(
        icon: Icons.info_outline,
        iconBackgroundColor: AppColors.geoChipBg,
        iconForegroundColor: AppColors.geoChipText,
        title: l10n.tabPlanetPositions,
        message: l10n.kundliPlanetPositionsEmpty,
      );
    }

    final ayanamsaName = data.ayanamsa?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // See KundliSandboxBanner's doc comment: this tab's data comes from
        // the same sandboxed `/kundli` response as the Chart tab, so it's
        // exactly as much "sample data" and must say so just as visibly.
        if (VedikaConfig.isSandbox) ...[
          KundliSandboxBanner(l10n: l10n, locale: locale),
          const SizedBox(height: 12),
        ],
        if (ayanamsaName != null) ...[
          Text(
            l10n.kundliPlanetPositionsAyanamsa(ayanamsaName),
            style: AppFonts.body(
              locale,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.hint,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
        ],
        for (var i = 0; i < planets.length; i++) ...[
          if (i != 0) const SizedBox(height: 10),
          EntranceFadeSlide(
            index: i,
            child: _PlanetPositionRow(l10n: l10n, locale: locale, planet: planets[i]),
          ),
        ],
      ],
    );
  }
}

/// One planet's row card — badge with its short label, full name, sign +
/// degree, nakshatra + pada, and (when applicable) house/retrograde/dignity
/// chips.
class _PlanetPositionRow extends StatelessWidget {
  const _PlanetPositionRow({
    required this.l10n,
    required this.locale,
    required this.planet,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliPlanet planet;

  @override
  Widget build(BuildContext context) {
    final code = planet.code;
    final badgeColor = code?.chartColor ?? AppColors.muted;
    // Planet/sign/nakshatra NAMES are Vedika's own English text regardless
    // of app locale — same documented gap as the chart's stat cards and
    // `_SummaryBanner` (see `projects/CLAUDE.md`'s Vedika integration
    // notes). Only the surrounding chip/label copy below is localized.
    final displayName = planet.name ?? planet.vedicName ?? code?.name;
    final sign = planet.sign;
    final degree = planet.degree;
    final nakshatraName = planet.nakshatra?.name;
    final pada = planet.nakshatra?.pada;
    final house = planet.house;
    final dignity = planet.interpretation?.inThisChart?.dignity;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              code?.shortLabel ?? l10n.kundliValueUnavailable,
              style: AppFonts.body(
                const Locale('en'),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName ?? l10n.kundliValueUnavailable,
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
                  sign == null
                      ? l10n.kundliValueUnavailable
                      : degree == null
                      ? sign
                      : '${degree.toStringAsFixed(2)}° · $sign',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(locale, fontSize: 11, color: AppColors.muted),
                ),
                if (nakshatraName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    pada == null
                        ? nakshatraName
                        : '$nakshatraName · ${l10n.kundliNakshatraPada(pada)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(locale, fontSize: 10.5, color: AppColors.hint),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (house != null) _Chip(text: l10n.kundliHouseNumber(house), locale: locale),
              if (planet.isRetrograde) ...[
                const SizedBox(height: 6),
                _Chip(
                  text: l10n.kundliRetrograde,
                  locale: locale,
                  background: AppColors.warnBg,
                  foreground: AppColors.mantraLabel,
                ),
              ],
              if (dignity != null && dignity.isNotEmpty) ...[
                const SizedBox(height: 6),
                _Chip(
                  // Dignity vocabulary ("own"/"exalted"/…) is the same
                  // Vedika domain-term case as planet/sign names above —
                  // shown as-is, just capitalized, not translated.
                  text: _capitalize(dignity),
                  locale: locale,
                  background: AppColors.tileGreenBg,
                  foreground: AppColors.tileGreenFg,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.locale,
    this.background,
    this.foreground,
  });

  final String text;
  final Locale locale;

  // Not given a default value directly in the constructor: [AppColors]
  // members are GETTERS backed by a mutable active palette (see that
  // class's doc comment), not compile-time constants, so they can't be
  // used as a `const`-required default parameter value — resolved in
  // [build] instead.
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? AppColors.cream,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.body(
          locale,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: foreground ?? AppColors.muted,
        ),
      ),
    );
  }
}
