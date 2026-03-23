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

// tests for KafkaConnectAdvancedOptions
void main() {
  // final instance = KafkaConnectAdvancedOptions();

  group('test KafkaConnectAdvancedOptions', () {
    // Defines what client configurations can be overridden by the connector. Default is None.
    // String connectorClientConfigOverridePolicy
    test('to test the property `connectorClientConfigOverridePolicy`', () async {
      // TODO
    });

    // What to do when there is no initial offset in Kafka or if the current offset does not exist any more on the server. Default is earliest.
    // String consumerAutoOffsetReset
    test('to test the property `consumerAutoOffsetReset`', () async {
      // TODO
    });

    // Accepted values: 1048576 - 104857600
    // int consumerFetchMaxBytes
    test('to test the property `consumerFetchMaxBytes`', () async {
      // TODO
    });

    // Transaction read isolation level. `read_uncommitted` is the default, but `read_committed` can be used if consume-exactly-once behavior is desired.
    // String consumerIsolationLevel
    test('to test the property `consumerIsolationLevel`', () async {
      // TODO
    });

    // Accepted values: 1048576 - 104857600
    // int consumerMaxPartitionFetchBytes
    test('to test the property `consumerMaxPartitionFetchBytes`', () async {
      // TODO
    });

    // Accepted values: 1 - 2147483647
    // int consumerMaxPollIntervalMs
    test('to test the property `consumerMaxPollIntervalMs`', () async {
      // TODO
    });

    // Accepted values: 1 - 10000
    // int consumerMaxPollRecords
    test('to test the property `consumerMaxPollRecords`', () async {
      // TODO
    });

    // Accepted values: 1 - 100000000
    // int offsetFlushIntervalMs
    test('to test the property `offsetFlushIntervalMs`', () async {
      // TODO
    });

    // Accepted values: 1 - 2147483647
    // int offsetFlushTimeoutMs
    test('to test the property `offsetFlushTimeoutMs`', () async {
      // TODO
    });

    // Accepted values: 1 - 5242880
    // int producerBatchSize
    test('to test the property `producerBatchSize`', () async {
      // TODO
    });

    // Accepted values: 5242880 - 134217728
    // int producerBufferMemory
    test('to test the property `producerBufferMemory`', () async {
      // TODO
    });

    // String producerCompressionType
    test('to test the property `producerCompressionType`', () async {
      // TODO
    });

    // Accepted values: 1 - 5000
    // int producerLingerMs
    test('to test the property `producerLingerMs`', () async {
      // TODO
    });

    // Accepted values: 131072 - 67108864
    // int producerMaxRequestSize
    test('to test the property `producerMaxRequestSize`', () async {
      // TODO
    });

    // Accepted values: 1 - 600000
    // int scheduledRebalanceMaxDelayMs
    test('to test the property `scheduledRebalanceMaxDelayMs`', () async {
      // TODO
    });

    // Accepted values: 1 - 2147483647
    // int sessionTimeoutMs
    test('to test the property `sessionTimeoutMs`', () async {
      // TODO
    });


  });

}
