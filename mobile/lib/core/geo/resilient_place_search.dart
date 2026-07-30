import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'city.dart';
import 'google_places_search.dart';
import 'place_search.dart';

/// [PlaceSearch] that tries Google Places first and falls back to the
/// bundled offline dataset ([AssetCityPlaceSearch]) automatically and
/// silently whenever Google is unavailable.
///
/// The "place of birth" field must never break just because a Google API
/// key is absent, quota is exhausted, or the device is offline — every one
/// of those cases lands here and is handled the same way: fall back, don't
/// surface an error.
class ResilientPlaceSearch implements PlaceSearch {
  ResilientPlaceSearch({required this.offline, required this.google});

  final AssetCityPlaceSearch offline;
  final GooglePlacesSearch google;

  /// Flips to `false` the first time Google fails at runtime (network
  /// error, quota, timeout, malformed response) and stays `false` for the
  /// rest of this instance's lifetime — this avoids paying an 8s timeout on
  /// every subsequent keystroke once Google has already proven unavailable.
  /// A missing API key is a separate, immediate check via
  /// [GooglePlacesSearch.isConfigured] and never even reaches this flag.
  bool _googleHealthy = true;

  /// Ensures the "Google unavailable, falling back" warning is only logged
  /// once per app session, not once per keystroke.
  bool _warnedThisSession = false;

  /// Which provider actually served the most recent [search] results —
  /// drives [attribution] so the UI credits whoever actually produced the
  /// results currently shown in the dropdown.
  bool _lastServedByGoogle = false;

  bool get _shouldTryGoogle =>
      GooglePlacesSearch.isConfigured && _googleHealthy;

  void _warnOnce(Object error) {
    if (_warnedThisSession) return;
    _warnedThisSession = true;
    debugPrint(
      'Google Places unavailable, falling back to offline city search: '
      '$error',
    );
  }

  @override
  Future<List<PlaceSuggestion>> search(String query, {int limit = 6}) async {
    if (_shouldTryGoogle) {
      try {
        final results = await google.search(query, limit: limit);
        _lastServedByGoogle = true;
        return results;
      } catch (e) {
        _googleHealthy = false;
        _warnOnce(e);
      }
    }
    _lastServedByGoogle = false;
    return offline.search(query, limit: limit);
  }

  @override
  Future<City?> resolve(PlaceSuggestion suggestion) async {
    // Offline suggestions already carry their resolved City (Google never
    // produced this suggestion), so resolving is a free local lookup with
    // nothing to fall back from.
    if (suggestion.city != null) {
      return offline.resolve(suggestion);
    }
    if (_shouldTryGoogle) {
      try {
        return await google.resolve(suggestion);
      } catch (e) {
        _googleHealthy = false;
        _warnOnce(e);
      }
    }
    // A Google-sourced suggestion can't be resolved offline — the offline
    // dataset has no notion of a Google place id — so resolution genuinely
    // failed here. The caller (the UI) shows a "couldn't load" message and
    // lets the user pick another suggestion.
    return null;
  }

  @override
  String get attribution =>
      _lastServedByGoogle ? google.attribution : offline.attribution;

  @override
  void startSession() {
    if (GooglePlacesSearch.isConfigured) {
      google.startSession();
    }
  }
}

/// App-wide [PlaceSearch] instance — tries Google Places first, falls back
/// to the bundled offline dataset automatically and silently.
final placeSearchProvider = Provider<PlaceSearch>((ref) {
  final offline = AssetCityPlaceSearch();
  return ResilientPlaceSearch(
    offline: offline,
    google: GooglePlacesSearch(offlineTimezoneSource: offline),
  );
});
