import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../profile/birth_profile_repository.dart';
import 'panchang_data.dart';
import 'panchang_repository.dart';
import 'panchang_static_data.dart';

/// Fallback coordinates used until a saved [BirthProfile] is available (a
/// guest, or the profile still loading) — Hyderabad, matching the location
/// chip's static placeholder text (see [PanchangStaticData.location]) so the
/// two never visibly disagree.
const double _fallbackLatitude = 17.3850;
const double _fallbackLongitude = 78.4867;
const String _fallbackTimezoneId = 'Asia/Kolkata';

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

/// Builds the "Shravana Masa · Shukla Paksha"-style subtitle under the date
/// stepper from live [data], falling back to
/// [PanchangStaticData.masaPaksha] whenever either half is missing —
/// matching the same "don't show a value the API didn't actually give us"
/// rule the rest of this screen follows.
String _masaPakshaLine(PanchangData? data) {
  final masa = data?.masa?.name;
  final paksha = data?.tithi?.paksha;
  if (masa == null || paksha == null) return PanchangStaticData.masaPaksha;
  return '$masa Masa · $paksha Paksha';
}

/// Builds the 5 Panchang-elements rows (Tithi/Nakshatra/Yoga/Karana/Vaar)
/// from live [data], falling back to [PanchangStaticData.elements]
/// ROW-BY-ROW wherever the API didn't return that specific value — so a
/// partially-populated response never blanks a whole row, and a wholly
/// missing response never crashes the card.
///
/// Neither this endpoint nor any other gives an exact "till HH:mm" expiry
/// time for Tithi/Yoga/Karana, so those rows simply have no trailing
/// qualifier when built from real data (showing a fabricated time would be
/// worse than showing none). Tithi does carry a real
/// `percentageRemaining`, and Nakshatra a real `pada`, so those two use
/// that instead.
List<PanchangElement> _elementsFrom(PanchangData? data, AppLocalizations l10n) {
  final fallback = PanchangStaticData.elements;
  if (data == null) return fallback;

  final tithiName = data.tithi?.name;
  final tithiPaksha = data.tithi?.paksha;
  final String tithiValue;
  if (tithiName == null) {
    tithiValue = fallback[0].value;
  } else {
    tithiValue = tithiPaksha == null ? tithiName : '$tithiPaksha $tithiName';
  }
  final percentRemaining = data.tithi?.percentageRemaining;
  final tithiTill = percentRemaining == null
      ? null
      : l10n.panchangPercentRemaining(percentRemaining.round());

  final pada = data.nakshatra?.pada;

  return [
    PanchangElement(PanchangElementId.tithi, tithiValue, tithiTill),
    PanchangElement(
      PanchangElementId.nakshatra,
      data.nakshatra?.name ?? fallback[1].value,
      pada == null ? null : l10n.panchangPada(pada),
    ),
    PanchangElement(
      PanchangElementId.yoga,
      data.yoga?.name ?? fallback[2].value,
      null,
    ),
    PanchangElement(
      PanchangElementId.karana,
      data.karana?.name ?? fallback[3].value,
      null,
    ),
    PanchangElement(
      PanchangElementId.vaar,
      data.vara?.name ?? fallback[4].value,
      null,
    ),
  ];
}

/// Builds the Muhurat grid's 4 cards from live [muhurta], falling back to
/// [PanchangStaticData.muhurats] card-by-card.
///
/// Only Rahu Kaal has a matching field in `/v2/daily/muhurta` — Abhijit
/// Muhurat, Yamaganda and Gulika Kaal have no equivalent in that response
/// at all, so those three ALWAYS stay on their static placeholder (per the
/// "keep the placeholder rather than show a wrong value" rule), and only
/// the Rahu Kaal card's time is ever replaced with a real value. The
/// returned list always has the same 4 entries in the same order as
/// [PanchangStaticData.muhurats] — callers (`_MuhuratGrid`) index into it
/// positionally.
List<Muhurat> _muhuratsFrom(MuhurtaData? muhurta) {
  final fallback = PanchangStaticData.muhurats;
  final rahuRange = muhurta?.rahuKaal?.formattedRange;
  if (rahuRange == null) return fallback;
  return [
    fallback[0],
    Muhurat(fallback[1].name, rahuRange, fallback[1].kind),
    fallback[2],
    fallback[3],
  ];
}

/// Panchang — daily Vedic almanac, per the approved Figma "B2 · Panchang"
/// (node 14:2) concept.
///
/// Reached from the bottom nav's Panchang tab (see [AppBottomNav]). The 5
/// elements (Tithi/Nakshatra/Yoga/Karana/Vaar) and the Rahu Kaal muhurat
/// card are LIVE, sourced from the Vedika API via [panchangDataProvider] /
/// [muhurtaDataProvider]. Sunrise/sunset/moonrise/moonset, the festival
/// card, the spiritual-advice card and 3 of the 4 muhurat cards
/// (Abhijit/Yamaganda/Gulika Kaal) stay on [PanchangStaticData] because no
/// Vedika endpoint used here returns them — see `_elementsFrom` /
/// `_muhuratsFrom` above for exactly which fields fall back and why.
class PanchangScreen extends ConsumerStatefulWidget {
  const PanchangScreen({super.key});

  @override
  ConsumerState<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends ConsumerState<PanchangScreen> {
  // TODAY, not the design mock's date — this screen shows live panchang now,
  // and a returning user opening the Panchang tab expects today's almanac,
  // not 12 July 2026 (which is what PanchangStaticData was frozen at while
  // the screen was static).
  //
  // Deliberately date-ONLY (`DateTime(y, m, d)`, no time component): this
  // value is part of the `PanchangRequest` record that keys
  // `panchangDataProvider.family`, and records compare structurally. A
  // `DateTime.now()` carrying milliseconds would produce a different key on
  // every single rebuild, so the provider would re-fetch — and re-BILL —
  // forever. Truncating to the calendar day makes the key stable.
  DateTime _selectedDate = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

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

    // The panchang endpoint needs a location. Prefer the signed-in user's
    // saved birth profile; fall back to a fixed default (documented above)
    // while it's still loading or doesn't exist (guest browsing) rather
    // than blocking the whole screen on it — `valueOrNull` degrades
    // loading/error states to `null` exactly as needed here.
    final city = ref.watch(birthProfileProvider).valueOrNull?.city;
    final request = (
      date: _selectedDate,
      lat: city?.latitude ?? _fallbackLatitude,
      lon: city?.longitude ?? _fallbackLongitude,
      tz: city?.timezoneId ?? _fallbackTimezoneId,
    );

    final panchangAsync = ref.watch(panchangDataProvider(request));
    final muhurtaAsync = ref.watch(muhurtaDataProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          _PanchangHeader(
            l10n: l10n,
            locale: locale,
            isCompact: isCompact,
            selectedDate: _selectedDate,
            masaPaksha: _masaPakshaLine(panchangAsync.valueOrNull),
            onPrevious: _goToPreviousDay,
            onNext: _goToNextDay,
          ),
          // Sandbox always returns the same fixed sample location
          // regardless of the coordinates sent to it (see
          // VedikaConfig.isSandbox's doc comment) — flag that honestly
          // rather than letting the screen imply this is the user's own
          // panchang.
          if (VedikaConfig.isSandbox)
            _SandboxDataBanner(l10n: l10n, locale: locale),
          Expanded(
            child: panchangAsync.when(
              data: (data) => _PanchangBody(
                l10n: l10n,
                locale: locale,
                elements: _elementsFrom(data, l10n),
                muhurats: _muhuratsFrom(muhurtaAsync.valueOrNull),
              ),
              loading: () => _PanchangLoadingView(l10n: l10n, locale: locale),
              error: (error, stackTrace) => _PanchangErrorView(
                l10n: l10n,
                locale: locale,
                onRetry: () => ref.invalidate(panchangDataProvider(request)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentTab: AppTab.panchang),
    );
  }
}

/// The scrollable content below the header/banner — identical widget tree
/// to what this screen originally built inline, just parameterized by
/// [elements]/[muhurats] instead of reading [PanchangStaticData] directly,
/// so the panchang-fetch loading/error states above can swap this whole
/// slot out without touching a single card's design.
class _PanchangBody extends StatelessWidget {
  const _PanchangBody({
    required this.l10n,
    required this.locale,
    required this.elements,
    required this.muhurats,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final List<PanchangElement> elements;
  final List<Muhurat> muhurats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _SunMoonCard(l10n: l10n, locale: locale),
        const SizedBox(height: 14),
        _ElementsCard(l10n: l10n, locale: locale, elements: elements),
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
        _MuhuratGrid(l10n: l10n, locale: locale, muhurats: muhurats),
        const SizedBox(height: 14),
        _FestivalCard(l10n: l10n, locale: locale),
        const SizedBox(height: 14),
        _AdviceCard(l10n: l10n, locale: locale),
        const SizedBox(height: 14),
        _ViewAllMuhuratLink(l10n: l10n, locale: locale),
        const SizedBox(height: 14),
        _OfflineBadge(l10n: l10n, locale: locale),
      ],
    );
  }
}

/// Centered loading state shown in the [_PanchangScreenState] body's slot
/// while the panchang fetch is in flight. The rest of the app's motion spec
/// calls for shimmer skeletons rather than a spinner on content screens
/// (see the project's CLAUDE.md motion-spec table, item 3) — that's a
/// larger investment across every card here and is left PENDING like the
/// rest of that item; this is a deliberately small, styled-not-default
/// stand-in rather than a bare [CircularProgressIndicator].
class _PanchangLoadingView extends StatelessWidget {
  const _PanchangLoadingView({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.saffron,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.panchangLoading,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state shown in the [_PanchangScreenState] body's slot when the
/// panchang fetch fails (network error, timeout, or a Vedika-side failure —
/// see [VedikaException]). Reuses the app's one shared [AppEmptyState]
/// widget rather than a bespoke error card.
class _PanchangErrorView extends StatelessWidget {
  const _PanchangErrorView({
    required this.l10n,
    required this.locale,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AppEmptyState(
          icon: Icons.cloud_off_rounded,
          iconBackgroundColor: AppColors.ashubhBg,
          iconForegroundColor: AppColors.ashubhFg,
          title: l10n.panchangLoadErrorTitle,
          message: l10n.panchangLoadErrorMessage,
          actionLabel: l10n.panchangRetry,
          onAction: onRetry,
        ),
      ),
    );
  }
}

/// Small, non-intrusive strip flagging that every value below came from
/// Vedika's sandbox — which ignores the coordinates it's sent and always
/// returns the same fixed sample location (see [VedikaConfig.isSandbox]).
/// Styled after [_OfflineBadge] (same rounded-strip recipe) rather than the
/// louder [AppEmptyState]/error treatment, since this isn't a failure.
class _SandboxDataBanner extends StatelessWidget {
  const _SandboxDataBanner({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.warnBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 12, color: AppColors.mantraLabel),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.panchangSandboxBanner,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                locale,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mantraLabel,
              ),
            ),
          ),
        ],
      ),
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
    required this.masaPaksha,
    required this.onPrevious,
    required this.onNext,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool isCompact;
  final DateTime selectedDate;

  /// "Shravana Masa · Shukla Paksha"-style subtitle — live once the
  /// panchang fetch resolves, [PanchangStaticData.masaPaksha] otherwise
  /// (see `_masaPakshaLine`).
  final String masaPaksha;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 16 > 52 ? statusBarInset + 16 : 52.0;

    return Container(
      width: double.infinity,
      // MINIMUM height, not a fixed one. This used to be
      // `height: isCompact ? 170 : 190`, which overflowed by 57px on any
      // compact device: 170 minus the 52px `topPadding` leaves 118px for a
      // title row + date stepper that need ~175. It only became visible
      // once the masa/paksha subtitle started coming from the API — a live
      // value like "Pausha Masa · Krishna Paksha" wraps where the frozen
      // placeholder happened not to — but the header was one long string
      // away from clipping regardless of where the text came from.
      //
      // A minimum keeps the roomy look of the design on normal phones while
      // letting the gradient grow rather than silently clip content (the
      // yellow overflow stripes only appear in debug; in release the text
      // is just cut off).
      constraints: BoxConstraints(minHeight: isCompact ? 170 : 190),
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 16),
      decoration: BoxDecoration(
        gradient: AppColors.navyHeroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            masaPaksha: masaPaksha,
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
    required this.masaPaksha,
    required this.onPrevious,
    required this.onNext,
  });

  final Locale locale;
  final DateTime selectedDate;
  final String masaPaksha;
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
                  masaPaksha,
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
  const _ElementsCard({
    required this.l10n,
    required this.locale,
    required this.elements,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final List<PanchangElement> elements;

  @override
  Widget build(BuildContext context) {
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
  const _MuhuratGrid({
    required this.l10n,
    required this.locale,
    required this.muhurats,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// Always 4 entries, same order as [PanchangStaticData.muhurats] — see
  /// `_muhuratsFrom` for how this is built.
  final List<Muhurat> muhurats;

  @override
  Widget build(BuildContext context) {
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
