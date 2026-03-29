import 'package:args/args.dart';

class AgentConfig {
  const AgentConfig({
    this.port = 9723,
    this.interval = 3,
    this.bind = '0.0.0.0',
    this.enableMdns = true,
    this.useTls = true,
    this.regenCert = false,
  });

  final int port;
  final int interval;
  final String bind;
  final bool enableMdns;
  final bool useTls;
  final bool regenCert;

  factory AgentConfig.fromArgs(ArgResults results) => AgentConfig(
        port: int.parse(results['port'] as String),
        interval: int.parse(results['interval'] as String),
        bind: results['bind'] as String,
        enableMdns: !(results['no-mdns'] as bool? ?? false),
        useTls: !(results['no-tls'] as bool? ?? false),
        regenCert: results['regen-cert'] as bool? ?? false,
      );
}
