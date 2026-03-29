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

// tests for CreateBlockRequest
void main() {
  // final instance = CreateBlockRequest();

  group('test CreateBlockRequest', () {
    // The [Region id](#operation/list-regions) where the Block Storage will be created.
    // String region
    test('to test the property `region`', () async {
      // TODO
    });

    // Size in GB may range between 10 and 40000, depending on the `block_type`.
    // int sizeGb
    test('to test the property `sizeGb`', () async {
      // TODO
    });

    // The user-supplied label.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // An optional parameter, that determines on the type of block storage volume that will be created. Soon to become a required parameter.  * `high_perf` from 10GB to 10,000GB * `storage_opt` from 40GB to 40,000GB
    // String blockType
    test('to test the property `blockType`', () async {
      // TODO
    });
  });
}
