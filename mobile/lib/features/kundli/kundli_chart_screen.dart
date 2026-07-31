import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'kundli_chart_static_data.dart';
import 'kundli_static_data.dart';
import 'north_indian_chart.dart';

/// Which chart layout is shown. Public (unlike the private `_ChartStyle` on
/// `kundli_input_screen.dart`) because [KundliChartScreen] accepts the
/// user's earlier selection from that screen via its constructor.
enum KundliChartStyle { northIndian, southIndian }

/// Kundli Chart — per the approved Figma "B6 · Kundli Chart" (node 18:2)
/// concept.
///
/// Pushed from the Kundli — New Chart screen's "Generate Kundli" CTA
/// (`kundli_input_screen.dart`). Like that screen, this is a pushed
/// destination with its own back button and NO bottom nav in the design.
///
/// Every astrology VALUE shown here (planet placements, Lagna/Rashi/
/// Nakshatra, dosha summary) is STATIC PLACEHOLDER DATA from
/// [KundliChartStaticData]; see that file's doc comment for what
/// eventually replaces it (the Vedika API). Only "Chart" of the 4 section
/// tabs is functional — Planet Positions/Dasha/Predictions are inert (see
/// [_SectionTabs]). Only the North Indian chart layout is drawn — see
/// [_ChartCard] for why South Indian shows a "coming soon" note instead of
/// a placeholder grid.
class KundliChartScreen extends ConsumerStatefulWidget {
  const KundliChartScreen({
    super.key,
    this.initialStyle = KundliChartStyle.northIndian,
  });

  /// The chart-style toggle carried over from the Kundli input screen.
  final KundliChartStyle initialStyle;

  @override
  ConsumerState<KundliChartScreen> createState() => _KundliChartScreenState();
}

class _KundliChartScreenState extends ConsumerState<KundliChartScreen> {
  // NOT initialized via a field initializer: `widget` isn't available yet
  // when instance field initializers run (they execute inside
  // `createState()`, before the framework attaches this State to its
  // element and assigns `_widget`) — reading it there throws. `initState()`
  // is the first point `widget` is safe to read.
  late KundliChartStyle _chartStyle;

  @override
  void initState() {
    super.initState();
    _chartStyle = widget.initialStyle;
  }

  void _selectStyle(KundliChartStyle style) {
    if (style == _chartStyle) return;
    setState(() => _chartStyle = style);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    // Same fallback pattern as the Kundli input screen: prefer the real
    // saved profile, fall back to its static placeholder name for the
    // should-be-impossible "no profile yet" case (see
    // KundliStaticData's doc comment).
    final profile = ref.watch(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final profileName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : KundliStaticData.fallbackProfileName;
    final styleLabel = _chartStyle == KundliChartStyle.northIndian
        ? l10n.chartNorthIndian
        : l10n.chartSouthIndian;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 32 : 56, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                l10n: l10n,
                locale: locale,
                profileName: profileName,
                styleLabel: styleLabel,
              ),
              const SizedBox(height: 16),
              _SectionTabs(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _StyleToggleRow(
                l10n: l10n,
                locale: locale,
                selected: _chartStyle,
                onSelect: _selectStyle,
              ),
              const SizedBox(height: 16),
              _ChartCard(l10n: l10n, locale: locale, style: _chartStyle),
              const SizedBox(height: 16),
              _KeyPlanetsLegend(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _StatCardsRow(l10n: l10n, locale: locale),
              const SizedBox(height: 16),
              _DoshaBanner(locale: locale),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header (Figma node 18:3): back button, profile name + chart-style
/// subtitle, PDF export pill.
class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.locale,
    required this.profileName,
    required this.styleLabel,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String profileName;
  final String styleLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  locale,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.lagnaKundli} · $styleLabel',
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
        const SizedBox(width: 12),
        _PdfPill(l10n: l10n, locale: locale),
      ],
    );
  }
}

class _PdfPill extends StatelessWidget {
  const _PdfPill({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.pdf,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        // PDF export is a later feature (premium reports, section C) —
        // inert for now.
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.tileBlueFg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                l10n.pdf,
                style: AppFonts.body(
                  locale,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
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

/// Section tabs (Figma node 18:11): Chart / Planet Positions / Dasha /
/// Predictions. Only "Chart" is selectable — the other three are inert
/// no-ops, each with its own reason (see [_TabPill] call sites below).
class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabPill(
            label: l10n.tabChart,
            locale: locale,
            isSelected: true,
            // This screen only ever shows Chart — nothing to switch to.
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            label: l10n.tabPlanetPositions,
            locale: locale,
            isSelected: false,
            // Planet Positions arrives once the Vedika API is wired up —
            // inert until then.
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            label: '${l10n.tabDasha} 👑',
            locale: locale,
            isSelected: false,
            // Premium-gated: opens the paywall. The Dasha view itself still
            // doesn't exist, so this is the paywall rather than a tab switch.
            onTap: () => Navigator.of(
              context,
            ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            label: '${l10n.tabPredictions} 👑',
            locale: locale,
            isSelected: false,
            // Same premium gating as Dasha above.
            onTap: () => Navigator.of(
              context,
            ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool isSelected;
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.saffron : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: isSelected ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              locale,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chart-style toggle (Figma node 50:24): North Indian vs South Indian.
class _StyleToggleRow extends StatelessWidget {
  const _StyleToggleRow({
    required this.l10n,
    required this.locale,
    required this.selected,
    required this.onSelect,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliChartStyle selected;
  final ValueChanged<KundliChartStyle> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StyleTogglePill(
            // Bare "◇" glyph in the Figma design has no glyph in our
            // bundled fonts (project ICON RULE) — Material equivalent.
            icon: Icons.diamond_outlined,
            label: l10n.chartNorthIndian,
            locale: locale,
            isSelected: selected == KundliChartStyle.northIndian,
            onTap: () => onSelect(KundliChartStyle.northIndian),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StyleTogglePill(
            icon: Icons.grid_on_rounded,
            label: l10n.chartSouthIndian,
            locale: locale,
            isSelected: selected == KundliChartStyle.southIndian,
            onTap: () => onSelect(KundliChartStyle.southIndian),
          ),
        ),
      ],
    );
  }
}

class _StyleTogglePill extends StatelessWidget {
  const _StyleTogglePill({
    required this.icon,
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = isSelected
        ? AppColors.genderSelectedText
        : AppColors.muted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.genderSelectedBg : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.saffron : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: contentColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: contentColor,
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

/// Chart card (Figma node 18:20): white card containing the square chart.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.l10n,
    required this.locale,
    required this.style,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliChartStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      // The Figma design fixes this card at 400px tall with a 320px chart
      // inside; AspectRatio(1) + this 20px padding scales correctly to any
      // screen width instead of copying that fixed height.
      child: AspectRatio(
        aspectRatio: 1,
        child: style == KundliChartStyle.northIndian
            ? const _EntranceChart()
            : _SouthIndianComingSoon(l10n: l10n, locale: locale),
      ),
    );
  }
}

/// Fades + scales the chart in from 0.96 on first paint (a subtle entrance,
/// per the app's motion vocabulary in `app_motion.dart`). A bare
/// `TweenAnimationBuilder` is used directly rather than adding a new public
/// motion widget for this one call site — [EntranceFadeSlide] there is a
/// fade+SLIDE for staggered list items, which isn't this shape.
class _EntranceChart extends StatelessWidget {
  const _EntranceChart();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: kEntranceDuration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
        );
      },
      child: const NorthIndianChart(planets: KundliChartStaticData.placements),
    );
  }
}

/// Shown inside the chart card when South Indian is selected. Only the
/// North Indian layout is implemented — drawing a South Indian grid here
/// would either misrepresent working functionality or require guessing at
/// a layout not yet built from the real chart data, so this is an honest
/// "coming soon" note rather than a wrong/placeholder grid.
class _SouthIndianComingSoon extends StatelessWidget {
  const _SouthIndianComingSoon({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          l10n.southChartComingSoon,
          textAlign: TextAlign.center,
          style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
        ),
      ),
    );
  }
}

/// "KEY PLANETS" legend (Figma node 50:29).
class _KeyPlanetsLegend extends StatelessWidget {
  const _KeyPlanetsLegend({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final codes = KundliChartStaticData.legendOrder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.keyPlanets,
            style: AppFonts.body(
              locale,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.hint,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < codes.length; i++) ...[
                if (i != 0) const SizedBox(width: 6),
                Expanded(
                  child: _LegendChip(code: codes[i], locale: locale),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.code, required this.locale});

  final PlanetCode code;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    // The dots are DRAWN here (not the Figma export's PNGs) since each one
    // must be tinted per planet — a fixed set of raster images couldn't do
    // that.
    final color = code.legendColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              code.shortLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                locale,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lagna / Rashi / Nakshatra stat cards (Figma node 18:49).
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.lagna,
            value: KundliChartStaticData.lagna,
            locale: locale,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l10n.rashi,
            value: KundliChartStaticData.rashi,
            locale: locale,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            // Reuses the existing `nakshatra` key (already used by the Home
            // Dashboard's Panchang card) rather than adding a duplicate.
            label: l10n.nakshatra,
            value: KundliChartStaticData.nakshatra,
            locale: locale,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(locale, fontSize: 10, color: AppColors.hint),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dosha summary banner (Figma node 18:59).
class _DoshaBanner extends StatelessWidget {
  const _DoshaBanner({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.geoChipBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 14, color: AppColors.tileGreenFg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              KundliChartStaticData.doshaSummary,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                color: AppColors.geoChipText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
