import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/vedika/vedika_client.dart';
import '../profile/birth_profile.dart';
import 'kundli_dasha_data.dart';
import 'kundli_data.dart';
import 'kundli_dosha_data.dart';

/// The birth parameters a kundli is computed from — a natal chart is a pure
/// function of these four values and never changes for a given birth, so
/// this is both what [KundliRepository] caches on and what
/// [kundliDataProvider] families over.
@immutable
class KundliRequest {
  const KundliRequest({
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.tzOffset,
  });

  /// LOCAL wall-clock birth moment, no timezone suffix — Vedika interprets
  /// this together with [tzOffset] rather than as UTC (see
  /// `VedikaClient`'s call site in [KundliRepository.fetch]).
  final DateTime datetime;
  final double latitude;
  final double longitude;

  /// UTC offset formatted the way Vedika expects it, e.g. `"+05:30"`.
  final String tzOffset;

  /// Builds the request Vedika needs from a saved [BirthProfile], reusing
  /// the same `package:timezone`-backed offset resolution the Birth
  /// Details screen and [BirthProfile.utcOffsetLabel] already use (see
  /// `utcOffsetMinutesFor` in `birth_profile.dart`), just reformatted from
  /// `"GMT+5:30"` into the bare `"+05:30"` Vedika's API takes.
  factory KundliRequest.fromBirthProfile(BirthProfile profile) {
    final datetime = DateTime(
      profile.dateOfBirth.year,
      profile.dateOfBirth.month,
      profile.dateOfBirth.day,
      profile.timeOfBirth.hour,
      profile.timeOfBirth.minute,
    );
    final offsetMinutes = utcOffsetMinutesFor(
      profile.city,
      profile.dateOfBirth,
      profile.timeOfBirth,
    );
    return KundliRequest(
      datetime: datetime,
      latitude: profile.city.latitude,
      longitude: profile.city.longitude,
      tzOffset: _formatTzOffset(offsetMinutes),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is KundliRequest &&
        other.datetime == datetime &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.tzOffset == tzOffset;
  }

  @override
  int get hashCode => Object.hash(datetime, latitude, longitude, tzOffset);
}

/// `330` minutes → `"+05:30"`, `-240` → `"-04:00"`.
String _formatTzOffset(int minutes) {
  final sign = minutes.isNegative ? '-' : '+';
  final absMinutes = minutes.abs();
  final hours = (absMinutes ~/ 60).toString().padLeft(2, '0');
  final mins = (absMinutes % 60).toString().padLeft(2, '0');
  return '$sign$hours:$mins';
}

/// Formats [dateTime] the way Vedika expects — LOCAL wall-clock, no zone
/// suffix, always with seconds (e.g. `"1990-08-14T06:45:00"`).
String _formatLocalDateTime(DateTime dateTime) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dateTime.year.toString().padLeft(4, '0')}-${two(dateTime.month)}-'
      '${two(dateTime.day)}T${two(dateTime.hour)}:${two(dateTime.minute)}:'
      '${two(dateTime.second)}';
}

/// Fetches a birth chart — plus, since 1 Aug 2026, dosha verdicts and the
/// Vimshottari dasha timeline — from Vedika's `/v2/astrology/*` endpoints.
///
/// **Cached in memory, keyed by [KundliRequest]**, one map per endpoint — a
/// natal chart (and everything derived from the same birth moment) never
/// changes for the same birth moment/location, so a given request is never
/// re-sent to the network twice in a session. Unlike Panchang or Horoscope
/// (which are recomputed per calendar day and need a day-scoped cache), none
/// of these three have any time-based invalidation to worry about, so a
/// plain in-memory map is enough for each — no TTL, no Firestore layer.
///
/// These caches sit one level *below* Riverpod's own
/// [FutureProvider.family], which only keeps a parameter's result around
/// while something is actively watching it — navigating away from this
/// screen and back would otherwise refetch. Caching here means that second
/// fetch resolves instantly from memory instead.
///
/// The three fetch methods are deliberately INDEPENDENT of one another —
/// each has its own cache, its own network call, and its own failure mode.
/// [kundliDoshasProvider] failing (or the dosha call never being retried)
/// must never block [kundliDataProvider], and vice versa; see
/// `kundli_chart_screen.dart`'s "a failure in one tab must not break the
/// Chart tab" rule.
class KundliRepository {
  KundliRepository(this._client);

  final VedikaClient _client;
  final Map<KundliRequest, KundliData> _cache = {};
  final Map<KundliRequest, AllDoshasData> _doshasCache = {};
  final Map<KundliRequest, VimshottariDashaData> _dashaCache = {};

  Future<KundliData> fetch({
    required DateTime datetime,
    required double lat,
    required double lon,
    required String tzOffset,
  }) async {
    final request = KundliRequest(
      datetime: datetime,
      latitude: lat,
      longitude: lon,
      tzOffset: tzOffset,
    );

    final cached = _cache[request];
    if (cached != null) return cached;

    final data = await _client.post(
      '/v2/astrology/kundli',
      body: _requestBody(request),
    );
    final parsed = KundliData.fromJson(data);
    // Only cached on a SUCCESSFUL parse — a failed request must stay
    // uncached so the screen's Retry button actually retries the network
    // call instead of replaying the same failure from memory.
    _cache[request] = parsed;
    return parsed;
  }

  /// Fetches `POST /v2/astrology/all-doshas` — Mangal Dosha, Kaal Sarp
  /// Dosha and Pitru Dosha in one call (see `kundli_dosha_data.dart`).
  Future<AllDoshasData> fetchDoshas({
    required DateTime datetime,
    required double lat,
    required double lon,
    required String tzOffset,
  }) async {
    final request = KundliRequest(
      datetime: datetime,
      latitude: lat,
      longitude: lon,
      tzOffset: tzOffset,
    );

    final cached = _doshasCache[request];
    if (cached != null) return cached;

    final data = await _client.post(
      '/v2/astrology/all-doshas',
      body: _requestBody(request),
    );
    final parsed = AllDoshasData.fromJson(data);
    _doshasCache[request] = parsed;
    return parsed;
  }

  /// Fetches `POST /v2/astrology/vimshottari-dasha` (see
  /// `kundli_dasha_data.dart`).
  Future<VimshottariDashaData> fetchDasha({
    required DateTime datetime,
    required double lat,
    required double lon,
    required String tzOffset,
  }) async {
    final request = KundliRequest(
      datetime: datetime,
      latitude: lat,
      longitude: lon,
      tzOffset: tzOffset,
    );

    final cached = _dashaCache[request];
    if (cached != null) return cached;

    final data = await _client.post(
      '/v2/astrology/vimshottari-dasha',
      body: _requestBody(request),
    );
    final parsed = VimshottariDashaData.fromJson(data);
    _dashaCache[request] = parsed;
    return parsed;
  }

  /// The `{datetime, latitude, longitude, timezone}` body every one of
  /// these `/v2/astrology/*` endpoints takes, built from [request] the same
  /// way for all three so they never drift apart.
  Map<String, dynamic> _requestBody(KundliRequest request) => {
    'datetime': _formatLocalDateTime(request.datetime),
    'latitude': request.latitude,
    'longitude': request.longitude,
    'timezone': request.tzOffset,
  };
}

final kundliRepositoryProvider = Provider<KundliRepository>((ref) {
  return KundliRepository(ref.watch(vedikaClientProvider));
});

/// The birth chart for [request]'s birth parameters.
///
/// See [KundliRepository]'s doc comment for the caching story — this family
/// only re-fetches when [request] itself changes, and the repository
/// beneath it skips the network call entirely for a request already
/// answered earlier in the session (e.g. navigating back to this screen).
final kundliDataProvider = FutureProvider.family<KundliData, KundliRequest>((
  ref,
  request,
) {
  return ref
      .watch(kundliRepositoryProvider)
      .fetch(
        datetime: request.datetime,
        lat: request.latitude,
        lon: request.longitude,
        tzOffset: request.tzOffset,
      );
});

/// The dosha verdicts for [request]'s birth parameters — feeds the Kundli
/// Chart screen's dosha-summary banner. Independent of [kundliDataProvider]
/// (own network call, own cache, own failure mode) — see
/// [KundliRepository]'s class doc.
final kundliDoshasProvider = FutureProvider.family<AllDoshasData, KundliRequest>((
  ref,
  request,
) {
  return ref
      .watch(kundliRepositoryProvider)
      .fetchDoshas(
        datetime: request.datetime,
        lat: request.latitude,
        lon: request.longitude,
        tzOffset: request.tzOffset,
      );
});

/// The Vimshottari dasha timeline for [request]'s birth parameters — feeds
/// the Kundli Chart screen's "Vimshottari Dasha" tab. Independent of
/// [kundliDataProvider]/[kundliDoshasProvider] — see [KundliRepository]'s
/// class doc.
final kundliDashaProvider =
    FutureProvider.family<VimshottariDashaData, KundliRequest>((
      ref,
      request,
    ) {
      return ref
          .watch(kundliRepositoryProvider)
          .fetchDasha(
            datetime: request.datetime,
            lat: request.latitude,
            lon: request.longitude,
            tzOffset: request.tzOffset,
          );
    });
