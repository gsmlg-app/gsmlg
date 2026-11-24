import 'dart:async';

import 'package:multicast_dns/multicast_dns.dart';

import '../models/vnc_models.dart';

/// Factory for creating an [MDnsClient], injectable for testing.
typedef MdnsClientFactory = MDnsClient Function();

/// Bounded Bonjour/mDNS scanner for VNC (`_rfb._tcp.local`) hosts on the local
/// network.
class VncMdnsDiscovery {
  VncMdnsDiscovery({MdnsClientFactory? clientFactory})
    : _clientFactory = clientFactory ?? _defaultClientFactory;

  static const String serviceName = '_rfb._tcp.local';

  static MDnsClient _defaultClientFactory() => MDnsClient();

  final MdnsClientFactory _clientFactory;

  /// Scans for `_rfb._tcp.local` services and yields deduplicated
  /// [VncDiscoveredHost] entries as they resolve, completing cleanly within
  /// [timeout] even if multicast networking is unavailable.
  Stream<VncDiscoveredHost> discover({
    Duration timeout = const Duration(seconds: 5),
  }) {
    late final StreamController<VncDiscoveredHost> controller;
    var cancelled = false;
    Timer? overallTimer;
    StreamSubscription<PtrResourceRecord>? ptrSubscription;
    void Function()? abortScan;

    controller = StreamController<VncDiscoveredHost>(
      onCancel: () {
        cancelled = true;
        overallTimer?.cancel();
        abortScan?.call();
        unawaited(ptrSubscription?.cancel().catchError((Object _) {}));
      },
    );

    unawaited(
      _runDiscovery(
        controller: controller,
        timeout: timeout,
        isCancelled: () => cancelled,
        onTimerCreated: (timer) => overallTimer = timer,
        onPtrSubscriptionCreated: (sub) => ptrSubscription = sub,
        onAbortRegistered: (abort) => abortScan = abort,
      ),
    );

    return controller.stream;
  }

  Future<void> _runDiscovery({
    required StreamController<VncDiscoveredHost> controller,
    required Duration timeout,
    required bool Function() isCancelled,
    required void Function(Timer timer) onTimerCreated,
    required void Function(StreamSubscription<PtrResourceRecord> sub)
    onPtrSubscriptionCreated,
    required void Function(void Function() abort) onAbortRegistered,
  }) async {
    final client = _clientFactory();
    final stopwatch = Stopwatch()..start();
    final seenIds = <String>{};
    final seenPtrs = <String>{};
    final inFlightResolutions = <Future<void>>[];
    final scanDone = Completer<void>();
    var timedOut = false;
    Timer? timer;

    Duration remaining() {
      final rem = timeout - stopwatch.elapsed;
      return rem > Duration.zero ? rem : Duration.zero;
    }

    void finishScan() {
      if (!scanDone.isCompleted) {
        scanDone.complete();
      }
    }

    onAbortRegistered(finishScan);

    try {
      if (timeout <= Duration.zero || isCancelled()) {
        return;
      }

      timer = Timer(timeout, () {
        timedOut = true;
        finishScan();
      });
      onTimerCreated(timer);

      await client
          .start(onError: (Object _) {})
          .timeout(remaining(), onTimeout: () => throw TimeoutException(null));

      if (timedOut || isCancelled()) {
        return;
      }

      final ptrStream = client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(serviceName),
        timeout: remaining(),
      );

      final ptrSub = ptrStream.listen(
        (ptr) {
          if (timedOut || isCancelled()) {
            return;
          }
          final normalizedPtr = _stripTrailingDot(ptr.domainName);
          if (normalizedPtr.isEmpty || !seenPtrs.add(normalizedPtr)) {
            return;
          }
          final task = _resolvePointer(
            client: client,
            ptrDomainName: normalizedPtr,
            remaining: remaining,
            isStopped: () => timedOut || isCancelled(),
            seenIds: seenIds,
            controller: controller,
          );
          inFlightResolutions.add(task);
        },
        onError: (Object _) {
          // Ignore transient mDNS lookup errors.
        },
        onDone: finishScan,
        cancelOnError: false,
      );
      onPtrSubscriptionCreated(ptrSub);

      await scanDone.future;
      await ptrSub.cancel().catchError((Object _) {});

      if (!timedOut && !isCancelled() && inFlightResolutions.isNotEmpty) {
        final rem = remaining();
        if (rem > Duration.zero) {
          await Future.wait(
            inFlightResolutions,
          ).timeout(rem, onTimeout: () => const <void>[]);
        }
      }
    } catch (_) {
      // Gracefully swallow socket/platform mDNS failures (e.g. no multicast
      // interface or sandboxed environment).
    } finally {
      timer?.cancel();
      try {
        client.stop();
      } catch (_) {}
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  Future<void> _resolvePointer({
    required MDnsClient client,
    required String ptrDomainName,
    required Duration Function() remaining,
    required bool Function() isStopped,
    required Set<String> seenIds,
    required StreamController<VncDiscoveredHost> controller,
  }) async {
    try {
      final srvRem = remaining();
      if (isStopped() || srvRem <= Duration.zero) {
        return;
      }

      final srvRecords = await _collectBounded(
        client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptrDomainName),
          timeout: srvRem,
        ),
        srvRem,
      );

      for (final srv in srvRecords) {
        if (isStopped()) {
          return;
        }
        final targetHost = _stripTrailingDot(srv.target);
        if (targetHost.isEmpty) {
          continue;
        }

        final addrRem = remaining();
        final addresses = <String>[];
        if (addrRem > Duration.zero) {
          final results = await Future.wait<List<IPAddressResourceRecord>>([
            _collectBounded(
              client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(targetHost),
                timeout: addrRem,
              ),
              addrRem,
            ),
            _collectBounded(
              client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv6(targetHost),
                timeout: addrRem,
              ),
              addrRem,
            ),
          ]);
          final seenAddr = <String>{};
          for (final list in results) {
            for (final record in list) {
              final address = record.address.address;
              if (seenAddr.add(address)) {
                addresses.add(address);
              }
            }
          }
        }

        if (isStopped()) {
          return;
        }

        final displayName = _extractDisplayName(ptrDomainName, targetHost);
        final discovered = VncDiscoveredHost(
          name: displayName,
          host: targetHost,
          port: srv.port,
          addresses: List<String>.unmodifiable(addresses),
        );

        if (seenIds.add(discovered.id) && !controller.isClosed) {
          controller.add(discovered);
        }
      }
    } catch (_) {
      // Ignore individual service resolution failures.
    }
  }

  Future<List<T>> _collectBounded<T>(Stream<T> stream, Duration timeout) async {
    final items = <T>[];
    final done = Completer<void>();
    late final StreamSubscription<T> sub;
    sub = stream.listen(
      items.add,
      onError: (Object _) {},
      onDone: () {
        if (!done.isCompleted) {
          done.complete();
        }
      },
      cancelOnError: false,
    );

    final timer = Timer(timeout, () {
      if (!done.isCompleted) {
        done.complete();
      }
    });

    try {
      await done.future;
    } finally {
      timer.cancel();
      await sub.cancel().catchError((Object _) {});
    }
    return items;
  }

  static String _stripTrailingDot(String value) {
    var result = value.trim();
    while (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  static String _extractDisplayName(String domainName, String fallbackHost) {
    var name = _stripTrailingDot(domainName);
    const suffix = '.$serviceName';
    if (name.toLowerCase().endsWith(suffix)) {
      name = name.substring(0, name.length - suffix.length);
    }
    name = _stripTrailingDot(name);
    return name.isNotEmpty ? name : fallbackHost;
  }
}
