import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/astrology/astro_terms.dart';
import '../../l10n/app_localizations.dart';
import 'muhurat_timings_screen.dart';
import 'panchang_data.dart';
import 'panchang_location.dart';
import 'panchang_repository.dart';
import 'panchang_static_data.dart';

/// Fallback coordinates used until a saved [BirthProfile] is available (a
/// guest, or the profile still loading) — Hyderabad, matching the location
/// chip's static placeholder text (see [PanchangStaticData.location]) so the
/// two never visibly disagree.
// Fallback coordinates now live in `panchang_location.dart` as
// `kFallbackPanchangCity`, so the label and the coordinates can never drift
// apart (21 Aug 2026).

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
List<PanchangElement> _elementsFrom(
  PanchangData? data,
  AppLocalizations l10n,
  Locale locale,
) {
  final fallback = PanchangStaticData.elements;
  if (data == null) return fallback;

  // Vedika returns these five as Latin transliteration and ignores every
  // language parameter (verified on production 2 Sep 2026), so they are
  // translated locally from the closed vocabulary — see
  // `core/astrology/astro_terms.dart`. Anything not in that table falls
  // through as the English Vedika sent, never as a guess.
  String? term(String? value, AstroTermKind kind) =>
      localizeAstroTerm(value, kind, locale);

  final tithiName = term(data.tithi?.name, AstroTermKind.tithi);
  final tithiPaksha = term(data.tithi?.paksha, AstroTermKind.paksha);
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
      term(data.nakshatra?.name, AstroTermKind.nakshatra) ??
          fallback[1].value,
      pada == null ? null : l10n.panchangPada(pada),
    ),
    PanchangElement(
      PanchangElementId.yoga,
      term(data.yoga?.name, AstroTermKind.yoga) ?? fallback[2].value,
      null,
    ),
    PanchangElement(
      PanchangElementId.karana,
      term(data.karana?.name, AstroTermKind.karana) ?? fallback[3].value,
      null,
    ),
    PanchangElement(
      PanchangElementId.vaar,
      term(data.vara?.name, AstroTermKind.vara) ?? fallback[4].value,
      null,
    ),
  ];
}

/// The muhurat cards that are backed by REAL data. Possibly just one.
/// Builds the muhurat grid from the day's real windows.
///
/// ALL FOUR CARDS ARE LIVE as of 2 Sep 2026 (client: "rahu kal and
/// yamaganda are basic things"). They come from
/// `POST /v2/astrology/inauspicious-period` via [inauspiciousPeriodsProvider]
/// — see [InauspiciousPeriods]'s doc comment for why that is a separate
/// call from `/v2/daily/muhurta`.
///
/// ## What changed, and why the old objection no longer applies
///
/// Three of these cards used to be dropped rather than faked. The reason
/// was sound: `/v2/daily/muhurta` does not return them at all, and the
/// `/v2/astrology/panchang` bundle's copies were CORRUPT — `end` before
/// `start` on all three (abhijit 00:53 -> 00:09, yamaganda 04:39 -> 03:16,
/// gulika 01:54 -> 00:31, measured 21 Aug 2026). A muhurat is a window
/// people plan around, so a wrong one is not a harmless placeholder, it is
/// bad advice.
///
/// The new endpoint returns all four correctly ordered — verified live for
/// 2 Sep 2026: abhijit 06:25:41->07:15:00, gulika 05:17:52->06:50:21,
/// rahu 06:50:21->08:22:50, yamaganda 02:12:54->03:45:23 — and its Rahu
/// Kaal matches `/v2/daily/muhurta`'s to the second, so the two sources
/// cannot disagree on screen.
///
/// **The corrupt-data guard is still in force.** Every range goes through
/// [RahuKaal.formattedRange], which returns null when `end` is not after
/// `start`. So if Vedika regresses, that card silently disappears rather
/// than rendering an impossible window. Keep it that way — an absent card
/// is recoverable, wrong advice is not.
///
/// Names and colour treatments still come from [PanchangStaticData.muhurats]
/// because those are UI copy, not data: Abhijit stays `shubh`, Rahu Kaal
/// and Yamaganda `ashubh`, Gulika `caution`. Only the TIMES are live.
List<Muhurat> _muhuratsFrom(InauspiciousPeriods? periods, AppLocalizations l10n) {
  if (periods == null) return const [];
  // Names come from l10n as of 2 Sep 2026, not `PanchangStaticData.muhurats`
  // — those were hardcoded English and therefore stayed English in Hindi,
  // Telugu, Tamil and Kannada, part of what the client reported as
  // *"many things showing in English only even when we select other
  // language"*.
  //
  // Brahma Muhurta is new here too, on client request. It is AUSPICIOUS
  // (`shubh`), like Abhijit — rendering the pre-dawn devotional window in
  // the warning tone the three inauspicious ones use would tell people to
  // avoid the best hour of their day.
  final windows = <(String, RahuKaal?, MuhuratKind)>[
    (l10n.muhuratBrahma, periods.brahmaMuhurta, MuhuratKind.shubh),
    (l10n.muhuratAbhijit, periods.abhijitMuhurta, MuhuratKind.shubh),
    (l10n.muhuratRahuKaal, periods.rahuKaal, MuhuratKind.ashubh),
    (l10n.muhuratYamaganda, periods.yamaganda, MuhuratKind.ashubh),
    (l10n.muhuratGulikaKaal, periods.gulikaKaal, MuhuratKind.caution),
  ];
  return [
    for (final (name, window, kind) in windows)
      // A window whose end is not after its start is dropped, not rendered
      // as an impossible range — Vedika does occasionally return one (a
      // negative `durationMinutes` was observed live on Abhijit).
      if (window?.formattedRange case final range?) Muhurat(name, range, kind),
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

    // WHERE THE USER IS, not where they were born — 21 Aug 2026.
    //
    // This used to read the saved birth profile's city. Sunrise, sunset and
    // Rahu Kaal are all derived from the observer's position, so a user born
    // in Jaipur and living in Erode was shown Jaipur's timings, and
    // travelling changed nothing. `panchangLocationProvider` resolves
    // manual override > device GPS > birth city > fallback; see
    // `panchang_location.dart`.
    final panchangLocation = ref.watch(panchangLocationProvider);
    final city = panchangLocation.city;
    final request = (
      date: _selectedDate,
      lat: city.latitude,
      lon: city.longitude,
      tz: city.timezoneId,
    );

    final panchangAsync = ref.watch(panchangDataProvider(request));
    // Same location as the panchang request — Rahu Kaal is sunrise/sunset
    // derived and therefore location-dependent (21 Aug 2026).
    // The muhurat GRID now comes from `inauspiciousPeriodsProvider`, which
    // is the only source that returns Yamaganda, Gulika and Abhijit (see
    // `_muhuratsFrom`). `/v2/daily/muhurta` is still fetched elsewhere for
    // choghadiya, but this screen no longer needs it.
    final periodsAsync = ref.watch(
      inauspiciousPeriodsProvider((
        lat: request.lat,
        lon: request.lon,
        tz: request.tz,
        // The SELECTED date, not today — stepping the date now moves the
        // muhurat windows with the header. See
        // `PanchangRepository.fetchInauspiciousPeriods`.
        date: _selectedDate,
      )),
    );

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
            // Name the city the coordinates above actually belong to.
            locationName: city.name,
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
                elements: _elementsFrom(data, l10n, locale),
                muhurats: _muhuratsFrom(periodsAsync.valueOrNull, l10n),
                sunTimes: data.sunTimes,
                guidance: data.guidance,
                festivalToday: data.festivalToday,
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
    required this.sunTimes,
    required this.guidance,
    required this.festivalToday,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final List<PanchangElement> elements;
  final List<Muhurat> muhurats;

  /// Real sun/moon times when the response carried them; null falls back to
  /// the static placeholder inside [_SunMoonCard].
  final PanchangSunTimes? sunTimes;

  /// Live guidance block — feeds the spiritual-advice card.
  final PanchangGuidance? guidance;

  /// A festival falling on the shown date, or null on the great majority of
  /// days that have none.
  final PanchangFestival? festivalToday;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _SunMoonCard(
          l10n: l10n,
          locale: locale,
          sunTimes: sunTimes,
        ),
        const SizedBox(height: 14),
        _ElementsCard(l10n: l10n, locale: locale, elements: elements),
        // Heading AND grid together — a "Muhurat today" heading with
        // nothing under it reads as a failed load rather than as "there is
        // nothing to show". Rahu Kaal is always available in practice, so
        // this hides only when the muhurta call itself failed.
        if (muhurats.isNotEmpty) ...[
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
        ],
        const SizedBox(height: 14),
        // Shown ONLY when a festival genuinely falls today (21 Aug 2026).
        // Was a hardcoded "Kamika Ekadashi" on every date — an Ekadashi
        // shown on a Navami, in the wrong month. The API's block is
        // "upcoming" festivals, so most days correctly have none and the
        // card is simply absent rather than inventing one.
        if (festivalToday != null) ...[
          _FestivalCard(
            l10n: l10n,
            locale: locale,
            festival: festivalToday!,
          ),
          const SizedBox(height: 14),
        ],
        _AdviceCard(
          l10n: l10n,
          locale: locale,
          guidance: guidance,
        ),
        const SizedBox(height: 14),
        _ViewAllMuhuratLink(l10n: l10n, locale: locale),
        const SizedBox(height: 14),
        // _OfflineBadge REMOVED 21 Aug 2026 — it read
        // "Available offline · Updated 6:00 AM", and neither half was true.
        //
        // There is no offline store: `PanchangRepository`'s cache is an
        // in-memory map that dies with the process (its own doc comment
        // says "a per-session optimization, not durable storage"), so a
        // cold start with no connection shows the error view, not cached
        // values. And "6:00 AM" was a hardcoded string, not a real fetch
        // time — it never moved.
        //
        // Telling a user their almanac is available offline is a promise
        // the app breaks the first time they open it on a train. Restore
        // this only alongside real persistence, with a genuine timestamp.

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
    required this.locationName,
    required this.onPrevious,
    required this.onNext,
  });

  /// The city this panchang was actually computed for.
  ///
  /// Was `PanchangStaticData.location` — the constant 'Hyderabad' — while
  /// the REQUEST underneath already used the user's saved birth city. A
  /// Jaipur user saw Jaipur's panchang labelled "Hyderabad" (21 Aug 2026).
  /// Falls back to the same Hyderabad default the coordinates fall back to,
  /// so the label and the data always name the same place.
  final String locationName;

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
                      locationName,
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
  const _SunMoonCard({
    required this.l10n,
    required this.locale,
    required this.sunTimes,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// REAL sunrise/sunset/moonrise/moonset for the requested location, when
  /// the response carried them (21 Aug 2026). Null falls back to the static
  /// placeholder, which is what every user used to see unconditionally:
  /// one fixed set of times for every city and every date.
  final PanchangSunTimes? sunTimes;

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
        sunTimes?.sunriseText ?? PanchangStaticData.sunrise,
      ),
      (
        Icons.wb_twilight_rounded,
        AppColors.tilePinkFg,
        l10n.panchangSunset,
        sunTimes?.sunsetText ?? PanchangStaticData.sunset,
      ),
      (
        Icons.nightlight_round,
        AppColors.tileBlueFg,
        l10n.panchangMoonrise,
        sunTimes?.moonriseText ?? PanchangStaticData.moonrise,
      ),
      (
        Icons.dark_mode_rounded,
        AppColors.tilePurpleFg,
        l10n.panchangMoonset,
        sunTimes?.moonsetText ?? PanchangStaticData.moonset,
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
          // Flexible, NOT Expanded — fixed 21 Aug 2026.
          //
          // `Expanded` forced this label to claim a full equal share of the
          // row even when it is as short as "Tithi", leaving the value side
          // too narrow: "Shukla Navami · 98% left" ellipsised down to
          // "Shukla N… 98% left". The tithi name is the single most
          // important value on this screen, and it was the one being cut.
          //
          // `Flexible` lets a short label take only the width it needs and
          // hands the slack to the value, while a long Indic label
          // ("తిథి"/"ಕರಣ" etc. plus longer translations) can still shrink
          // proportionally rather than overflowing.
          Flexible(
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
          // Expanded (not Flexible) so the value side receives ALL the width
          // the short label leaves behind, and right-aligned within it. An
          // earlier attempt used Flexible + a Spacer; Spacer is
          // Expanded(SizedBox()), so it swallowed the slack itself and made
          // the truncation worse ("Shukla N…" -> "Shukl…").
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
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
                  // NOT Flexible — the qualifier takes its intrinsic width
                  // and the NAME gets everything else.
                  //
                  // While both were Flexible they split the row evenly, so
                  // "Shukla Navami" was clipped to "Shukla N…" to make room
                  // for "98% left". The tithi name is the headline value on
                  // this screen; the percentage is a footnote. These
                  // qualifiers are short and bounded by construction —
                  // "98% left" and "Pada 2" — so giving them their natural
                  // width cannot starve the name.
                  Text(
                    element.tillLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      locale,
                      fontSize: 10.5,
                      color: AppColors.hint,
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

  /// However many muhurats are REAL — no longer a fixed four.
  ///
  /// This used to be indexed positionally (`muhurats[0]`..`[3]`), which
  /// only worked because the list was always padded to four with static
  /// placeholders. Now that unbacked windows are dropped rather than
  /// invented, the count varies and the layout has to follow.
  final List<Muhurat> muhurats;

  @override
  Widget build(BuildContext context) {
    // Laid out in rows of two, with a half-width trailing card when the
    // count is odd — rather than stretching a lone card across the full
    // width, which would read as a different kind of element.
    final rows = <Widget>[];
    for (var i = 0; i < muhurats.length; i += 2) {
      if (i != 0) rows.add(const SizedBox(height: 10));
      rows.add(
        Row(
          children: [
            Expanded(
              child: _MuhuratCard(
                muhurat: muhurats[i],
                l10n: l10n,
                locale: locale,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: i + 1 < muhurats.length
                  ? _MuhuratCard(
                      muhurat: muhurats[i + 1],
                      l10n: l10n,
                      locale: locale,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(children: rows);
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
  const _FestivalCard({
    required this.l10n,
    required this.locale,
    required this.festival,
  });

  /// The real festival falling today.
  final PanchangFestival festival;

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
          // Opens the festival's own details — wired 21 Aug 2026. The card
          // carried a "Details ›" affordance from the day it was built and
          // never had a destination, because there was no real festival
          // behind it to describe. Now that `upcoming_festivals` is parsed
          // there is: name, date, a written description, and Vedika's own
          // confidence rating with a source URL.
          onTap: () => _showFestivalDetails(context, l10n, locale, festival),
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
                        festival.name ?? '',
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
  const _AdviceCard({
    required this.l10n,
    required this.locale,
    required this.guidance,
  });

  /// Live reading of the day from `guidance.summary` — it names this day's
  /// actual tithi, nakshatra and yoga.
  ///
  /// WIRED 21 Aug 2026. The field was in every panchang response already;
  /// it simply was never parsed, so this card showed one fixed paragraph
  /// ("An auspicious day for charity...") on every date, including days the
  /// API itself rates "Challenging".
  final PanchangGuidance? guidance;

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
                  guidance?.summary ?? PanchangStaticData.advice,
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
        // Real destination since 21 Aug 2026 — this was `onTap: () {}` on a
        // link that looked and behaved like every working link in the app.
        // The full day/night choghadiya schedule was already being fetched
        // and parsed on this screen; only Rahu Kaal was ever rendered from
        // it. See MuhuratTimingsScreen.
        onTap: () => Navigator.of(
          context,
        ).push(fadeThroughRoute(const MuhuratTimingsScreen())),
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

// ignore: unused_element  — restore alongside real offline persistence
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

/// Festival details, as a modal sheet.
///
/// ADDED 21 Aug 2026 for the festival card's previously-inert "Details ›"
/// link. A sheet rather than a pushed screen: this is one short reading
/// about one day, and a full route for three paragraphs would be heavier
/// than the content.
///
/// Everything shown is Vedika's own — including [PanchangFestival.confidence]
/// and [PanchangFestival.source]. Festival dates are genuinely contested
/// (regional calendars disagree, and some depend on local sunrise), so where
/// the API says a date is "verified" and names where it got it, passing that
/// through is more honest than presenting every date with equal certainty.
Future<void> _showFestivalDetails(
  BuildContext context,
  AppLocalizations l10n,
  Locale locale,
  PanchangFestival festival,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                festival.name ?? '',
                style: AppFonts.heading(
                  locale,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              if (festival.date != null) ...[
                const SizedBox(height: 4),
                Text(
                  festival.date!,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    color: AppColors.hint,
                  ),
                ),
              ],
              if (festival.description != null &&
                  festival.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  festival.description!,
                  style: AppFonts.body(
                    locale,
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
              ],
              // REMOVED 2 Sep 2026 on client instruction: *"in festival
              // section it's showing dirkpanchang link please don't show
              // that link"*. Vedika populates `source` with a URL on
              // drikpanchang.com — a rival panchang site — so this rendered
              // a competitor's address inside our own festival card. The
              // field is still PARSED (`PanchangFestival.source`), just not
              // shown; it stays useful for debugging where a contested
              // festival date came from.
            ],
          ),
        ),
      );
    },
  );
}
