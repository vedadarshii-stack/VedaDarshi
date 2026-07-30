import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/geo/city.dart';

/// Gender options offered on the Birth Details screen — see "A5 · Birth
/// Details Setup" (Figma node 8:2).
enum Gender { male, female, other }

/// A user's (or, later, a family/friend's) birth details, as captured on the
/// Birth Details screen.
///
/// Immutable — building a new [BirthProfile] rather than mutating an
/// existing one.
class BirthProfile {
  const BirthProfile({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.isBirthTimeUnknown,
    required this.city,
  });

  final String fullName;
  final Gender gender;

  /// Date-only — the time-of-day components are meaningless here and should
  /// be ignored (see [timeOfBirth] for the actual birth time).
  final DateTime dateOfBirth;

  final TimeOfDay timeOfBirth;

  /// When `true`, [timeOfBirth] holds the noon placeholder (12:00 PM) used
  /// for calculations, and the UI should show that fact rather than implying
  /// the user provided an exact time.
  final bool isBirthTimeUnknown;

  final City city;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender.name,
      'dateOfBirth': _dateOnlyIso(dateOfBirth),
      'timeOfBirth': _formatTimeOfDay(timeOfBirth),
      'isBirthTimeUnknown': isBirthTimeUnknown,
      'city': city.toJson(),
    };
  }

  factory BirthProfile.fromJson(Map<String, dynamic> json) {
    return BirthProfile(
      fullName: json['fullName'] as String,
      gender: Gender.values.byName(json['gender'] as String),
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      timeOfBirth: _parseTimeOfDay(json['timeOfBirth'] as String),
      isBirthTimeUnknown: json['isBirthTimeUnknown'] as bool,
      city: City.fromPersistedJson(json['city'] as Map<String, dynamic>),
    );
  }

  /// Maps this profile onto `/users/{uid}/birthProfiles/primary` (see
  /// `lib/core/data/firestore_refs.dart`).
  ///
  /// `isPrimary: true` is written unconditionally — this factory only ever
  /// produces the account owner's own profile document; a future
  /// family/friend profile would get its own writer.
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'gender': gender.name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'timeOfBirth': _formatTimeOfDay(timeOfBirth),
      'isBirthTimeUnknown': isBirthTimeUnknown,
      'isPrimary': true,
      'city': {
        'name': city.name,
        'state': city.state,
        'countryCode': city.countryCode,
        'latitude': city.latitude,
        'longitude': city.longitude,
        'timezoneId': city.timezoneId,
      },
      // Stored (not recomputed) because the astrology API needs the plain
      // numeric UTC offset at the birth moment, and recomputing it
      // server-side (e.g. in a Cloud Function) would mean shipping the same
      // IANA timezone database there too, just to re-derive a number the
      // client already computed once at save time.
      'utcOffsetMinutes': utcOffsetMinutesFor(city, dateOfBirth, timeOfBirth),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Strict Firestore parser — throws on malformed input. Kept private;
  /// callers should use [BirthProfile.tryFromFirestore] instead, which never
  /// throws.
  factory BirthProfile._fromFirestore(Map<String, dynamic> data) {
    final cityData = data['city'] as Map<String, dynamic>;
    final city = City(
      name: cityData['name'] as String,
      // Tolerate a missing/blank state — same as the local-cache City JSON
      // (city-states and some dataset entries have no admin1 value).
      state: (cityData['state'] as String?) ?? '',
      countryCode: cityData['countryCode'] as String,
      latitude: (cityData['latitude'] as num).toDouble(),
      longitude: (cityData['longitude'] as num).toDouble(),
      timezoneId: cityData['timezoneId'] as String,
    );

    // Tolerate dateOfBirth arriving as either a Firestore Timestamp (what
    // toFirestore() writes) or an ISO date string (defensive against a
    // hand-edited/older document shape).
    final rawDate = data['dateOfBirth'];
    final DateTime dateOfBirth;
    if (rawDate is Timestamp) {
      dateOfBirth = rawDate.toDate();
    } else if (rawDate is String) {
      dateOfBirth = DateTime.parse(rawDate);
    } else {
      throw const FormatException('dateOfBirth missing or of unknown type');
    }

    // An unrecognized gender string (future value added server-side, or a
    // corrupt document) falls back to Gender.other rather than throwing.
    final genderName = data['gender'] as String?;
    final gender = Gender.values.firstWhere(
      (g) => g.name == genderName,
      orElse: () => Gender.other,
    );

    return BirthProfile(
      fullName: data['fullName'] as String,
      gender: gender,
      dateOfBirth: dateOfBirth,
      timeOfBirth: _parseTimeOfDay(data['timeOfBirth'] as String),
      isBirthTimeUnknown: data['isBirthTimeUnknown'] as bool? ?? false,
      city: city,
    );
  }

  /// Defensive Firestore parser — a malformed/corrupt remote document must
  /// never crash the app (it's out of our control once the security rules
  /// allow arbitrary bytes into a doc the user might restore from another
  /// device or app version). Returns `null` on any problem instead, which
  /// callers treat the same as "no profile found remotely".
  static BirthProfile? tryFromFirestore(Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      return BirthProfile._fromFirestore(data);
    } catch (_) {
      return null;
    }
  }

  static String _dateOnlyIso(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// The UTC offset AT the birth date+time, in the birth city's timezone —
  /// e.g. `"GMT+5:30"`. See [utcOffsetLabelFor] for the shared calculation
  /// (also used by the Birth Details screen's live geo chip, before a full
  /// [BirthProfile] exists).
  String get utcOffsetLabel =>
      utcOffsetLabelFor(city, dateOfBirth, timeOfBirth);
}

/// Resolves the UTC offset AT [date] + [time] in [city]'s timezone — e.g.
/// `"GMT+5:30"` — via `package:timezone`, so historical DST/offset-rule
/// changes are accounted for correctly (not just the timezone's *current*
/// offset).
///
/// Shared by [BirthProfile.utcOffsetLabel] and the Birth Details screen's
/// geo-detected chip, which needs to preview the offset before a full
/// [BirthProfile] can be constructed (name/gender aren't filled in yet).
///
/// Must not throw for an unknown/unregistered timezone id — falls back to a
/// bare `"GMT"` instead (guards against a corrupt/edited city entry; this
/// should never happen with the bundled dataset).
String utcOffsetLabelFor(City city, DateTime date, TimeOfDay time) {
  final offset = _resolveOffset(city, date, time);
  if (offset == null) return 'GMT';

  final sign = offset.isNegative ? '-' : '+';
  final absOffset = offset.abs();
  final hours = absOffset.inHours;
  final minutes = absOffset.inMinutes % 60;
  return 'GMT$sign$hours:${minutes.toString().padLeft(2, '0')}';
}

/// The UTC offset AT [date] + [time] in [city]'s timezone, in minutes
/// (e.g. `330` for `GMT+5:30`, `-240` for `GMT-4:00`) — the numeric form the
/// astrology API needs (see [BirthProfile.toFirestore]'s `utcOffsetMinutes`
/// field).
///
/// Shares [utcOffsetLabelFor]'s `package:timezone` resolution via
/// [_resolveOffset]. Must not throw for an unknown/unregistered timezone id
/// — falls back to `0` instead, same guard as [utcOffsetLabelFor]'s bare
/// `"GMT"` fallback.
int utcOffsetMinutesFor(City city, DateTime date, TimeOfDay time) {
  final offset = _resolveOffset(city, date, time);
  return (offset ?? Duration.zero).inMinutes;
}

/// Shared `package:timezone` lookup behind [utcOffsetLabelFor] and
/// [utcOffsetMinutesFor] — returns `null` (rather than throwing) for an
/// unknown/unregistered timezone id.
Duration? _resolveOffset(City city, DateTime date, TimeOfDay time) {
  try {
    final location = tz.getLocation(city.timezoneId);
    final birthMoment = tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return birthMoment.timeZoneOffset;
  } catch (_) {
    return null;
  }
}
