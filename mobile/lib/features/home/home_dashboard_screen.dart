import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/astrology/astro_terms.dart';
import '../../l10n/app_localizations.dart';
import '../ai/ai_astrologer_screen.dart';
import '../articles/article_detail_screen.dart';
import '../articles/articles_screen.dart';
import '../articles/articles_repository.dart';
import '../articles/articles_static_data.dart';
import '../horoscope/horoscope_detail_screen.dart';
import '../horoscope/horoscope_repository.dart';
import '../horoscope/horoscope_signs_screen.dart';
import '../horoscope/user_sign_provider.dart';
import '../horoscope/zodiac_sign.dart';
import '../kundli/kundli_input_screen.dart';
import '../matching/gun_milan_select_screen.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/notifications_static_data.dart';
import '../panchang/panchang_data.dart';
import '../panchang/panchang_location.dart';
import '../panchang/panchang_repository.dart';
import '../profile/birth_profile_repository.dart';
import '../reports/premium_reports_screen.dart';
import '../search/search_screen.dart';
import 'daily_quote_repository.dart';
import 'home_static_data.dart';

/// Fallback coordinates used until a saved [BirthProfile] is available (a
/// guest, or the profile still loading) — byte-identical to
/// `panchang_screen.dart`'s own fallback (Hyderabad) so Home's hero card and
/// the Panchang tab never visibly disagree about whose "today" they're
/// showing sample data for. Not shared code (that constant is private to its
/// own library) — kept in sync deliberately if either ever changes.
// Fallback coordinates now live in `panchang_location.dart` as
// `kFallbackPanchangCity` (21 Aug 2026).

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

/// Formats [date] as "Saturday, 12 July 2026" — same recipe as
/// `panchang_screen.dart`'s private `_formatPanchangDate` (duplicated, not
/// shared, since that helper is private to its own library; no `intl`
/// dependency needed for this one fixed format).
String _formatHomeDate(DateTime date) {
  final weekday = _weekdayNames[date.weekday - 1];
  final month = _monthNames[date.month - 1];
  return '$weekday, ${date.day} $month ${date.year}';
}

/// Today, truncated to the calendar day (no time component) — this feeds
/// `panchangDataProvider.family`'s request record, and records compare
/// structurally, so a `DateTime.now()` carrying milliseconds would produce a
/// different cache key (and a new billed Vedika call) on every rebuild.
/// Same rationale as `panchang_screen.dart`'s `_PanchangScreenState._today`.
DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Picks the next upcoming AUSPICIOUS window for the Muhurat tile.
///
/// ADDED 24 Aug 2026, replacing a genuine bug: the tile was filled from
/// `muhurta.rahuKaal.formattedRange` — Rahu Kaal is the one INAUSPICIOUS
/// window Vedic tradition says to avoid, so a "Muhurat" (auspicious-time)
/// label pointed straight at it, telling a user to go ahead and act during
/// the one window they should not. Same defect class already fixed once on
/// this screen for the Direction tile (see `_glanceTilesFrom`'s comment on
/// `disha_shool` safe-vs-avoid) — a screen that surfaces both a "safe" and
/// an "avoid" value under the same endpoint must never let the avoid value
/// leak out under the safe value's label. Rahu Kaal itself is legitimate and
/// stays exactly where it belongs: the Panchang tab's own Rahu Kaal card.
///
/// [schedule] is `MuhurtaData.choghadiya` — the SAME `/v2/daily/muhurta`
/// call `rahuKaal` already came from, so this costs no extra request. Each
/// `ChoghadiyaPeriod.quality` of `good` is a genuinely auspicious window;
/// `bad`/`neutral`/`unknown` are not, and must never be shown here.
///
/// Walks the day list then the night list (their natural chronological
/// order) and returns the first `good` window whose start time is still in
/// the future. If every `good` window today has already started, falls back
/// to the FIRST `good` window of the day so the tile still shows something
/// meaningful rather than nothing. Returns `null` — the tile is omitted
/// entirely, see `_glanceTilesFrom` — only when no `good` window exists in
/// the schedule at all; there is no placeholder value to fall back to,
/// because a wrong or made-up muhurat is worse than no tile.
String? _nextGoodMuhuratRange(ChoghadiyaSchedule? schedule) {
  if (schedule == null) return null;
  final goodPeriods = [
    for (final period in [...schedule.day, ...schedule.night])
      if (period.quality == ChoghadiyaQuality.good) period,
  ];
  if (goodPeriods.isEmpty) return null;

  final now = DateTime.now();
  for (final period in goodPeriods) {
    final start = period.start?.toLocal();
    final range = period.formattedRange;
    if (start != null && range != null && start.isAfter(now)) {
      return range;
    }
  }
  // Nothing left today — first good window of the day is still a genuinely
  // auspicious answer, just not an upcoming one.
  for (final period in goodPeriods) {
    final range = period.formattedRange;
    if (range != null) return range;
  }
  return null;
}

/// Builds the "Today at a glance" tiles, swapping in a live value wherever
/// one exists and OMITTING a tile entirely when the live value is the only
/// honest one and it isn't available (Lucky Number, Muhurat) — see
/// [HomeStaticData.glanceTiles]'s doc comment.
///
/// REWRITTEN 21 Aug 2026, then again 24 Aug 2026. The previous version wired
/// only Muhurat (and wired it wrong — see [_nextGoodMuhuratRange]) and said
/// the other five "have NO Vedika equivalent at all — verified", so they
/// were to "stay on [HomeStaticData] permanently". That verification was
/// done against `/v2/astrology/panchang/today` and a parameter-less
/// `/v2/daily/muhurta` — the two narrowest routes in the contract. Three of
/// the six are in the panchang BUNDLE this app already fetches:
///
///  - Lucky Color   <- `vaara.interpretation.luckyColor`
///  - Today's Planet<- `vaara.lord` (the weekday's ruling graha)
///  - Direction     <- `disha_shool.safeDirections`
///
/// so they cost nothing extra, and still fall back to their
/// [HomeStaticData] placeholder when unavailable — those placeholders are
/// plausible defaults, not wrong advice, so degrading to them silently is
/// fine. Lucky Number (`luckyNumber`, from the user's own daily horoscope —
/// see `HomeDashboardScreen.build`) and Muhurat do NOT get that treatment:
/// their old placeholders were either the same value for every user forever
/// (Lucky Number) or actively wrong (Muhurat's Rahu Kaal), so both are
/// omitted from the grid rather than shown as a guess. Moon Phase is gone
/// outright — `/v2/daily/moon-phase` exists in the contract but is a
/// separate BILLED call, not added unasked (see [HomeStaticData]'s doc).
List<GlanceTile> _glanceTilesFrom({
  required MuhurtaData? muhurta,
  required PanchangData? panchang,
  required int? luckyNumber,
  required InauspiciousPeriods? periods,
  required Locale locale,
}) {
  final muhuratRange = _nextGoodMuhuratRange(muhurta?.choghadiya);
  // Rahu Kaal — the day's inauspicious window, from the same call that
  // fills the Panchang tab's muhurat grid. Null-safe by construction:
  // `formattedRange` returns null when Vedika sends `end` before `start`,
  // so a corrupt window drops the tile rather than rendering nonsense.
  final rahuKaalRange = periods?.rahuKaal?.formattedRange;
  final luckyColor = localizeAstroTerm(
    panchang?.vara?.luckyColor,
    AstroTermKind.colour,
    locale,
  );
  // The weekday lord is a graha name Vedika sends in English ("Mercury").
  final planet = localizeAstroTerm(
    panchang?.vara?.lord,
    AstroTermKind.graha,
    locale,
  );
  // "Direction" on this tile means the AUSPICIOUS way to travel, so it is
  // the first safe direction — NOT `disha_shool.direction`, which is the
  // direction to avoid. Rendering the inauspicious one under a bare
  // "Direction" label would invert the advice.
  final safe = panchang?.dishaShool?.safeDirections;
  final direction = (safe != null && safe.isNotEmpty)
      ? localizeAstroTerm(safe.first, AstroTermKind.direction, locale)
      : null;

  final staticById = {
    for (final tile in HomeStaticData.glanceTiles) tile.id: tile,
  };

  return [
    if (luckyNumber != null)
      GlanceTile(GlanceTileId.luckyNumber, '$luckyNumber'),
    luckyColor != null
        ? GlanceTile(GlanceTileId.luckyColor, luckyColor)
        : staticById[GlanceTileId.luckyColor]!,
    direction != null
        ? GlanceTile(GlanceTileId.direction, direction)
        : staticById[GlanceTileId.direction]!,
    planet != null
        ? GlanceTile(GlanceTileId.todaysPlanet, planet)
        : staticById[GlanceTileId.todaysPlanet]!,
    if (muhuratRange != null) GlanceTile(GlanceTileId.muhurat, muhuratRange),
    // The five muhurat windows, in the order a day runs: the pre-dawn
    // Brahma Muhurta, midday Abhijit, then the three to avoid. Each is
    // dropped individually when its window is missing or malformed, so a
    // partial response shrinks the grid instead of emptying it.
    if (periods?.brahmaMuhurta?.formattedRange case final range?)
      GlanceTile(GlanceTileId.brahmaMuhurta, range),
    if (periods?.abhijitMuhurta?.formattedRange case final range?)
      GlanceTile(GlanceTileId.abhijit, range),
    if (rahuKaalRange != null)
      GlanceTile(GlanceTileId.rahuKaal, rahuKaalRange),
    if (periods?.yamaganda?.formattedRange case final range?)
      GlanceTile(GlanceTileId.yamaganda, range),
    if (periods?.gulikaKaal?.formattedRange case final range?)
      GlanceTile(GlanceTileId.gulikaKaal, range),
  ];
}

/// Home Dashboard — the app's real post-onboarding home screen, per the
/// approved Figma "B1 · Home Dashboard" (node 10:3) concept.
///
/// Reached once a [BirthProfile] exists (see `RootGate` and
/// `post_sign_in_route.dart`) — replaces the temporary
/// `HomePlaceholderScreen`.
///
/// **What's LIVE, sourced from the same `panchangDataProvider` /
/// `muhurtaDataProvider` the Panchang tab uses (see
/// `panchang_repository.dart`) — deliberately reused rather than a second
/// repository/HTTP call, so Home and the Panchang tab share one cached,
/// one-billed fetch per day:**
///  - the Panchang hero card's Tithi, Nakshatra, Yoga and Karana, and its
///    date line (always today's real date, not a frozen mock date);
///  - the "Today at a glance" grid's Lucky Color, Direction and Today's
///    Planet (from the panchang bundle), and Muhurat — the next upcoming
///    AUSPICIOUS (`good`) choghadiya window, from the same muhurta call
///    that already fetches Rahu Kaal (see [_nextGoodMuhuratRange]) — and
///    Lucky Number, from the signed-in user's own daily horoscope
///    (`dailyHoroscopeProvider`, keyed by `userZodiacSignProvider`'s
///    rashi — the SAME provider the horoscope teaser below already
///    watches, so this adds no new call the app wasn't already capable of
///    making);
///  - the remedy line of the remedy card — the first entry of
///    `disha_shool.remedies`, from the same panchang bundle fetch, when
///    Vedika supplies one.
///
/// Lucky Number, Muhurat and the remedy line have NO placeholder to
/// degrade to on failure — see [HomeStaticData]'s doc comment for why —
/// so each is simply omitted from the screen while loading, on a fetch
/// error, or when the live value doesn't exist. Lucky Color, Direction and
/// Today's Planet keep their [HomeStaticData] placeholder in that
/// situation, since those placeholders are plausible defaults rather than
/// wrong advice.
///
/// **What's still STATIC PLACEHOLDER DATA from [HomeStaticData], and why:**
/// sunrise/sunset on the hero card, the Lucky Color/Direction/Today's
/// Planet glance tiles' fallback values — no Vedika endpoint this app calls
/// returns anything better for them (verified against `panchang_data.dart`'s
/// response models, same limitation documented on `panchang_screen.dart`).
/// The festival strip, horoscope teaser body/rating, articles, AI teaser,
/// reports and daily quote are all still 100% static; see
/// [HomeStaticData]'s doc comment.
///
/// Every live field degrades to its static counterpart, or is omitted —
/// silently, with NO error UI — while loading, on a fetch error, or before a
/// birth profile resolves: Home is the app's landing screen and must never
/// show a full-screen failure over one card's data. A small sandbox banner
/// (matching the Panchang tab's wording/styling) appears instead whenever
/// [VedikaConfig.isSandbox] is true, since the sandbox always returns one
/// fixed sample location rather than the user's own.
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

    // Same location-resolution pattern as `panchang_screen.dart`: prefer
    // the signed-in user's saved birth profile, fall back to a fixed
    // default (documented above) while it's still loading or doesn't exist
    // (guest browsing) — `valueOrNull` degrades loading/error to `null`
    // exactly as needed. Home has no date stepper, so the date is always
    // TODAY.
    // WHERE THE USER IS, not their birth city — 21 Aug 2026. Same change and
    // same reasoning as `panchang_screen.dart`; both must agree, since Home's
    // hero card and the Panchang tab show the same day's almanac.
    final city = ref.watch(panchangLocationProvider).city;
    final panchangRequest = (
      date: _today(),
      lat: city.latitude,
      lon: city.longitude,
      tz: city.timezoneId,
    );
    // `.valueOrNull` IS the graceful-degradation mechanism here: loading,
    // an error, and "not fetched yet" all collapse to `null`, and every
    // widget below that takes this value falls back to
    // [HomeStaticData] when it's `null` — Home never shows a spinner or an
    // error card over live data the way the Panchang tab does.
    final livePanchang = ref
        .watch(panchangDataProvider(panchangRequest))
        .valueOrNull;
    // Muhurta takes the SAME location as the panchang request — Rahu Kaal
    // is derived from sunrise/sunset, so it varies by place (21 Aug 2026).
    final liveMuhurta = ref
        .watch(
          muhurtaDataProvider((
            lat: panchangRequest.lat,
            lon: panchangRequest.lon,
            tz: panchangRequest.tz,
          )),
        )
        .valueOrNull;
    // Rahu Kaal / Yamaganda etc. — same location as the panchang request,
    // for the same reason muhurta is: these windows derive from
    // sunrise/sunset and so vary by place.
    final livePeriods = ref
        .watch(
          inauspiciousPeriodsProvider((
            lat: panchangRequest.lat,
            lon: panchangRequest.lon,
            tz: panchangRequest.tz,
            // Home always shows today; only Panchang has a date stepper.
            //
            // TRUNCATED TO THE CALENDAR DAY on purpose. A raw
            // `DateTime.now()` here would be a different value on every
            // rebuild, so the provider FAMILY KEY would change every frame —
            // a new provider instance and a fresh billed fetch each time,
            // not just a cache miss.
            date: _todayDate(),
          )),
        )
        .valueOrNull;

    // Lucky Number — ADDED 24 Aug 2026, replacing a constant "3, 9" shown to
    // every user on every day. Reuses `userZodiacSignProvider` (the same
    // provider `_HoroscopeSection` below already watches for the horoscope
    // teaser's sign) and `dailyHoroscopeProvider` (the same provider/cache
    // `horoscope_detail_screen.dart` uses) — no new network call path.
    // `.valueOrNull` on both collapses "no kundli yet", "still loading" and
    // "fetch failed" to `null` alike, which is exactly what
    // `_glanceTilesFrom` needs to omit the tile silently.
    final userSign = ref.watch(userZodiacSignProvider);
    final liveDailyHoroscope = userSign == null
        ? null
        : ref.watch(dailyHoroscopeProvider(userSign.id)).valueOrNull;
    final luckyNumber = liveDailyHoroscope?.luckyNumber;

    // Remedy — the first entry of the SAME panchang bundle fetch above
    // (`disha_shool.remedies`), when Vedika supplies one. No placeholder:
    // an empty/missing list means the remedy card is omitted below rather
    // than showing `HomeStaticData.remedy`'s old fixed sentence.
    final liveRemedies = livePanchang?.dishaShool?.remedies;
    final remedyText = (liveRemedies != null && liveRemedies.isNotEmpty)
        ? liveRemedies.first
        : null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, isCompact ? 24 : 44, 20, 8),
          children: [
            _TopBar(l10n: l10n, locale: locale, userName: userName),
            const SizedBox(height: 14),
            // Sandbox always returns the same fixed sample location
            // regardless of the coordinates sent to it (see
            // VedikaConfig.isSandbox's doc comment) — same banner
            // wording/styling as `panchang_screen.dart`'s
            // `_SandboxDataBanner`, flagged here too since the hero card
            // below can show the same sandbox-sourced values.
            if (VedikaConfig.isSandbox) ...[
              _SandboxDataBanner(l10n: l10n, locale: locale),
              const SizedBox(height: 14),
            ],
            _PanchangHeroCard(l10n: l10n, locale: locale, live: livePanchang),
            const SizedBox(height: 14),
            _GlanceSection(
              l10n: l10n,
              locale: locale,
              muhurta: liveMuhurta,
              panchang: livePanchang,
              luckyNumber: luckyNumber,
              periods: livePeriods,
            ),
            const SizedBox(height: 14),
            // _RemedyCard REMOVED entirely (not just its mantra half) when
            // there is no live remedy — see the field's doc above and
            // [HomeStaticData]'s class doc. An empty gap here would be
            // worse than the plain absence of a spacer, so the spacing is
            // conditional too, same pattern as `_FestivalCard` below.
            if (remedyText != null) ...[
              _RemedyCard(l10n: l10n, locale: locale, remedy: remedyText),
              const SizedBox(height: 14),
            ],
            // _FestivalCard REMOVED 21 Aug 2026 — it was hardcoded to
            // "Sawan Somvar — tomorrow". On 21 Aug 2026 the Panchang screen
            // (live) read "Bhadrapada Masa": Sawan was over, and the day was
            // a Friday, not Somvar. A festival card that names the wrong
            // festival on the wrong day is worse than no card, and there is
            // no festival field in any endpoint this app calls. Restore it
            // when a real source exists — the widget itself is kept below.

            _ExploreSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _HoroscopeSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _WisdomSection(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            _ContinueAiCard(l10n: l10n, locale: locale),
            const SizedBox(height: 14),
            // _RecentReportsSection REMOVED 21 Aug 2026 — it listed
            // "Career Report · Viewed 2 days ago" and "Marriage Report ·
            // New" on accounts that had opened neither. Same defect class as
            // the "Last: ₹1,999" line already removed from Profile: invented
            // activity the user cannot tell apart from their own. Nothing
            // tracks report views yet. Restore when it does.

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
                    Icon(
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
        _TopBarIconButton(
          emoji: '🔍',
          locale: locale,
          onTap: () => Navigator.of(
            context,
          ).push(fadeThroughRoute(const SearchScreen())),
        ),
        const SizedBox(width: 8),
        _TopBarIconButton(
          emoji: '🔔',
          locale: locale,
          onTap: () => Navigator.of(
            context,
          ).push(fadeThroughRoute(const NotificationsScreen())),
          // Reflects the static seed's unread count only — there's no
          // shared state/provider with NotificationsScreen's local
          // read-state yet (same limitation as the Articles bookmark
          // toggles being screen-local). NEVER hardcode this number.
          showBadge: NotificationsStaticData.unreadCount > 0,
        ),
      ],
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.emoji,
    required this.locale,
    required this.onTap,
    this.showBadge = false,
  });

  final String emoji;
  final Locale locale;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.surface,
            shape: CircleBorder(side: BorderSide(color: AppColors.cardBorder)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: Text(
                    emoji,
                    style: AppFonts.body(locale, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.saffron,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small, non-intrusive strip flagging that the panchang values below came
/// from Vedika's sandbox — which ignores the coordinates it's sent and
/// always returns the same fixed sample location (see
/// [VedikaConfig.isSandbox]). Byte-identical recipe (and the same l10n
/// string) as `panchang_screen.dart`'s `_SandboxDataBanner`, duplicated
/// rather than shared since that widget is private to its own library.
class _SandboxDataBanner extends StatelessWidget {
  const _SandboxDataBanner({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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

/// Full-width gradient card summarising today's panchang.
class _PanchangHeroCard extends StatelessWidget {
  const _PanchangHeroCard({
    required this.l10n,
    required this.locale,
    required this.live,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// Live panchang for today, from the shared `panchangDataProvider` — see
  /// [HomeDashboardScreen]'s class doc for what's live vs static here.
  /// `null` while loading, on error, or before a birth profile resolves.
  final PanchangData? live;

  @override
  Widget build(BuildContext context) {
    // NO FABRICATED ASTROLOGY — CHANGED 21 Aug 2026.
    //
    // These four used to fall back to `HomeStaticData.panchang`, whose
    // values are a designer's sample: 'Shukla Ashtami' / 'Rohini' /
    // 'Siddhi' / 'Bava'. `live` is null while the request is in flight, so
    // on every cold start Home stated a specific, confident, WRONG tithi
    // for a second or two before the real one replaced it. On 21 Aug 2026
    // the real values were Navami / Anuradha / Indra / Balava — nothing in
    // common. It is also what made this look like a permanently broken
    // binding when it was only ever the loading state.
    //
    // A wrong tithi is not a cosmetic placeholder in a panchang app: it is
    // the product, and a user who glances at it during load and closes the
    // app has simply been told the wrong thing. An em dash says "not yet"
    // and can never be mistaken for a reading.
    //
    // Applies to the error path too, deliberately. If the fetch fails we
    // still must not invent a tithi — Home stays quiet and the Panchang tab
    // (which does surface a real error card) is where the user finds out.
    const pending = '—';
    // Still needed for sunrise/sunset below: those two have NO field in any
    // endpoint this app calls, so they remain documented placeholders rather
    // than a loading state.
    final fallback = HomeStaticData.panchang;
    // Translated locally from the closed vocabulary, exactly as the Panchang
    // tab does — Vedika sends these in Latin transliteration whatever
    // language is requested. See `core/astrology/astro_terms.dart`.
    String? term(String? value, AstroTermKind kind) =>
        localizeAstroTerm(value, kind, locale);

    final tithiName = term(live?.tithi?.name, AstroTermKind.tithi);
    final tithiPaksha = term(live?.tithi?.paksha, AstroTermKind.paksha);
    final tithi = tithiName == null
        ? pending
        : (tithiPaksha == null ? tithiName : '$tithiPaksha $tithiName');
    final nakshatra =
        term(live?.nakshatra?.name, AstroTermKind.nakshatra) ?? pending;
    final yoga = term(live?.yoga?.name, AstroTermKind.yoga) ?? pending;
    final karana = term(live?.karana?.name, AstroTermKind.karana) ?? pending;

    // The date line is always today's real date — unlike the other fields
    // above, this one never falls back to the frozen mock date in
    // [HomeStaticData], live or not.
    final date = _formatHomeDate(DateTime.now());

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Opens the Panchang tab — wired 21 Aug 2026. The whole hero
          // card is the tap target, which is what the "Full Panchang ›"
          // affordance in its footer has always implied; both were inert.
          //
          // Goes through AppBottomNav.openTab rather than pushing
          // PanchangScreen directly: Panchang is a tab ROOT, entered with a
          // zero-duration pushReplacement. A plain push would stack a second
          // Panchang over Home and grow the back stack on every tap.
          onTap: () => AppBottomNav.openTab(context, AppTab.panchang),
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
                            date,
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
                  tithi,
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
                        value: nakshatra,
                        locale: locale,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PanchangStatChip(
                        label: l10n.yoga,
                        value: yoga,
                        locale: locale,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PanchangStatChip(
                        label: l10n.karana,
                        value: karana,
                        locale: locale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // The TIMES side flexes; the link keeps its natural
                    // width — fixed 21 Aug 2026.
                    //
                    // This row was [times…, Spacer(), Flexible(link)].
                    // `Spacer` is `Expanded`, so it took every spare pixel
                    // and the link was left with only the remainder, which
                    // ellipsised "Full Panchang" down to "Full Pa…". A
                    // truncated call-to-action is worse than a truncated
                    // value: the user cannot tell what tapping it does.
                    // Now the times shrink first (they are also the less
                    // important half of the row) and the link is always
                    // whole.
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.wb_sunny_outlined,
                            size: 14,
                            color: AppColors.creamTextSoft,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              // REAL sunrise/sunset since 21 Aug 2026 —
                              // `include=sunrise` on the panchang bundle
                              // returns them (see PanchangSunTimes). The old
                              // comment here said no endpoint provided them,
                              // which was true only of the `/today` route
                              // this app used to call. The Panchang tab was
                              // wired first; Home was still showing the
                              // fixed 05:52, so the two screens disagreed
                              // about the same sunrise.
                              live?.sunTimes?.sunriseText ?? fallback.sunrise,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                locale,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.creamTextSoft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.nightlight_round,
                            size: 14,
                            color: AppColors.creamTextSoft,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              live?.sunTimes?.sunsetText ?? fallback.sunset,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                locale,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.creamTextSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.fullPanchang,
                          maxLines: 1,
                          style: AppFonts.body(
                            locale,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    case GlanceTileId.muhurat:
      return _GlanceTileMeta(l10n.muhurat, '⏰', AppColors.genderSelectedBg);
    // Rahu Kaal is the INAUSPICIOUS window, so it gets the ashubh tint —
    // never the same treatment as Muhurat above, which is the auspicious
    // one. Rendering them alike would invert the advice, the same trap the
    // Direction tile documents.
    case GlanceTileId.rahuKaal:
      return _GlanceTileMeta(l10n.muhuratRahuKaal, '⚠️', AppColors.ashubhBg);
    // Yamaganda is inauspicious like Rahu Kaal; Gulika is the milder
    // "caution" one, matching the Panchang grid's own three-way split.
    case GlanceTileId.yamaganda:
      return _GlanceTileMeta(l10n.muhuratYamaganda, '⚠️', AppColors.ashubhBg);
    case GlanceTileId.gulikaKaal:
      return _GlanceTileMeta(l10n.muhuratGulikaKaal, '🌗', AppColors.mantraBg);
    // AUSPICIOUS — same calm treatment as Muhurat above, deliberately NOT
    // the ashubh tint the three windows to avoid carry.
    case GlanceTileId.abhijit:
      return _GlanceTileMeta(
        l10n.muhuratAbhijit,
        '☀️',
        AppColors.genderSelectedBg,
      );
    case GlanceTileId.brahmaMuhurta:
      return _GlanceTileMeta(l10n.muhuratBrahma, '🪔', AppColors.geoChipBg);
  }
}

/// "Today at a glance" — a 3-per-row grid of quick-fact tiles.
///
/// REWRITTEN 24 Aug 2026 from two fixed `Row`s of exactly 3 tiles (`tiles[0
/// .. 2]`, `tiles[3 .. 5]`) to a `Wrap`, because the tile count is no longer
/// always 6: Lucky Number and Muhurat are each omitted outright when no live
/// value exists (see [_glanceTilesFrom] and [HomeStaticData.glanceTiles]),
/// so this section can now render 3, 4 or 5 tiles. `tiles.sublist(3, 6)`
/// would throw on a 3- or 4-tile list; even patched to tolerate a short
/// list, filling a partial row with `Expanded` would stretch its one or two
/// tiles to the full row width instead of matching their neighbours' size.
/// `Wrap` avoids both: every tile gets the SAME explicit width (one third of
/// the available row width, computed via `LayoutBuilder`), and a short last
/// row is simply left-aligned rather than stretched.
class _GlanceSection extends StatelessWidget {
  const _GlanceSection({
    required this.l10n,
    required this.locale,
    required this.muhurta,
    required this.panchang,
    required this.luckyNumber,
    required this.periods,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// Today's live muhurta — the Muhurat tile's next-good-choghadiya range.
  /// See [_nextGoodMuhuratRange].
  final MuhurtaData? muhurta;

  /// Today's live panchang — Lucky Color, Today's Planet, Direction and the
  /// remedy line all come from here (21 Aug 2026). See [_glanceTilesFrom].
  final PanchangData? panchang;

  /// The signed-in user's own Lucky Number for today, or `null` to omit the
  /// tile — see `HomeDashboardScreen.build`.
  final int? luckyNumber;

  /// The day's Rahu Kaal / Yamaganda / Gulika / Abhijit windows. Only Rahu
  /// Kaal is rendered in this grid; the full set fills the Panchang tab's
  /// muhurat cards.
  final InauspiciousPeriods? periods;

  static const int _columns = 3;
  static const double _spacing = 10;

  @override
  Widget build(BuildContext context) {
    final tiles = _glanceTilesFrom(
      muhurta: muhurta,
      panchang: panchang,
      luckyNumber: luckyNumber,
      periods: periods,
      locale: locale,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.todayAtAGlance, locale: locale),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth =
                (constraints.maxWidth - _spacing * (_columns - 1)) /
                _columns;
            return Wrap(
              spacing: _spacing,
              runSpacing: _spacing,
              children: [
                for (final tile in tiles)
                  SizedBox(
                    width: tileWidth,
                    child: _GlanceTileCard(
                      tile: tile,
                      l10n: l10n,
                      locale: locale,
                    ),
                  ),
              ],
            );
          },
        ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glanceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
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

/// Today's remedy card.
///
/// RENAMED from `_RemedyMantraCard` and shrunk to remedy-only 24 Aug 2026.
/// The mantra half is REMOVED outright, not just its content: there is no
/// live source for it at all (no endpoint this app calls returns one), so
/// leaving the row in place would mean showing `HomeStaticData.mantra`'s
/// fixed Devanagari text to every user forever — the exact defect already
/// fixed for the remedy line itself. The `todaysMantra` l10n key stays valid
/// (removing it would break `horoscope_detail_screen.dart`'s own, separate
/// mantra card, which is out of this fix's scope) — it is simply unused
/// here now. With only one row left there is nothing to retitle: this row
/// already carries its own `l10n.todaysRemedy` label.
///
/// [remedy] is always non-null and non-empty here — the caller
/// (`HomeDashboardScreen.build`) omits this whole card, spacing included,
/// rather than constructing it with nothing to show.
class _RemedyCard extends StatelessWidget {
  const _RemedyCard({
    required this.l10n,
    required this.locale,
    required this.remedy,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String remedy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mantraBorder),
      ),
      child: _LabeledIconRow(
        // 🌺 not 🪷 — see the note in lib/features/ai/ai_topics.dart:
        // the lotus is Unicode 14 and renders as tofu on Android 12.
        emoji: '🌺',
        label: l10n.todaysRemedy,
        body: Text(
          remedy,
          style: AppFonts.body(locale, fontSize: 12, color: AppColors.mantraBody),
        ),
        locale: locale,
      ),
    );
  }
}

/// Emoji + uppercase label + body, stacked in a row — used by [_RemedyCard].
class _LabeledIconRow extends StatelessWidget {
  const _LabeledIconRow({
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
// ignore: unused_element  — kept for when a real festival source exists
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

/// Presentation metadata for one Explore shortcut tile.
class _ExploreTileMeta {
  const _ExploreTileMeta(this.label, this.emoji, this.background, {this.onTap});

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
      _ExploreTileMeta(
        l10n.navMatch,
        '💍',
        AppColors.tilePinkBg,
        // Same fadeThroughRoute push pattern as the Kundli tile above — this
        // screen has no bottom nav of its own in the Figma design, so it's
        // pushed as a destination rather than switched to as a tab root.
        onTap: () => Navigator.of(
          context,
        ).push<void>(fadeThroughRoute(const GunMilanSelectScreen())),
      ),
      _ExploreTileMeta(
        l10n.navReports,
        '📜',
        AppColors.tileBlueBg,
        // Same fadeThroughRoute push pattern as the Kundli/Match tiles
        // above — Premium Reports has no bottom nav of its own in the
        // Figma design, so it's pushed as a destination rather than
        // switched to as a tab root.
        onTap: () => _openPremiumReports(context),
      ),
      _ExploreTileMeta(
        l10n.navAskAi,
        '🔮',
        AppColors.tilePurpleBg,
        // Same fadeThroughRoute push pattern as the Kundli/Match tiles
        // above.
        onTap: () => _openAiAstrologer(context),
      ),
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
              color: AppColors.surface,
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

/// Opens "B4 · Horoscope Detail" for the user's OWN sign.
///
/// [sign] is the rashi derived from their birth chart
/// (`userZodiacSignProvider`). It used to be resolved from the constant
/// `HoroscopeStaticData.userSignId` — i.e. Leo, for everybody.
///
/// When it is still null (chart loading, guest, or fetch failed) this opens
/// the all-signs grid instead of guessing: sending someone to a stranger's
/// horoscope is exactly the defect being fixed.
void _openHoroscopeDetail(BuildContext context, ZodiacSign? sign) {
  if (sign == null) {
    _openAllSigns(context);
    return;
  }
  Navigator.of(
    context,
  ).push<void>(fadeThroughRoute(HoroscopeDetailScreen(sign: sign)));
}

/// "Today's Horoscope" teaser card.
///
/// A ConsumerWidget since 21 Aug 2026 so the SIGN can come from the user's
/// own chart (`userZodiacSignProvider`) instead of the hardcoded
/// "Simha · Leo" every user saw. The prediction body and rating below are
/// still [HomeStaticData] — the daily horoscope endpoint is not wired into
/// this teaser yet — but the sign it is attributed to is now real.
class _HoroscopeSection extends ConsumerWidget {
  const _HoroscopeSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horoscope = HomeStaticData.horoscope;
    final userSign = ref.watch(userZodiacSignProvider);
    // Em dash, never a default sign — see userZodiacSignProvider's doc.
    final signLabel = userSign == null
        ? '—'
        : '${userSign.sanskritName} · ${userSign.englishName}';
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
              onTap: () => _openHoroscopeDetail(context, userSign),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.navyGradient,
                      ),
                      // The user's OWN glyph — was hardcoded '♌' (Leo)
                      // alongside the hardcoded "Simha · Leo" label. Fixing
                      // only the label would have left the card showing a
                      // Leo glyph beside "Dhanu · Sagittarius", which reads
                      // as a rendering bug rather than the data bug it is.
                      //
                      // Uses AppFonts.zodiac (the bundled ZodiacGlyphs.ttf),
                      // not AppFonts.body: Android renders ♈–♓ from its
                      // COLOUR emoji font, which ignores `color:` — the old
                      // `AppColors.gold` here was silently doing nothing.
                      // See the ICON RULE in projects/CLAUDE.md.
                      child: Text(
                        userSign?.glyph ?? '·',
                        style: AppFonts.zodiac(
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
                                  signLabel,
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
                                    Icon(
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

/// Resolves the [Article] a Home "Wisdom for you" [ArticleTeaser] links to,
/// from the real Articles catalogue (see "D1 · Articles", Figma node 25:3).
/// Falls back to the featured article rather than throwing if the id is
/// ever missing — see [ArticleTeaser.articleId]'s doc comment for why the
/// two surfaces' copy doesn't always match exactly yet.
Article _resolveArticle(String articleId, List<Article> catalogue) {
  return catalogue.firstWhere(
    (article) => article.id == articleId,
    orElse: () => catalogue.isNotEmpty
        ? catalogue.first
        : ArticlesStaticData.featured,
  );
}

/// Opens the full Articles list (see "D1 · Articles", Figma node 25:3).
void _openArticles(BuildContext context) {
  Navigator.of(context).push<void>(fadeThroughRoute(const ArticlesScreen()));
}

/// Opens "D2 · Article Detail" for the [Article] linked to [teaser].
///
/// Takes a [WidgetRef] so it resolves against the LIVE catalogue (10 Sep
/// 2026). Resolving against the bundled list would open a stale copy of an
/// article the editor has since rewritten — or fail to find a CMS-only one
/// and silently open something else.
void _openArticleDetail(
  BuildContext context,
  WidgetRef ref,
  ArticleTeaser teaser,
) {
  final catalogue =
      ref.read(articlesProvider).valueOrNull ?? ArticlesStaticData.all;
  final article = _resolveArticle(teaser.articleId, catalogue);
  Navigator.of(
    context,
  ).push<void>(fadeThroughRoute(ArticleDetailScreen(article: article)));
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
          onAction: () => _openArticles(context),
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
                headerGradient: LinearGradient(
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

class _ArticleCard extends ConsumerWidget {
  const _ArticleCard({
    required this.article,
    required this.locale,
    required this.headerGradient,
  });

  final ArticleTeaser article;
  final Locale locale;
  final Gradient headerGradient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: article.title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openArticleDetail(context, ref, article),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                  child: Icon(
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

/// Opens the AI Astrologer chat (see "C3 · AI Astrologer", Figma node 21:2).
///
/// Shared by both Home entry points ([_ExploreSection]'s "Ask AI" tile and
/// [_ContinueAiCard]'s "Continue" action) and the bottom nav's Ask AI tab
/// (`app_bottom_nav.dart`). Like the Kundli/Match tiles above, this screen
/// has no bottom nav of its own in the Figma design, so it's pushed as a
/// destination rather than switched to as a tab root.
void _openAiAstrologer(BuildContext context) {
  Navigator.of(
    context,
  ).push<void>(fadeThroughRoute(const AiAstrologerScreen()));
}

/// Opens the Premium Reports screen (see "C4 · Premium Reports", Figma node
/// 22:2).
///
/// Shared by both Home entry points ([_ExploreSection]'s "Reports" tile and
/// [_RecentReportsSection]'s "My reports" action). Like the Kundli/Match/AI
/// tiles above, this screen has no bottom nav of its own in the Figma
/// design, so it's pushed as a destination rather than switched to as a tab
/// root.
void _openPremiumReports(BuildContext context) {
  Navigator.of(
    context,
  ).push<void>(fadeThroughRoute(const PremiumReportsScreen()));
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
          onTap: () => _openAiAstrologer(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glanceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.aiAvatarGradient,
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
                      Icon(
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
// ignore: unused_element  — kept for when report history is tracked
class _RecentReportsSection extends StatelessWidget {
  const _RecentReportsSection({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final reports = HomeStaticData.reports;
    final backgrounds = [AppColors.tileBlueBg, AppColors.tilePinkBg];
    const emojis = ['💼', '💍'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          l10n.recentReports,
          locale: locale,
          actionLabel: l10n.myReports,
          onAction: () => _openPremiumReports(context),
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
              color: AppColors.surface,
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
///
/// Reads the CMS quote as of 12 Sep 2026 (`dailyQuoteProvider`). It is a
/// `Consumer` rather than a `StatelessWidget` so the rest of the dashboard
/// does not rebuild when the quote resolves.
///
/// The provider never surfaces an error or a loading state to the user: while
/// the read is in flight, and on any failure, it yields the bundled sentence.
/// A spinner — or worse, an error box — at the very bottom of Home would be a
/// lot of ceremony for one decorative line.
class _DailyQuoteCard extends ConsumerWidget {
  const _DailyQuoteCard({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote =
        ref.watch(dailyQuoteProvider).valueOrNull ?? HomeStaticData.quote;
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
          Icon(Icons.format_quote_rounded, size: 22, color: AppColors.gold),
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
                Icon(Icons.north_east, size: 11, color: AppColors.quoteMuted),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Today with the time component stripped — a stable key for
/// [inauspiciousPeriodsProvider]. See its call site above.
DateTime _todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
