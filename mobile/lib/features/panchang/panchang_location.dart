import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/geo/city.dart';
import '../../core/geo/place_search.dart';
import '../profile/birth_profile_repository.dart';

/// Where a resolved [PanchangLocation] came from — surfaced in the UI so the
/// user can tell "we detected this" from "you chose this".
enum PanchangLocationSource {
  /// The user picked this city in Settings. Always wins.
  manual,

  /// Nearest city to the device's coarse GPS position.
  device,

  /// The saved birth profile's city — the behaviour before 21 Aug 2026.
  birthProfile,

  /// Nothing else resolved (guest, permission denied, no fix).
  fallback,
}

/// The city a panchang is computed for, plus how it was chosen.
class PanchangLocation {
  const PanchangLocation({required this.city, required this.source});

  final City city;
  final PanchangLocationSource source;
}

/// Default when nothing else resolves — matches the coordinates the panchang
/// screens already fell back to.
const City kFallbackPanchangCity = City(
  name: 'Hyderabad',
  state: 'Telangana',
  countryCode: 'IN',
  latitude: 17.3850,
  longitude: 78.4867,
  timezoneId: 'Asia/Kolkata',
);

/// The user's chosen panchang city, or `null` to use auto-detection.
///
/// Persisted so the choice survives a restart. Stored as the same JSON a
/// [City] round-trips through elsewhere in the app.
class PanchangLocationOverride extends Notifier<City?> {
  static const _prefsKey = 'panchang_location_override';

  @override
  City? build() => null;

  /// Loads any saved override. Called once from `main()` before the first
  /// frame, the same way the locale and theme controllers are seeded, so the
  /// panchang never renders one city and then swaps to another.
  static Future<City?> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return null;
      return City.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A corrupt value must degrade to auto-detection, never crash startup.
      return null;
    }
  }

  Future<void> setCity(City? city) async {
    state = city;
    final prefs = await SharedPreferences.getInstance();
    if (city == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, jsonEncode(city.toJson()));
    }
  }
}

final panchangLocationOverrideProvider =
    NotifierProvider<PanchangLocationOverride, City?>(
      PanchangLocationOverride.new,
    );

/// The device's current city, resolved from COARSE GPS against the offline
/// city dataset — or `null` when unavailable for any reason.
///
/// ## Privacy shape, deliberately
///
/// The raw fix never leaves the device: [AssetCityPlaceSearch.nearestCity]
/// maps it to a bundled city entry locally, and only that city's own
/// published coordinates are sent to Vedika. So the app learns "near
/// Erode", not the user's street. `LocationAccuracy.low` is requested for
/// the same reason — a panchang only needs the right city.
///
/// Returns null rather than throwing on every failure path (service off,
/// permission denied or permanently denied, timeout, corrupt dataset); the
/// resolver below then falls through to the next source.
final deviceCityProvider = FutureProvider<City?>((ref) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // A last known fix is instant and plenty accurate for "which city"; only
    // pay for a live fix when there isn't one.
    final position =
        await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );

    return AssetCityPlaceSearch().nearestCity(
      position.latitude,
      position.longitude,
    );
  } catch (_) {
    return null;
  }
});

/// THE panchang location, resolved by precedence.
///
/// ADDED 21 Aug 2026. Both Home and the Panchang tab previously used the
/// saved BIRTH city, which is the wrong input for a daily almanac: sunrise,
/// sunset and Rahu Kaal depend on where the user physically is. Someone born
/// in Jaipur and living in Erode got Jaipur's timings, and travelling
/// changed nothing.
///
/// Precedence, highest first:
///  1. [panchangLocationOverrideProvider] — an explicit choice in Settings.
///     Always wins; auto-detection must never silently overrule the user.
///  2. [deviceCityProvider] — nearest city to the coarse GPS fix.
///  3. The saved birth profile's city — the old behaviour, still the best
///     guess when GPS is unavailable, since most users never leave their
///     birth region.
///  4. [kFallbackPanchangCity] — a guest with no profile and no fix.
final panchangLocationProvider = Provider<PanchangLocation>((ref) {
  final override = ref.watch(panchangLocationOverrideProvider);
  if (override != null) {
    return PanchangLocation(
      city: override,
      source: PanchangLocationSource.manual,
    );
  }

  final device = ref.watch(deviceCityProvider).valueOrNull;
  if (device != null) {
    return PanchangLocation(
      city: device,
      source: PanchangLocationSource.device,
    );
  }

  final birthCity = ref.watch(birthProfileProvider).valueOrNull?.city;
  if (birthCity != null) {
    return PanchangLocation(
      city: birthCity,
      source: PanchangLocationSource.birthProfile,
    );
  }

  return const PanchangLocation(
    city: kFallbackPanchangCity,
    source: PanchangLocationSource.fallback,
  );
});
