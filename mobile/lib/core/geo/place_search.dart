import 'dart:convert';
import 'dart:math' show cos, pi;

import 'package:flutter/services.dart' show rootBundle;

import 'city.dart';

export 'resilient_place_search.dart' show placeSearchProvider;

/// Path to the bundled offline city dataset (see `pubspec.yaml` assets).
const String _cityDatasetAssetPath = 'assets/data/cities.json';

/// A search hit, before coordinates have been resolved.
///
/// Google Places Autocomplete returns lightweight predictions (a label +
/// an opaque place id) — resolving one into full coordinates and a
/// timezone costs a separate "Place Details" call, so [PlaceSearch.search]
/// deliberately returns these two-step [PlaceSuggestion]s rather than
/// fully-resolved [City] objects. The offline dataset already has the full
/// [City] on hand at search time, so it just stashes it in [city] and its
/// [PlaceSearch.resolve] is a free, synchronous-in-effect lookup.
class PlaceSuggestion {
  const PlaceSuggestion({required this.label, required this.id, this.city});

  /// Human-readable label to show in the results dropdown, e.g.
  /// `"Hyderabad, Telangana, India"`.
  final String label;

  /// Provider-specific opaque id used to resolve this suggestion into a
  /// full [City] — a Google place id, or a composite offline-dataset key.
  final String id;

  /// Already-resolved city, when the provider had it on hand up front. The
  /// offline dataset always sets this; Google never does (a Places
  /// Autocomplete prediction carries no coordinates).
  final City? city;
}

/// Looks up birth cities by name as the user types, then resolves a chosen
/// suggestion into full coordinates + timezone.
///
/// This is an interface — not a concrete implementation used directly by
/// the UI — so callers (see `birth_details_screen.dart`) are written
/// against it rather than any one data source. [GooglePlacesSearch] is now
/// the primary implementation, with [AssetCityPlaceSearch] (the bundled
/// offline `assets/data/cities.json` dataset) as an automatic, silent
/// fallback via [ResilientPlaceSearch] — the "place of birth" field must
/// never break when a Google API key is absent, quota is exhausted, or the
/// device is offline.
abstract interface class PlaceSearch {
  /// Returns up to [limit] suggestions matching [query], best match first.
  Future<List<PlaceSuggestion>> search(String query, {int limit = 6});

  /// Resolves a suggestion into a full [City] with coordinates + IANA
  /// timezone. Returns `null` if resolution fails.
  Future<City?> resolve(PlaceSuggestion suggestion);

  /// Attribution text that MUST be displayed alongside results — a
  /// licence/ToS requirement of whichever provider actually served them
  /// (GeoNames CC BY 4.0 for the offline dataset, Google's ToS for Places).
  String get attribution;

  /// Starts a new search/billing session, for providers that have a
  /// concept of one. Google bills an Autocomplete-then-Details sequence as
  /// ONE session when the same session token is sent on every call in it,
  /// instead of billing per keystroke — the UI calls this once when a
  /// fresh search interaction begins (the place field gaining focus). A
  /// no-op for providers without a session concept.
  void startSession();
}

/// [PlaceSearch] backed by the bundled `assets/data/cities.json` dataset
/// (5,599 cities: ~3,780 Indian + ~1,819 world cities over 300k population).
///
/// The dataset is decoded lazily and cached in memory on first use — never
/// re-read or re-parsed per keystroke.
class AssetCityPlaceSearch implements PlaceSearch {
  List<City>? _cities;
  Future<List<City>>? _loadFuture;

  /// Loads + decodes the dataset exactly once, caching the parsed list in
  /// [_cities]. Concurrent callers (e.g. two searches fired in quick
  /// succession before the first load finishes) share the same in-flight
  /// [Future] via [_loadFuture] rather than triggering a second asset read.
  Future<List<City>> _loadCities() {
    final cached = _cities;
    if (cached != null) return Future.value(cached);

    final inFlight = _loadFuture;
    if (inFlight != null) return inFlight;

    final future = _decodeCities();
    _loadFuture = future;
    return future;
  }

  Future<List<City>> _decodeCities() async {
    final raw = await rootBundle.loadString(_cityDatasetAssetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    final cities = decoded
        .map((entry) => City.fromJson(entry as Map<String, dynamic>))
        .toList(growable: false);
    _cities = cities;
    return cities;
  }

  @override
  Future<List<PlaceSuggestion>> search(String query, {int limit = 6}) async {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return const [];

    final cities = await _loadCities();

    final startsWithIndia = <City>[];
    final startsWithOther = <City>[];
    final containsIndia = <City>[];
    final containsOther = <City>[];

    for (final city in cities) {
      final normalizedName = _normalize(city.name);
      final normalizedNameState = _normalize('${city.name}, ${city.state}');
      final isIndia = city.countryCode == 'IN';

      final startsWith =
          normalizedName.startsWith(normalizedQuery) ||
          normalizedNameState.startsWith(normalizedQuery);
      if (startsWith) {
        (isIndia ? startsWithIndia : startsWithOther).add(city);
        continue;
      }

      final contains =
          normalizedName.contains(normalizedQuery) ||
          normalizedNameState.contains(normalizedQuery);
      if (contains) {
        (isIndia ? containsIndia : containsOther).add(city);
      }
    }

    // Rank: startsWith before contains; within each group, India before
    // other countries; within each of those, preserve the dataset's
    // (population-descending) file order.
    final ranked = [
      ...startsWithIndia,
      ...startsWithOther,
      ...containsIndia,
      ...containsOther,
    ];

    return ranked
        .take(limit)
        .map(
          (city) => PlaceSuggestion(
            label: city.fullLabel,
            id: '${city.name}|${city.state}|${city.countryCode}',
            city: city,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<City?> resolve(PlaceSuggestion suggestion) async => suggestion.city;

  @override
  String get attribution => 'city data © GeoNames (CC BY 4.0)';

  @override
  void startSession() {
    // The offline dataset has no billing/session concept — nothing to do.
  }

  /// Finds the IANA timezone of the nearest city in the offline dataset to
  /// the given coordinates.
  ///
  /// Timezone zones are large geographic regions, so the nearest known
  /// city's zone is correct in practice for city-of-birth purposes — and
  /// this costs nothing (no paid Time Zone API call), since the offline
  /// dataset used for local search already carries a timezone id per city.
  /// [GooglePlacesSearch.resolve] uses this to fill in the timezone that
  /// Google Places itself never returns.
  Future<String> timezoneForCoordinates(
    double lat,
    double lon, {
    String? countryCode,
  }) async {
    final cities = await _loadCities();
    if (cities.isEmpty) {
      // Unreachable in practice — the bundled dataset always has 5,599
      // entries — but a corrupt/missing asset must never crash the app, so
      // fall back to India's zone: it's this app's primary market and a
      // reasonable last-resort default.
      return 'Asia/Kolkata';
    }

    var candidates = cities;
    if (countryCode != null && countryCode.isNotEmpty) {
      final sameCountry = cities
          .where((c) => c.countryCode == countryCode)
          .toList(growable: false);
      if (sameCountry.isNotEmpty) {
        candidates = sameCountry;
      }
    }

    final latRad = lat * pi / 180;
    City? nearest;
    double? nearestDist;
    for (final city in candidates) {
      final dLat = city.latitude - lat;
      final dLon = (city.longitude - lon) * cos(latRad);
      final dist = dLat * dLat + dLon * dLon;
      if (nearestDist == null || dist < nearestDist) {
        nearestDist = dist;
        nearest = city;
      }
    }

    return nearest?.timezoneId ?? 'Asia/Kolkata';
  }

  /// Lower-cases and strips diacritics so e.g. `"bengaluru"` matches
  /// `"Bengalūru"`-style entries and search is case-insensitive.
  String _normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacriticMap[char] ?? char);
    }
    return buffer.toString();
  }

  static const Map<String, String> _diacriticMap = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ā': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'ē': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ī': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ō': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ū': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'ñ': 'n',
    'ç': 'c',
    'ș': 's',
    'ş': 's',
    'ž': 'z',
    'ł': 'l',
  };
}
