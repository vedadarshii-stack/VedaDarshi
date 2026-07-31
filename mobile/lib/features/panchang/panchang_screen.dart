import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../l10n/app_localizations.dart';
import 'panchang_static_data.dart';

const List<String> _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Formats [date] as "Saturday, 12 July 2026" without the `intl` package —
/// the panchang date stepper below only ever needs this one fixed format.
String _formatPanchangDate(DateTime date) {
  final weekday = _weekdayNames[date.weekday - 1];
  final month = _monthNames[date.month - 1];
  return '$weekday, ${date.day} $month ${date.year}';
}

/// Panchang — daily Vedic almanac, per the approved Figma "B2 · Panchang"
/// (node 14:2) concept.
///
/// Reached from the bottom nav's Panchang tab (see [AppBottomNav]). Every
/// astrology value shown below is STATIC PLACEHOLDER DATA from
/// [PanchangStaticData]; see that file's doc comment for what eventually
/// replaces it (the Vedika API panchang endpoint).
class PanchangScreen extends ConsumerStatefulWidget {
  const PanchangScreen({super.key});

  @override
  ConsumerState<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends ConsumerState<PanchangScreen> {
  // Seeded from PanchangStaticData.date (Saturday, 12 July 2026). The date
  // stepper arrows below are fully functional and update this field, but
  // every panchang VALUE on this screen (elements, muhurats, festival,
  // advice) stays static regardless of the selected date — those values
  // will start following the selected date once the Vedika API panchang
  // endpoint is wired up in place of PanchangStaticData; today they
  // intentionally don't change when the arrows are tapped.
  DateTime _selectedDate = DateTime(2026, 7, 12);

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _PanchangHeader(
            l10n: l10n,
            locale: locale,
            isCompact: isCompact,
            selectedDate: _selectedDate,
            onPrevious: _goToPreviousDay,
            onNext: _goToNextDay,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _SunMoonCard(l10n: l10n, locale: locale),
                const SizedBox(height: 14),
                _ElementsCard(l10n: l10n, locale: locale),
                const SizedBox(height: 14),
                Text(
                  l10n.muhuratToday,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                _MuhuratGrid(l10n: l10n, locale: locale),
                const SizedBox(height: 14),
                _FestivalCard(l10n: l10n, locale: locale),
                const SizedBox(height: 14),
                _AdviceCard(l10n: l10n, locale: locale),
                const SizedBox(height: 14),
                _ViewAllMuhuratLink(l10n: l10n, locale: locale),
                const SizedBox(height: 14),
                _OfflineBadge(l10n: l10n, locale: locale),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentTab: AppTab.panchang),
    );
  }
}

/// Navy hero header: title + location chip, and the functional date
/// stepper. NOT inside a top [SafeArea] — the navy background is meant to
/// run under the status bar, per "B2 · Panchang" (node 14:3).
class _PanchangHeader extends StatelessWidget {
  const _PanchangHeader({
    required this.l10n,
    required this.locale,
    required this.isCompact,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool isCompact;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 16 > 52 ? statusBarInset + 16 : 52.0;

    return Container(
      width: double.infinity,
      height: isCompact ? 170 : 190,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 0),
      decoration: BoxDecoration(
        gradient: AppColors.navyHeroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.panchangTitle,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      PanchangStaticData.location,
                      style: AppFonts.body(
                        locale,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DateStepper(
            locale: locale,
            selectedDate: selectedDate,
            onPrevious: onPrevious,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

class _DateStepper extends StatelessWidget {
  const _DateStepper({
    required this.locale,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  final Locale locale;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StepperArrow(icon: Icons.chevron_left, onTap: onPrevious),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatPanchangDate(selectedDate),
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  PanchangStaticData.masaPaksha,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 10.5,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          _StepperArrow(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _StepperArrow extends StatelessWidget {
  const _StepperArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 20, color: AppColors.mutedOnNavy),
          ),
        ),
      ),
    );
  }
}

/// Sunrise / sunset / moonrise / moonset stat strip.
class _SunMoonCard extends StatelessWidget {
  const _SunMoonCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    // Typographic ☀/☾ glyphs from the design have no glyph in any bundled
    // font and would render as tofu (see the project's TYPOGRAPHY RULE) —
    // replaced with Material icons, same as every other bare symbol in this
    // app's designs.
    final items = [
      (
        Icons.wb_sunny_rounded,
        AppColors.genderSelectedText,
        l10n.panchangSunrise,
        PanchangStaticData.sunrise,
      ),
      (
        Icons.wb_twilight_rounded,
        AppColors.tilePinkFg,
        l10n.panchangSunset,
        PanchangStaticData.sunset,
      ),
      (
        Icons.nightlight_round,
        AppColors.tileBlueFg,
        l10n.panchangMoonrise,
        PanchangStaticData.moonrise,
      ),
      (
        Icons.dark_mode_rounded,
        AppColors.tilePurpleFg,
        l10n.panchangMoonset,
        PanchangStaticData.moonset,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i != 0) const SizedBox(width: 4),
            Expanded(
              child: _SunMoonItem(
                icon: items[i].$1,
                color: items[i].$2,
                label: items[i].$3,
                value: items[i].$4,
                locale: locale,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SunMoonItem extends StatelessWidget {
  const _SunMoonItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.locale,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.body(locale, fontSize: 9.5, color: AppColors.hint),
        ),
        const SizedBox(height: 2),
        // Allowed to shrink: 4 items across a 360dp screen is tight,
        // especially in the longer Indic locales.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: AppFonts.body(
              locale,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Resolves the l10n label for a [PanchangElementId]. Nakshatra/Yoga/Karana
/// reuse the existing `nakshatra`/`yoga`/`karana` keys (already used on the
/// Home dashboard's Panchang hero card) since their English values already
/// match what this row needs — no point duplicating them.
String _elementLabel(PanchangElementId id, AppLocalizations l10n) {
  switch (id) {
    case PanchangElementId.tithi:
      return l10n.panchangTithi;
    case PanchangElementId.nakshatra:
      return l10n.nakshatra;
    case PanchangElementId.yoga:
      return l10n.yoga;
    case PanchangElementId.karana:
      return l10n.karana;
    case PanchangElementId.vaar:
      return l10n.panchangVaar;
  }
}

/// Tithi / Nakshatra / Yoga / Karana / Vaar card.
class _ElementsCard extends StatelessWidget {
  const _ElementsCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final elements = PanchangStaticData.elements;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < elements.length; i++) ...[
            _ElementRow(
              element: elements[i],
              label: _elementLabel(elements[i].id, l10n),
              locale: locale,
            ),
            if (i != elements.length - 1)
              Container(height: 1, color: AppColors.rowDivider),
          ],
        ],
      ),
    );
  }
}

class _ElementRow extends StatelessWidget {
  const _ElementRow({
    required this.element,
    required this.label,
    required this.locale,
  });

  final PanchangElement element;
  final String label;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppFonts.body(
                locale,
                fontSize: 12.5,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // The value + "till" pair must be allowed to wrap/shrink: in
          // Telugu/Tamil/Kannada the label alone can take most of the row.
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    element.value,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      locale,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (element.tillLabel != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      element.tillLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        locale,
                        fontSize: 10.5,
                        color: AppColors.hint,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MuhuratKindMeta {
  const _MuhuratKindMeta({
    required this.background,
    required this.icon,
    required this.badgeLabel,
    required this.badgeColor,
  });

  final Color background;
  final IconData icon;
  final String badgeLabel;
  final Color badgeColor;
}

_MuhuratKindMeta _muhuratKindMeta(MuhuratKind kind, AppLocalizations l10n) {
  switch (kind) {
    case MuhuratKind.shubh:
      // Reuses the existing shubh green tokens from the Home dashboard's
      // glance-tile palette rather than adding near-duplicate colours.
      return _MuhuratKindMeta(
        background: AppColors.geoChipBg,
        icon: Icons.check_rounded,
        badgeLabel: l10n.muhuratShubh,
        badgeColor: AppColors.tileGreenFg,
      );
    case MuhuratKind.ashubh:
      return _MuhuratKindMeta(
        background: AppColors.ashubhBg,
        icon: Icons.priority_high_rounded,
        badgeLabel: l10n.muhuratAshubh,
        badgeColor: AppColors.ashubhFg,
      );
    case MuhuratKind.caution:
      // Reuses the existing mantraLabel amber token rather than adding a
      // near-duplicate colour.
      return _MuhuratKindMeta(
        background: AppColors.warnBg,
        icon: Icons.priority_high_rounded,
        badgeLabel: l10n.muhuratAshubh,
        badgeColor: AppColors.mantraLabel,
      );
  }
}

/// Two rows of two Muhurat cards (Abhijit / Rahu Kaal / Yamaganda / Gulika
/// Kaal).
class _MuhuratGrid extends StatelessWidget {
  const _MuhuratGrid({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final muhurats = PanchangStaticData.muhurats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MuhuratCard(
                muhurat: muhurats[0],
                l10n: l10n,
                locale: locale,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MuhuratCard(
                muhurat: muhurats[1],
                l10n: l10n,
                locale: locale,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MuhuratCard(
                muhurat: muhurats[2],
                l10n: l10n,
                locale: locale,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MuhuratCard(
                muhurat: muhurats[3],
                l10n: l10n,
                locale: locale,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MuhuratCard extends StatelessWidget {
  const _MuhuratCard({
    required this.muhurat,
    required this.l10n,
    required this.locale,
  });

  final Muhurat muhurat;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final meta = _muhuratKindMeta(muhurat.kind, l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: meta.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(meta.icon, size: 11, color: meta.badgeColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  meta.badgeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: meta.badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            muhurat.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            muhurat.time,
            style: AppFonts.body(locale, fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Festival-of-the-day navy strip — identical recipe to the Home dashboard's
/// festival card.
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
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
                        l10n.festivalToday,
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
                        PanchangStaticData.festival,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          locale,
                          fontSize: 12.5,
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
                          l10n.details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            locale,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
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

/// Spiritual advice card.
class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        border: Border.all(color: AppColors.mantraBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ॐ mark — Devanagari, forced to the 'hi' locale regardless of the
          // app's active locale (see the project's TYPOGRAPHY RULE). This
          // replaces the design's 🕉 emoji for consistency with the same
          // mark used elsewhere in the app (e.g. Home's Panchang hero card
          // and remedy/mantra card).
          Text(
            'ॐ',
            style: AppFonts.body(
              const Locale('hi'),
              fontSize: 18,
              color: AppColors.mantraIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.todaysSpiritualAdvice,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mantraLabel,
                    letterSpacing: 0.72,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  PanchangStaticData.advice,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11.5,
                    color: AppColors.mantraBody,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewAllMuhuratLink extends StatelessWidget {
  const _ViewAllMuhuratLink({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l10n.viewAllMuhurat,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.saffron,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.saffron),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 12,
            color: AppColors.tileGoldFg,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.availableOffline(PanchangStaticData.offlineUpdatedAt),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                locale,
                fontSize: 11,
                color: AppColors.tileGoldFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
