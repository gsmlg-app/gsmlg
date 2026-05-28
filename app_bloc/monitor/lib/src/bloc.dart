import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/monitor_models.dart';

import 'package:monitor_bloc/src/monitor_repository.dart';
import 'package:monitor_bloc/src/trust_store.dart';

part 'event.dart';
part 'state.dart';

class MonitorBloc extends Bloc<MonitorEvent, MonitorState> {
  MonitorBloc({
    required MonitorRepository repository,
    required TrustStore trustStore,
  }) : _repository = repository,
       _trustStore = trustStore,
       super(const MonitorInitial()) {
    on<MonitorConnectHost>(_onConnectHost);
    on<MonitorDisconnectHost>(_onDisconnectHost);
    on<MonitorAddManualHost>(_onAddManualHost);
    on<MonitorRemoveHost>(_onRemoveHost);
    on<MonitorDiscoverHosts>(_onDiscoverHosts);
    on<MonitorTrustHost>(_onTrustHost);
    on<MonitorRejectHost>(_onRejectHost);
    on<_MonitorMetricsReceived>(_onMetricsReceived);
    on<_MonitorConnectionStatusChanged>(_onConnectionStatusChanged);
    on<_MonitorHostInfoReceived>(_onHostInfoReceived);
    on<_MonitorHostDiscovered>(_onHostDiscovered);
    on<_MonitorCertificateReceived>(_onCertificateReceived);
    on<MonitorSetInterval>(_onSetInterval);
    on<MonitorPingHost>(_onPingHost);
  }

  final MonitorRepository _repository;
  final TrustStore _trustStore;
  final Map<String, StreamSubscription> _hostSubscriptions = {};
  StreamSubscription? _discoverySubscription;

  Future<void> _onAddManualHost(
    MonitorAddManualHost event,
    Emitter<MonitorState> emit,
  ) async {
    final currentState = state;
    final hosts = Map<String, MonitorHost>.from(
      currentState is MonitorLoaded ? currentState.hosts : {},
    );

    final hostId = '${event.ip}:${event.port}';
    hosts[hostId] = MonitorHost(
      id: hostId,
      ip: event.ip,
      port: event.port,
      status: ConnectionStatus.disconnected,
    );

    emit(MonitorLoaded(hosts: hosts));

    // Auto-connect after adding
    add(MonitorConnectHost(hostId: hostId));
  }

  Future<void> _onConnectHost(
    MonitorConnectHost event,
    Emitter<MonitorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final host = currentState.hosts[event.hostId];
    if (host == null) return;

    // Cancel existing subscription
    await _hostSubscriptions[event.hostId]?.cancel();

    // Look up pinned fingerprint for this host
    final pinnedFingerprint = await _trustStore.getPinnedFingerprint(
      event.hostId,
    );

    _hostSubscriptions[event.hostId] = _repository
        .connect(
          event.hostId,
          host.ip,
          host.port,
          pinnedFingerprint: pinnedFingerprint,
        )
        .listen((connectionEvent) {
          switch (connectionEvent) {
            case MonitorMessageReceived(:final message):
              if (message.type == MonitorMessageType.hostInfo) {
                add(
                  _MonitorHostInfoReceived(
                    hostId: event.hostId,
                    hostInfo: message.hostInfo,
                  ),
                );
              } else if (message.type == MonitorMessageType.metrics) {
                add(
                  _MonitorMetricsReceived(
                    hostId: event.hostId,
                    metrics: message.systemMetrics,
                  ),
                );
              }
            case MonitorConnectionStatusChanged(:final status, :final error):
              add(
                _MonitorConnectionStatusChanged(
                  hostId: event.hostId,
                  status: status,
                  error: error,
                ),
              );
            case MonitorCertificateReceived(:final fingerprint):
              add(
                _MonitorCertificateReceived(
                  hostId: event.hostId,
                  fingerprint: fingerprint,
                ),
              );
          }
        });
  }

  Future<void> _onDisconnectHost(
    MonitorDisconnectHost event,
    Emitter<MonitorState> emit,
  ) async {
    await _hostSubscriptions[event.hostId]?.cancel();
    _hostSubscriptions.remove(event.hostId);
    await _repository.disconnect(event.hostId);

    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final host = hosts[event.hostId];
    if (host != null) {
      hosts[event.hostId] = host.copyWith(
        status: ConnectionStatus.disconnected,
        metrics: null,
      );
      emit(MonitorLoaded(hosts: hosts));
    }
  }

  Future<void> _onRemoveHost(
    MonitorRemoveHost event,
    Emitter<MonitorState> emit,
  ) async {
    await _hostSubscriptions[event.hostId]?.cancel();
    _hostSubscriptions.remove(event.hostId);
    await _repository.disconnect(event.hostId);
    await _trustStore.removePinnedFingerprint(event.hostId);

    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    hosts.remove(event.hostId);
    emit(MonitorLoaded(hosts: hosts));
  }

  Future<void> _onDiscoverHosts(
    MonitorDiscoverHosts event,
    Emitter<MonitorState> emit,
  ) async {
    // Cancel any in-progress discovery
    await _discoverySubscription?.cancel();

    // Ensure we're in a loaded state
    if (state is! MonitorLoaded) {
      emit(const MonitorLoaded());
    }

    _discoverySubscription = _repository.discoverHosts().listen(
      (discovered) {
        add(_MonitorHostDiscovered(host: discovered));
      },
      onDone: () {
        _discoverySubscription = null;
      },
    );
  }

  void _onHostDiscovered(
    _MonitorHostDiscovered event,
    Emitter<MonitorState> emit,
  ) {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final discovered = event.host;

    // Don't overwrite manually added hosts
    if (hosts.containsKey(discovered.id)) return;

    hosts[discovered.id] = MonitorHost(
      id: discovered.id,
      ip: discovered.ip,
      port: discovered.port,
      status: ConnectionStatus.disconnected,
      isManual: false,
      label: discovered.hostname,
      certFingerprint: discovered.fingerprint,
    );

    emit(MonitorLoaded(hosts: hosts));

    // Auto-connect to discovered hosts
    add(MonitorConnectHost(hostId: discovered.id));
  }

  Future<void> _onTrustHost(
    MonitorTrustHost event,
    Emitter<MonitorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final host = currentState.hosts[event.hostId];
    if (host == null || host.certFingerprint == null) return;

    // Pin the fingerprint
    await _trustStore.pinFingerprint(event.hostId, host.certFingerprint!);

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    hosts[event.hostId] = host.copyWith(trustStatus: TrustStatus.trusted);
    emit(MonitorLoaded(hosts: hosts));
  }

  Future<void> _onRejectHost(
    MonitorRejectHost event,
    Emitter<MonitorState> emit,
  ) async {
    // Disconnect and remove the untrusted host
    await _hostSubscriptions[event.hostId]?.cancel();
    _hostSubscriptions.remove(event.hostId);
    await _repository.disconnect(event.hostId);

    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    hosts.remove(event.hostId);
    emit(MonitorLoaded(hosts: hosts));
  }

  void _onCertificateReceived(
    _MonitorCertificateReceived event,
    Emitter<MonitorState> emit,
  ) {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final host = hosts[event.hostId];
    if (host == null) return;

    hosts[event.hostId] = host.copyWith(
      certFingerprint: event.fingerprint,
      trustStatus: TrustStatus.pending,
    );
    emit(MonitorLoaded(hosts: hosts));
  }

  void _onMetricsReceived(
    _MonitorMetricsReceived event,
    Emitter<MonitorState> emit,
  ) {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final host = hosts[event.hostId];
    if (host == null) return;

    final m = event.metrics;

    // Update history ring buffers
    var cpuHistory = host.cpuHistory;
    var memoryHistory = host.memoryHistory;

    // Use current interfaces/disks to prune history and avoid memory growth
    final rxHistory = <String, RingBuffer<double>>{};
    final txHistory = <String, RingBuffer<double>>{};
    final readHistory = <String, RingBuffer<double>>{};
    final writeHistory = <String, RingBuffer<double>>{};

    if (m.cpu != null) {
      cpuHistory = cpuHistory.add(m.cpu!.usagePercent);
    }
    if (m.memory != null) {
      memoryHistory = memoryHistory.add(m.memory!.usagePercent);
    }

    for (final net in m.networks) {
      final iface = net.interface_;
      rxHistory[iface] = (host.rxHistory[iface] ?? RingBuffer<double>()).add(
        net.rxBytesPerSec.toDouble(),
      );
      txHistory[iface] = (host.txHistory[iface] ?? RingBuffer<double>()).add(
        net.txBytesPerSec.toDouble(),
      );
    }

    for (final disk in m.disks) {
      final dev = disk.device;
      readHistory[dev] = (host.readHistory[dev] ?? RingBuffer<double>()).add(
        disk.readBytesPerSec.toDouble(),
      );
      writeHistory[dev] = (host.writeHistory[dev] ?? RingBuffer<double>()).add(
        disk.writeBytesPerSec.toDouble(),
      );
    }

    hosts[event.hostId] = host.copyWith(
      metrics: m,
      cpuHistory: cpuHistory,
      memoryHistory: memoryHistory,
      rxHistory: rxHistory,
      txHistory: txHistory,
      readHistory: readHistory,
      writeHistory: writeHistory,
    );
    emit(MonitorLoaded(hosts: hosts));
  }

  void _onHostInfoReceived(
    _MonitorHostInfoReceived event,
    Emitter<MonitorState> emit,
  ) {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final host = hosts[event.hostId];
    if (host != null) {
      final warning = _isVersionOlder(
        event.hostInfo.agentVersion,
        Protocol.minAgentVersion,
      );
      hosts[event.hostId] = host.copyWith(
        hostInfo: event.hostInfo,
        versionWarning: warning,
      );
      emit(MonitorLoaded(hosts: hosts));
    }
  }

  void _onSetInterval(MonitorSetInterval event, Emitter<MonitorState> emit) {
    _repository.sendSetInterval(event.hostId, event.seconds);

    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final host = hosts[event.hostId];
    if (host != null) {
      hosts[event.hostId] = host.copyWith(interval: event.seconds);
      emit(MonitorLoaded(hosts: hosts));
    }
  }

  void _onPingHost(MonitorPingHost event, Emitter<MonitorState> emit) {
    _repository.sendPing(event.hostId);
  }

  /// Returns true if [version] is older than [minVersion] using semver comparison.
  bool _isVersionOlder(String version, String minVersion) {
    final v = version.split('.').map(int.tryParse).toList();
    final m = minVersion.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final vi = i < v.length ? (v[i] ?? 0) : 0;
      final mi = i < m.length ? (m[i] ?? 0) : 0;
      if (vi < mi) return true;
      if (vi > mi) return false;
    }
    return false;
  }

  void _onConnectionStatusChanged(
    _MonitorConnectionStatusChanged event,
    Emitter<MonitorState> emit,
  ) {
    final currentState = state;
    if (currentState is! MonitorLoaded) return;

    final hosts = Map<String, MonitorHost>.from(currentState.hosts);
    final host = hosts[event.hostId];
    if (host != null) {
      hosts[event.hostId] = host.copyWith(status: event.status);
      emit(MonitorLoaded(hosts: hosts));
    }
  }

  @override
  Future<void> close() async {
    await _discoverySubscription?.cancel();
    for (final sub in _hostSubscriptions.values) {
      await sub.cancel();
    }
    _hostSubscriptions.clear();
    await _repository.disconnectAll();
    return super.close();
  }
}
