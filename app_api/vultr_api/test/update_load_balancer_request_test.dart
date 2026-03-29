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

// tests for UpdateLoadBalancerRequest
void main() {
  // final instance = UpdateLoadBalancerRequest();

  group('test UpdateLoadBalancerRequest', () {
    // CreateLoadBalancerRequestSsl ssl
    test('to test the property `ssl`', () async {
      // TODO
    });

    // CreateLoadBalancerRequestStickySession stickySession
    test('to test the property `stickySession`', () async {
      // TODO
    });

    // An array of forwarding rule objects.
    // List<CreateLoadBalancerRequestForwardingRulesInner> forwardingRules (default value: const [])
    test('to test the property `forwardingRules`', () async {
      // TODO
    });

    // UpdateLoadBalancerRequestHealthCheck healthCheck
    test('to test the property `healthCheck`', () async {
      // TODO
    });

    // If `true`, you must configure backend nodes to accept Proxy protocol.  * true * false (Default)
    // bool proxyProtocol
    test('to test the property `proxyProtocol`', () async {
      // TODO
    });

    // The maximum time allowed for the connection to remain inactive before timing out in seconds. This defaults to 600.
    // int timeout
    test('to test the property `timeout`', () async {
      // TODO
    });

    // If `true`, this will redirect all HTTP traffic to HTTPS. You must have an HTTPS rule and SSL certificate installed on the load balancer to enable this option.  * true * false
    // bool sslRedirect
    test('to test the property `sslRedirect`', () async {
      // TODO
    });

    // If `true`, this will enable HTTP2 traffic. You must have an HTTPS forwarding rule combo (HTTPS -> HTTPS) to enable this option.  * true * false
    // bool http2
    test('to test the property `http2`', () async {
      // TODO
    });

    // If `true`, this will enable HTTP3/QUIC traffic. You must have HTTP2 enabled.  * true * false
    // bool http3
    test('to test the property `http3`', () async {
      // TODO
    });

    // The number of nodes to add to the load balancer (1-99), must be an odd number. This defaults to 1.
    // int nodes
    test('to test the property `nodes`', () async {
      // TODO
    });

    // The balancing algorithm.  * roundrobin (default) * leastconn
    // String balancingAlgorithm
    test('to test the property `balancingAlgorithm`', () async {
      // TODO
    });

    // Send the complete array of Instances IDs that should be attached to this Load Balancer. Instances will be attached or detached to match your array. For example, if Instances **X**, **Y**, and **Z** are currently attached, and you send [A,B,Z], then Instance **A** and **B** will be attached,  **X** and **Y** will be detached, and **Z** will remain attached.
    // List<String> instances (default value: const [])
    test('to test the property `instances`', () async {
      // TODO
    });

    // The label for your Load Balancer
    // String label
    test('to test the property `label`', () async {
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

    // An array of firewall rule objects.
    // List<CreateLoadBalancerRequestFirewallRulesInner> firewallRules (default value: const [])
    test('to test the property `firewallRules`', () async {
      // TODO
    });

    // CreateLoadBalancerRequestAutoSsl autoSsl
    test('to test the property `autoSsl`', () async {
      // TODO
    });

    // Array of [Region ids](#operation/list-regions) to deploy child Load Balancers to.
    // List<String> globalRegions (default value: const [])
    test('to test the property `globalRegions`', () async {
      // TODO
    });
  });
}
