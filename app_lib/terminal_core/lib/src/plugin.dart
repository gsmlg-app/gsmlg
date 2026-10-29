import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:terminal_core/src/conn.dart';
import 'package:terminal_core/src/host.dart';

abstract mixin class Plugin {
  PluginManager? _manager;

  /// The plugin manager that manages the lifecycle of this plugin.
  PluginManager get manager {
    if (_manager == null) {
      throw StateError('Plugin is not attached to a manager');
    }

    return _manager!;
  }

  HostSpec? _hostSpec;

  /// The interface through which the plugin can read information about the host.
  /// This is available after [didMounted] is called.
  HostSpec get hostSpec {
    if (_hostSpec == null) {
      throw Exception('Plugin has not been mounted');
    }
    return _hostSpec!;
  }

  Host? _host;

  /// The interface through which the plugin can interact with the host. Access
  /// to this property will throw an exception if the host has not been connected.
  Host get host {
    if (_host == null) {
      throw Exception('Plugin has not been connected to a host.');
    }
    return _host!;
  }

  /// Whether the plugin is currently mounted.
  bool get mounted => _manager != null;

  /// Whether the plugin is connected to a host.
  bool get connected => _host != null;

  /// The title of the plugin. Usually displayed as the tab title.
  final title = ValueNotifier<String?>(null);

  /// Called when the plugin is mounted to a host. After this method is called,
  /// the [hostSpec] property will be available.
  void didMounted() {}

  /// Called when the plugin is unmounted from a host. After this method is
  /// called, the [hostSpec] property will no longer be available.
  void didUnmounted() {}

  /// Called when the host that this plugin is mounted to is connected. This
  /// method may be called multiple times if the host is disconnected and
  /// reconnected.
  void didConnected() {}

  /// Called when the host that this plugin is mounted to is disconnected. This
  /// method may be called multiple times if the host is disconnected and
  /// reconnected.
  void didDisconnected() {}

  /// Called when the state of the host that this plugin is mounted to changes.
  void onConnectionStatus(HostConnectorStatus status) {}

  /// Called when the connection to the host fails with an error.
  void onConnectionError(Object error) {}

  /// Builds the UI for this plugin. This may be called multiple times during
  /// the lifetime of the plugin, for example when the plugin is moved to a new
  /// tab group.
  Widget build(BuildContext context);
}

class PluginManager with ChangeNotifier {
  final HostSpec hostSpec;

  PluginManager(this.hostSpec);

  final _plugins = <Plugin>[];

  List<Plugin> get plugins => List.unmodifiable(_plugins);

  Host? _host;

  /// Returns true if the manager is connected to a host.
  bool get isConnected => _host != null;

  HostConnector? _connector;

  /// Connects plugins independently of their widgets' mount state.
  Future<void> connect() async {
    if (_plugins.isEmpty || isConnected) return;

    var connector = _connector;
    if (connector == null) {
      connector = hostSpec.createConnector();
      _connector = connector;
      connector.addListener(_onConnectorChanged);
    }

    await connector.connect();
    if (_connector != connector || _plugins.isEmpty) return;

    final host = connector.host;
    if (host != null && !isConnected) {
      didConnected(host);
    } else if (connector.lastError != null) {
      didConnectionError(connector.lastError!);
    }
  }

  void _onConnectorChanged() {
    final connector = _connector;
    if (connector == null) return;
    if (isConnected &&
        (connector.status == HostConnectorStatus.disconnected ||
            connector.status == HostConnectorStatus.aborted)) {
      didDisconnected();
    }
    didConnectionStatusChanged(connector.status);
  }

  void add(Plugin plugin) {
    if (plugin._manager != null) {
      throw Exception('Plugin is already mounted');
    }
    _plugins.add(plugin);

    plugin._manager = this;
    plugin._hostSpec = hostSpec;
    plugin.didMounted();

    if (_host != null) {
      plugin._host = _host;
      plugin.didConnected();
    }

    notifyListeners();
  }

  void remove(Plugin plugin) {
    if (plugin._manager != this) {
      throw Exception('Plugin is not mounted');
    }
    _plugins.remove(plugin);

    plugin.didUnmounted();
    plugin._manager = null;
    plugin._hostSpec = null;
    plugin._host = null;

    if (_plugins.isEmpty) {
      final connector = _connector;
      final host = _host;
      _connector = null;
      _host = null;
      if (connector != null) {
        connector.removeListener(_onConnectorChanged);
        connector.dispose();
      } else if (host != null) {
        unawaited(host.disconnect());
      }
    }

    notifyListeners();
  }

  void didConnected(Host host) {
    if (_host != null) {
      throw Exception('plugin manager is already connected to $_host');
    }

    _host = host;

    for (final plugin in _plugins) {
      plugin._host = host;
      plugin.didConnected();
    }
  }

  void didDisconnected() {
    if (_host == null) {
      throw Exception('plugin manager is not connected');
    }

    _host = null;

    for (final plugin in _plugins) {
      plugin._host = null;
      plugin.didDisconnected();
    }
  }

  void didConnectionStatusChanged(HostConnectorStatus status) {
    for (final plugin in _plugins) {
      plugin.onConnectionStatus(status);
    }
  }

  void didConnectionError(Object error) {
    for (final plugin in _plugins) {
      plugin.onConnectionError(error);
    }
  }
}
