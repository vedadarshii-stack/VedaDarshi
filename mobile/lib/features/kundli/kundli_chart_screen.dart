import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_client.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'kundli_chart_static_data.dart';
import 'kundli_dasha_tab.dart';
import 'kundli_data.dart';
import 'kundli_dosha_data.dart';
import 'kundli_planet_positions_tab.dart';
import 'kundli_repository.dart';
import 'kundli_sandbox_banner.dart';
import 'kundli_shimmer_block.dart';
import 'kundli_static_data.dart';
import 'north_indian_chart.dart';

/// Which chart layout is shown. Public (unlike the private `_ChartStyle` on
/// `kundli_input_screen.dart`) because [KundliChartScreen] accepts the
/// user's earlier selection from that screen via its constructor.
enum KundliChartStyle { northIndian, southIndian }

/// Which of the screen's section tabs is active — see [_SectionTabs].
/// Predictions isn't a member here: it stays permanently premium-gated and
/// pushes the paywall instead of ever becoming "selected" content, so it
/// has no corresponding screen state.
enum _KundliTab { chart, planetPositions, dasha }

/// Kundli Chart — per the approved Figma "B6 · Kundli Chart" (node 18:2)
/// concept.
///
/// Pushed from the Kundli — New Chart screen's "Generate Kundli" CTA
/// (`kundli_input_screen.dart`). Like that screen, this is a pushed
/// destination with its own back button and NO bottom nav in the design.
///
/// **Every astrology VALUE shown here (planet placements, Lagna/Rashi/
/// Nakshatra, chart summary, dosha verdicts, dasha timeline) now comes from
/// the live Vedika API** (`kundli_repository.dart` and its three data
/// files: `kundli_data.dart`, `kundli_dosha_data.dart`,
/// `kundli_dasha_data.dart`) — see [_ChartDataSection] for the Chart tab's
/// loading/error/data states. Three of the 4 section tabs are now
/// functional — Chart, Planet Positions and Vimshottari Dasha; only
/// Predictions stays inert (premium-gated, no entitlement source yet — see
/// [_SectionTabs]). Only the North Indian chart layout is drawn — see
/// [_ChartCard] for why South Indian shows a "coming soon" note instead of
/// a placeholder grid.
///
/// **SANDBOX GOTCHA:** while [VedikaConfig.isSandbox] is true, Vedika
/// ignores the birth details this screen sends and always returns the same
/// fixed sample chart (verified 1 Aug 2026 — see that getter's doc
/// comment). [KundliSandboxBanner] makes that non-negotiably visible whenever it
/// applies, rather than silently presenting a stranger's chart as the
/// user's own.
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

  /// Defaults to Chart — the only tab that was ever selectable before this
  /// screen's Planet Positions / Vimshottari Dasha tabs were wired up.
  _KundliTab _selectedTab = _KundliTab.chart;

  @override
  void initState() {
    super.initState();
    _chartStyle = widget.initialStyle;
  }

  void _selectStyle(KundliChartStyle style) {
    if (style == _chartStyle) return;
    setState(() => _chartStyle = style);
  }

  void _selectTab(_KundliTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    // Same fallback pattern as the Kundli input screen: prefer the real
    // saved profile, fall back to its static placeholder name for the
    // should-be-impossible "no profile yet" case (see
    // KundliStaticData's doc comment). This is display-only — it never
    // stands in for the actual coordinates the chart is computed from, see
    // [request] below.
    final profile = ref.watch(birthProfileProvider).valueOrNull;
    final trimmedName = profile?.fullName.trim();
    final profileName = (trimmedName != null && trimmedName.isNotEmpty)
        ? trimmedName
        : KundliStaticData.fallbackProfileName;
    final styleLabel = _chartStyle == KundliChartStyle.northIndian
        ? l10n.chartNorthIndian
        : l10n.chartSouthIndian;

    // Unlike [profileName] above, there is no honest placeholder for the
    // birth coordinates a chart is computed from — [request] (and therefore
    // [kundliAsync]) is `null` only in the practically-impossible case the
    // profile hasn't resolved yet / resolved to nothing (RootGate
    // guarantees a saved profile exists before this screen is reachable at
    // all). [_ChartDataSection] renders an honest empty/error state for
    // that case rather than fabricating coordinates.
    final request = profile == null
        ? null
        : KundliRequest.fromBirthProfile(profile);
    final kundliAsync = request == null
        ? null
        : ref.watch(kundliDataProvider(request));

    // Fetched eagerly (not gated on which tab is selected) because the
    // Chart tab — the screen's default tab — needs it immediately for the
    // dosha-summary banner. Independent of [kundliAsync]: a dosha-call
    // failure must never take down the Chart tab's planet chart itself,
    // only degrade that one banner (see [_DoshaOrSummaryBanner]).
    final doshasAsync = request == null
        ? null
        : ref.watch(kundliDoshasProvider(request));

    // UNLIKE [doshasAsync], only watched once the Dasha tab is actually
    // selected — real Vedika calls are billed per call in production
    // (`projects/CLAUDE.md`), and most visits to this screen never open
    // this tab. `kundliDashaProvider`/[KundliRepository] both cache their
    // result once fetched, so switching away and back doesn't re-fetch.
    final dashaAsync = (request != null && _selectedTab == _KundliTab.dasha)
        ? ref.watch(kundliDashaProvider(request))
        : null;

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
              _SectionTabs(
                l10n: l10n,
                locale: locale,
                selected: _selectedTab,
                onSelect: _selectTab,
              ),
              const SizedBox(height: 16),
              // Chart-style (North/South) only means anything on the Chart
              // tab itself — Planet Positions and Vimshottari Dasha are
              // plain lists with no chart layout to toggle.
              if (_selectedTab == _KundliTab.chart) ...[
                _StyleToggleRow(
                  l10n: l10n,
                  locale: locale,
                  selected: _chartStyle,
                  onSelect: _selectStyle,
                ),
                const SizedBox(height: 16),
              ],
              switch (_selectedTab) {
                _KundliTab.chart => _ChartDataSection(
                  l10n: l10n,
                  locale: locale,
                  style: _chartStyle,
                  kundliAsync: kundliAsync,
                  doshasAsync: doshasAsync,
                  onRetry: request == null
                      ? null
                      : () => ref.invalidate(kundliDataProvider(request)),
                ),
                _KundliTab.planetPositions => KundliPlanetPositionsTab(
                  l10n: l10n,
                  locale: locale,
                  kundliAsync: kundliAsync,
                  onRetry: request == null
                      ? null
                      : () => ref.invalidate(kundliDataProvider(request)),
                ),
                _KundliTab.dasha => KundliDashaTab(
                  l10n: l10n,
                  locale: locale,
                  dashaAsync: dashaAsync,
                  onRetry: request == null
                      ? null
                      : () => ref.invalidate(kundliDashaProvider(request)),
                ),
              },
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
                color: AppColors.surface,
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

/// Section tabs (Figma node 18:11): Chart / Planet Positions / Vimshottari
/// Dasha / Predictions. The first three are now real, selectable tabs —
/// only Predictions stays inert, opening the paywall instead of switching
/// (see that pill's `onTap` below for why).
class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.l10n,
    required this.locale,
    required this.selected,
    required this.onSelect,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final _KundliTab selected;
  final ValueChanged<_KundliTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabPill(
            label: l10n.tabChart,
            locale: locale,
            isSelected: selected == _KundliTab.chart,
            onTap: () => onSelect(_KundliTab.chart),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            label: l10n.tabPlanetPositions,
            locale: locale,
            isSelected: selected == _KundliTab.planetPositions,
            onTap: () => onSelect(_KundliTab.planetPositions),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            label: l10n.tabDasha,
            locale: locale,
            isSelected: selected == _KundliTab.dasha,
            onTap: () => onSelect(_KundliTab.dasha),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            label: '${l10n.tabPredictions} 👑',
            locale: locale,
            isSelected: false,
            // Still premium-gated with no entitlement source (RevenueCat
            // unwired — see `projects/CLAUDE.md`), so this opens the
            // paywall rather than ever becoming a selectable tab; there is
            // no `_KundliTab.predictions` state to switch to.
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
            color: isSelected ? AppColors.saffron : AppColors.surface,
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
            color: isSelected ? AppColors.genderSelectedBg : AppColors.surface,
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

/// Everything below "CHART STYLE" that depends on real Vedika data: the
/// chart card itself, the stat cards and the chart-summary banner — plus
/// the sandbox banner, and the loading/error states covering all of it
/// while [kundliAsync] is unresolved. Kept as one section (rather than each
/// child watching its own provider) so the loading/error states can
/// occupy the exact same layout slot as the real content, instead of each
/// card independently flickering between states.
class _ChartDataSection extends StatelessWidget {
  const _ChartDataSection({
    required this.l10n,
    required this.locale,
    required this.style,
    required this.kundliAsync,
    required this.doshasAsync,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliChartStyle style;

  /// `null` only in the practically-impossible "no birth profile" case —
  /// see [KundliChartScreen.build]'s `request` comment.
  final AsyncValue<KundliData>? kundliAsync;

  /// Independent of [kundliAsync] — see [KundliChartScreen.build]'s
  /// `doshasAsync` comment. Passed straight through to
  /// [_ChartLoadedSection]; the Chart tab's own loading/error states below
  /// are keyed on [kundliAsync] only, since the chart itself doesn't depend
  /// on the dosha call succeeding.
  final AsyncValue<AllDoshasData>? doshasAsync;

  /// `null` iff [kundliAsync] is `null` — there is nothing to retry without
  /// birth coordinates to retry it with.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final async = kundliAsync;
    if (async == null) {
      return _ChartErrorState(
        l10n: l10n,
        locale: locale,
        message: l10n.kundliLoadErrorMessage,
        onRetry: null,
      );
    }
    return async.when(
      loading: () => _ChartLoadingState(l10n: l10n, locale: locale),
      error: (error, stackTrace) => _ChartErrorState(
        l10n: l10n,
        locale: locale,
        // A VedikaException's own message is already a screen-ready
        // sentence (see that class's doc comment); anything else (a bug in
        // our own parsing, an unexpected exception type) falls back to a
        // generic localized message instead of leaking a raw exception
        // string onto the screen.
        message: error is VedikaException
            ? error.message
            : l10n.kundliLoadErrorMessage,
        onRetry: onRetry,
      ),
      data: (data) => _ChartLoadedSection(
        l10n: l10n,
        locale: locale,
        style: style,
        data: data,
        doshasAsync: doshasAsync,
      ),
    );
  }
}

/// The real chart card + legend + stat cards + dosha/summary banner, once
/// [data] has loaded — plus [KundliSandboxBanner] whenever
/// [VedikaConfig.isSandbox] applies.
class _ChartLoadedSection extends StatelessWidget {
  const _ChartLoadedSection({
    required this.l10n,
    required this.locale,
    required this.style,
    required this.data,
    required this.doshasAsync,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliChartStyle style;
  final KundliData data;
  final AsyncValue<AllDoshasData>? doshasAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Non-negotiable while pointed at the sandbox — see
        // VedikaConfig.isSandbox's doc comment: it always answers with one
        // fixed sample chart, never the birth details actually sent.
        if (VedikaConfig.isSandbox) ...[
          KundliSandboxBanner(l10n: l10n, locale: locale),
          const SizedBox(height: 16),
        ],
        _ChartCard(
          l10n: l10n,
          locale: locale,
          style: style,
          planets: data.toChartPlanets(),
        ),
        const SizedBox(height: 16),
        _KeyPlanetsLegend(l10n: l10n, locale: locale),
        const SizedBox(height: 16),
        _StatCardsRow(
          l10n: l10n,
          locale: locale,
          lagna: data.ascendant?.sign ?? l10n.kundliValueUnavailable,
          rashi: data.moonSign ?? l10n.kundliValueUnavailable,
          nakshatra: data.nakshatra ?? l10n.kundliValueUnavailable,
        ),
        // [_DoshaOrSummaryBanner] renders nothing (and adds no extra gap)
        // when there is genuinely no dosha verdict AND no summary overview
        // to fall back to — so the 16px gap above it is its own
        // responsibility, not this Column's, to avoid a dangling blank gap.
        _DoshaOrSummaryBanner(
          l10n: l10n,
          locale: locale,
          doshasAsync: doshasAsync,
          summaryOverview: data.summary?.overview,
        ),
      ],
    );
  }
}

/// Loading placeholder shaped like [_ChartLoadedSection] — pulsing
/// [KundliShimmerBlock]s rather than a bare spinner, per the app's motion
/// spec ("shimmer skeletons on all cards, NO spinners on content screens" —
/// `projects/CLAUDE.md`'s motion-spec table, item 3). That item was PENDING
/// project-wide because nothing had real network latency to design a
/// loading card against; this screen was the first to need it, and
/// [KundliShimmerBlock] is now shared by the Planet Positions and
/// Vimshottari Dasha tabs' own loading states too.
class _ChartLoadingState extends StatelessWidget {
  const _ChartLoadingState({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.kundliLoadingChart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: KundliShimmerBlock(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          KundliShimmerBlock(height: 74, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KundliShimmerBlock(
                  height: 62,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KundliShimmerBlock(
                  height: 62,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KundliShimmerBlock(
                  height: 62,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Error state covering the same layout slot as [_ChartLoadedSection] —
/// reuses the shared [AppEmptyState] card (the "F1 Empty States" gallery
/// building block) rather than a bespoke error widget, with a Retry pill
/// when [onRetry] is available.
class _ChartErrorState extends StatelessWidget {
  const _ChartErrorState({
    required this.l10n,
    required this.locale,
    required this.message,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      // Reuses the Panchang screen's "inauspicious" tint — the closest
      // existing semantic match for an error state, per this project's
      // reuse-before-adding-a-color convention (see AppColors' doc
      // comments).
      iconBackgroundColor: AppColors.ashubhBg,
      iconForegroundColor: AppColors.ashubhFg,
      title: l10n.kundliLoadErrorTitle,
      message: message,
      actionLabel: onRetry == null ? null : l10n.kundliRetry,
      onAction: onRetry,
    );
  }
}

/// Chart card (Figma node 18:20): white card containing the square chart.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.l10n,
    required this.locale,
    required this.style,
    required this.planets,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final KundliChartStyle style;
  final List<ChartPlanet> planets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      // The Figma design fixes this card at 400px tall with a 320px chart
      // inside; AspectRatio(1) + this 20px padding scales correctly to any
      // screen width instead of copying that fixed height.
      child: AspectRatio(
        aspectRatio: 1,
        child: style == KundliChartStyle.northIndian
            ? _EntranceChart(planets: planets)
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
  const _EntranceChart({required this.planets});

  final List<ChartPlanet> planets;

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
      child: NorthIndianChart(planets: planets),
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
        color: AppColors.surface,
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

/// Lagna / Rashi / Nakshatra stat cards (Figma node 18:49). [lagna]/[rashi]/
/// [nakshatra] are the real Vedika values — Ascendant sign, Moon sign and
/// the Moon's birth star respectively (see [_ChartLoadedSection]) — with
/// the caller already substituting `l10n.kundliValueUnavailable` for any
/// field Vedika omitted, so this widget itself never has to know about
/// nullability.
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.l10n,
    required this.locale,
    required this.lagna,
    required this.rashi,
    required this.nakshatra,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String lagna;
  final String rashi;
  final String nakshatra;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(label: l10n.lagna, value: lagna, locale: locale),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: l10n.rashi, value: rashi, locale: locale),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            // Reuses the existing `nakshatra` key (already used by the Home
            // Dashboard's Panchang card) rather than adding a duplicate.
            label: l10n.nakshatra,
            value: nakshatra,
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
        color: AppColors.surface,
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

/// Decides between the REAL dosha verdict banner and the [_SummaryBanner]
/// fallback, occupying the approved design's dosha-summary banner slot
/// (Figma node 18:59, "No Mangal Dosha detected · Kaal Sarp: Partial").
///
/// Until 1 Aug 2026 this slot could never show a real verdict — Vedika's
/// `/v2/astrology/kundli` response carries no dosha computation at all, so
/// it showed `summary.overview` instead (a real but different piece of
/// data, with the checkmark swapped for a sparkle since it made no dosha
/// claim). `/v2/astrology/all-doshas` now provides exactly this verdict, so
/// the real banner is restored — but [_SummaryBanner] stays as the
/// fallback for whenever the dosha call hasn't produced anything usable
/// (still loading, failed, or Vedika omitted both `has_dosha` flags): never
/// silently blank, and never a lie either direction (never "no dosha
/// detected" for data that's simply missing, per [_DoshaVerdict.from]).
class _DoshaOrSummaryBanner extends StatelessWidget {
  const _DoshaOrSummaryBanner({
    required this.l10n,
    required this.locale,
    required this.doshasAsync,
    required this.summaryOverview,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final AsyncValue<AllDoshasData>? doshasAsync;
  final String? summaryOverview;

  @override
  Widget build(BuildContext context) {
    // `valueOrNull` collapses "no provider" / loading / error into `null`
    // in one step (established pattern elsewhere in this app, e.g.
    // `birthProfileProvider.valueOrNull` on the Home dashboard) — exactly
    // the fallback trigger this banner needs. Falling back while doshas is
    // still LOADING (not just on outright failure) is deliberate too: by
    // the time this widget can build at all, the Chart tab's own kundli
    // data — and therefore [summaryOverview] — has already loaded, so
    // showing that immediately reads better than a blank gap that pops a
    // dosha verdict into a moment later.
    final doshas = doshasAsync?.valueOrNull;
    final verdict = doshas == null ? null : _DoshaVerdict.from(doshas, l10n);

    if (verdict != null) {
      return _DoshaVerdictBanner(verdict: verdict, locale: locale);
    }
    final overview = summaryOverview;
    if (overview != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _SummaryBanner(text: overview, locale: locale),
      );
    }
    // Neither a dosha verdict nor a summary overview — genuinely nothing to
    // show, so nothing renders (no dangling 16px gap either, see the call
    // site's comment).
    return const SizedBox.shrink();
  }
}

/// Presentation-ready dosha verdict, or `null` when [doshas] doesn't carry
/// enough to say anything meaningful (both `mangal_dosha.has_dosha` AND
/// `kaal_sarp_dosha.has_dosha` missing) — the caller falls back to
/// [_SummaryBanner] in that case.
@immutable
class _DoshaVerdict {
  const _DoshaVerdict({
    required this.isClear,
    required this.mangalText,
    required this.kaalSarpText,
    this.pitruText,
  });

  /// True ONLY when every dosha `/v2/astrology/all-doshas` reports on is
  /// EXPLICITLY confirmed absent — the one condition under which
  /// [_DoshaVerdictBanner] is allowed to use the checkmark icon, per this
  /// feature's explicit rule: a checkmark claims "verified clear", so it
  /// must never show while a dosha exists OR while a verdict is simply
  /// unknown.
  ///
  /// **This includes PITRU DOSHA, which the Figma banner never mentions.**
  /// The endpoint returns three doshas (mangal, kaal sarp, pitru) and the
  /// sandbox's own fixed sample comes back `mangal=false, kaalSarp=false,
  /// pitru=TRUE` — so keying "clear" off only the two doshas the design
  /// happens to name would put a green checkmark on a chart that genuinely
  /// HAS a dosha. The icon reads as a verdict on the whole chart, not as a
  /// verdict on two hand-picked doshas, so it has to answer for all three.
  final bool isClear;
  final String mangalText;
  final String kaalSarpText;

  /// Only non-null when Pitru Dosha is explicitly PRESENT. Absent/unknown
  /// pitru adds no clause, which keeps the common case reading exactly like
  /// the approved two-part design ("No Mangal Dosha detected · No Kaal Sarp
  /// Dosha detected") instead of padding it with a third negative.
  final String? pitruText;

  static _DoshaVerdict? from(AllDoshasData doshas, AppLocalizations l10n) {
    final mangalHas = doshas.mangalDosha?.hasDosha;
    final kaalSarpHas = doshas.kaalSarpDosha?.hasDosha;
    final pitruHas = doshas.pitruDosha?.hasDosha;
    if (mangalHas == null && kaalSarpHas == null) return null;

    return _DoshaVerdict(
      // `pitruHas != true` rather than `== false`: an UNKNOWN pitru must not
      // block the checkmark (the banner never claimed to report on pitru),
      // but a KNOWN-present one must.
      isClear: mangalHas == false && kaalSarpHas == false && pitruHas != true,
      mangalText: _mangalText(doshas.mangalDosha, l10n),
      kaalSarpText: _kaalSarpText(doshas.kaalSarpDosha, l10n),
      pitruText: pitruHas == true ? l10n.kundliDoshaPitruPresent : null,
    );
  }

  static String _mangalText(MangalDosha? mangal, AppLocalizations l10n) {
    if (mangal?.hasDosha == null) return l10n.kundliValueUnavailable;
    // Prefer Vedika's own personalized verdict sentence when present — see
    // `MangalDosha.description`'s doc comment for why this field (unlike
    // Kaal Sarp's) IS a real personalized verdict, safe to render directly
    // rather than templating our own wording.
    final description = mangal!.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    return mangal.hasDosha!
        ? l10n.kundliDoshaMangalPresent
        : l10n.kundliDoshaMangalAbsent;
  }

  static String _kaalSarpText(KaalSarpDosha? kaalSarp, AppLocalizations l10n) {
    if (kaalSarp?.hasDosha == null) return l10n.kundliValueUnavailable;
    if (!kaalSarp!.hasDosha!) return l10n.kundliDoshaKaalSarpAbsent;
    // Unlike Mangal Dosha's `description`, Kaal Sarp's `description` field
    // is a GENERAL definition of the dosha, not a personalized verdict
    // (see `KaalSarpDosha.description`'s doc comment) — so this one IS
    // composed from the structured `type` field instead of reused as-is.
    final type = kaalSarp.type?.trim();
    if (type != null && type.isNotEmpty && type != 'None') {
      return l10n.kundliDoshaKaalSarpPresentType(type);
    }
    return l10n.kundliDoshaKaalSarpPresent;
  }
}

/// The real two-verdict banner — checkmark + [AppColors.geoChipBg] (the
/// same calm tone [_SummaryBanner] already used) when [_DoshaVerdict.isClear],
/// otherwise a neutral/warning icon on [AppColors.warnBg] (the app's
/// existing "caution, not error" tone, already used by [KundliSandboxBanner])
/// for when a dosha is present OR its status couldn't be determined —
/// **never a checkmark in that branch**, per [_DoshaVerdict.isClear]'s doc.
class _DoshaVerdictBanner extends StatelessWidget {
  const _DoshaVerdictBanner({required this.verdict, required this.locale});

  final _DoshaVerdict verdict;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final isClear = verdict.isClear;
    final background = isClear ? AppColors.geoChipBg : AppColors.warnBg;
    final foreground = isClear ? AppColors.geoChipText : AppColors.mantraLabel;
    final icon = isClear ? Icons.check_circle : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // Same single-line, " · "-joined shape as the approved
              // Figma banner ("No Mangal Dosha detected · Kaal Sarp:
              // Partial") — allowed to wrap to a few lines (rather than the
              // original's hard single line) because Mangal Dosha's clause
              // can now be a full Vedika sentence (see [_DoshaVerdict._mangalText]),
              // which is longer than the design's placeholder text.
              [
                verdict.mangalText,
                verdict.kaalSarpText,
                // Only appended when pitru is explicitly present — see
                // [_DoshaVerdict.pitruText]. It's what forces the icon off
                // the checkmark, so it has to be visible or the neutral
                // icon would look unexplained.
                ?verdict.pitruText,
              ].join(' · '),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(locale, fontSize: 11.5, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fallback content for [_DoshaOrSummaryBanner] — shows Vedika's real
/// `summary.overview` text (an Ascendant/Sun/Moon-derived narrative
/// paragraph) whenever the real dosha verdict isn't available. This was
/// the ONLY content this banner slot could show before 1 Aug 2026 — see
/// [_DoshaOrSummaryBanner]'s class doc for the full history. The sparkle
/// icon (rather than a checkmark) stays: `summary.overview` makes no dosha
/// claim, clear or otherwise.
class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.text, required this.locale});

  final String text;
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
          Icon(Icons.auto_awesome, size: 14, color: AppColors.geoChipText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // Vedika returns this interpretation text in English only,
              // regardless of the app's active locale — there's no
              // per-language field anywhere in the response. Rendered
              // as-is; this is a real gap for the 4 Indic locales. Making
              // it translate needs either a client-side translation layer
              // or Vedika exposing localized interpretation text, neither
              // of which exists today.
              text,
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
