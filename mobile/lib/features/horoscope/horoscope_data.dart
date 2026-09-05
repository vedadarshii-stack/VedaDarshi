/// Immutable models for Vedika's horoscope reading endpoints: the
/// `/v2/astrology/horoscope/{sign}` family (daily / weekly / monthly) and
/// `/v2/astrology/prediction/yearly` (yearly — a different path family, see
/// `horoscope_repository.dart` for why that matters and why the yearly
/// reading is a `POST`, not a `GET`).
///
/// `VedikaClient.get`/`.post` already unwrap the `{success, data, …}`
/// envelope, so every `fromJson` here parses the inner `data` map directly.
/// Vedika does not document any field as guaranteed-present, and the
/// sandbox is separately known to serve one fixed sample chart regardless
/// of what's requested (see `VedikaConfig.isSandbox`) — so EVERY field
/// below is nullable and parsed defensively (wrong type / missing key both
/// become `null`, never a thrown exception). Screens must be able to render
/// sensibly with every field null.
///
/// Shapes were verified live: daily/weekly/monthly against the sandbox
/// 1 Aug 2026, e.g.:
/// ```
/// curl -s "https://api.vedika.io/sandbox/v2/astrology/horoscope/leo" | python3 -m json.tool
/// ```
/// yearly against production 26 Aug 2026, e.g.:
/// ```
/// curl -s -X POST "https://api.vedika.io/v2/astrology/prediction/yearly" \
///   -H "Content-Type: application/json" -d '{"rashi": "leo"}' | python3 -m json.tool
/// ```
library;

import 'dart:ui';

import '../../core/astrology/astro_terms.dart';

import 'package:flutter/foundation.dart' show immutable;

import '../../core/vedika/vedika_text_sanitizer.dart';

/// One day's reading for a sign — `GET /v2/astrology/horoscope/{sign}`.
///
/// Vedika returns exactly ONE [theme] + ONE [rating] + ONE [prediction] for
/// the whole day, not independent per-life-area scores. That matters
/// downstream: the Horoscope Detail screen's "Today's scores" card (5 rows:
/// career/love/health/money/luck) and its 3 category prediction cards were
/// designed against a richer shape than Vedika actually provides — see the
/// comments in `horoscope_detail_screen.dart` for exactly how each UI
/// element degrades to static placeholder content where no real field
/// exists, rather than fabricating one.
@immutable
class DailyHoroscope {
  const DailyHoroscope({
    this.sign,
    this.symbol,
    this.date,
    this.theme,
    this.prediction,
    this.rating,
    this.luckyNumber,
    this.luckyColor,
    this.luckyTime,
    this.compatibleSign,
    this.moonPhase,
    this.moonPhaseEffect,
    this.overallScore,
    this.areas = const {},
    this.remedies = const [],
  });

  factory DailyHoroscope.fromJson(Map<String, dynamic> json) {
    return DailyHoroscope(
      sign: _asString(json['sign']),
      symbol: _asString(json['symbol']),
      date: _asString(json['date']),
      theme: _asString(json['theme']),
      prediction: _asString(json['prediction']),
      rating: _asInt(json['rating']),
      luckyNumber: _asInt(json['luckyNumber']),
      luckyColor: _asString(json['luckyColor']),
      luckyTime: _asString(json['luckyTime']),
      compatibleSign: _asString(json['compatibleSign']),
      moonPhase: _asString(json['moonPhase']),
      moonPhaseEffect: _asString(json['moonPhaseEffect']),
      overallScore: _asInt(json['overallScore']),
      areas: HoroscopeAreaReading.parseMap(json['predictions']),
      remedies: _asStringList(json['remedies']),
    );
  }

  /// Lowercase English sign name, e.g. `'leo'`.
  final String? sign;

  /// Unicode zodiac glyph, e.g. `'♌'`. NOT used for rendering — the app
  /// renders zodiac glyphs from [ZodiacSign.glyph] via `AppFonts.zodiac`
  /// (its dedicated bundled font) so every sign is visually consistent;
  /// this is kept only because it's part of the verified response shape.
  final String? symbol;

  /// ISO `yyyy-MM-dd`. See [formattedDate] for the display form.
  final String? date;

  /// A single dominant life area for the day, e.g. `'health'`, `'wealth'`,
  /// `'spirituality'` — the vocabulary is wider than the app's 3 fixed
  /// prediction categories (career/love/health), so most days it won't
  /// match any of them. See `_sectionForTheme` in
  /// `horoscope_detail_screen.dart`.
  final String? theme;

  /// Free-text reading for the day, already covering [theme], [rating] and
  /// the lucky facts in prose — this is the one real per-day narrative
  /// Vedika gives us.
  final String? prediction;

  /// 1–5 overall rating for the day.
  final int? rating;

  final int? luckyNumber;
  final String? luckyColor;

  /// Raw `"HH:mm-HH:mm"` 24-hour range, e.g. `"06:00-08:00"`. See
  /// [formattedLuckyTime] for the display form.
  final String? luckyTime;

  final String? compatibleSign;
  final String? moonPhase;
  final String? moonPhaseEffect;

  /// 0–100 overall score for the day.
  ///
  /// ADDED 2 Sep 2026. The client reported *"in horoscope page scores are
  /// not changing… daily they are showing the same"* — correct, because the
  /// scores card was still [HoroscopeDetailStaticData.scores], a hardcoded
  /// 85/72/80/65/90.
  ///
  /// ⚠️ **The reason it was static is now obsolete, and that is the lesson.**
  /// This model was written against the SANDBOX, whose daily response
  /// genuinely carried one theme, one 1–5 rating and one paragraph — so
  /// `CLAUDE.md` recorded "no daily equivalent" for per-area scores and the
  /// card stayed placeholder. **Production returns far more**: `predictions`
  /// with career/finance/health/relationship (each score + sentiment + text
  /// + tip), plus `overallScore` and `remedies`. Re-check every other
  /// "the API doesn't have it" note in this repo against production before
  /// trusting it.
  final int? overallScore;

  /// Per-life-area readings, keyed by Vedika's own area name — observed:
  /// `career`, `finance`, `health`, `relationship`.
  final Map<String, HoroscopeAreaReading> areas;

  /// Vedika's remedy suggestions for the day. English-only, like all its
  /// free text.
  final List<String> remedies;

  /// [date] formatted like `"Saturday, 12 July 2026"` — fixed English
  /// weekday/month names, not localized per app language. This matches the
  /// existing convention elsewhere in the app (e.g.
  /// `BirthProfile.formatDate`) of formatting real dates in English
  /// regardless of the active locale; see the TYPOGRAPHY/localization notes
  /// in the project's top-level CLAUDE.md. Returns `null` if [date] is
  /// missing or unparseable, so callers can fall back to placeholder text.
  /// LOCALISED 4 Sep 2026 — this rendered "Friday, 4 September 2026" in
  /// English on an otherwise Telugu header, the same leak the Panchang date
  /// line had. Digits stay Latin; only the weekday and month names change.
  String? formattedDateIn(Locale locale) {
    final parsed = date == null ? null : DateTime.tryParse(date!);
    if (parsed == null) return null;
    final weekday = _weekdayNames[parsed.weekday - 1];
    final month = _monthNames[parsed.month - 1];
    return '${localizeAstroTerm(weekday, AstroTermKind.gregorianWeekday, locale) ?? weekday}, '
        '${parsed.day} '
        '${localizeAstroTerm(month, AstroTermKind.gregorianMonth, locale) ?? month} '
        '${parsed.year}';
  }

  /// [luckyTime] reformatted from Vedika's 24-hour range into the app's
  /// existing 12-hour display style (`"6:00 AM – 8:00 AM"`, matching
  /// `HoroscopeDetailStaticData.luckyTime`'s style). Falls back to the raw
  /// string unchanged if it isn't in the expected `"HH:mm-HH:mm"` shape —
  /// still real data, just not re-styled, which beats discarding it.
  String? get formattedLuckyTime {
    final raw = luckyTime;
    if (raw == null) return null;
    final parts = raw.split('-');
    if (parts.length != 2) return raw;
    final start = _formatClock(parts[0].trim());
    final end = _formatClock(parts[1].trim());
    if (start == null || end == null) return raw;
    return '$start – $end';
  }

  static String? _formatClock(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}

/// One day within a [WeeklyHoroscope.days] list.
/// One life-area reading inside [DailyHoroscope.areas].
///
/// ADDED 2 Sep 2026 — see [DailyHoroscope.overallScore] for why this was
/// missing until now.
@immutable
class HoroscopeAreaReading {
  const HoroscopeAreaReading({this.score, this.sentiment, this.text, this.tip});

  final int? score;

  /// Vedika's own word: `positive`, `neutral`, `challenging`.
  final String? sentiment;

  /// The paragraph for this area. English-only regardless of app locale.
  final String? text;

  /// A one-line actionable suggestion.
  final String? tip;

  factory HoroscopeAreaReading.fromJson(Map<String, dynamic> json) {
    return HoroscopeAreaReading(
      score: _asInt(json['score']),
      sentiment: _asString(json['sentiment']),
      text: _asString(json['text']),
      tip: _asString(json['tip']),
    );
  }

  /// Parses Vedika's `predictions` object — a MAP keyed by area name, not a
  /// list — into area → reading. Unknown keys are kept as-is rather than
  /// filtered against a fixed enum, so a new area Vedika starts returning
  /// shows up instead of being silently dropped.
  static Map<String, HoroscopeAreaReading> parseMap(dynamic value) {
    if (value is! Map) return const {};
    final out = <String, HoroscopeAreaReading>{};
    for (final entry in value.entries) {
      final key = entry.key;
      final raw = entry.value;
      if (key is String && raw is Map<String, dynamic>) {
        out[key] = HoroscopeAreaReading.fromJson(raw);
      }
    }
    return out;
  }
}


@immutable
class WeeklyHoroscopeDay {
  const WeeklyHoroscopeDay({this.dayOffset, this.rating, this.theme});

  factory WeeklyHoroscopeDay.fromJson(Map<String, dynamic> json) {
    return WeeklyHoroscopeDay(
      dayOffset: _asInt(json['dayOffset']),
      rating: _asInt(json['rating']),
      theme: _asString(json['theme']),
    );
  }

  /// 0-based offset from the week's start date (0 = first day).
  final int? dayOffset;

  /// 1–5.
  final int? rating;
  final String? theme;
}

/// `GET /v2/astrology/horoscope/{sign}/weekly`. Rendered by the Horoscope
/// Detail screen's Weekly period (see `horoscope_detail_screen.dart`'s
/// `_WeeklyBody`) — the Weekly period chip on the Horoscope — All Signs
/// grid drives a fetch of this via [weeklyHoroscopeProvider] in
/// `horoscope_repository.dart`.
@immutable
class WeeklyHoroscope {
  const WeeklyHoroscope({
    this.sign,
    this.symbol,
    this.date,
    this.advice,
    this.bestDay,
    this.days = const [],
  });

  factory WeeklyHoroscope.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'];
    return WeeklyHoroscope(
      sign: _asString(json['sign']),
      symbol: _asString(json['symbol']),
      date: _asString(json['date']),
      advice: _asString(json['advice']),
      bestDay: _asInt(json['bestDay']),
      days: rawDays is List
          ? rawDays
                .whereType<Map>()
                .map(
                  (e) =>
                      WeeklyHoroscopeDay.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final String? sign;
  final String? symbol;

  /// ISO `yyyy-MM-dd` of the week's start date.
  final String? date;

  final String? advice;

  /// 0-based offset (matches [WeeklyHoroscopeDay.dayOffset]) of the week's
  /// best day.
  final int? bestDay;
  final List<WeeklyHoroscopeDay> days;

  /// [date] and the 6 days after it formatted like `"Week of 12 – 18 Jul
  /// 2026"` — fixed English, same convention as [DailyHoroscope.formattedDate]
  /// (see its doc comment for why). Returns `null` if [date] is missing or
  /// unparseable, so callers can fall back to placeholder text.
  String? get formattedWeekLabel {
    final start = date == null ? null : DateTime.tryParse(date!);
    if (start == null) return null;
    final end = start.add(const Duration(days: 6));
    final endMonth = _monthNames[end.month - 1];
    return 'Week of ${start.day} – ${end.day} $endMonth ${end.year}';
  }

  /// [day]'s calendar date — this week's [date] plus its
  /// [WeeklyHoroscopeDay.dayOffset] — formatted like `"Mon 14"`. Returns
  /// `null` if [date] or [WeeklyHoroscopeDay.dayOffset] is missing/
  /// unparseable, so callers can fall back to a generic "Day N" label
  /// instead of a wrong date.
  String? formattedDayLabel(WeeklyHoroscopeDay day) {
    final start = date == null ? null : DateTime.tryParse(date!);
    final offset = day.dayOffset;
    if (start == null || offset == null) return null;
    final d = start.add(Duration(days: offset));
    return '${_weekdayNames[d.weekday - 1].substring(0, 3)} ${d.day}';
  }
}

/// `GET /v2/astrology/horoscope/{sign}/monthly`. Rendered by the Horoscope
/// Detail screen's Monthly period — see the note on [WeeklyHoroscope].
@immutable
class MonthlyHoroscope {
  const MonthlyHoroscope({
    this.sign,
    this.symbol,
    this.date,
    this.monthlyTheme,
    this.overallRating,
    this.loveScore,
    this.careerScore,
    this.healthScore,
    this.financeScore,
    this.keyDates,
  });

  factory MonthlyHoroscope.fromJson(Map<String, dynamic> json) {
    final rawKeyDates = json['keyDates'];
    return MonthlyHoroscope(
      sign: _asString(json['sign']),
      symbol: _asString(json['symbol']),
      date: _asString(json['date']),
      monthlyTheme: _asString(json['monthlyTheme']),
      overallRating: _asInt(json['overallRating']),
      loveScore: _asInt(json['loveScore']),
      careerScore: _asInt(json['careerScore']),
      healthScore: _asInt(json['healthScore']),
      financeScore: _asInt(json['financeScore']),
      keyDates: rawKeyDates is List
          ? rawKeyDates
                .whereType<num>()
                .map((n) => n.toInt())
                .toList(growable: false)
          : null,
    );
  }

  final String? sign;
  final String? symbol;

  /// ISO `yyyy-MM-dd` of the month's start date.
  final String? date;

  final String? monthlyTheme;

  /// 0–100, unlike [DailyHoroscope.rating] which is 1–5.
  final int? overallRating;
  final int? loveScore;
  final int? careerScore;
  final int? healthScore;
  final int? financeScore;

  /// Days of the month (1–31) flagged as significant, e.g. `[4, 19, 23]`.
  final List<int>? keyDates;

  /// [date] formatted like `"August 2026"` — fixed English, same convention
  /// as [DailyHoroscope.formattedDate] (see its doc comment for why).
  /// Returns `null` if [date] is missing or unparseable, so callers can
  /// fall back to placeholder text.
  String? get formattedMonthLabel {
    final parsed = date == null ? null : DateTime.tryParse(date!);
    if (parsed == null) return null;
    return '${_monthNames[parsed.month - 1]} ${parsed.year}';
  }
}

/// One life-area score within a [YearlyHoroscope.areas] list.
@immutable
class YearlyHoroscopeArea {
  const YearlyHoroscopeArea({this.area, this.score});

  factory YearlyHoroscopeArea.fromJson(Map<String, dynamic> json) {
    return YearlyHoroscopeArea(
      area: _asString(json['area']),
      score: _asInt(json['score']),
    );
  }

  /// Vedika's own free-text label for this life area, e.g. `'career'`,
  /// `'health'` — not guaranteed to be one of this app's fixed
  /// [HoroscopeScoreId] values. The Horoscope Detail screen's Yearly period
  /// maps it onto the app's fixed 5-row scores card by keyword (see
  /// `_yearlyScoreId` in `horoscope_detail_screen.dart`), the same
  /// conservative "map only an unambiguous fit, otherwise drop it" rule
  /// `_sectionForTheme` already uses for the Daily period's theme.
  final String? area;

  /// Deliberately NOT clamped here — models parse, they don't reshape. The
  /// 0–100 scale is assumed (matching [YearlyHoroscope.overallScore] and
  /// [MonthlyHoroscope.overallRating]) but wasn't separately confirmed
  /// live, so the screen clamps defensively when it builds a score bar from
  /// this value.
  final int? score;
}

/// [YearlyHoroscope.luckyElements] — see that field's doc comment for which
/// of the response's lucky fields this deliberately leaves out.
@immutable
class YearlyLuckyElements {
  const YearlyLuckyElements({
    this.luckyColor,
    this.luckyDay,
    this.luckyDirection,
    this.luckyNumber,
    this.luckyTime,
  });

  factory YearlyLuckyElements.fromJson(Map<String, dynamic> json) {
    return YearlyLuckyElements(
      luckyColor: _asString(json['luckyColor']),
      luckyDay: _asString(json['luckyDay']),
      luckyDirection: _asString(json['luckyDirection']),
      luckyNumber: _asInt(json['luckyNumber']),
      luckyTime: _asString(json['luckyTime']),
    );
  }

  final String? luckyColor;

  /// e.g. `'Monday'` — rendered verbatim (English) same as
  /// [DailyHoroscope.theme]; no translation pipeline for it.
  final String? luckyDay;
  final String? luckyDirection;
  final int? luckyNumber;

  /// Raw string, rendered as-is. Unlike [DailyHoroscope.luckyTime], this
  /// isn't documented as a `"HH:mm-HH:mm"` range, so there's no
  /// `formattedLuckyTime`-style reformatting here — reformatting an unknown
  /// shape risks mangling it worse than showing it verbatim.
  final String? luckyTime;
}

/// `POST /v2/astrology/prediction/yearly` — one year's reading for a sign,
/// body `{"rashi": <lowercase English sign name>}`. See
/// `horoscope_repository.dart` for the endpoint, why it's a `POST` unlike
/// the daily/weekly/monthly `GET`s, and the correction to the earlier
/// (wrong) "yearly doesn't exist" conclusion.
///
/// Verified live 26 Aug 2026. The full response is considerably richer than
/// what's modelled here — the Horoscope Detail screen's Yearly period only
/// needs a period range, an overview, per-area scores, lucky elements and
/// remedies, so that's all this parses. Deliberately NOT modelled:
/// - `predictions` (a map keyed by domain → `{score, sentiment, text}`) —
///   duplicates [areas]' scores in a keyed-map shape that adds parsing
///   complexity without giving the screen anything [areas] doesn't already.
/// - `transitSummary`, `quote`, `rashi`, `rashiLord`, `dasha` — not
///   rendered by the Yearly period; `dasha` in particular already has a
///   dedicated home on the Kundli screen's Vimshottari Dasha tab, so
///   duplicating it here would be redundant, not just unused.
/// - [YearlyLuckyElements] leaves out `secondaryDirection` — the response
///   has a second, lower-priority direction alongside `luckyDirection`, but
///   the screen only has room for one direction chip (the same 3-chip
///   header the Daily period uses), so the primary one wins and the
///   secondary is dropped rather than parsed and never used.
/// - each [areas] entry's `description`/`sentiment` — the reused score-bar
///   widget only has room for a label + a percentage, the same shape
///   [MonthlyHoroscope]'s scores already use.
@immutable
class YearlyHoroscope {
  const YearlyHoroscope({
    this.periodStart,
    this.periodEnd,
    this.summary,
    this.overallScore,
    this.areas = const [],
    this.luckyElements,
    this.remedies = const [],
  });

  factory YearlyHoroscope.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'];
    final rawLucky = json['luckyElements'];
    return YearlyHoroscope(
      periodStart: _asString(json['periodStart']),
      periodEnd: _asString(json['periodEnd']),
      summary: _asString(json['summary']),
      overallScore: _asInt(json['overallScore']),
      areas: rawAreas is List
          ? rawAreas
                .whereType<Map>()
                .map(
                  (e) => YearlyHoroscopeArea.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const [],
      luckyElements: rawLucky is Map
          ? YearlyLuckyElements.fromJson(Map<String, dynamic>.from(rawLucky))
          : null,
      remedies: _asStringList(json['remedies']),
    );
  }

  /// ISO `yyyy-MM-dd` — Vedika computes a rolling 12 months from the
  /// request date, not a fixed calendar year, so this is normally "today".
  final String? periodStart;

  /// ISO `yyyy-MM-dd`, one year after [periodStart].
  final String? periodEnd;

  /// Free-text year-ahead overview — Vedika's one real yearly narrative,
  /// the equivalent of [WeeklyHoroscope.advice]/
  /// [MonthlyHoroscope.monthlyTheme] for this period.
  final String? summary;

  /// 0–100, same assumed convention as [MonthlyHoroscope.overallRating]
  /// (see the scale caveat on [YearlyHoroscopeArea.score]).
  final int? overallScore;

  final List<YearlyHoroscopeArea> areas;
  final YearlyLuckyElements? luckyElements;

  /// Vedika's `remedies` field shape isn't pinned down by the OpenAPI
  /// summary (a single string and a list of strings are both plausible for
  /// a field named this way) — [_asStringList] accepts either.
  final List<String> remedies;

  /// [periodStart]–[periodEnd] formatted like `"26 Aug 2026 – 26 Aug 2027"`
  /// — fixed English, same convention as [DailyHoroscope.formattedDate]
  /// (see its doc comment for why). Returns `null` if either date is
  /// missing or unparseable.
  String? get formattedPeriodRange {
    final start = periodStart == null
        ? null
        : DateTime.tryParse(periodStart!);
    final end = periodEnd == null ? null : DateTime.tryParse(periodEnd!);
    if (start == null || end == null) return null;
    String fmt(DateTime d) =>
        '${d.day} ${_monthNames[d.month - 1].substring(0, 3)} ${d.year}';
    return '${fmt(start)} – ${fmt(end)}';
  }
}

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

// Every string field in this file (sign names, dates, lucky colors, AND the
// free-text theme/prediction/advice/monthlyTheme/summary fields alike) is
// parsed through this one function, so [stripVedikaAttribution] runs here
// once rather than at each individual free-text field — see that
// function's doc comment for why it's safe to apply unconditionally.
String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return stripVedikaAttribution(value);
  return stripVedikaAttribution(value.toString());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Accepts either a single non-empty string or a list of them — see
/// [YearlyHoroscope.remedies]' doc comment for why both shapes are handled.
/// Anything else (missing key, wrong type, empty list) becomes `const []`.
List<String> _asStringList(dynamic value) {
  if (value == null) return const [];
  if (value is String) return value.isEmpty ? const [] : [value];
  if (value is List) {
    return value
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}
