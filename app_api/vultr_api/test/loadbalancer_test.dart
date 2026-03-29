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

// tests for Loadbalancer
void main() {
  // final instance = Loadbalancer();

  group('test Loadbalancer', () {
    // A unique ID for the Load Balancer.
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Date this Load Balancer was created.
    // String dateCreated
    test('to test the property `dateCreated`', () async {
      // TODO
    });

    // The [Region id](#operation/list-regions) where the Load Balancer is located.
    // String region
    test('to test the property `region`', () async {
      // TODO
    });

    // The user-supplied label for this load-balancer.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // The current status.  * active
    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // The IPv4 address of this Load Balancer.
    // String ipv4
    test('to test the property `ipv4`', () async {
      // TODO
    });

    // The IPv6 address of this Load Balancer.
    // String ipv6
    test('to test the property `ipv6`', () async {
      // TODO
    });

    // LoadbalancerGenericInfo genericInfo
    test('to test the property `genericInfo`', () async {
      // TODO
    });

    // LoadbalancerHealthCheck healthCheck
    test('to test the property `healthCheck`', () async {
      // TODO
    });

    // Indicates if this Load Balancer has an SSL certificate installed.
    // bool hasSsl
    test('to test the property `hasSsl`', () async {
      // TODO
    });

    // Indicates if this Load Balancer has HTTP2 enabled.
    // bool http2
    test('to test the property `http2`', () async {
      // TODO
    });

    // Indicates if this Load Balancer has HTTP3 enabled.
    // bool http3
    test('to test the property `http3`', () async {
      // TODO
    });

    // The number of nodes to add to the load balancer (1-99), must be an odd number. This defaults to 1.
    // int nodes
    test('to test the property `nodes`', () async {
      // TODO
    });

    // An array of forwarding rule objects.
    // List<LoadbalancerForwardRulesInner> forwardRules (default value: const [])
    test('to test the property `forwardRules`', () async {
      // TODO
    });

    // Array of [Instance ids](#operation/list-instances) attached to this Load Balancer.
    // List<String> instances (default value: const [])
    test('to test the property `instances`', () async {
      // TODO
    });

    // An array of firewall rule objects.
    // List<LoadbalancerFirewallRulesInner> firewallRules (default value: const [])
    test('to test the property `firewallRules`', () async {
      // TODO
    });

    // LoadbalancerNodeIps nodeIps
    test('to test the property `nodeIps`', () async {
      // TODO
    });

    // LoadbalancerAutoSsl autoSsl
    test('to test the property `autoSsl`', () async {
      // TODO
    });

    // If this load balancer is a child of a global load balancer, this field will display the ID of the parent load balancer.
    // String globalParentId
    test('to test the property `globalParentId`', () async {
      // TODO
    });

    // Array of [Region ids](#operation/list-regions) to deploy child Load Balancers to.
    // List<String> globalRegions (default value: const [])
    test('to test the property `globalRegions`', () async {
      // TODO
    });

    // If this load balancer is the parent of a global load balancer, this filed will display an array of children load balancer ids
    // List<String> globalChildrenIds (default value: const [])
    test('to test the property `globalChildrenIds`', () async {
      // TODO
    });

    // The Canonical Name (CNAME) record value
    // String globalCname
    test('to test the property `globalCname`', () async {
      // TODO
    });

    // Base64 encoded ssl certificate, private key, and chain
    // String sslCertB64
    test('to test the property `sslCertB64`', () async {
      // TODO
    });

    // Pending charges for the current billing period
    // int pendingCharges
    test('to test the property `pendingCharges`', () async {
      // TODO
    });

    // The Canonical Name (CNAME) record value
    // String cname
    test('to test the property `cname`', () async {
      // TODO
    });
  });
}
