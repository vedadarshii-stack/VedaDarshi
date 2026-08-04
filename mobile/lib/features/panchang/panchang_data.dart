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
/// There is deliberately NO sunrise/sunset/moonrise/moonset field here —
/// this endpoint does not return them (verified), so the screen keeps its
/// static placeholder for that card unconditionally rather than this model
/// inventing a field that doesn't exist.
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

  factory PanchangData.fromJson(Map<String, dynamic> json) {
    return PanchangData(
      coordinates: PanchangCoordinates.fromJson(_map(json['coordinates'])),
      datetime: _dateTime(json['datetime']),
      tithi: PanchangTithi.fromJson(_map(json['tithi'])),
      nakshatra: PanchangNakshatra.fromJson(_map(json['nakshatra'])),
      yoga: PanchangYoga.fromJson(_map(json['yoga'])),
      karana: PanchangKarana.fromJson(_map(json['karana'])),
      vara: PanchangVara.fromJson(_map(json['vara'])),
      masa: PanchangMasa.fromJson(_map(json['masa'])),
      ritu: PanchangRitu.fromJson(_map(json['ritu'])),
      dishaShool: PanchangDishaShool.fromJson(_map(json['disha_shool'])),
      guidance: PanchangGuidance.fromJson(_map(json['guidance'])),
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
      paksha: _str(json['paksha']),
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
  const PanchangVara({this.name, this.lord});

  final String? name;
  final String? lord;

  static PanchangVara? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangVara(name: _str(json['name']), lord: _str(json['lord']));
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
  const PanchangGuidance({this.activitiesToAvoid, this.bestActivities});

  final List<String>? activitiesToAvoid;
  final List<String>? bestActivities;

  static PanchangGuidance? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PanchangGuidance(
      activitiesToAvoid: _strList(json['activitiesToAvoid']),
      bestActivities: _strList(json['bestActivities']),
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

  /// Deliberately read AS PARSED — [start]/[end]'s `.hour`/`.minute` are
  /// used directly by [formattedRange] WITHOUT calling `.toLocal()`.
  /// Vedika stamps these with a trailing `Z`, but the sandbox's fixed
  /// 1995-01-01 sample is wall-clock local time for that sample city, not
  /// true UTC (verified: the returned window sits in the afternoon, which
  /// is consistent with a Sunday Rahu Kaal in IST, not with a UTC morning
  /// reading) — running it through `.toLocal()` would silently double-shift
  /// it by the device's own timezone offset on top of that mislabeling.
  final DateTime? start;
  final DateTime? end;
  final bool? isDay;

  /// `09:06 – 10:42 AM`-style range, or `null` if either timestamp is
  /// missing/unparseable.
  String? get formattedRange {
    final s = start;
    final e = end;
    if (s == null || e == null) return null;
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
