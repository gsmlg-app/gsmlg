/// IP to City database library using DB-IP MMDB database.
///
/// This library provides IP geolocation lookup capabilities using the
/// DB-IP City Lite database embedded as an asset.
///
/// ## License
///
/// The free IP to City Lite database by DB-IP is licensed under a
/// Creative Commons Attribution 4.0 International License.
/// https://creativecommons.org/licenses/by/4.0/
///
/// You are free to use this database in your application, provided you
/// give attribution to DB-IP.com for the data.
///
/// ## Usage
///
/// ```dart
/// import 'package:ip_db/ip_db.dart';
///
/// void main() async {
///   final db = IpDatabase();
///
///   // Initialize (downloads database if needed)
///   await db.initialize();
///
///   // Lookup an IP address
///   final location = await db.lookup('8.8.8.8');
///   print(location?.displayName); // Mountain View, California, United States
///   print(location?.countryCode); // US
///   print(location?.latitude);    // 37.386
///   print(location?.longitude);   // -122.0838
///
///   // Close when done
///   db.close();
/// }
/// ```
library;

export 'src/ip_database.dart';
export 'src/ip_location.dart';
