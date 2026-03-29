import 'dart:async';
import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/collectors/cpu_collector.dart';
import 'package:monitor_agent/src/collectors/disk_collector.dart';
import 'package:monitor_agent/src/collectors/gpu_collector.dart';
import 'package:monitor_agent/src/collectors/memory_collector.dart';
import 'package:monitor_agent/src/collectors/network_collector.dart';
import 'package:monitor_agent/src/config.dart';
import 'package:monitor_agent/src/server/cert_manager.dart';
import 'package:monitor_agent/src/server/mdns_service.dart';
import 'package:monitor_agent/src/server/ws_server.dart';

class MonitorAgent {
  MonitorAgent(this.config);

  final AgentConfig config;
  late final WsServer _server;
  MdnsService? _mdnsService;
  Timer? _timer;
  MetricsCollector<CpuMetrics>? _cpuCollector;
  MetricsCollector<MemoryMetrics>? _memoryCollector;
  MetricsCollector<List<GpuMetrics>>? _gpuCollector;
  MetricsCollector<List<NetworkMetrics>>? _networkCollector;
  MetricsCollector<List<DiskMetrics>>? _diskCollector;

  Future<void> start() async {
    // TLS setup
    SecurityContext? securityContext;
    String? fingerprint;

    if (config.useTls) {
      final certManager = CertManager(regenCert: config.regenCert);
      securityContext = await certManager.initialize();
      fingerprint = certManager.fingerprint;
      print('Agent fingerprint: $fingerprint');
    }

    _server = WsServer(
      port: config.port,
      bind: config.bind,
      securityContext: securityContext,
      fingerprint: fingerprint,
    );
    await _server.start();

    // mDNS registration
    if (config.enableMdns) {
      _mdnsService = MdnsService(
        serviceName: 'GSMLG Monitor (${Platform.localHostname})',
        port: config.port,
        hostname: Platform.localHostname,
        agentVersion: '1.0.0',
        fingerprint: fingerprint ?? '',
      );
      await _mdnsService!.register();
    }

    _cpuCollector = _tryCreate('CPU', createCpuCollector);
    _memoryCollector = _tryCreate('Memory', createMemoryCollector);
    _gpuCollector = _tryCreate('GPU', createGpuCollector);
    _networkCollector = _tryCreate('Network', createNetworkCollector);
    _diskCollector = _tryCreate('Disk', createDiskCollector);

    _server.clientCount.listen((count) {
      if (count > 0) {
        _sendHostInfo();
      }
    });

    _timer = Timer.periodic(Duration(seconds: config.interval), (_) async {
      if (_server.currentClientCount > 0) {
        await _collectAndBroadcast();
      }
    });

    print('Collecting metrics every ${config.interval}s');
  }

  T? _tryCreate<T>(String name, T Function() factory) {
    try {
      return factory();
    } catch (_) {
      print('Warning: $name collector not available on this platform');
      return null;
    }
  }

  void _sendHostInfo() {
    final info = HostInfo(
      hostname: Platform.localHostname,
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      cpuModel: '',
      cpuCores: Platform.numberOfProcessors,
      totalMemory: 0,
      agentVersion: '1.0.0',
    );

    _server.broadcast(
      MonitorMessage(type: MonitorMessageType.hostInfo, payload: info.toJson()),
    );
  }

  Future<void> _collectAndBroadcast() async {
    final results = await Future.wait([
      _cpuCollector?.collect() ?? Future.value(null),
      _memoryCollector?.collect() ?? Future.value(null),
      _gpuCollector?.collect() ?? Future.value(null),
      _networkCollector?.collect() ?? Future.value(null),
      _diskCollector?.collect() ?? Future.value(null),
    ]);

    final metrics = SystemMetrics(
      cpu: results[0] as CpuMetrics?,
      memory: results[1] as MemoryMetrics?,
      gpus: (results[2] as List<GpuMetrics>?) ?? const [],
      networks: (results[3] as List<NetworkMetrics>?) ?? const [],
      disks: (results[4] as List<DiskMetrics>?) ?? const [],
    );

    _server.broadcast(
      MonitorMessage(
        type: MonitorMessageType.metrics,
        payload: metrics.toJson(),
      ),
    );
  }

  Future<void> stop() async {
    _timer?.cancel();
    await _mdnsService?.deregister();
    await _server.stop();
    print('Monitor agent stopped');
  }
}
