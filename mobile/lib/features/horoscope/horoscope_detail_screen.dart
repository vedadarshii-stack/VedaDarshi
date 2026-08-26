import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/vedika/vedika_config.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../premium/subscription_paywall_screen.dart';
import 'horoscope_data.dart';
import 'horoscope_detail_static_data.dart';
import 'horoscope_period.dart';
import 'horoscope_repository.dart';
import 'zodiac_sign.dart';

/// Horoscope Detail — per the approved Figma "B4 · Horoscope Detail"
/// (node 16:2) concept.
///
/// Pushed from the Horoscope — All Signs grid (tapping any sign card with
/// whichever [HoroscopePeriod] chip is selected, see
/// `horoscope_signs_screen.dart`) and from the Home dashboard's "Today's
/// Horoscope" teaser card (which resolves the user's own sign and always
/// means [HoroscopePeriod.daily], hence the default). Like
/// "B3 · Horoscope — All Signs", this screen has NO bottom nav — it's a
/// level deeper in the navigation stack and gets a back button instead.
///
/// **Backed by the real Vedika API for all four periods** — see
/// `horoscope_repository.dart` for the endpoints/caching and
/// `horoscope_detail_static_data.dart`'s doc comment for exactly which UI
/// values are genuinely sourced from Vedika (falling back to placeholder
/// text only when a field is missing) versus which ones have no Vedika
/// equivalent at all and stay static permanently. **Yearly is a `POST` to
/// `/v2/astrology/prediction/yearly`** — a different path family from the
/// other three's `GET .../horoscope/{sign}[/period]` (see the `switch`
/// below and `horoscope_repository.dart` for why an earlier investigation
/// wrongly concluded yearly didn't exist at all).
///
/// Figma only designed the Daily reading — there is no separate frame for
/// Weekly/Monthly. Rather than invent a new screen for each, [_WeeklyBody]
/// and [_MonthlyBody] reuse this screen's existing header/card/
/// premium-teaser components with period-appropriate content in each slot
/// (see their doc comments for exactly what maps where).
class HoroscopeDetailScreen extends ConsumerWidget {
  const HoroscopeDetailScreen({
    super.key,
    required this.sign,
    this.period = HoroscopePeriod.daily,
  });

  final ZodiacSign sign;

  /// Which reading to show. Defaults to [HoroscopePeriod.daily] for call
  /// sites that only ever mean "today" (the Home dashboard's horoscope
  /// teaser) — the Horoscope — All Signs grid always passes its selected
  /// period chip explicitly.
  final HoroscopePeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    switch (period) {
      case HoroscopePeriod.daily:
        final horoscopeAsync = ref.watch(dailyHoroscopeProvider(sign.id));
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: horoscopeAsync.when(
            data: (horoscope) => _DailyBody(
              sign: sign,
              horoscope: horoscope,
              l10n: l10n,
              locale: locale,
            ),
            loading: () => _LoadingState(locale: locale),
            error: (error, stackTrace) => _ErrorState(
              l10n: l10n,
              locale: locale,
              onRetry: () => ref.invalidate(dailyHoroscopeProvider(sign.id)),
            ),
          ),
        );

      case HoroscopePeriod.weekly:
        final weeklyAsync = ref.watch(weeklyHoroscopeProvider(sign.id));
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: weeklyAsync.when(
            data: (weekly) => _WeeklyBody(
              sign: sign,
              weekly: weekly,
              l10n: l10n,
              locale: locale,
            ),
            loading: () => _LoadingState(locale: locale),
            error: (error, stackTrace) => _ErrorState(
              l10n: l10n,
              locale: locale,
              onRetry: () => ref.invalidate(weeklyHoroscopeProvider(sign.id)),
            ),
          ),
        );

      case HoroscopePeriod.monthly:
        final monthlyAsync = ref.watch(monthlyHoroscopeProvider(sign.id));
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: monthlyAsync.when(
            data: (monthly) => _MonthlyBody(
              sign: sign,
              monthly: monthly,
              l10n: l10n,
              locale: locale,
            ),
            loading: () => _LoadingState(locale: locale),
            error: (error, stackTrace) => _ErrorState(
              l10n: l10n,
              locale: locale,
              onRetry: () => ref.invalidate(monthlyHoroscopeProvider(sign.id)),
            ),
          ),
        );

      case HoroscopePeriod.yearly:
        final yearlyAsync = ref.watch(yearlyHoroscopeProvider(sign.id));
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: yearlyAsync.when(
            data: (yearly) => _YearlyBody(
              sign: sign,
              yearly: yearly,
              l10n: l10n,
              locale: locale,
            ),
            loading: () => _LoadingState(locale: locale),
            error: (error, stackTrace) => _ErrorState(
              l10n: l10n,
              locale: locale,
              onRetry: () => ref.invalidate(yearlyHoroscopeProvider(sign.id)),
            ),
          ),
        );
    }
  }
}

/// Loaded-state body for the Daily period. Split out from
/// [HoroscopeDetailScreen] so [AsyncValue.when] can swap it for
/// [_LoadingState]/[_ErrorState] without duplicating the Scaffold.
class _DailyBody extends StatelessWidget {
  const _DailyBody({
    required this.sign,
    required this.horoscope,
    required this.l10n,
    required this.locale,
  });

  final ZodiacSign sign;
  final DailyHoroscope horoscope;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    // Vedika gives one theme + one rating + one prediction for the whole
    // day, not 3 independent category readings — see the doc comment on
    // [DailyHoroscope]. So at most ONE of the 3 fixed prediction cards
    // (career/love/health) can be genuinely real on any given day; the
    // other two keep their existing static placeholder text unchanged,
    // exactly as they were before this screen was wired up. This is never
    // fabrication — a card either gets today's real reading in its slot,
    // or it keeps the same placeholder it always had. (For the Yearly
    // period, `horoscope.theme`/`.prediction`/`.rating` are all null, so
    // every card below falls through to its static placeholder.)
    final realSection = _sectionForTheme(horoscope.theme);
    final predictions = [
      for (final staticPrediction in HoroscopeDetailStaticData.predictions)
        if (realSection == staticPrediction.id &&
            horoscope.prediction != null &&
            horoscope.rating != null)
          HoroscopePrediction(
            staticPrediction.id,
            horoscope.rating!.clamp(0, 5).toInt(),
            horoscope.prediction!,
          )
        else
          staticPrediction,
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(
          sign: sign,
          // Real when Vedika returned a parseable `date`, otherwise the
          // placeholder — never blank. (Always the placeholder on Yearly.)
          dateLabel: horoscope.formattedDate ?? HoroscopeDetailStaticData.date,
          luckyColorValue:
              horoscope.luckyColor ?? HoroscopeDetailStaticData.luckyColor,
          luckyNumberValue:
              horoscope.luckyNumber?.toString() ??
              HoroscopeDetailStaticData.luckyNumber,
          l10n: l10n,
          locale: locale,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The sandbox returns one fixed sample chart for every sign
              // (see VedikaConfig.isSandbox) — flagging that here rather
              // than letting it silently pass as a real reading.
              if (VedikaConfig.isSandbox) ...[
                _SandboxBanner(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
              ],
              _ScoresCard(l10n: l10n, locale: locale),
              const SizedBox(height: 12),
              _TimesRow(horoscope: horoscope, l10n: l10n, locale: locale),
              const SizedBox(height: 12),
              for (final prediction in predictions) ...[
                _PredictionCard(
                  prediction: prediction,
                  l10n: l10n,
                  locale: locale,
                ),
                const SizedBox(height: 12),
              ],
              _RemedyCard(locale: locale),
              const SizedBox(height: 12),
              _MantraCard(l10n: l10n, locale: locale),
              const SizedBox(height: 12),
              _PremiumTeaser(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ],
    );
  }
}

/// Loaded-state body for the Weekly period.
///
/// There is no Figma frame for a weekly reading, so this reuses [_Header]
/// and the same surface/border/radius card language as the Daily period
/// rather than inventing a new screen. What's real vs. static, mapped
/// field-by-field:
/// - [_Header]: sign glyph/name unchanged; the date chip becomes
///   [WeeklyHoroscope.formattedWeekLabel] (real when parseable); the
///   lucky-color/lucky-number chips have NO weekly equivalent in Vedika's
///   response, so they always show [HoroscopeDetailStaticData]'s
///   placeholders here (same as when a daily field is simply missing).
/// - "This Week's Advice" ([_PeriodNoteCard]): [WeeklyHoroscope.advice],
///   Vedika's one real weekly narrative, falling back to
///   [HoroscopeDetailStaticData.weeklyAdvice] when absent.
/// - "7-Day Outlook" ([_WeeklyOutlookCard]): [WeeklyHoroscope.days] (each
///   day's real `theme`/`rating`), with [WeeklyHoroscope.bestDay]
///   highlighted — hidden entirely if Vedika returned no days rather than
///   showing an empty card.
/// - No scores card, no lucky/avoid-time row, no remedy/mantra — none of
///   those have a weekly equivalent and there's no sensible "closest
///   existing component" to force them into, so they're simply omitted
///   for this period rather than shown with fabricated content.
class _WeeklyBody extends StatelessWidget {
  const _WeeklyBody({
    required this.sign,
    required this.weekly,
    required this.l10n,
    required this.locale,
  });

  final ZodiacSign sign;
  final WeeklyHoroscope weekly;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(
          sign: sign,
          dateLabel:
              weekly.formattedWeekLabel ?? HoroscopeDetailStaticData.date,
          luckyColorValue: HoroscopeDetailStaticData.luckyColor,
          luckyNumberValue: HoroscopeDetailStaticData.luckyNumber,
          l10n: l10n,
          locale: locale,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (VedikaConfig.isSandbox) ...[
                _SandboxBanner(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
              ],
              _PeriodNoteCard(
                emoji: '🧭',
                title: l10n.weeklyAdviceTitle,
                body: weekly.advice ?? HoroscopeDetailStaticData.weeklyAdvice,
                locale: locale,
              ),
              if (weekly.days.isNotEmpty) ...[
                const SizedBox(height: 12),
                _WeeklyOutlookCard(weekly: weekly, l10n: l10n, locale: locale),
              ],
              const SizedBox(height: 12),
              _PremiumTeaser(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ],
    );
  }
}

/// "7-Day Outlook" card for the Weekly period — one row per
/// [WeeklyHoroscope.days] entry, reusing [_RatingDots] for each day's
/// [WeeklyHoroscopeDay.rating] the same way the Daily period's prediction
/// cards do.
class _WeeklyOutlookCard extends StatelessWidget {
  const _WeeklyOutlookCard({
    required this.weekly,
    required this.l10n,
    required this.locale,
  });

  final WeeklyHoroscope weekly;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyOutlookTitle,
            style: AppFonts.body(
              locale,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < weekly.days.length; i++) ...[
            if (i != 0) const SizedBox(height: 8),
            _WeeklyDayRow(
              weekly: weekly,
              day: weekly.days[i],
              isBestDay:
                  weekly.bestDay != null &&
                  weekly.days[i].dayOffset == weekly.bestDay,
              l10n: l10n,
              locale: locale,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyDayRow extends StatelessWidget {
  const _WeeklyDayRow({
    required this.weekly,
    required this.day,
    required this.isBestDay,
    required this.l10n,
    required this.locale,
  });

  final WeeklyHoroscope weekly;
  final WeeklyHoroscopeDay day;
  final bool isBestDay;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    // Falls back to a 1-based "Day N" from the offset (not the raw
    // 0-based dayOffset, which would read as "Day 0" to a user) if the
    // week's start date is missing/unparseable — still orients the user
    // without fabricating a calendar date.
    final dayLabel =
        weekly.formattedDayLabel(day) ?? 'Day ${(day.dayOffset ?? 0) + 1}';
    final rating = day.rating;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isBestDay ? AppColors.tileGoldBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              dayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              // Vedika's `theme` vocabulary (e.g. 'spirituality',
              // 'travel') isn't translated anywhere in the app — same
              // English-regardless-of-locale gap as `_PredictionCard`'s
              // body text below.
              day.theme ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                color: AppColors.muted,
              ),
            ),
          ),
          if (rating != null) ...[
            const SizedBox(width: 8),
            _RatingDots(
              rating: rating.clamp(0, 5).toInt(),
              color: isBestDay ? AppColors.tileGoldFg : AppColors.saffron,
            ),
          ],
          if (isBestDay) ...[
            const SizedBox(width: 8),
            _BestDayBadge(l10n: l10n, locale: locale),
          ],
        ],
      ),
    );
  }
}

/// Small pill marking [WeeklyHoroscope.bestDay]'s row — same solid-fill +
/// white-text pattern as the "Your sign" badge on the Horoscope — All
/// Signs grid (`horoscope_signs_screen.dart`), reusing [AppColors.saffron]
/// rather than introducing a new badge treatment.
class _BestDayBadge extends StatelessWidget {
  const _BestDayBadge({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.saffron,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.weeklyBestDayBadge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.body(
          locale,
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Loaded-state body for the Monthly period.
///
/// Also no Figma frame for this one. What's real vs. static, mapped
/// field-by-field:
/// - [_Header]: date chip becomes [MonthlyHoroscope.formattedMonthLabel];
///   lucky-color/lucky-number chips stay static (no monthly equivalent),
///   same reasoning as [_WeeklyBody].
/// - "This Month's Scores" ([_ScoresCard]): **genuinely real**, unlike the
///   Daily/Weekly periods — Vedika's monthly response DOES return
///   love/career/health/finance scores (see [MonthlyHoroscope]), merged
///   via [_monthlyScores] into the card's fixed 5-row shape. Only the
///   `luck` row (no Monthly equivalent) stays static, and
///   [MonthlyHoroscope.overallRating] is shown as a badge next to the
///   title when present.
/// - "This Month's Theme" ([_PeriodNoteCard]):
///   [MonthlyHoroscope.monthlyTheme], falling back to
///   [HoroscopeDetailStaticData.monthlyTheme] when absent.
/// - "Key Dates This Month" ([_KeyDatesCard]): [MonthlyHoroscope.keyDates],
///   hidden entirely when null/empty rather than shown blank.
class _MonthlyBody extends StatelessWidget {
  const _MonthlyBody({
    required this.sign,
    required this.monthly,
    required this.l10n,
    required this.locale,
  });

  final ZodiacSign sign;
  final MonthlyHoroscope monthly;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final keyDates = monthly.keyDates;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(
          sign: sign,
          dateLabel:
              monthly.formattedMonthLabel ?? HoroscopeDetailStaticData.date,
          luckyColorValue: HoroscopeDetailStaticData.luckyColor,
          luckyNumberValue: HoroscopeDetailStaticData.luckyNumber,
          l10n: l10n,
          locale: locale,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (VedikaConfig.isSandbox) ...[
                _SandboxBanner(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
              ],
              _ScoresCard(
                l10n: l10n,
                locale: locale,
                title: l10n.monthlyScoresTitle,
                scores: _monthlyScores(monthly),
                overallRatingLabel: monthly.overallRating == null
                    ? null
                    : l10n.monthlyOverallRating(monthly.overallRating!),
              ),
              const SizedBox(height: 12),
              _PeriodNoteCard(
                emoji: '🌙',
                title: l10n.monthlyThemeTitle,
                body:
                    monthly.monthlyTheme ??
                    HoroscopeDetailStaticData.monthlyTheme,
                locale: locale,
              ),
              if (keyDates != null && keyDates.isNotEmpty) ...[
                const SizedBox(height: 12),
                _KeyDatesCard(keyDates: keyDates, l10n: l10n, locale: locale),
              ],
              const SizedBox(height: 12),
              _PremiumTeaser(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ],
    );
  }
}

/// Merges [MonthlyHoroscope]'s 4 real category scores into the "Today's
/// scores" card's fixed 5-row shape (career/love/health/money/luck).
/// [HoroscopeScoreId.luck] has no Monthly equivalent — Vedika's monthly
/// response has love/career/health/finance scores but no luck score — so
/// that one row alone keeps [HoroscopeDetailStaticData.scores]' static
/// value, the same "real where possible, static where not" rule
/// `_DailyBody`'s prediction cards follow via `_sectionForTheme` above.
List<HoroscopeScore> _monthlyScores(MonthlyHoroscope monthly) {
  final fallback = {
    for (final s in HoroscopeDetailStaticData.scores) s.id: s.percent,
  };
  return [
    HoroscopeScore(
      HoroscopeScoreId.career,
      monthly.careerScore ?? fallback[HoroscopeScoreId.career]!,
    ),
    HoroscopeScore(
      HoroscopeScoreId.love,
      monthly.loveScore ?? fallback[HoroscopeScoreId.love]!,
    ),
    HoroscopeScore(
      HoroscopeScoreId.health,
      monthly.healthScore ?? fallback[HoroscopeScoreId.health]!,
    ),
    HoroscopeScore(
      HoroscopeScoreId.money,
      monthly.financeScore ?? fallback[HoroscopeScoreId.money]!,
    ),
    HoroscopeScore(HoroscopeScoreId.luck, fallback[HoroscopeScoreId.luck]!),
  ];
}

/// Loaded-state body for the Yearly period — `POST
/// /v2/astrology/prediction/yearly` (see [YearlyHoroscope] and
/// `horoscope_repository.dart`).
///
/// No Figma frame for this one either (see [_WeeklyBody]/[_MonthlyBody]).
/// **Unlike every other period, nothing here ever falls back to
/// [HoroscopeDetailStaticData]** — a missing field means the corresponding
/// block is omitted entirely, never replaced with placeholder content.
/// That rule exists because this period previously rendered an all-null
/// `DailyHoroscope` through `_DailyBody`, which silently dressed up 100%
/// static placeholder content as a real yearly reading (a client-reported
/// bug — "yearly looks identical to daily"); this body must never repeat
/// that mistake.
///
/// What's shown, mapped field-by-field:
/// - [_Header]: sign glyph/name unchanged; the date chip becomes
///   [YearlyHoroscope.formattedPeriodRange] (omitted if unparseable); the
///   lucky-color/lucky-number/direction chips come from
///   [YearlyHoroscope.luckyElements] via [_yearlyHeaderChips] — 0 to 3
///   chips, each shown only when Vedika actually returned it.
/// - "Lucky Day" / "Lucky Time" ([_YearlyLuckyTimesRow]): also from
///   [YearlyHoroscope.luckyElements], split out of the header because the
///   header only has room for 3 chips; the whole row is omitted if neither
///   is present.
/// - "This Year's Overview" ([_PeriodNoteCard]): [YearlyHoroscope.summary],
///   omitted if null (unlike Weekly/Monthly's equivalent note cards, which
///   fall back to a static placeholder).
/// - "This Year's Scores" ([_ScoresCard]): [YearlyHoroscope.areas] mapped
///   via [_yearlyScores], with [YearlyHoroscope.overallScore] as the badge.
///   Omitted entirely if there's neither a mapped score nor an overall
///   score to show.
/// - Remedies ([_RemedyCard]): [YearlyHoroscope.remedies], joined by
///   [_joinRemedies]. Omitted if empty — this is the one period where
///   [_RemedyCard] ever shows real content instead of
///   [HoroscopeDetailStaticData.remedy].
/// - No mantra, no avoid-time card — Vedika's yearly response has no
///   equivalent for either, and per the no-fallback rule above there's
///   nothing to show in their place, so neither is part of this body.
class _YearlyBody extends StatelessWidget {
  const _YearlyBody({
    required this.sign,
    required this.yearly,
    required this.l10n,
    required this.locale,
  });

  final ZodiacSign sign;
  final YearlyHoroscope yearly;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final lucky = yearly.luckyElements;
    final scores = _yearlyScores(yearly);
    final overallScore = yearly.overallScore;
    final remedies = yearly.remedies;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(
          sign: sign,
          dateLabel: yearly.formattedPeriodRange,
          chipsOverride: _yearlyHeaderChips(yearly, l10n, locale),
          l10n: l10n,
          locale: locale,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (VedikaConfig.isSandbox) ...[
                _SandboxBanner(l10n: l10n, locale: locale),
                const SizedBox(height: 12),
              ],
              if (lucky != null &&
                  (lucky.luckyDay != null || lucky.luckyTime != null)) ...[
                _YearlyLuckyTimesRow(
                  lucky: lucky,
                  l10n: l10n,
                  locale: locale,
                ),
                const SizedBox(height: 12),
              ],
              if (yearly.summary != null) ...[
                _PeriodNoteCard(
                  emoji: '🔮',
                  title: l10n.yearlySummaryTitle,
                  body: yearly.summary!,
                  locale: locale,
                ),
                const SizedBox(height: 12),
              ],
              if (scores.isNotEmpty || overallScore != null) ...[
                _ScoresCard(
                  l10n: l10n,
                  locale: locale,
                  title: l10n.yearlyScoresTitle,
                  scores: scores,
                  overallRatingLabel: overallScore == null
                      ? null
                      : l10n.yearlyOverallRating(overallScore),
                ),
                const SizedBox(height: 12),
              ],
              if (remedies.isNotEmpty) ...[
                _RemedyCard(text: _joinRemedies(remedies), locale: locale),
                const SizedBox(height: 12),
              ],
              _PremiumTeaser(l10n: l10n, locale: locale),
            ],
          ),
        ),
      ],
    );
  }
}

/// Builds [_Header]'s `chipsOverride` for the Yearly period from
/// [YearlyHoroscope.luckyElements] — up to 3 chips (lucky color / lucky
/// number / direction, mirroring the other periods' header layout), each
/// included only when Vedika actually returned it. Never padded out to 3
/// with a placeholder — see [_YearlyBody]'s doc comment.
List<Widget> _yearlyHeaderChips(
  YearlyHoroscope yearly,
  AppLocalizations l10n,
  Locale locale,
) {
  final lucky = yearly.luckyElements;
  final color = lucky?.luckyColor;
  final number = lucky?.luckyNumber;
  final direction = lucky?.luckyDirection;

  final entries = <MapEntry<String, String>>[
    if (color != null) MapEntry(l10n.luckyColor, color),
    if (number != null) MapEntry(l10n.luckyNumber, number.toString()),
    if (direction != null) MapEntry(l10n.direction, direction),
  ];

  final chips = <Widget>[];
  for (var i = 0; i < entries.length; i++) {
    if (i != 0) chips.add(const SizedBox(width: 10));
    chips.add(
      Expanded(
        child: _HeaderChip(
          label: entries[i].key,
          value: entries[i].value,
          locale: locale,
        ),
      ),
    );
  }
  return chips;
}

/// "Lucky Day" / "Lucky Time" pair for the Yearly period — reuses the same
/// [_TimeCard] tile [_TimesRow] uses for Daily's lucky/avoid time pair, but
/// both tiles here are "good news" (Yearly has no avoid-time equivalent),
/// so both use the same positive color. Only built when at least one of
/// [YearlyLuckyElements.luckyDay]/[YearlyLuckyElements.luckyTime] is
/// present (see [_YearlyBody]); shows just the one tile that exists if
/// only one is.
class _YearlyLuckyTimesRow extends StatelessWidget {
  const _YearlyLuckyTimesRow({
    required this.lucky,
    required this.l10n,
    required this.locale,
  });

  final YearlyLuckyElements lucky;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (lucky.luckyDay != null)
        _TimeCard(
          background: AppColors.geoChipBg,
          badgeIcon: Icons.event_rounded,
          badgeLabel: l10n.luckyDay,
          badgeColor: AppColors.tileGreenFg,
          value: lucky.luckyDay!,
          valueColor: AppColors.geoChipText,
          locale: locale,
        ),
      if (lucky.luckyTime != null)
        _TimeCard(
          background: AppColors.geoChipBg,
          badgeIcon: Icons.check_rounded,
          badgeLabel: l10n.luckyTime,
          badgeColor: AppColors.tileGreenFg,
          value: lucky.luckyTime!,
          valueColor: AppColors.geoChipText,
          locale: locale,
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

/// Best-effort mapping of a [YearlyHoroscopeArea.area] label onto one of
/// this screen's 5 fixed [HoroscopeScoreId] rows. Unlike `_sectionForTheme`
/// above (which merges career and money into one "Career & Money"
/// prediction card), the scores card keeps career and money as separate
/// rows, so this needs its own keyword list.
///
/// **VERIFIED against a real yearly response, 26 Aug 2026.** Vedika returns
/// exactly four areas, and all four map cleanly:
///
/// | Vedika `area`  | row     |
/// |----------------|---------|
/// | `career`       | career  |
/// | `relationship` | love    |
/// | `health`       | health  |
/// | `finance`      | money   |
///
/// It returns **no** `luck` area, so that row is simply absent from the
/// yearly scores card — correct, not a gap to paper over. The extra
/// synonyms below (`work`, `romance`, `wealth`, `fortune`, …) are defensive
/// only: they cost nothing and cover Vedika widening the vocabulary later.
/// An area whose label matches nothing is left OUT of the card rather than
/// guessed at, the same conservative rule `_sectionForTheme` follows.
HoroscopeScoreId? _yearlyScoreId(String? area) {
  switch (area?.toLowerCase()) {
    case 'career':
    case 'work':
    case 'profession':
    case 'business':
    case 'job':
      return HoroscopeScoreId.career;
    case 'love':
    case 'relationship':
    case 'relationships':
    case 'romance':
    case 'family':
    case 'marriage':
      return HoroscopeScoreId.love;
    case 'health':
    case 'wellness':
    case 'wellbeing':
    case 'energy':
      return HoroscopeScoreId.health;
    case 'finance':
    case 'wealth':
    case 'money':
    case 'property':
    case 'investment':
    case 'investments':
      return HoroscopeScoreId.money;
    case 'luck':
    case 'fortune':
    case 'general':
    case 'overall':
      return HoroscopeScoreId.luck;
    default:
      return null;
  }
}

/// Maps [YearlyHoroscope.areas] onto the scores card's fixed 5-row shape
/// via [_yearlyScoreId] — **never falling back to
/// [HoroscopeDetailStaticData.scores]**, unlike `_monthlyScores`. An
/// unmapped or missing row for Yearly is simply left out (see
/// [_YearlyBody]'s doc comment for why this period never uses static
/// fallbacks). If two areas map to the same row, the first one wins.
/// Scores are clamped to 0–100 defensively — see
/// [YearlyHoroscopeArea.score]'s doc comment on the unconfirmed scale.
List<HoroscopeScore> _yearlyScores(YearlyHoroscope yearly) {
  final byId = <HoroscopeScoreId, int>{};
  for (final entry in yearly.areas) {
    final id = _yearlyScoreId(entry.area);
    final score = entry.score;
    if (id == null || score == null || byId.containsKey(id)) continue;
    byId[id] = score.clamp(0, 100);
  }
  return [
    for (final id in HoroscopeScoreId.values)
      if (byId.containsKey(id)) HoroscopeScore(id, byId[id]!),
  ];
}

/// Joins [YearlyHoroscope.remedies] into one block for [_RemedyCard], which
/// only has room for a single piece of text. A single remedy is shown
/// as-is; multiple are bullet-joined.
String _joinRemedies(List<String> remedies) {
  if (remedies.isEmpty) return '';
  if (remedies.length == 1) return remedies.first;
  return remedies.map((r) => '• $r').join('\n');
}

/// One-paragraph note card shared by the Weekly ("This Week's Advice"),
/// Monthly ("This Month's Theme") and Yearly ("This Year's Overview")
/// periods — same surface/border/radius container as [_PredictionCard] so
/// it reads as part of the same design language even though there's no
/// dedicated Figma frame for any of the three.
class _PeriodNoteCard extends StatelessWidget {
  const _PeriodNoteCard({
    required this.emoji,
    required this.title,
    required this.body,
    required this.locale,
  });

  final String emoji;
  final String title;
  final String body;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.6,
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

/// "Key Dates This Month" card for the Monthly period — a [Wrap] of pill
/// chips, one per [MonthlyHoroscope.keyDates] entry. Day numbers are plain
/// digits (not locale-formatted) — same as [HoroscopeDetailStaticData
/// .luckyNumber] elsewhere on this screen, digits don't need translation.
class _KeyDatesCard extends StatelessWidget {
  const _KeyDatesCard({
    required this.keyDates,
    required this.l10n,
    required this.locale,
  });

  final List<int> keyDates;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyKeyDatesTitle,
            style: AppFonts.body(
              locale,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final day in keyDates)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tileGoldBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$day',
                    style: AppFonts.body(
                      locale,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tileGoldFg,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Maps Vedika's free-text [DailyHoroscope.theme] onto one of the screen's
/// 3 fixed prediction categories, or `null` when it doesn't fit any of
/// them (most themes don't — Vedika's vocabulary includes things like
/// `'spirituality'`, `'creativity'`, `'travel'` that have no home in this
/// design). Deliberately conservative: only mapped when the fit is
/// unambiguous, never guessed.
HoroscopeSectionId? _sectionForTheme(String? theme) {
  switch (theme?.toLowerCase()) {
    case 'career':
    case 'wealth':
    case 'finance':
    case 'money':
    case 'business':
    case 'work':
      return HoroscopeSectionId.career;
    case 'love':
    case 'relationships':
    case 'romance':
    case 'family':
      return HoroscopeSectionId.love;
    case 'health':
    case 'wellness':
    case 'energy':
      return HoroscopeSectionId.health;
    default:
      return null;
  }
}

/// Small "Sample data" notice shown only when [VedikaConfig.isSandbox] is
/// true, so a tester never mistakes the sandbox's fixed sample chart for a
/// real reading. Styled with the app's existing caution tokens
/// ([AppColors.warnBg]/[AppColors.mantraLabel] — the same pairing the
/// Panchang screen uses for its "caution" muhurat cards) rather than
/// inventing a new color pair.
class _SandboxBanner extends StatelessWidget {
  const _SandboxBanner({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warnBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.mantraLabel,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.horoscopeSandboxBanner,
              style: AppFonts.body(
                locale,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.mantraLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain back-button row, matching the circle style used on the Horoscope —
/// All Signs screen's header (surface + border, not the gradient-hero
/// translucent style [_Header] below uses) — appropriate here because
/// [_LoadingState]/[_ErrorState] render on the plain cream background, with
/// no gradient hero to sit inside yet.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.surface,
        shape: CircleBorder(side: BorderSide(color: AppColors.cardBorder)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown while [dailyHoroscopeProvider] is in flight. The motion spec
/// (Figma node 80:2, item 3) calls for shimmer skeletons on content
/// screens rather than a spinner — not built anywhere in the app yet (see
/// the project's top-level CLAUDE.md motion-spec table, still PENDING
/// project-wide), so this uses the same `CircularProgressIndicator` the
/// app already relies on for its other in-flight states (OTP verify,
/// Google sign-in, Birth Details save) rather than introducing a one-off
/// shimmer just for this screen.
class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(alignment: Alignment.centerLeft, child: _BackButton()),
          ),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.saffron),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when [dailyHoroscopeProvider] fails (network/timeout/Vedika
/// error — see [VedikaException]). Reuses the shared [AppEmptyState] card
/// (the same widget Search's no-results and Notifications' empty states
/// use) with a Retry action that invalidates the provider, rather than a
/// bespoke error widget.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.l10n,
    required this.locale,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(alignment: Alignment.centerLeft, child: _BackButton()),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  iconBackgroundColor: AppColors.ashubhBg,
                  iconForegroundColor: AppColors.ashubhFg,
                  title: l10n.horoscopeErrorTitle,
                  message: l10n.horoscopeErrorMessage,
                  actionLabel: l10n.horoscopeRetryAction,
                  onAction: onRetry,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header hero (Figma node 16:3): back + share, sign avatar + names + date,
/// and the 3 lucky-fact chips.
///
/// Deliberately NOT inside a top [SafeArea] — [AppColors.horoscopeHeaderGradient]
/// must run under the status bar, per the design.
///
/// Takes already-resolved display strings rather than a [DailyHoroscope]
/// directly, so [_DailyBody], [_WeeklyBody], [_MonthlyBody] and
/// [_YearlyBody] can all share this one header — each period resolves its
/// own real-value-or-placeholder fallback (see their doc comments for
/// exactly which fields are real per period) before handing it a plain
/// [String].
class _Header extends StatelessWidget {
  const _Header({
    required this.sign,
    required this.dateLabel,
    this.luckyColorValue,
    this.luckyNumberValue,
    this.chipsOverride,
    required this.l10n,
    required this.locale,
  });

  final ZodiacSign sign;

  /// Already resolved to real data or a placeholder — see the class doc
  /// comment. `null` omits the date line entirely rather than rendering a
  /// blank one (used by [_YearlyBody], which never falls back to a
  /// placeholder — see its own doc comment).
  final String? dateLabel;

  /// Ignored when [chipsOverride] is provided.
  final String? luckyColorValue;
  final String? luckyNumberValue;

  /// When non-null, replaces the default 3-chip row (lucky color / lucky
  /// number / direction) with these widgets instead — used by
  /// [_YearlyBody], which has its own set of lucky fields and, per its
  /// "omit rather than fabricate" rule, may have fewer than 3 (or none) to
  /// show. An empty list hides the chip row entirely rather than rendering
  /// an empty [Row].
  final List<Widget>? chipsOverride;
  final AppLocalizations l10n;
  final Locale locale;

  /// [chipsOverride] if provided, otherwise the default 3-chip row (lucky
  /// color / lucky number / direction) every non-Yearly period uses.
  List<Widget> get _resolvedChips {
    final override = chipsOverride;
    if (override != null) return override;
    return [
      Expanded(
        // Reuses the existing `luckyColor` key ("Lucky Color") rather than
        // adding a near-duplicate "Lucky Colour" key — the design's
        // spelling difference isn't worth a second string.
        child: _HeaderChip(
          label: l10n.luckyColor,
          value: luckyColorValue ?? '',
          locale: locale,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _HeaderChip(
          label: l10n.luckyNumber,
          value: luckyNumberValue ?? '',
          locale: locale,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        // Direction has NO Vedika equivalent — none of the daily/
        // weekly/monthly endpoints return a lucky direction, so this
        // stays a permanent placeholder (see
        // horoscope_detail_static_data.dart), not a loading gap.
        child: _HeaderChip(
          label: l10n.direction,
          value: HoroscopeDetailStaticData.direction,
          locale: locale,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    final topPadding = statusBarInset + 16 > 52 ? statusBarInset + 16 : 52.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 22),
      decoration: BoxDecoration(
        gradient: AppColors.horoscopeHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                child: PressableScale(
                  borderRadius: BorderRadius.circular(999),
                  // No-op for now: share/deeplink lands with that feature
                  // work, not this screen build.
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.creamText),
                ),
                child: Text(
                  sign.glyph,
                  style: AppFonts.zodiac(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${sign.sanskritName} · ${sign.englishName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        locale,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (dateLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        dateLabel!,
                        style: AppFonts.body(
                          locale,
                          fontSize: 12,
                          color: AppColors.creamText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_resolvedChips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(children: _resolvedChips),
          ],
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              locale,
              fontSize: 9.5,
              color: AppColors.creamText,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

/// Resolves the l10n label + colour for a [HoroscopeScoreId] row.
({String label, Color color}) _scoreMeta(
  HoroscopeScoreId id,
  AppLocalizations l10n,
) {
  switch (id) {
    case HoroscopeScoreId.career:
      return (label: l10n.scoreCareer, color: AppColors.tileBlueFg);
    case HoroscopeScoreId.love:
      return (label: l10n.scoreLove, color: AppColors.tilePinkFg);
    case HoroscopeScoreId.health:
      return (label: l10n.scoreHealth, color: AppColors.tileGreenFg);
    case HoroscopeScoreId.money:
      return (label: l10n.scoreMoney, color: AppColors.tileGoldFg);
    case HoroscopeScoreId.luck:
      return (label: l10n.scoreLuck, color: AppColors.genderSelectedText);
  }
}

/// "Today's scores" card (Figma node 49:2) — 5 animated score bars.
///
/// Static for Daily and Weekly: Vedika's daily endpoint returns ONE
/// aggregate theme+rating for the whole day (see [DailyHoroscope]) and its
/// weekly endpoint returns none at all, so there is no real per-category
/// number to animate these bars to for either period. Synthesizing 4 of
/// the 5 from a single rating would be fabricated data, not "real data
/// with a fallback" — kept static instead, same as
/// [HoroscopeDetailStaticData.direction]/[HoroscopeDetailStaticData
/// .avoidTime] below.
///
/// **Real for Monthly and Yearly** — Vedika's monthly response DOES return
/// love/career/health/finance scores (see [MonthlyHoroscope]) and its
/// yearly response returns an `areas` list (see [YearlyHoroscope]), so
/// `_MonthlyBody`/`_YearlyBody` pass those in via [scores] (merged by
/// `_monthlyScores`/`_yearlyScores`) and [overallRatingLabel], overriding
/// this card's own defaults.
class _ScoresCard extends StatelessWidget {
  const _ScoresCard({
    required this.l10n,
    required this.locale,
    this.title,
    this.scores = HoroscopeDetailStaticData.scores,
    this.overallRatingLabel,
  });

  final AppLocalizations l10n;
  final Locale locale;

  /// Defaults to [AppLocalizations.todaysScores] — `_MonthlyBody`/
  /// `_YearlyBody` override it so the card doesn't read as "Today's" for a
  /// month- or year-long reading.
  final String? title;
  final List<HoroscopeScore> scores;

  /// Already-localized badge text shown next to the title (e.g.
  /// `l10n.monthlyOverallRating(72)`), resolved by the caller rather than
  /// this card, since which l10n key applies depends on the period. Only
  /// [MonthlyHoroscope] and [YearlyHoroscope] have an aggregate like this —
  /// `null` on every other period, which hides the badge entirely rather
  /// than showing a fabricated number.
  final String? overallRatingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? l10n.todaysScores,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (overallRatingLabel != null)
                Text(
                  overallRatingLabel!,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < scores.length; i++) ...[
            if (i != 0) const SizedBox(height: 10),
            _ScoreRow(score: scores[i], index: i, l10n: l10n, locale: locale),
          ],
        ],
      ),
    );
  }
}

class _ScoreRow extends StatefulWidget {
  const _ScoreRow({
    required this.score,
    required this.index,
    required this.l10n,
    required this.locale,
  });

  final HoroscopeScore score;
  final int index;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  State<_ScoreRow> createState() => _ScoreRowState();
}

class _ScoreRowState extends State<_ScoreRow> {
  // Starts at 0 and is only bumped to the real target after the per-row
  // stagger delay below — TweenAnimationBuilder animates automatically
  // whenever its `end` changes, so this delayed setState is what makes the
  // bars cascade in one after another instead of growing in lockstep. Same
  // delayed-setState pattern as EntranceFadeSlide.
  double _target = 0;

  @override
  void initState() {
    super.initState();
    final delay = kEntranceStagger * widget.index;
    Future.delayed(delay, () {
      if (mounted) setState(() => _target = widget.score.percent / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = _scoreMeta(widget.score.id, widget.l10n);

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            meta.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              widget.locale,
              fontSize: 11.5,
              color: AppColors.muted,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              color: AppColors.rowDivider,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _target),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    alignment: Alignment.centerLeft,
                    child: Container(color: meta.color),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            '${widget.score.percent}%',
            textAlign: TextAlign.end,
            style: AppFonts.body(
              widget.locale,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: meta.color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Lucky-time / avoid-time pair (Figma node 49:29).
class _TimesRow extends StatelessWidget {
  const _TimesRow({
    required this.horoscope,
    required this.l10n,
    required this.locale,
  });

  final DailyHoroscope horoscope;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TimeCard(
            background: AppColors.geoChipBg,
            badgeIcon: Icons.check_rounded,
            badgeLabel: l10n.luckyTime,
            badgeColor: AppColors.tileGreenFg,
            // Real (reformatted to 12-hour) when Vedika returned a
            // parseable `luckyTime`, otherwise the placeholder.
            value:
                horoscope.formattedLuckyTime ??
                HoroscopeDetailStaticData.luckyTime,
            valueColor: AppColors.geoChipText,
            locale: locale,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // Avoid time has NO Vedika equivalent — none of the horoscope
          // endpoints return an inauspicious window, so this stays a
          // permanent placeholder (see horoscope_detail_static_data.dart).
          child: _TimeCard(
            background: AppColors.ashubhBg,
            badgeIcon: Icons.close_rounded,
            badgeLabel: l10n.avoidTime,
            badgeColor: AppColors.ashubhFg,
            value: HoroscopeDetailStaticData.avoidTime,
            valueColor: AppColors.avoidText,
            locale: locale,
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.background,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.badgeColor,
    required this.value,
    required this.valueColor,
    required this.locale,
  });

  final Color background;
  final IconData badgeIcon;
  final String badgeLabel;
  final Color badgeColor;
  final String value;
  final Color valueColor;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badgeIcon, size: 10, color: badgeColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  badgeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves the l10n title / tile background / rating-dot colour / emoji
/// for a [HoroscopeSectionId] prediction card.
({String title, Color tileBg, Color dotColor, String emoji}) _sectionMeta(
  HoroscopeSectionId id,
  AppLocalizations l10n,
) {
  switch (id) {
    case HoroscopeSectionId.career:
      return (
        title: l10n.sectionCareerMoney,
        tileBg: AppColors.tileBlueBg,
        dotColor: AppColors.tileBlueFg,
        emoji: '💼',
      );
    case HoroscopeSectionId.love:
      return (
        title: l10n.sectionLoveRelationships,
        tileBg: AppColors.tilePinkBg,
        dotColor: AppColors.tilePinkFg,
        emoji: '❤️',
      );
    case HoroscopeSectionId.health:
      return (
        title: l10n.sectionHealthEnergy,
        tileBg: AppColors.geoChipBg,
        dotColor: AppColors.tileGreenFg,
        emoji: '🌿',
      );
  }
}

/// One prediction card (Figma nodes 16:27 / 16:40 / 16:53).
class _PredictionCard extends StatelessWidget {
  const _PredictionCard({
    required this.prediction,
    required this.l10n,
    required this.locale,
  });

  final HoroscopePrediction prediction;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final meta = _sectionMeta(prediction.id, l10n);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: meta.tileBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(meta.emoji, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  meta.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Spacer(),
              _RatingDots(rating: prediction.rating, color: meta.dotColor),
            ],
          ),
          const SizedBox(height: 8),
          // When this is real Vedika content (see [_sectionForTheme]),
          // `prediction.body` is Vedika's English `prediction` text
          // verbatim — the API returns English regardless of the app's
          // active locale, and there is no translation pipeline for it.
          // Rendered as-is rather than faking a translation; this is a
          // real, known content gap for the 4 Indic locales (hi/te/ta/kn).
          Text(
            prediction.body,
            style: AppFonts.body(
              locale,
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// 5-dot rating row, drawn instead of using the Figma export's 42×6 image:
/// the dots must be tinted per section AND driven by [rating], and three
/// static PNGs (one per section) couldn't do either — they'd also be raster
/// at a fixed 42×6 rather than crisp at any density.
class _RatingDots extends StatelessWidget {
  const _RatingDots({required this.rating, required this.color});

  final int rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i != 0) const SizedBox(width: 3),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < rating ? color : AppColors.rowDivider,
            ),
          ),
        ],
      ],
    );
  }
}

/// Remedy card (Figma node 16:66).
///
/// [text] defaults to [HoroscopeDetailStaticData.remedy] for the Daily
/// period — permanently static there, since no daily/weekly/monthly
/// endpoint returns a remedy (same reasoning as [_ScoresCard]).
/// `_YearlyBody` passes Vedika's own real `remedies` instead, since the
/// yearly response does return them.
class _RemedyCard extends StatelessWidget {
  const _RemedyCard({
    this.text = HoroscopeDetailStaticData.remedy,
    required this.locale,
  });

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mantraBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌺 not 🪷 — Unicode 14 lotus is tofu on Android 12; see
          // lib/features/ai/ai_topics.dart.
          Text('🌺', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppFonts.body(
                locale,
                fontSize: 11.5,
                color: AppColors.mantraBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantra card (Figma node 49:36). Permanently static — Vedika's
/// horoscope endpoints return no mantra, and even if one did, the app
/// currently has no translation pipeline for Devanagari mantra text (see
/// its own comment on the forced `Locale('hi')` below).
class _MantraCard extends StatelessWidget {
  const _MantraCard({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tileBlueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📿', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.todaysMantra,
                  style: AppFonts.body(
                    locale,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tileBlueFg,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 1),
                // Forced to 'hi' regardless of the app's active locale — the
                // mantra is Devanagari and has no glyph in Poppins/Playfair
                // (see the project's TYPOGRAPHY RULE).
                Text(
                  HoroscopeDetailStaticData.mantra,
                  style: AppFonts.body(
                    const Locale('hi'),
                    fontSize: 12,
                    color: AppColors.navyTop,
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

/// Premium teaser card (Figma node 49:41) with the gold glow pulse (motion
/// spec item 5).
class _PremiumTeaser extends StatelessWidget {
  const _PremiumTeaser({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return GoldGlowPulse(
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        button: true,
        child: PressableScale(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(
            context,
          ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.premiumDarkGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Text('👑', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.premiumUnlockPredictions,
                    style: AppFonts.body(
                      locale,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.quoteGold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.premiumCta,
                      style: AppFonts.body(
                        locale,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 11, color: AppColors.gold),
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
