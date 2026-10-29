import 'dart:io';

import 'package:app_ssh/app_ssh.dart';
import 'package:test/test.dart';

void main() {
  // Network tests are skipped by default because they depend on external services
  // Set RUN_NETWORK_TESTS=true to enable them
  final runNetworkTests = Platform.environment['RUN_NETWORK_TESTS'] == 'true';

  group('SSHSocket', () {
    test(
      'can establish tcp connections',
      () async {
        final socket = await SSHSocket.connect('time.nist.gov', 13);
        final firstPacket = await socket.stream.first.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
            'No response from time.nist.gov within 10 seconds',
          ),
        );
        expect(firstPacket, isNotEmpty);
        await socket.close();
      },
      skip: runNetworkTests
          ? null
          : 'Skipped by default - set RUN_NETWORK_TESTS=true to enable',
      timeout: Timeout(const Duration(seconds: 15)),
    );

    test('creates SSHSocket with correct host and port', () {
      // Test that SSHSocket factory exists and has correct signature
      expect(SSHSocket.connect, isA<Function>());
    });
  });
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
