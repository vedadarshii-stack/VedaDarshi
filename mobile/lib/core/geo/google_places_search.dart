import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'city.dart';
import 'place_search.dart';

/// Thrown internally whenever the Places API can't be reached, times out, or
/// returns something unusable. Never escapes this class's public methods —
/// [search] and [resolve] always catch it (and any other exception) and
/// rethrow as this same type, so [ResilientPlaceSearch] has one exception
/// shape to catch and fall back to the offline dataset on.
class _PlacesUnavailable implements Exception {
  _PlacesUnavailable(this.message);
  final String message;

  @override
  String toString() => 'PlacesUnavailable: $message';
}

/// [PlaceSearch] backed by the Places API (New): Autocomplete for [search],
/// Place Details for [resolve].
///
/// Requires `GOOGLE_PLACES_API_KEY` in the app's `.env` file (loaded at
/// startup by flutter_dotenv, see `main.dart`) — see [isConfigured]. Never
/// hardcode a real or fake key here; when no key is configured this class is
/// simply never called ([ResilientPlaceSearch] checks [isConfigured] up
/// front) and the offline city dataset serves the search instead.
class GooglePlacesSearch implements PlaceSearch {
  GooglePlacesSearch({required this.offlineTimezoneSource});

  /// Google Places never returns a timezone, and we deliberately don't call
  /// the paid Time Zone API for it — instead we look up the nearest city in
  /// the already-bundled offline dataset (see
  /// [AssetCityPlaceSearch.timezoneForCoordinates]), which costs nothing.
  final AssetCityPlaceSearch offlineTimezoneSource;

  /// Read from the `.env` file loaded at startup (see `main.dart`), NOT from
  /// `--dart-define`, so a plain `flutter build` / `flutter run` needs no
  /// extra flags. Resolved on every access rather than cached in a `const`,
  /// because dotenv values only exist once `dotenv.load()` has run.
  ///
  /// Returns an empty string when the key is absent or dotenv failed to load
  /// — deliberately never throws, since a missing key is a supported state
  /// (the app falls back to the offline city dataset).
  static String get _apiKey {
    try {
      return dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    } catch (_) {
      // dotenv.load() never ran (e.g. a test harness) — treat as unset.
      return '';
    }
  }

  /// Whether a Places API key was configured in `.env`. When `false`,
  /// [ResilientPlaceSearch] never attempts a network call at all.
  static bool get isConfigured => _apiKey.isNotEmpty;

  static const Duration _timeout = Duration(seconds: 8);

  String? _sessionToken;

  /// Starts a new Autocomplete session token.
  ///
  /// Google bills an Autocomplete-then-Details sequence as ONE session when
  /// the SAME session token is sent on both the autocomplete calls and the
  /// subsequent details call, instead of billing per keystroke — this
  /// materially reduces cost. Call this once when a NEW search interaction
  /// begins (the UI calls it when the place field gains focus); the token
  /// is discarded after [resolve] completes, win or lose, since it was a
  /// one-shot autocomplete-then-details session.
  @override
  void startSession() {
    _sessionToken = _generateToken();
  }

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Future<List<PlaceSuggestion>> search(String query, {int limit = 6}) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': _apiKey,
            },
            body: jsonEncode({
              'input': query,
              'includedPrimaryTypes': [
                'locality',
                'administrative_area_level_3',
              ],
              if (_sessionToken != null) 'sessionToken': _sessionToken,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw _PlacesUnavailable(
          'autocomplete returned ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw _PlacesUnavailable('unexpected autocomplete response shape');
      }

      final suggestions = decoded['suggestions'];
      if (suggestions is! List) return const [];

      final results = <PlaceSuggestion>[];
      for (final entry in suggestions) {
        if (results.length >= limit) break;
        // Defensive, null-safe walk: every level of the expected shape may
        // be absent or the wrong type — skip malformed entries rather than
        // throwing. Only a fully undecodable/mis-shaped top-level response
        // (handled above) escalates to _PlacesUnavailable.
        if (entry is! Map<String, dynamic>) continue;
        final placePrediction = entry['placePrediction'];
        if (placePrediction is! Map<String, dynamic>) continue;
        final placeId = placePrediction['placeId'];
        if (placeId is! String || placeId.isEmpty) continue;
        final text = placePrediction['text'];
        final label = text is Map<String, dynamic> ? text['text'] : null;
        if (label is! String || label.isEmpty) continue;
        results.add(PlaceSuggestion(label: label, id: placeId));
      }
      return results;
    } on _PlacesUnavailable {
      rethrow;
    } catch (e) {
      // Covers timeouts (TimeoutException), no connectivity
      // (SocketException), malformed JSON (FormatException), etc.
      throw _PlacesUnavailable('autocomplete failed: $e');
    }
  }

  @override
  Future<City?> resolve(PlaceSuggestion suggestion) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://places.googleapis.com/v1/places/${suggestion.id}',
            ),
            headers: {
              'X-Goog-Api-Key': _apiKey,
              'X-Goog-FieldMask':
                  'id,displayName,formattedAddress,location,addressComponents',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw _PlacesUnavailable('details returned ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw _PlacesUnavailable('unexpected details response shape');
      }

      // A City without coordinates is useless, so a missing/unparsable
      // location is the one place we escalate rather than defaulting.
      final location = decoded['location'];
      final lat = location is Map<String, dynamic>
          ? location['latitude']
          : null;
      final lon = location is Map<String, dynamic>
          ? location['longitude']
          : null;
      if (lat is! num || lon is! num) {
        throw _PlacesUnavailable('details response missing coordinates');
      }
      final latitude = lat.toDouble();
      final longitude = lon.toDouble();

      final displayName = decoded['displayName'];
      final nameFromApi = displayName is Map<String, dynamic>
          ? displayName['text']
          : null;
      final name = (nameFromApi is String && nameFromApi.isNotEmpty)
          ? nameFromApi
          : suggestion.label.split(',').first.trim();

      var state = '';
      var countryCode = '';
      final addressComponents = decoded['addressComponents'];
      if (addressComponents is List) {
        for (final component in addressComponents) {
          if (component is! Map<String, dynamic>) continue;
          final types = component['types'];
          if (types is! List) continue;
          if (types.contains('administrative_area_level_1')) {
            final longText = component['longText'];
            if (longText is String) state = longText;
          }
          if (types.contains('country')) {
            final shortText = component['shortText'];
            if (shortText is String) countryCode = shortText;
          }
        }
      }

      final timezoneId = await offlineTimezoneSource.timezoneForCoordinates(
        latitude,
        longitude,
        countryCode: countryCode,
      );

      return City(
        name: name,
        state: state,
        countryCode: countryCode,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
      );
    } on _PlacesUnavailable {
      rethrow;
    } catch (e) {
      throw _PlacesUnavailable('details failed: $e');
    } finally {
      _sessionToken = null;
    }
  }

  @override
  String get attribution => 'powered by Google';
}
