import 'dart:async';

import 'package:multicast_dns/multicast_dns.dart';

import '../models/vnc_models.dart';

/// Factory for creating an [MDnsClient], injectable for testing.
typedef MdnsClientFactory = MDnsClient Function();

/// Bounded Bonjour/mDNS scanner for VNC (`_rfb._tcp.local`) hosts on the local
/// network.
class VncMdnsDiscovery {
  VncMdnsDiscovery({
    MdnsClientFactory? clientFactory,
    Duration maxSubLookupTimeout = const Duration(milliseconds: 1200),
    Duration postFirstRecordSettle = const Duration(milliseconds: 150),
  }) : _clientFactory = clientFactory ?? _defaultClientFactory,
       _maxSubLookupTimeout = maxSubLookupTimeout,
       _postFirstRecordSettle = postFirstRecordSettle;

  static const String serviceName = '_rfb._tcp.local';

  static MDnsClient _defaultClientFactory() => MDnsClient();

  final MdnsClientFactory _clientFactory;
  final Duration _maxSubLookupTimeout;
  final Duration _postFirstRecordSettle;

  /// Scans for `_rfb._tcp.local` services and yields deduplicated
  /// [VncDiscoveredHost] entries as they resolve, completing cleanly within
  /// [timeout] even if multicast networking is unavailable.
  ///
  /// Discovery starts lazily when the returned stream is listened to and stops
  /// immediately if the subscription is cancelled.
  Stream<VncDiscoveredHost> discover({
    Duration timeout = const Duration(seconds: 5),
  }) {
    late final StreamController<VncDiscoveredHost> controller;
    var cancelled = false;
    Timer? overallTimer;
    StreamSubscription<PtrResourceRecord>? ptrSubscription;
    void Function()? abortScan;

    controller = StreamController<VncDiscoveredHost>(
      onListen: () {
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
      },
      onCancel: () {
        cancelled = true;
        overallTimer?.cancel();
        abortScan?.call();
        unawaited(ptrSubscription?.cancel().catchError((Object _) {}));
      },
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
    final abortCompleter = Completer<void>();
    var timedOut = false;
    Timer? timer;

    Duration remaining() {
      final rem = timeout - stopwatch.elapsed;
      return rem > Duration.zero ? rem : Duration.zero;
    }

    void triggerAbort() {
      if (!abortCompleter.isCompleted) {
        abortCompleter.complete();
      }
      if (!scanDone.isCompleted) {
        scanDone.complete();
      }
    }

    onAbortRegistered(triggerAbort);

    try {
      if (timeout <= Duration.zero || isCancelled()) {
        return;
      }

      timer = Timer(timeout, () {
        timedOut = true;
        triggerAbort();
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
            abortSignal: abortCompleter.future,
            isCancelled: isCancelled,
            seenIds: seenIds,
            controller: controller,
          );
          inFlightResolutions.add(task);
        },
        onError: (Object _) {
          // Ignore transient mDNS lookup errors.
        },
        onDone: () {
          if (!scanDone.isCompleted) {
            scanDone.complete();
          }
        },
        cancelOnError: false,
      );
      onPtrSubscriptionCreated(ptrSub);

      await scanDone.future;
      await ptrSub.cancel().catchError((Object _) {});

      if (!timedOut && remaining() <= Duration.zero) {
        timedOut = true;
        triggerAbort();
      }

      if (!isCancelled() && inFlightResolutions.isNotEmpty) {
        // When timedOut is true, abortSignal has unblocked all in-flight
        // sub-lookups so they can emit already-resolved hosts; give those
        // microtasks a brief drain window before closing the controller.
        final drainTimeout = timedOut
            ? const Duration(milliseconds: 200)
            : remaining();
        await Future.wait(
          inFlightResolutions,
        ).timeout(drainTimeout, onTimeout: () => const <void>[]);
      }
    } catch (_) {
      // Gracefully swallow socket/platform mDNS failures (e.g. no multicast
      // interface or sandboxed environment).
    } finally {
      timer?.cancel();
      if (!abortCompleter.isCompleted) {
        abortCompleter.complete();
      }
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
    required Future<void> abortSignal,
    required bool Function() isCancelled,
    required Set<String> seenIds,
    required StreamController<VncDiscoveredHost> controller,
  }) async {
    try {
      final srvRem = _minDuration(remaining(), _maxSubLookupTimeout);
      if (isCancelled() || srvRem <= Duration.zero) {
        return;
      }

      final srvRecords = await _collectBounded(
        client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptrDomainName),
          timeout: srvRem,
        ),
        srvRem,
        abortSignal: abortSignal,
        settleAfterFirst: _postFirstRecordSettle,
      );

      for (final srv in srvRecords) {
        if (isCancelled()) {
          return;
        }
        final targetHost = _stripTrailingDot(srv.target);
        if (targetHost.isEmpty) {
          continue;
        }

        final addrRem = _minDuration(remaining(), _maxSubLookupTimeout);
        final addresses = addrRem > Duration.zero
            ? await _resolveAddresses(
                client: client,
                targetHost: targetHost,
                timeout: addrRem,
                abortSignal: abortSignal,
              )
            : const <String>[];

        if (isCancelled()) {
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

  Future<List<String>> _resolveAddresses({
    required MDnsClient client,
    required String targetHost,
    required Duration timeout,
    required Future<void> abortSignal,
  }) async {
    final ipv4Addresses = <String>[];
    final ipv6Addresses = <String>[];
    final done = Completer<void>();
    Timer? settleTimer;
    Timer? hardTimer;
    var activeStreams = 2;

    void finish() {
      if (!done.isCompleted) {
        done.complete();
      }
    }

    void scheduleSettle() {
      settleTimer ??= Timer(_postFirstRecordSettle, finish);
    }

    void onStreamDone() {
      activeStreams--;
      if (activeStreams <= 0) {
        finish();
      }
    }

    final ipv4Sub = client
        .lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(targetHost),
          timeout: timeout,
        )
        .listen(
          (record) {
            ipv4Addresses.add(record.address.address);
            scheduleSettle();
          },
          onError: (Object _) {},
          onDone: onStreamDone,
          cancelOnError: false,
        );

    final ipv6Sub = client
        .lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv6(targetHost),
          timeout: timeout,
        )
        .listen(
          (record) {
            ipv6Addresses.add(record.address.address);
            scheduleSettle();
          },
          onError: (Object _) {},
          onDone: onStreamDone,
          cancelOnError: false,
        );

    hardTimer = Timer(timeout, finish);
    unawaited(abortSignal.then((_) => finish()));

    try {
      await done.future;
    } finally {
      hardTimer.cancel();
      settleTimer?.cancel();
      await ipv4Sub.cancel().catchError((Object _) {});
      await ipv6Sub.cancel().catchError((Object _) {});
    }

    // Prefer IPv4 addresses first, followed by IPv6, deduplicated in order.
    final combined = <String>[];
    final seen = <String>{};
    for (final addr in [...ipv4Addresses, ...ipv6Addresses]) {
      if (seen.add(addr)) {
        combined.add(addr);
      }
    }
    return combined;
  }

  Future<List<T>> _collectBounded<T>(
    Stream<T> stream,
    Duration timeout, {
    required Future<void> abortSignal,
    Duration? settleAfterFirst,
  }) async {
    final items = <T>[];
    final done = Completer<void>();
    Timer? settleTimer;

    void finish() {
      if (!done.isCompleted) {
        done.complete();
      }
    }

    final sub = stream.listen(
      (item) {
        items.add(item);
        if (settleAfterFirst != null) {
          settleTimer ??= Timer(settleAfterFirst, finish);
        }
      },
      onError: (Object _) {},
      onDone: finish,
      cancelOnError: false,
    );

    final hardTimer = Timer(timeout, finish);
    unawaited(abortSignal.then((_) => finish()));

    try {
      await done.future;
    } finally {
      hardTimer.cancel();
      settleTimer?.cancel();
      await sub.cancel().catchError((Object _) {});
    }
    return items;
  }

  static Duration _minDuration(Duration a, Duration b) => a < b ? a : b;

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
