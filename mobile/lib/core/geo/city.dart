/// Country names for the country codes present in `assets/data/cities.json`
/// that we bother spelling out in [City.fullLabel] — chosen because they
/// cover the app's primary (India) and secondary (South Asian diaspora +
/// major English-speaking) audiences. Any other ISO country code just falls
/// back to showing the raw code.
const Map<String, String> _countryNames = {
  'IN': 'India',
  'PK': 'Pakistan',
  'US': 'United States',
  'GB': 'United Kingdom',
  'AE': 'United Arab Emirates',
  'CA': 'Canada',
  'AU': 'Australia',
  'SG': 'Singapore',
  'NP': 'Nepal',
  'LK': 'Sri Lanka',
  'BD': 'Bangladesh',
  'MY': 'Malaysia',
};

/// A single searchable birth city, backed by the offline `cities.json`
/// dataset (see [AssetCityPlaceSearch]).
///
/// Immutable — a new [City] is created rather than mutating an existing one.
class City {
  const City({
    required this.name,
    required this.state,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
  });

  /// City name, e.g. `"Hyderabad"`.
  final String name;

  /// State/admin1 division, e.g. `"Telangana"`. May be empty for city-states
  /// or entries where the source dataset has no admin1 value.
  final String state;

  /// ISO 3166-1 alpha-2 country code, e.g. `"IN"`.
  final String countryCode;

  final double latitude;
  final double longitude;

  /// IANA timezone id, e.g. `"Asia/Kolkata"` — used to resolve the
  /// historically-correct UTC offset for a given birth date/time (see
  /// `BirthProfile.utcOffsetLabel`).
  final String timezoneId;

  /// Reads the offline dataset's SHORT keys: `n`/`s`/`c`/`la`/`lo`/`tz`.
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['n'] as String,
      state: json['s'] as String? ?? '',
      countryCode: json['c'] as String,
      latitude: (json['la'] as num).toDouble(),
      longitude: (json['lo'] as num).toDouble(),
      timezoneId: json['tz'] as String,
    );
  }

  /// Writes FULL descriptive keys — this is persisted app data (as part of
  /// a saved birth profile), not a re-transmission of the dataset, so it is
  /// kept human-readable rather than reusing the dataset's short keys.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'state': state,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'timezoneId': timezoneId,
    };
  }

  factory City.fromPersistedJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      state: json['state'] as String? ?? '',
      countryCode: json['countryCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezoneId: json['timezoneId'] as String,
    );
  }

  /// Short label for compact UI, e.g. `"Hyderabad, Telangana"`. Omits the
  /// state when it's empty, e.g. `"Singapore"`.
  String get displayLabel => state.isEmpty ? name : '$name, $state';

  /// Full label including the country name, e.g.
  /// `"Hyderabad, Telangana, India"`. Falls back to the raw ISO code for
  /// countries not in [_countryNames].
  String get fullLabel {
    final country = _countryNames[countryCode] ?? countryCode;
    return state.isEmpty ? '$name, $country' : '$name, $state, $country';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City &&
        other.name == name &&
        other.state == state &&
        other.countryCode == countryCode &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timezoneId == timezoneId;
  }

  @override
  int get hashCode =>
      Object.hash(name, state, countryCode, latitude, longitude, timezoneId);
}
