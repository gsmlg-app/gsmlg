import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

enum TrustStatus {
  unknown,
  pending,
  trusted,
  mismatch,
}

class DiscoveredHost {
  const DiscoveredHost({
    required this.ip,
    required this.port,
    required this.hostname,
    this.fingerprint,
    this.agentVersion,
  });

  final String ip;
  final int port;
  final String hostname;
  final String? fingerprint;
  final String? agentVersion;

  String get id => '$ip:$port';
}

sealed class MonitorConnectionEvent {
  const MonitorConnectionEvent();
}

final class MonitorMessageReceived extends MonitorConnectionEvent {
  const MonitorMessageReceived(this.message);
  final MonitorMessage message;
}

final class MonitorConnectionStatusChanged extends MonitorConnectionEvent {
  const MonitorConnectionStatusChanged(this.status, [this.error]);
  final ConnectionStatus status;
  final Object? error;
}

final class MonitorCertificateReceived extends MonitorConnectionEvent {
  const MonitorCertificateReceived(this.fingerprint);
  final String fingerprint;
}

class MonitorRepository {
  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  /// Discover agents on the local network via mDNS.
  Stream<DiscoveredHost> discoverHosts() async* {
    final client = MDnsClient();
    try {
      await client.start();

      // Browse for _gsmlg-monitor._tcp services
      await for (final ptr in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_gsmlg-monitor._tcp'),
      )) {
        // Resolve SRV record
        await for (final srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
        )) {
          // Resolve IP address
          await for (final ip in client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target),
          )) {
            // Try to get TXT records for metadata
            String? fingerprint;
            String? version;
            String hostname = srv.target;

            try {
              await for (final txt in client.lookup<TxtResourceRecord>(
                ResourceRecordQuery.text(ptr.domainName),
              )) {
                final text = txt.text;
                for (final entry in text.split('\n')) {
                  if (entry.startsWith('fingerprint=')) {
                    fingerprint = entry.substring('fingerprint='.length);
                  } else if (entry.startsWith('version=')) {
                    version = entry.substring('version='.length);
                  } else if (entry.startsWith('hostname=')) {
                    hostname = entry.substring('hostname='.length);
                  }
                }
              }
            } catch (_) {
              // TXT records may not be available
            }

            yield DiscoveredHost(
              ip: ip.address.address,
              port: srv.port,
              hostname: hostname,
              fingerprint: fingerprint,
              agentVersion: version,
            );
          }
        }
      }
    } catch (_) {
      // mDNS browsing failed silently
    } finally {
      client.stop();
    }
  }

  /// Connect to a monitor agent. Yields connection events.
  /// If [useTls] is true (default), connects via WSS.
  /// If [pinnedFingerprint] is provided, verifies the server cert matches.
  /// Automatically reconnects with exponential backoff on disconnection.
  Stream<MonitorConnectionEvent> connect(
    String hostId,
    String ip,
    int port, {
    bool useTls = true,
    String? pinnedFingerprint,
  }) async* {
    final scheme = useTls ? 'wss' : 'ws';
    final uri = Uri.parse('$scheme://$ip:$port');

    var delay = const Duration(seconds: 1);
    const maxDelay = Duration(seconds: 30);
    const maxRetryDuration = Duration(minutes: 5);
    final deadline = DateTime.now().add(maxRetryDuration);

    while (DateTime.now().isBefore(deadline)) {
      yield const MonitorConnectionStatusChanged(ConnectionStatus.connecting);

      try {
        WebSocketChannel channel;

        if (useTls) {
          // Create HttpClient that accepts self-signed certs
          String? receivedFingerprint;

          final httpClient = HttpClient()
            ..badCertificateCallback =
                (X509Certificate cert, String host, int port) {
              // Compute fingerprint of the server's cert
              receivedFingerprint = _computeCertFingerprint(cert);

              if (pinnedFingerprint == null) {
                // First connection -- accept and let the UI handle trust
                return true;
              }
              // Verify against pinned fingerprint
              return receivedFingerprint == pinnedFingerprint;
            };

          final ws = await WebSocket.connect(
            uri.toString(),
            customClient: httpClient,
          );
          channel = IOWebSocketChannel(ws);

          if (receivedFingerprint != null) {
            if (pinnedFingerprint == null) {
              // New host -- emit certificate for user verification
              yield MonitorCertificateReceived(receivedFingerprint!);
            } else if (receivedFingerprint != pinnedFingerprint) {
              // Mismatch -- this shouldn't happen since badCertificateCallback
              // would have rejected, but just in case
              yield const MonitorConnectionStatusChanged(
                ConnectionStatus.error,
                'Certificate fingerprint mismatch',
              );
              return;
            }
          }
        } else {
          channel = WebSocketChannel.connect(uri);
          await channel.ready;
        }

        _channels[hostId] = channel;
        yield const MonitorConnectionStatusChanged(ConnectionStatus.connected);

        await for (final data in channel.stream) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final message = MonitorMessage.fromJson(json);
            yield MonitorMessageReceived(message);
          } catch (_) {
            // Skip malformed messages
          }
        }

        // Stream ended normally = disconnected, reset delay for next retry
        delay = const Duration(seconds: 1);
        _channels.remove(hostId);
        yield const MonitorConnectionStatusChanged(
          ConnectionStatus.disconnected,
        );
      } catch (e) {
        _channels.remove(hostId);
        yield MonitorConnectionStatusChanged(ConnectionStatus.error, e);
      }

      // Wait before retrying with exponential backoff
      await Future.delayed(delay);
      delay = Duration(
        milliseconds:
            (delay.inMilliseconds * 2).clamp(0, maxDelay.inMilliseconds),
      );
    }

    // Exceeded retry duration
    yield const MonitorConnectionStatusChanged(
      ConnectionStatus.error,
      'Reconnection timeout',
    );
  }

  String _computeCertFingerprint(X509Certificate cert) {
    final der = cert.der;
    final digest = sha256.convert(der);
    return 'SHA256:${digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':')}';
  }

  Future<void> disconnect(String hostId) async {
    await _subscriptions[hostId]?.cancel();
    _subscriptions.remove(hostId);
    await _channels[hostId]?.sink.close();
    _channels.remove(hostId);
  }

  Future<void> disconnectAll() async {
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();
    for (final channel in _channels.values) {
      await channel.sink.close();
    }
    _channels.clear();
  }

  void sendSetInterval(String hostId, int seconds) {
    final channel = _channels[hostId];
    if (channel != null) {
      channel.sink.add(jsonEncode({
        'type': 'set_interval',
        'payload': {'seconds': seconds},
      }));
    }
  }

  void sendPing(String hostId) {
    final channel = _channels[hostId];
    if (channel != null) {
      channel.sink.add(jsonEncode(
        const MonitorMessage(type: MonitorMessageType.ping, payload: {})
            .toJson(),
      ));
    }
  }
}
