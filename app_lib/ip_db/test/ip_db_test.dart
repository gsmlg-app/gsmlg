import 'package:flutter_test/flutter_test.dart';
import 'package:ip_db/ip_db.dart';

void main() {
  group('IpLocation', () {
    test('fromMmdbRecord parses valid record', () {
      final record = {
        'continent': {
          'code': 'NA',
          'names': {'en': 'North America'},
        },
        'country': {
          'iso_code': 'US',
          'names': {'en': 'United States'},
        },
        'subdivisions': [
          {
            'iso_code': 'CA',
            'names': {'en': 'California'},
          },
        ],
        'city': {
          'names': {'en': 'Mountain View'},
          'geoname_id': 5375480,
        },
        'location': {
          'latitude': 37.386,
          'longitude': -122.0838,
          'time_zone': 'America/Los_Angeles',
        },
        'postal': {
          'code': '94035',
        },
      };

      final location = IpLocation.fromMmdbRecord(record);

      expect(location.continent, 'North America');
      expect(location.continentCode, 'NA');
      expect(location.country, 'United States');
      expect(location.countryCode, 'US');
      expect(location.stateProv, 'California');
      expect(location.stateProvCode, 'CA');
      expect(location.city, 'Mountain View');
      expect(location.postalCode, '94035');
      expect(location.latitude, 37.386);
      expect(location.longitude, -122.0838);
      expect(location.timezone, 'America/Los_Angeles');
      expect(location.geonameId, 5375480);
    });

    test('fromMmdbRecord handles missing fields', () {
      final record = <String, dynamic>{
        'country': {
          'iso_code': 'US',
          'names': {'en': 'United States'},
        },
      };

      final location = IpLocation.fromMmdbRecord(record);

      expect(location.country, 'United States');
      expect(location.countryCode, 'US');
      expect(location.city, isNull);
      expect(location.latitude, isNull);
      expect(location.longitude, isNull);
    });

    test('hasCoordinates returns correct value', () {
      final withCoords = IpLocation(latitude: 37.386, longitude: -122.0838);
      final withoutCoords = IpLocation(country: 'United States');

      expect(withCoords.hasCoordinates, isTrue);
      expect(withoutCoords.hasCoordinates, isFalse);
    });

    test('displayName formats correctly', () {
      final full = IpLocation(
        city: 'Mountain View',
        stateProv: 'California',
        country: 'United States',
      );
      final partial = IpLocation(country: 'United States');
      final empty = IpLocation();

      expect(full.displayName, 'Mountain View, California, United States');
      expect(partial.displayName, 'United States');
      expect(empty.displayName, 'Unknown');
    });
  });

  group('IpDatabase', () {
    test('status is notInitialized before initialize()', () {
      final db = IpDatabase();
      expect(db.status, IpDatabaseStatus.notInitialized);
      expect(db.isReady, isFalse);
    });

    test('lookup throws StateError when not initialized', () async {
      final db = IpDatabase();
      expect(() async => await db.lookup('8.8.8.8'), throwsStateError);
    });
  });
}
