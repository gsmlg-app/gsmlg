//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:vultr_api/api.dart';
import 'package:test/test.dart';

// tests for CreateLoadBalancerRequestHealthCheck
void main() {
  // final instance = CreateLoadBalancerRequestHealthCheck();

  group('test CreateLoadBalancerRequestHealthCheck', () {
    // The protocol to use for health checks.  * HTTPS * HTTP * TCP
    // String protocol
    test('to test the property `protocol`', () async {
      // TODO
    });

    // The port to use for health checks.
    // int port
    test('to test the property `port`', () async {
      // TODO
    });

    // HTTP Path to check. Only applies if protocol is HTTP, or HTTPS.
    // String path
    test('to test the property `path`', () async {
      // TODO
    });

    // Interval between health checks.
    // int checkInterval
    test('to test the property `checkInterval`', () async {
      // TODO
    });

    // Timeout before health check fails.
    // int responseTimeout
    test('to test the property `responseTimeout`', () async {
      // TODO
    });

    // Number times a check must fail before becoming unhealthy.
    // int unhealthyThreshold
    test('to test the property `unhealthyThreshold`', () async {
      // TODO
    });

    // Number of times a check must succeed before returning to healthy status.
    // int healthyThreshold
    test('to test the property `healthyThreshold`', () async {
      // TODO
    });
  });
}
