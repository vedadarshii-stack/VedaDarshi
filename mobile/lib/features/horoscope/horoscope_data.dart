/// Immutable models for the Vedika `/v2/astrology/horoscope/{sign}` family
/// of endpoints (daily / weekly / monthly — **yearly does not exist**, see
/// `horoscope_repository.dart`).
///
/// `VedikaClient.get` already unwraps the `{success, data, …}` envelope, so
/// every `fromJson` here parses the inner `data` map directly. Vedika does
/// not document any field as guaranteed-present, and the sandbox is
/// separately known to serve one fixed sample chart regardless of what's
/// requested (see `VedikaConfig.isSandbox`) — so EVERY field below is
/// nullable and parsed defensively (wrong type / missing key both become
/// `null`, never a thrown exception). Screens must be able to render
/// sensibly with every field null.
///
/// Shapes were verified live against the sandbox 1 Aug 2026, e.g.:
/// ```
/// curl -s "https://api.vedika.io/sandbox/v2/astrology/horoscope/leo" | python3 -m json.tool
/// ```
library;

import 'package:flutter/foundation.dart' show immutable;

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

  /// [date] formatted like `"Saturday, 12 July 2026"` — fixed English
  /// weekday/month names, not localized per app language. This matches the
  /// existing convention elsewhere in the app (e.g.
  /// `BirthProfile.formatDate`) of formatting real dates in English
  /// regardless of the active locale; see the TYPOGRAPHY/localization notes
  /// in the project's top-level CLAUDE.md. Returns `null` if [date] is
  /// missing or unparseable, so callers can fall back to placeholder text.
  String? get formattedDate {
    final parsed = date == null ? null : DateTime.tryParse(date!);
    if (parsed == null) return null;
    return '${_weekdayNames[parsed.weekday - 1]}, ${parsed.day} '
        '${_monthNames[parsed.month - 1]} ${parsed.year}';
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

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
