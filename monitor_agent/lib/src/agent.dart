import 'dart:async';
import 'dart:io';

import 'package:monitor_agent/src/collectors/raw_collector.dart';
import 'package:monitor_agent/src/config.dart';
import 'package:monitor_agent/src/server/cert_manager.dart';
import 'package:monitor_agent/src/server/mdns_service.dart';
import 'package:monitor_agent/src/server/ws_server.dart';
import 'package:monitor_models/monitor_models.dart';

class MonitorAgent {
  MonitorAgent(this.config);

  final AgentConfig config;
  late final WsServer _server;
  MdnsService? _mdnsService;
  Timer? _timer;
  late final RawCollector _rawCollector;
  Map<String, dynamic>? _previousSample;

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
        agentVersion: '2.0.0',
        fingerprint: fingerprint ?? '',
      );
      await _mdnsService!.register();
    }

    _rawCollector = createRawCollector();

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

  void _sendHostInfo() {
    final info = HostInfo(
      hostname: Platform.localHostname,
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      cpuModel: '',
      cpuCores: Platform.numberOfProcessors,
      totalMemory: 0,
      agentVersion: '2.0.0',
    );

    _server.broadcast(
      MonitorMessage(type: MonitorMessageType.hostInfo, payload: info.toJson()),
    );
  }

  Future<void> _collectAndBroadcast() async {
    try {
      final raw = await _rawCollector.collectRaw();
      final snapshot = ActivitySnapshot.fromSamples(
        raw,
        previous: _previousSample,
      );
      _previousSample = raw;

      _server.broadcast(
        MonitorMessage(
          type: MonitorMessageType.metrics,
          payload: snapshot.toJson(),
        ),
      );
    } catch (e, stack) {
      print('Error collecting metrics: $e\n$stack');
    }
  }

  Future<void> stop() async {
    _timer?.cancel();
    await _mdnsService?.deregister();
    await _server.stop();
    print('Monitor agent stopped');
  }
}
