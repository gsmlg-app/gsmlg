import 'dart:io';

import 'package:args/args.dart';
import 'package:monitor_agent/monitor_agent.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', defaultsTo: '9723', help: 'WebSocket server port')
    ..addOption('interval',
        defaultsTo: '3', help: 'Metrics push interval (seconds)')
    ..addOption('bind', defaultsTo: '0.0.0.0', help: 'Bind address')
    ..addFlag('no-mdns', defaultsTo: false, help: 'Disable mDNS registration')
    ..addFlag('no-tls', defaultsTo: false, help: 'Disable TLS (plain WebSocket)')
    ..addFlag('regen-cert', defaultsTo: false, help: 'Regenerate TLS certificate')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  final results = parser.parse(args);

  if (results['help'] as bool) {
    print('GSMLG Monitor Agent\n');
    print(parser.usage);
    exit(0);
  }

  final config = AgentConfig.fromArgs(results);
  final agent = MonitorAgent(config);

  ProcessSignal.sigint.watch().listen((_) async {
    await agent.stop();
    exit(0);
  });

  await agent.start();
}
