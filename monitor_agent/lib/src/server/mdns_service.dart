import 'dart:io';

/// Handles mDNS/DNS-SD service registration for the monitor agent.
///
/// Uses platform-specific tools for service advertisement:
/// - macOS: `dns-sd -R` (Bonjour)
/// - Linux: `avahi-publish-service` (Avahi)
/// - Windows: not supported (logs a warning)
class MdnsService {
  MdnsService({
    required this.serviceName,
    required this.port,
    required this.hostname,
    required this.agentVersion,
    required this.fingerprint,
    this.enabled = true,
  });

  final String serviceName;
  final int port;
  final String hostname;
  final String agentVersion;
  final String fingerprint;
  final bool enabled;

  Process? _process;

  static const serviceType = '_gsmlg-monitor._tcp';

  Future<void> register() async {
    if (!enabled) {
      print('mDNS registration disabled');
      return;
    }

    try {
      if (Platform.isMacOS) {
        await _registerMacOS();
      } else if (Platform.isLinux) {
        await _registerLinux();
      } else {
        print('mDNS registration not supported on ${Platform.operatingSystem}');
        return;
      }
      print('mDNS: registered $serviceType as "$serviceName" on port $port');
    } catch (e) {
      print('mDNS registration failed: $e');
    }
  }

  Future<void> _registerMacOS() async {
    // dns-sd -R <name> <type> <domain> <port> [<txt>...]
    _process = await Process.start('dns-sd', [
      '-R',
      serviceName,
      serviceType,
      'local',
      port.toString(),
      'version=$agentVersion',
      'hostname=$hostname',
      'fingerprint=$fingerprint',
    ]);

    // dns-sd runs in foreground, just let it run
    _process!.stderr.drain();
    _process!.stdout.drain();
  }

  Future<void> _registerLinux() async {
    // avahi-publish-service <name> <type> <port> [<txt>...]
    _process = await Process.start('avahi-publish-service', [
      serviceName,
      serviceType,
      port.toString(),
      'version=$agentVersion',
      'hostname=$hostname',
      'fingerprint=$fingerprint',
    ]);

    _process!.stderr.drain();
    _process!.stdout.drain();
  }

  Future<void> deregister() async {
    if (_process != null) {
      _process!.kill();
      await _process!.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          _process!.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
      _process = null;
      print('mDNS: deregistered $serviceType');
    }
  }
}
