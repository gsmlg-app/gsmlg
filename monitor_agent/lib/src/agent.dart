import 'dart:async';
import 'dart:io';

import 'package:monitor_agent/src/collectors/raw_collector.dart';
import 'package:monitor_agent/src/config.dart';
import 'package:monitor_agent/src/server/cert_manager.dart';
import 'package:monitor_agent/src/server/mdns_service.dart';
import 'package:monitor_agent/src/server/ws_server.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MonitorAgent {
  MonitorAgent(this.config);

  final AgentConfig config;
  late final WsServer _server;
  MdnsService? _mdnsService;
  Timer? _timer;
  late final RawCollector _rawCollector;
  Map<String, dynamic>? _previousSample;
  final List<ActivitySnapshot> _history = [];

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

    // When a client connects, immediately send host info and full history
    _server.onClientConnected = (client) {
      _sendHostInfoTo(client);
      if (_history.isNotEmpty) {
        _sendHistoryTo(client);
      }
    };

    // Warm up the first sample immediately so subsequent ticks have baseline
    try {
      _previousSample = await _rawCollector.collectRaw();
    } catch (_) {}

    _timer = Timer.periodic(Duration(seconds: config.interval), (_) async {
      await _collectAndTick();
    });

    print('Collecting metrics every ${config.interval}s');
  }

  void _sendHostInfoTo(WebSocketChannel client) {
    final info = HostInfo(
      hostname: Platform.localHostname,
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      cpuModel: '',
      cpuCores: Platform.numberOfProcessors,
      totalMemory: 0,
      agentVersion: '2.0.0',
    );

    _server.sendTo(
      client,
      MonitorMessage(type: MonitorMessageType.hostInfo, payload: info.toJson()),
    );
  }

  void _sendHistoryTo(WebSocketChannel client) {
    _server.sendTo(
      client,
      MonitorMessage(
        type: MonitorMessageType.history,
        payload: {
          Protocol.snapshots: _history.map((s) => s.toJson()).toList(),
        },
      ),
    );
  }

  Future<void> _collectAndTick() async {
    try {
      final raw = await _rawCollector.collectRaw();
      final snapshot = ActivitySnapshot.fromSamples(
        raw,
        previous: _previousSample,
      );
      _previousSample = raw;

      _history.add(snapshot);
      if (_history.length > 60) _history.removeAt(0);

      if (_server.currentClientCount > 0) {
        _server.broadcast(
          MonitorMessage(
            type: MonitorMessageType.metricsDelta,
            payload: snapshot.toDeltaJson(),
          ),
        );
      }
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
