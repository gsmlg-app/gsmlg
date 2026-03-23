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

// tests for FirewallRule
void main() {
  // final instance = FirewallRule();

  group('test FirewallRule', () {
    // A unique ID for the Firewall Rule.
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // This field is deprecated. Use `ip_type` instead.  The type of IP rule.  * v4 * v6
    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // The type of IP rule.  * v4 * v6
    // String ipType
    test('to test the property `ipType`', () async {
      // TODO
    });

    // Action to take when this rule is met.  * accept
    // String action
    test('to test the property `action`', () async {
      // TODO
    });

    // The protocol for this rule.  * ICMP * TCP * UDP * GRE 
    // String protocol
    test('to test the property `protocol`', () async {
      // TODO
    });

    // Port or port range for this rule.
    // String port
    test('to test the property `port`', () async {
      // TODO
    });

    // IP address representing a subnet. The IP address format must match with the \"ip_type\" parameter value.
    // String subnet
    test('to test the property `subnet`', () async {
      // TODO
    });

    // The number of bits for the netmask in CIDR notation. Example: 24
    // int subnetSize
    test('to test the property `subnetSize`', () async {
      // TODO
    });

    // If the source string is given a value of \"cloudflare\" subnet and subnet_size will both be ignored. Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"\" | Use the value from `subnet` and `subnet_size`. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall |
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
