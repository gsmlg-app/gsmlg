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

// tests for CreateNodepoolsRequest
void main() {
  // final instance = CreateNodepoolsRequest();

  group('test CreateNodepoolsRequest', () {
    // Number of instances in this nodepool
    // int nodeQuantity
    test('to test the property `nodeQuantity`', () async {
      // TODO
    });

    // Label for the nodepool. You cannot change the label after a nodepool is created. You cannot have duplicate node pool labels in the same cluster.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Plan that this nodepool will use
    // String plan
    test('to test the property `plan`', () async {
      // TODO
    });

    // Tag for node pool
    // String tag
    test('to test the property `tag`', () async {
      // TODO
    });

    // Option to use the auto scaler with your cluster. Default false.
    // bool autoScaler
    test('to test the property `autoScaler`', () async {
      // TODO
    });

    // Auto scaler field for minimum nodes you want for your cluster. Default 1.
    // int minNodes
    test('to test the property `minNodes`', () async {
      // TODO
    });

    // Auto scaler field for maximum nodes you want for your cluster. Default 1.
    // int maxNodes
    test('to test the property `maxNodes`', () async {
      // TODO
    });

    // Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool. Labels will be applied to both new and existing nodes.
    // Object labels
    test('to test the property `labels`', () async {
      // TODO
    });

    // Array of objects containing key, value, and effect.
    // List<NodepoolTaintReq> taints (default value: const [])
    test('to test the property `taints`', () async {
      // TODO
    });

    // The user-supplied, base64 encoded user data for all nodes in nodepool (only applied on nodes created after user data is set).
    // String userData
    test('to test the property `userData`', () async {
      // TODO
    });
  });
}
