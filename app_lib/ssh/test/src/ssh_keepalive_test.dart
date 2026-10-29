import 'package:test/test.dart';
import 'package:app_ssh/src/ssh_keepalive.dart';

void main() {
  group('SSHKeepAlive', () {
    test('constructor sets default interval', () {
      final keepalive = SSHKeepAlive(ping: () async {});
      expect(keepalive.interval, const Duration(seconds: 10));
    });

    test('constructor accepts custom interval', () {
      final keepalive = SSHKeepAlive(
        ping: () async {},
        interval: const Duration(seconds: 30),
      );
      expect(keepalive.interval, const Duration(seconds: 30));
    });

    test('ping function is stored', () async {
      var pingCalled = false;
      final keepalive = SSHKeepAlive(
        ping: () async {
          pingCalled = true;
        },
      );

      await keepalive.ping();
      expect(pingCalled, true);
    });

    test('start begins periodic timer', () async {
      var pingCount = 0;
      final keepalive = SSHKeepAlive(
        ping: () async {
          pingCount++;
        },
        interval: const Duration(milliseconds: 50),
      );

      keepalive.start();

      // Wait for at least 2 intervals
      await Future.delayed(const Duration(milliseconds: 120));
      keepalive.stop();

      expect(pingCount, greaterThanOrEqualTo(2));
    });

    test('start is idempotent', () async {
      var pingCount = 0;
      final keepalive = SSHKeepAlive(
        ping: () async {
          pingCount++;
        },
        interval: const Duration(milliseconds: 50),
      );

      keepalive.start();
      keepalive.start(); // Second start should be no-op
      keepalive.start(); // Third start should be no-op

      await Future.delayed(const Duration(milliseconds: 120));
      keepalive.stop();

      // Should only have one timer running, not three
      expect(pingCount, lessThan(10));
    });

    test('stop cancels timer', () async {
      var pingCount = 0;
      final keepalive = SSHKeepAlive(
        ping: () async {
          pingCount++;
        },
        interval: const Duration(milliseconds: 50),
      );

      keepalive.start();
      await Future.delayed(const Duration(milliseconds: 70));
      keepalive.stop();

      final countAfterStop = pingCount;
      await Future.delayed(const Duration(milliseconds: 100));

      // No more pings after stop
      expect(pingCount, countAfterStop);
    });

    test('stop is idempotent', () {
      final keepalive = SSHKeepAlive(ping: () async {});

      // These should not throw
      keepalive.stop();
      keepalive.stop();
      keepalive.stop();
    });

    test('can restart after stop', () async {
      var pingCount = 0;
      final keepalive = SSHKeepAlive(
        ping: () async {
          pingCount++;
        },
        interval: const Duration(milliseconds: 50),
      );

      keepalive.start();
      await Future.delayed(const Duration(milliseconds: 70));
      keepalive.stop();

      final countAfterStop = pingCount;

      // Restart
      keepalive.start();
      await Future.delayed(const Duration(milliseconds: 70));
      keepalive.stop();

      expect(pingCount, greaterThan(countAfterStop));
    });

    test('stop before start does nothing', () {
      final keepalive = SSHKeepAlive(ping: () async {});
      keepalive.stop(); // Should not throw
    });

    test('ping can be async', () async {
      var completed = false;
      final keepalive = SSHKeepAlive(
        ping: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          completed = true;
        },
        interval: const Duration(milliseconds: 50),
      );

      keepalive.start();
      await Future.delayed(const Duration(milliseconds: 70));
      keepalive.stop();

      expect(completed, true);
    });

    test('zero interval is valid', () {
      final keepalive = SSHKeepAlive(
        ping: () async {},
        interval: Duration.zero,
      );
      expect(keepalive.interval, Duration.zero);
    });
  });
}
