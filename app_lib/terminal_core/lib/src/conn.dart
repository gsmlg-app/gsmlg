import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:terminal_core/src/host.dart';

abstract class HostSpec {
  String get name;

  HostConnector createConnector();
}

enum HostConnectorStatus {
  initialized,
  connecting,
  connected,
  disconnected,
  aborted,
}

/// Manages the connection lifecycle to a host.
///
/// Extends [ChangeNotifier] to notify listeners when the connection status changes.
/// Use [addListener] to subscribe to status changes.
abstract class HostConnector<T extends Host> extends ChangeNotifier {
  HostConnector();

  HostConnectorStatus _status = HostConnectorStatus.initialized;

  T? _host;

  int _connectionGeneration = 0;
  bool _disposed = false;

  /// The last connection error, if any.
  Object? _lastError;

  /// Current connection status.
  HostConnectorStatus get status => _status;

  /// The connected host, or null if not connected.
  T? get host => _host;

  /// The last connection error, or null if connected successfully.
  Object? get lastError => _lastError;

  @protected
  Future<T> createHost();

  /// Updates the status and notifies listeners.
  @protected
  void setStatus(HostConnectorStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  Future<void> connect() async {
    if (_disposed ||
        _status == HostConnectorStatus.connected ||
        _status == HostConnectorStatus.connecting) {
      return;
    }

    _lastError = null;
    final generation = ++_connectionGeneration;
    setStatus(HostConnectorStatus.connecting);

    try {
      final host = await createHost();
      if (_disposed || generation != _connectionGeneration) {
        await host.disconnect();
        return;
      }
      _host = host;
      host.done.then(
        (_) {
          if (identical(_host, host)) _onDone();
        },
        onError: (Object error) {
          if (identical(_host, host)) _onError(error);
        },
      );

      setStatus(HostConnectorStatus.connected);
    } catch (e) {
      if (_disposed || generation != _connectionGeneration) return;
      _lastError = e;
      setStatus(HostConnectorStatus.disconnected);
    }
  }

  Future<void> disconnect() async {
    _connectionGeneration++;
    final host = _host;
    _host = null;
    if (!_disposed) setStatus(HostConnectorStatus.disconnected);
    await host?.disconnect();
  }

  @override
  void dispose() {
    if (_disposed) return;
    unawaited(
      disconnect().catchError((Object error) {
        _lastError = error;
      }),
    );
    _disposed = true;
    super.dispose();
  }

  void _onDone() {
    _host = null;
    setStatus(HostConnectorStatus.disconnected);
  }

  void _onError(Object error) {
    _host = null;
    setStatus(HostConnectorStatus.aborted);
  }
}
