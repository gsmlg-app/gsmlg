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

// tests for LoadbalancerGenericInfo
void main() {
  // final instance = LoadbalancerGenericInfo();

  group('test LoadbalancerGenericInfo', () {
    // The balancing algorithm.  * roundrobin (default) * leastconn
    // String balancingAlgorithm
    test('to test the property `balancingAlgorithm`', () async {
      // TODO
    });

    // If `true`, this will redirect all HTTP traffic to HTTPS. You must have an HTTPS rule and SSL certificate installed on the load balancer to enable this option.  * true * false
    // bool sslRedirect
    test('to test the property `sslRedirect`', () async {
      // TODO
    });

    // LoadbalancerGenericInfoStickySessions stickySessions
    test('to test the property `stickySessions`', () async {
      // TODO
    });

    // \"If `true`, you must configure backend nodes to accept Proxy protocol. \\n\\n* true\\n* false (Default)\"
    // bool proxyProtocol
    test('to test the property `proxyProtocol`', () async {
      // TODO
    });

    // The maximum time allowed for the connection to remain inactive before timing out in seconds. This defaults to 600.
    // int timeout
    test('to test the property `timeout`', () async {
      // TODO
    });

    // Use `vpc` instead. ID of the private network you wish to use. If private_network is omitted it will default to the public network.
    // String privateNetwork
    test('to test the property `privateNetwork`', () async {
      // TODO
    });

    // ID of the VPC you wish to use. If a VPC ID is omitted it will default to the public network.
    // String vpc
    test('to test the property `vpc`', () async {
      // TODO
    });


  });

}
