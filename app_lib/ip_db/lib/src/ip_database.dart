import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:maxminddb/maxminddb.dart';

import 'ip_location.dart';

/// Status of the IP database.
enum IpDatabaseStatus {
  /// Database is not initialized.
  notInitialized,

  /// Database is being loaded.
  loading,

  /// Database is ready for queries.
  ready,

  /// An error occurred during initialization.
  error,
}

/// A database for looking up IP address geolocation information.
///
/// Uses the DB-IP City Lite database in MMDB format, embedded as an asset.
class IpDatabase {
  static const String _assetPath = 'packages/ip_db/assets/dbip-city-lite.mmdb';

  MaxMindDatabase? _database;
  IpDatabaseStatus _status = IpDatabaseStatus.notInitialized;
  String? _errorMessage;

  /// The current status of the database.
  IpDatabaseStatus get status => _status;

  /// The error message if status is [IpDatabaseStatus.error].
  String? get errorMessage => _errorMessage;

  /// Whether the database is ready for queries.
  bool get isReady => _status == IpDatabaseStatus.ready;

  /// Callback for status changes.
  void Function(IpDatabaseStatus status)? onStatusChanged;

  /// Initializes the database by loading from embedded assets.
  Future<void> initialize() async {
    if (_status == IpDatabaseStatus.loading) {
      return; // Already loading
    }

    if (_status == IpDatabaseStatus.ready) {
      return; // Already initialized
    }

    _status = IpDatabaseStatus.loading;
    _notifyStatusChanged();

    try {
      // Load the database from assets
      final ByteData data = await rootBundle.load(_assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Create database from memory
      _database = await MaxMindDatabase.memory(bytes);
      _status = IpDatabaseStatus.ready;
      _notifyStatusChanged();
    } catch (e) {
      _status = IpDatabaseStatus.error;
      _errorMessage = e.toString();
      _notifyStatusChanged();
      rethrow;
    }
  }

  /// Looks up the location for an IP address.
  ///
  /// Returns null if the IP address is not found in the database.
  /// Throws [StateError] if the database is not initialized.
  Future<IpLocation?> lookup(String ipAddress) async {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }

    try {
      final result = await _database!.search(ipAddress);
      if (result is! Map<String, dynamic>) {
        return null;
      }
      return IpLocation.fromMmdbRecord(result);
    } catch (e) {
      // IP address not found or invalid
      return null;
    }
  }

  /// Looks up the location for an [InternetAddress].
  Future<IpLocation?> lookupAddress(InternetAddress address) {
    return lookup(address.address);
  }

  /// Closes the database and releases resources.
  void close() {
    _database = null;
    _status = IpDatabaseStatus.notInitialized;
    _errorMessage = null;
  }

  void _notifyStatusChanged() {
    onStatusChanged?.call(_status);
  }
}
