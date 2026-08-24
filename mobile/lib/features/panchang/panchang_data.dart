import 'package:flutter/foundation.dart' show immutable;

// ---------------------------------------------------------------------------
// Defensive JSON helpers
// ---------------------------------------------------------------------------
//
// Vedika does not publish a fixed schema for these endpoints, and the
// VERIFIED sandbox sample already omits fields its own spec mentions (e.g.
// `guidance` and `datetime` are absent from a real `/panchang/today` call
// even though the documented shape lists them). Every value below is
// therefore parsed through these null-tolerant helpers rather than an `as`
// cast — a missing or wrongly-typed key degrades to `null`, it never
// throws, so one absent field can never crash the whole screen.

String? _str(dynamic v) => v is String ? v : null;

int? _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return null;
}

double? _dbl(dynamic v) {
  if (v is num) return v.toDouble();
  return null;
}

bool? _bool(dynamic v) => v is bool ? v : null;

List<String>? _strList(dynamic v) =>
    v is List ? v.whereType<String>().toList() : null;

Map<String, dynamic>? _map(dynamic v) => v is Map<String, dynamic> ? v : null;

/// Parses an ISO-8601 timestamp, tolerating anything that isn't a
/// well-formed date string rather than throwing.
DateTime? _dateTime(dynamic v) {
  if (v is! String) return null;
  try {
    return DateTime.parse(v);
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Panchang — GET /v2/astrology/panchang/today | /v2/astrology/panchang/{date}
// ---------------------------------------------------------------------------

/// One day's panchang, per the Vedika Intelligence API.
///
/// EVERY field is nullable, deliberately — the panchang endpoint's real
/// response (verified 1 Aug 2026 against the sandbox) does not include
/// `coordinates`, `datetime` or `guidance` even though those are documented,
/// and there is no guarantee future calls will include everything either.
/// Callers must supply their own fallback for any field they render (the
/// Panchang screen falls back to its static placeholder copy row-by-row —
/// see `panchang_screen.dart`'s `_elementsFrom`).
///
/// SUNRISE/SUNSET/MOONRISE/MOONSET: available after all — see [sunTimes].
/// This doc previously said they did "not exist", which was true only of
/// `/v2/astrology/panchang/today`, the one route this app happened to call.
/// The `/v2/astrology/panchang` bundle returns them under a `sunrise` block
/// when asked with `include=sunrise` (21 Aug 2026). The lesson is the one
/// already recorded in projects/CLAUDE.md for the dosha endpoints: "the
/// endpoint I happened to call doesn't have it" is not "the API doesn't
/// have it" — there are 615 paths in the contract, so search it before
/// concluding something is impossible.
@immutable
class PanchangData {
  const PanchangData({
    this.coordinates,
    this.datetime,
    this.tithi,
    this.nakshatra,
    this.yoga,
    this.karana,
    this.vara,
    this.masa,
    this.ritu,
    this.dishaShool,
    this.guidance,
    this.sunTimes,
    this.festivals = const [],
  });

  final PanchangCoordinates? coordinates;
  final DateTime? datetime;
  final PanchangTithi? tithi;
  final PanchangNakshatra? nakshatra;
  final PanchangYoga? yoga;
  final PanchangKarana? karana;
  final PanchangVara? vara;
  final PanchangMasa? masa;
  final PanchangRitu? ritu;
  final PanchangDishaShool? dishaShool;
  final PanchangGuidance? guidance;

  /// Real sunrise/sunset/moonrise/moonset for the requested location.
  ///
  /// Null unless the request asked for `include=sunrise`. See
  /// [PanchangSunTimes].
  final PanchangSunTimes? sunTimes;

  /// Festivals near this date, from the `upcoming_festivals` block
  /// (`include=festivals`). Empty unless the request asked for it.
  final List<PanchangFestival> festivals;

  /// The festival falling on the requested day, or null.
  ///
  /// Note the block is called UPCOMING festivals: on most days the nearest
  /// entry is days away. A card headed "Festival today" must therefore show
  /// something only when [PanchangFestival.isToday] — anything else would
  /// swap one wrong festival for another.
  PanchangFestival? get festivalToday {
    for (final festival in festivals) {
      if (festival.isToday) return festival;
    }
    return null;
  }

  factory PanchangData.fromJson(Map<String, dynamic> json) {
    return PanchangData(
      coordinates: PanchangCoordinates.fromJson(_map(json['coordinates'])),
      datetime: _dateTime(json['datetime']),
      tithi: PanchangTithi.fromJson(_map(json['tithi'])),
      nakshatra: PanchangNakshatra.fromJson(_map(json['nakshatra'])),
      yoga: PanchangYoga.fromJson(_map(json['yoga'])),
      karana: PanchangKarana.fromJson(_map(json['karana'])),
      // `vara` on /v2/astrology/panchang/today, `vaara` on the
      // /v2/astrology/panchang bundle. Accept BOTH so the model does not
      // care which endpoint produced it (21 Aug 2026).
      vara: PanchangVara.fromJson(_map(json['vara'] ?? json['vaara'])),
      masa: PanchangMasa.fromJson(_map(json['masa'])),
      ritu: PanchangRitu.fromJson(_map(json['ritu'])),
      dishaShool: PanchangDishaShool.fromJson(_map(json['disha_shool'])),
      guidance: PanchangGuidance.fromJson(_map(json['guidance'])),
      // Present only when the request asks for it via `include=sunrise`
      // (the bundle endpoint). Null on the plain /today route.
      sunTimes: PanchangSunTimes.fromJson(_map(json['sunrise'])),
      festivals: PanchangFestival._listFrom(json['upcoming_festivals']),
    );
  }
}

@immutable
class PanchangCoordinates {
  const PanchangCoordinates({this.latitude, this.longitude});

  final double? latitude;
  final double? longitude;

  static PanchangCoordinates? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangCoordinates(
      latitude: _dbl(json['latitude']),
      longitude: _dbl(json['longitude']),
    );
  }
}

@immutable
class PanchangTithi {
  const PanchangTithi({
    this.name,
    this.number,
    this.paksha,
    this.lord,
    this.percentageRemaining,
  });

  final String? name;
  final int? number;
  final String? paksha;
  final String? lord;

  /// How much of this tithi is left, as a 0–100 percentage. There is no
  /// "till HH:mm" timestamp anywhere in this response — a screen that wants
  /// an expiry hint should show this percentage rather than fabricate a
  /// clock time the API never gave it.
  final double? percentageRemaining;

  static PanchangTithi? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangTithi(
      name: _str(json['name']),
      number: _int(json['number']),
      // String on /today, `{id, name}` on the bundle — accept either.
      paksha: _str(json['paksha']) ?? _str(_map(json['paksha'])?['name']),
      lord: _str(json['lord']),
      percentageRemaining: _dbl(json['percentageRemaining']),
    );
  }
}

@immutable
class PanchangNakshatra {
  const PanchangNakshatra({
    this.name,
    this.number,
    this.pada,
    this.lord,
    this.deity,
    this.gana,
  });

  final String? name;
  final int? number;
  final int? pada;
  final String? lord;
  final String? deity;
  final String? gana;

  static PanchangNakshatra? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangNakshatra(
      name: _str(json['name']),
      number: _int(json['number']),
      pada: _int(json['pada']),
      lord: _str(json['lord']),
      deity: _str(json['deity']),
      gana: _str(json['gana']),
    );
  }
}

@immutable
class PanchangYoga {
  const PanchangYoga({this.name, this.number});

  final String? name;
  final int? number;

  static PanchangYoga? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangYoga(name: _str(json['name']), number: _int(json['number']));
  }
}

@immutable
class PanchangKarana {
  const PanchangKarana({this.name, this.number});

  final String? name;
  final int? number;

  static PanchangKarana? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangKarana(
      name: _str(json['name']),
      number: _int(json['number']),
    );
  }
}

@immutable
class PanchangVara {
  const PanchangVara({this.name, this.lord, this.luckyColor, this.gemstone});

  final String? name;

  /// Ruling planet of the weekday, e.g. `"Venus"` on a Friday.
  final String? lord;

  /// e.g. `"White or Pink"`. From `interpretation.luckyColor`.
  ///
  /// ADDED 21 Aug 2026. Home's "Lucky Color" tile was a fixed "Gold" for
  /// every user on every day, under a comment stating that no endpoint this
  /// app calls returns one. The field was in the same response the tile's
  /// neighbours already used.
  final String? luckyColor;

  final String? gemstone;

  static PanchangVara? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // The bundle returns BOTH `name` ("Shukravara") and `englishName`
    // ("Friday"); /today returns only `name`, already in English. The screen
    // shows a weekday, so English wins when offered.
    final interpretation = _map(json['interpretation']);
    return PanchangVara(
      name: _str(json['englishName']) ?? _str(json['name']),
      lord: _str(json['lord']),
      luckyColor: _str(interpretation?['luckyColor']),
      gemstone: _str(interpretation?['gemstone']),
    );
  }
}

@immutable
class PanchangMasa {
  const PanchangMasa({this.name, this.id, this.sunSign, this.deityAssociation});

  final String? name;
  final int? id;
  final String? sunSign;
  final String? deityAssociation;

  static PanchangMasa? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangMasa(
      name: _str(json['name']),
      id: _int(json['id']),
      sunSign: _str(json['sunSign']),
      deityAssociation: _str(json['deityAssociation']),
    );
  }
}

@immutable
class PanchangRitu {
  const PanchangRitu({this.name, this.englishName, this.id});

  final String? name;
  final String? englishName;
  final int? id;

  static PanchangRitu? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangRitu(
      name: _str(json['name']),
      englishName: _str(json['englishName']),
      id: _int(json['id']),
    );
  }
}

@immutable
class PanchangDishaShool {
  const PanchangDishaShool({
    this.direction,
    this.description,
    this.safeDirections,
    this.remedies,
  });

  final String? direction;
  final String? description;
  final List<String>? safeDirections;

  /// Documented in the endpoint's spec but absent from the verified sandbox
  /// response — nullable like everything else here, no screen renders it yet.
  final List<String>? remedies;

  static PanchangDishaShool? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangDishaShool(
      direction: _str(json['direction']),
      description: _str(json['description']),
      safeDirections: _strList(json['safeDirections']),
      remedies: _strList(json['remedies']),
    );
  }
}

@immutable
class PanchangGuidance {
  const PanchangGuidance({
    this.activitiesToAvoid,
    this.bestActivities,
    this.summary,
    this.overallAuspiciousness,
  });

  final List<String>? activitiesToAvoid;
  final List<String>? bestActivities;

  /// A written reading of the day, referencing this day's actual tithi,
  /// nakshatra and yoga.
  ///
  /// ADDED 21 Aug 2026 — it was in the response all along, just never
  /// parsed, while the Panchang screen showed a fixed "Today's Spiritual
  /// Advice" paragraph that never changed.
  final String? summary;

  /// e.g. `"Challenging"` / `"Auspicious"`.
  final String? overallAuspiciousness;

  static PanchangGuidance? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangGuidance(
      activitiesToAvoid: _strList(json['activitiesToAvoid']),
      bestActivities: _strList(json['bestActivities']),
      summary: _str(json['summary']),
      overallAuspiciousness: _str(json['overallAuspiciousness']),
    );
  }
}

// ---------------------------------------------------------------------------
// Muhurta — GET /v2/daily/muhurta
// ---------------------------------------------------------------------------

/// Formats a clock time the same way this app's static muhurat copy is
/// written, e.g. `09:06` (2-digit hour, zero-padded).
String _formatClock(DateTime dt) {
  var hour = dt.hour % 12;
  if (hour == 0) hour = 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${hour.toString().padLeft(2, '0')}:$minute';
}

/// Formats a start–end pair as `09:06 – 10:42 AM` (one shared trailing
/// AM/PM when both ends fall in the same half of the day) or
/// `11:54 AM – 12:47 PM` (crossing noon) — matching
/// `PanchangStaticData.muhurats`' existing hand-written format exactly, so
/// swapping in a real value never looks different from its neighbours.
String _formatClockRange(DateTime start, DateTime end) {
  final startSuffix = start.hour >= 12 ? 'PM' : 'AM';
  final endSuffix = end.hour >= 12 ? 'PM' : 'AM';
  final startText = _formatClock(start);
  final endText = _formatClock(end);
  if (startSuffix == endSuffix) {
    return '$startText – $endText $endSuffix';
  }
  return '$startText $startSuffix – $endText $endSuffix';
}

/// Daily muhurat windows, per the Vedika Intelligence API.
///
/// Only [rahuKaal] is consumed today — it is the one field this endpoint
/// returns that maps to an existing card on the Panchang screen (Rahu Kaal).
/// [choghadiya] and [hora] are modelled at a useful-but-partial level of
/// detail (enough for a future "view all muhurat timings" screen — see that
/// still-inert link on `panchang_screen.dart`) rather than exhaustively,
/// since nothing renders them yet; extend them when that screen is built.
/// This endpoint has no Abhijit Muhurat, Yamaganda or Gulika Kaal field at
/// all, so those three cards stay on their static placeholder values.
@immutable
class MuhurtaData {
  const MuhurtaData({this.rahuKaal, this.choghadiya, this.hora});

  final RahuKaal? rahuKaal;
  final ChoghadiyaSchedule? choghadiya;
  final HoraSchedule? hora;

  factory MuhurtaData.fromJson(Map<String, dynamic> json) {
    return MuhurtaData(
      rahuKaal: RahuKaal.fromJson(_map(json['rahu_kaal'])),
      choghadiya: ChoghadiyaSchedule.fromJson(_map(json['choghadiya'])),
      hora: HoraSchedule.fromJson(_map(json['hora'])),
    );
  }
}

@immutable
class RahuKaal {
  const RahuKaal({this.start, this.end, this.isDay});

  /// TRUE UTC, converted with `.toLocal()` before display — CHANGED
  /// 21 Aug 2026.
  ///
  /// These were previously read as-parsed, on the sandbox-derived belief
  /// that the trailing `Z` was a mislabelled wall-clock time and that
  /// `.toLocal()` would double-shift it. **Production does not behave that
  /// way** — it stamps genuine UTC, verified against a request whose
  /// correct answer is independently known:
  ///
  /// ```
  /// 2026-08-21 Jaipur -> 05:24:09Z – 07:01:26Z
  ///                      = 10:54 – 12:31 IST, is_day:true, 1.62 h
  /// ```
  ///
  /// Friday Rahu Kaal really is ~10:30–12:00, so the UTC reading is the
  /// correct one and the conversion is required. Read as-parsed it rendered
  /// as "05:24 – 07:01 AM" — plausible, and wrong by 5h30m.
  final DateTime? start;
  final DateTime? end;
  final bool? isDay;

  /// `09:06 – 10:42 AM`-style range in the DEVICE's local time, or `null`
  /// when the window is missing, unparseable, or self-contradictory.
  ///
  /// The `!e.isAfter(s)` guard is not defensive padding — Vedika really does
  /// return `end` BEFORE `start` when the endpoint is called without its
  /// `datetime`/location parameters (see `PanchangRepository.fetchMuhurta`,
  /// which now always sends them). Returning `null` makes the caller fall
  /// back to its placeholder instead of printing an impossible ~10-hour
  /// "06:55 – 05:33 PM" Rahu Kaal, which is what shipped before.
  String? get formattedRange {
    final s = start?.toLocal();
    final e = end?.toLocal();
    if (s == null || e == null) return null;
    if (!e.isAfter(s)) return null;
    return _formatClockRange(s, e);
  }

  static RahuKaal? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return RahuKaal(
      start: _dateTime(json['start']),
      end: _dateTime(json['end']),
      isDay: _bool(json['is_day']),
    );
  }
}

/// Whether a choghadiya window is auspicious, neutral or to be avoided.
///
/// [unknown] is a real state, not padding: Vedika omits `vpiType` on some
/// windows, and a screen must be able to show the timing without asserting
/// a quality it was never given.
enum ChoghadiyaQuality { good, neutral, bad, unknown }

@immutable
class ChoghadiyaPeriod {
  const ChoghadiyaPeriod({
    this.id,
    this.name,
    this.vpiType,
    this.element,
    this.lord,
    this.bestFor,
    this.start,
    this.end,
    this.isDay,
  });

  final int? id;
  final String? name;

  /// One of `"good"` / `"neutral"` / `"bad"`, as returned by Vedika.
  final String? vpiType;
  final String? element;
  final String? lord;
  final String? bestFor;
  final DateTime? start;
  final DateTime? end;
  final bool? isDay;

  /// `06:00 – 07:36 AM`-style local range, or null when either end is
  /// missing or the window is self-contradictory.
  ///
  /// Converts with `.toLocal()` and rejects `end <= start` for exactly the
  /// same reasons as [RahuKaal.formattedRange] — same endpoint, same
  /// timestamps, so the same two hazards apply.
  String? get formattedRange {
    final s = start?.toLocal();
    final e = end?.toLocal();
    if (s == null || e == null || !e.isAfter(s)) return null;
    return _formatClockRange(s, e);
  }

  /// Coarse quality of this window, normalised from Vedika's `vpiType`.
  ChoghadiyaQuality get quality {
    switch (vpiType?.trim().toLowerCase()) {
      case 'good':
        return ChoghadiyaQuality.good;
      case 'bad':
        return ChoghadiyaQuality.bad;
      case 'neutral':
        return ChoghadiyaQuality.neutral;
      default:
        return ChoghadiyaQuality.unknown;
    }
  }

  static ChoghadiyaPeriod? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final choghadiya = _map(json['choghadiya']);
    return ChoghadiyaPeriod(
      id: _int(json['id']),
      name: _str(choghadiya?['name']),
      vpiType: _str(choghadiya?['vpiType']),
      element: _str(choghadiya?['element']),
      lord: _str(choghadiya?['lord']),
      bestFor: _str(choghadiya?['bestFor']),
      start: _dateTime(json['start']),
      end: _dateTime(json['end']),
      isDay: _bool(json['isDay']),
    );
  }

  static List<ChoghadiyaPeriod> _listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(ChoghadiyaPeriod.fromJson)
        .whereType<ChoghadiyaPeriod>()
        .toList();
  }
}

@immutable
class ChoghadiyaSchedule {
  const ChoghadiyaSchedule({this.day = const [], this.night = const []});

  final List<ChoghadiyaPeriod> day;
  final List<ChoghadiyaPeriod> night;

  static ChoghadiyaSchedule? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ChoghadiyaSchedule(
      day: ChoghadiyaPeriod._listFromJson(json['day']),
      night: ChoghadiyaPeriod._listFromJson(json['night']),
    );
  }
}

@immutable
class HoraPeriod {
  const HoraPeriod({this.id, this.start, this.end, this.isDay});

  final int? id;
  final DateTime? start;
  final DateTime? end;
  final bool? isDay;

  static HoraPeriod? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return HoraPeriod(
      id: _int(json['id']),
      start: _dateTime(json['start']),
      end: _dateTime(json['end']),
      isDay: _bool(json['isDay']),
    );
  }

  static List<HoraPeriod> _listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(HoraPeriod.fromJson)
        .whereType<HoraPeriod>()
        .toList();
  }
}

@immutable
class HoraSchedule {
  const HoraSchedule({this.periods = const []});

  final List<HoraPeriod> periods;

  static HoraSchedule? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return HoraSchedule(periods: HoraPeriod._listFromJson(json['hora']));
  }
}

/// Sunrise, sunset, moonrise and moonset for the requested coordinates.
///
/// From the `sunrise` add-on block of `/v2/astrology/panchang`
/// (`include=sunrise`). These are the first REAL values the app has had for
/// this card — it previously showed a fixed `05:52 AM / 07:04 PM /
/// 11:20 AM / 11:52 PM` to every user in every city on every date.
///
/// Timestamps arrive with a real offset (`2026-08-20T06:00:29+05:30`), so
/// they are converted with `.toLocal()` before formatting — same rule as
/// [RahuKaal], and unlike it these have never been ambiguous.
///
/// ⚠️ KNOWN UPSTREAM QUIRK: this block is computed for the SERVER's current
/// day, not the `datetime` sent with the request — a call for 21 Aug 2026
/// returned a `sunrise` block stamped 20 Aug while `tithi`/`vaara` in the
/// same response correctly described the 21st. Sunrise moves by about a
/// minute a day, so the displayed time is right to within a minute, but the
/// date it belongs to can be off by one. Do not use these timestamps' DATE
/// for anything; use their time-of-day only.
@immutable
class PanchangSunTimes {
  const PanchangSunTimes({
    this.sunrise,
    this.sunset,
    this.moonrise,
    this.moonset,
  });

  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? moonrise;
  final DateTime? moonset;

  /// `05:52 AM`-style local clock time, or null when absent.
  String? get sunriseText => _clock(sunrise);
  String? get sunsetText => _clock(sunset);
  String? get moonriseText => _clock(moonrise);
  String? get moonsetText => _clock(moonset);

  static String? _clock(DateTime? t) {
    if (t == null) return null;
    final local = t.toLocal();
    return '${_formatClock(local)} ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  static PanchangSunTimes? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangSunTimes(
      sunrise: _dateTime(json['sunrise']),
      sunset: _dateTime(json['sunset']),
      moonrise: _dateTime(json['moonrise']),
      moonset: _dateTime(json['moonset']),
    );
  }
}


/// One festival from the panchang bundle's `upcoming_festivals` block.
///
/// ADDED 21 Aug 2026. The Panchang screen's festival card was the constant
/// "Kamika Ekadashi", and Home's was "Sawan Somvar — tomorrow". Both were
/// simply wrong on 21 Aug 2026: the day was Shukla Navami in Bhadrapada, so
/// neither an Ekadashi nor in Sawan, and it was a Friday rather than a
/// Somvar. Real festivals were available in the same response.
///
/// [confidence] is Vedika's own word — entries are marked `"verified"` and
/// carry a [source] URL. Worth surfacing eventually; a festival date the API
/// is unsure about should not be stated as flatly as one it has verified.
@immutable
class PanchangFestival {
  const PanchangFestival({
    this.name,
    this.date,
    this.daysFromNow,
    this.description,
    this.confidence,
    this.source,
  });

  final String? name;

  /// `YYYY-MM-DD`, as returned.
  final String? date;

  /// 0 = today. Vedika computes this, so it is preferred over parsing
  /// [date] and comparing locally — that would reintroduce exactly the
  /// timezone-boundary bug that made the whole panchang a day late.
  final int? daysFromNow;

  final String? description;
  final String? confidence;
  final String? source;

  bool get isToday => daysFromNow == 0;

  static PanchangFestival? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangFestival(
      name: _str(json['name']),
      date: _str(json['date']),
      daysFromNow: _int(json['daysFromNow']),
      description: _str(json['description']),
      confidence: _str(json['confidence']),
      source: _str(json['source']),
    );
  }

  static List<PanchangFestival> _listFrom(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(PanchangFestival.fromJson)
        .whereType<PanchangFestival>()
        .toList();
  }
}
