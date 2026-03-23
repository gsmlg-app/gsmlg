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

// tests for CreateVpc2Request
void main() {
  // final instance = CreateVpc2Request();

  group('test CreateVpc2Request', () {
    // Create the VPC in this [Region id](#operation/list-regions).
    // String region
    test('to test the property `region`', () async {
      // TODO
    });

    // A description of the VPC. </br> Must be no longer than 255 characters and may include only letters, numbers, spaces, underscores and hyphens.
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // Accepted values: * `v4`
    // String ipType
    test('to test the property `ipType`', () async {
      // TODO
    });

    // The VPC subnet IP address. For example: 10.99.0.0<br><span style=\"color: red\">If a prefix_length is specified then ip_block is a required field.</span>
    // String ipBlock
    test('to test the property `ipBlock`', () async {
      // TODO
    });

    // The number of bits for the netmask in CIDR notation. Example: 24<br><span style=\"color: red\">If an ip_block is specified then prefix_length is a required field.</span>
    // int prefixLength
    test('to test the property `prefixLength`', () async {
      // TODO
    });


  });

}
