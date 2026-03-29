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

// tests for PostFirewallsFirewallGroupIdRulesRequest
void main() {
  // final instance = PostFirewallsFirewallGroupIdRulesRequest();

  group('test PostFirewallsFirewallGroupIdRulesRequest', () {
    // The type of IP rule.  * v4 * v6
    // String ipType
    test('to test the property `ipType`', () async {
      // TODO
    });

    // The protocol for this rule.  * ICMP * TCP * UDP * GRE * ESP * AH
    // String protocol
    test('to test the property `protocol`', () async {
      // TODO
    });

    // IP address representing a subnet. The IP address format must match with the \"ip_type\" parameter value.
    // String subnet
    test('to test the property `subnet`', () async {
      // TODO
    });

    // The number of bits for the netmask in CIDR notation. Example: 32
    // int subnetSize
    test('to test the property `subnetSize`', () async {
      // TODO
    });

    // TCP/UDP only. This field can be a specific port or a colon separated port range.
    // String port
    test('to test the property `port`', () async {
      // TODO
    });

    // If the source string is given a value of \"cloudflare\" subnet and subnet_size will both be ignored. Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"\" | Use the value from `subnet` and `subnet_size`. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall | |   | [Load Balancer id](#operation/list-load-balancers) | Provide a load balancer ID to use its IPs |
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // User-supplied notes for this rule.
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });
  });
}
