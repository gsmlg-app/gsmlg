/// Represents the geolocation information for an IP address.
class IpLocation {
  /// The continent name (e.g., "North America")
  final String? continent;

  /// The continent code (e.g., "NA")
  final String? continentCode;

  /// The country name (e.g., "United States")
  final String? country;

  /// The ISO 3166-1 alpha-2 country code (e.g., "US")
  final String? countryCode;

  /// The state/region/province name
  final String? stateProv;

  /// The ISO 3166-2 state/region code
  final String? stateProvCode;

  /// The city name
  final String? city;

  /// The postal/zip code
  final String? postalCode;

  /// The latitude coordinate
  final double? latitude;

  /// The longitude coordinate
  final double? longitude;

  /// The timezone (e.g., "America/New_York")
  final String? timezone;

  /// The geoname ID
  final int? geonameId;

  const IpLocation({
    this.continent,
    this.continentCode,
    this.country,
    this.countryCode,
    this.stateProv,
    this.stateProvCode,
    this.city,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.timezone,
    this.geonameId,
  });

  /// Creates an [IpLocation] from a MaxMind DB record map.
  factory IpLocation.fromMmdbRecord(Map<String, dynamic> record) {
    final continent = record['continent'] as Map<String, dynamic>?;
    final country = record['country'] as Map<String, dynamic>?;
    final subdivisions = record['subdivisions'] as List<dynamic>?;
    final city = record['city'] as Map<String, dynamic>?;
    final location = record['location'] as Map<String, dynamic>?;
    final postal = record['postal'] as Map<String, dynamic>?;

    // Get names with fallback to English
    String? getName(Map<String, dynamic>? obj) {
      if (obj == null) return null;
      final names = obj['names'] as Map<String, dynamic>?;
      if (names == null) return null;
      return names['en'] as String? ?? names.values.firstOrNull as String?;
    }

    // Get first subdivision (state/province)
    Map<String, dynamic>? firstSubdivision;
    if (subdivisions != null && subdivisions.isNotEmpty) {
      firstSubdivision = subdivisions.first as Map<String, dynamic>?;
    }

    return IpLocation(
      continent: getName(continent),
      continentCode: continent?['code'] as String?,
      country: getName(country),
      countryCode: country?['iso_code'] as String?,
      stateProv: getName(firstSubdivision),
      stateProvCode: firstSubdivision?['iso_code'] as String?,
      city: getName(city),
      postalCode: postal?['code'] as String?,
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      timezone: location?['time_zone'] as String?,
      geonameId: city?['geoname_id'] as int?,
    );
  }

  /// Returns true if this location has valid coordinates.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Returns a human-readable location string.
  String get displayName {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (stateProv != null) parts.add(stateProv!);
    if (country != null) parts.add(country!);
    return parts.isEmpty ? 'Unknown' : parts.join(', ');
  }

  @override
  String toString() {
    return 'IpLocation('
        'city: $city, '
        'stateProv: $stateProv, '
        'country: $country, '
        'countryCode: $countryCode, '
        'latitude: $latitude, '
        'longitude: $longitude'
        ')';
  }
}
