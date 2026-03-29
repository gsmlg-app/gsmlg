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

/// tests for LoadBalancerApi
void main() {
  // final instance = LoadBalancerApi();

  group('tests for LoadBalancerApi', () {
    // Create Load Balancer
    //
    // Create a new Load Balancer in a particular `region`.
    //
    //Future<CreateLoadBalancer202Response> createLoadBalancer({ CreateLoadBalancerRequest createLoadBalancerRequest }) async
    test('test createLoadBalancer', () async {
      // TODO
    });

    // Create Forwarding Rule
    //
    // Create a new forwarding rule for a Load Balancer.
    //
    //Future createLoadBalancerForwardingRules(String loadBalancerId, { CreateLoadBalancerForwardingRulesRequest createLoadBalancerForwardingRulesRequest }) async
    test('test createLoadBalancerForwardingRules', () async {
      // TODO
    });

    // Update Reverse DNS IPV4
    //
    // Update (ipv4) Reverse DNS for a Load Balancer.
    //
    //Future createLoadBalancerReverseDnsIpv4(String loadBalancerId, { CreateLoadBalancerReverseDnsIpv4Request createLoadBalancerReverseDnsIpv4Request }) async
    test('test createLoadBalancerReverseDnsIpv4', () async {
      // TODO
    });

    // Create Reverse DNS IPV6
    //
    // Create Reverse DNS (ipv6) for a Load Balancer.
    //
    //Future createLoadBalancerReverseDnsIpv6(String loadBalancerId, { CreateLoadBalancerReverseDnsIpv6Request createLoadBalancerReverseDnsIpv6Request }) async
    test('test createLoadBalancerReverseDnsIpv6', () async {
      // TODO
    });

    // Delete Load Balancer
    //
    // Delete a Load Balancer.
    //
    //Future deleteLoadBalancer(String loadBalancerId) async
    test('test deleteLoadBalancer', () async {
      // TODO
    });

    // Disable Load Balancer Auto SSL
    //
    // Disable a Load Balancer Auto SSL. This will not remove an ssl certificate from the load balancer.
    //
    //Future deleteLoadBalancerAutoSsl(String loadBalancerId) async
    test('test deleteLoadBalancerAutoSsl', () async {
      // TODO
    });

    // Delete Forwarding Rule
    //
    // Delete a Forwarding Rule on a Load Balancer.
    //
    //Future deleteLoadBalancerForwardingRule(String loadBalancerId, String forwardingRuleId) async
    test('test deleteLoadBalancerForwardingRule', () async {
      // TODO
    });

    // Delete Reverse DNS
    //
    // Delete a ipv6 reverse dns entry on a Load Balancer.
    //
    //Future deleteLoadBalancerReverseDns(String loadBalancerId) async
    test('test deleteLoadBalancerReverseDns', () async {
      // TODO
    });

    // Delete Load Balancer SSL
    //
    // Delete a Load Balancer SSL.
    //
    //Future deleteLoadBalancerSsl(String loadBalancerId) async
    test('test deleteLoadBalancerSsl', () async {
      // TODO
    });

    // Get Load Balancer
    //
    // Get information for a Load Balancer.
    //
    //Future<CreateLoadBalancer202Response> getLoadBalancer(String loadBalancerId) async
    test('test getLoadBalancer', () async {
      // TODO
    });

    // Get Forwarding Rule
    //
    // Get information for a Forwarding Rule on a Load Balancer.
    //
    //Future<GetLoadBalancerForwardingRule200Response> getLoadBalancerForwardingRule(String loadBalancerId, String forwardingRuleId) async
    test('test getLoadBalancerForwardingRule', () async {
      // TODO
    });

    // Get Reverse DNS
    //
    // Get Reverse DNS information for a Load Balancer.
    //
    //Future<GetLoadBalancerReverseDns200Response> getLoadBalancerReverseDns(String loadBalancerId) async
    test('test getLoadBalancerReverseDns', () async {
      // TODO
    });

    // Get Firewall Rule
    //
    // Get a firewall rule for a Load Balancer.
    //
    //Future<LoadbalancerFirewallRule> getLoadbalancerFirewallRule(String loadbalancerId, String firewallRuleId) async
    test('test getLoadbalancerFirewallRule', () async {
      // TODO
    });

    // List Forwarding Rules
    //
    // List the fowarding rules for a Load Balancer.
    //
    //Future<ListLoadBalancerForwardingRules200Response> listLoadBalancerForwardingRules(String loadBalancerId, { int perPage, String cursor }) async
    test('test listLoadBalancerForwardingRules', () async {
      // TODO
    });

    // List Load Balancers
    //
    // List the Load Balancers in your account.
    //
    //Future<ListLoadBalancers200Response> listLoadBalancers({ int perPage, String cursor }) async
    test('test listLoadBalancers', () async {
      // TODO
    });

    // List Firewall Rules
    //
    // List the firewall rules for a Load Balancer.
    //
    //Future<LoadbalancerFirewallRule> listLoadbalancerFirewallRules(String loadbalancerId, { String perPage, String cursor }) async
    test('test listLoadbalancerFirewallRules', () async {
      // TODO
    });

    // Update Load Balancer
    //
    // Update information for a Load Balancer. All attributes are optional. If not set, the attributes will retain their original values.
    //
    //Future updateLoadBalancer(String loadBalancerId, { UpdateLoadBalancerRequest updateLoadBalancerRequest }) async
    test('test updateLoadBalancer', () async {
      // TODO
    });
  });
}
