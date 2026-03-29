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

// tests for Pullzone
void main() {
  // final instance = Pullzone();

  group('test Pullzone', () {
    // A unique ID for the CDN Pull Zone.
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // The date this CDN Pull Zone was created.
    // String dateCreated
    test('to test the property `dateCreated`', () async {
      // TODO
    });

    // The current status.  * active * pending
    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // The user-supplied label.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // The URI scheme of the origin domain.
    // String originScheme
    test('to test the property `originScheme`', () async {
      // TODO
    });

    // The domain name from which the content stored in the CDN will be pulled.
    // String originDomain
    test('to test the property `originDomain`', () async {
      // TODO
    });

    // The Vultr CDN endpoint to access your cached files.
    // String cdnUrl
    test('to test the property `cdnUrl`', () async {
      // TODO
    });

    // A custom domain provided by the user which can be used to access the cached files.
    // String vanityDomain
    test('to test the property `vanityDomain`', () async {
      // TODO
    });

    // How much data may be cached on each CDN node.
    // num cacheSize
    test('to test the property `cacheSize`', () async {
      // TODO
    });

    // The amount of requests to limit to the CDN.
    // num requests
    test('to test the property `requests`', () async {
      // TODO
    });

    // The amount of inbound bytes allowed to the CDN.
    // num inBytes
    test('to test the property `inBytes`', () async {
      // TODO
    });

    // The amount of outbound bytes allowed from the CDN.
    // num outBytes
    test('to test the property `outBytes`', () async {
      // TODO
    });

    // Per CDN rate limiting per requests/sec.
    // num packetsPerSec
    test('to test the property `packetsPerSec`', () async {
      // TODO
    });

    // The last date and time that the cached content on server proxies was cleared
    // String lastPurge
    test('to test the property `lastPurge`', () async {
      // TODO
    });

    // Cross-origin resource sharing.
    // bool cors
    test('to test the property `cors`', () async {
      // TODO
    });

    // Optional feature to compress files, reduce the amount of data that's transferred.
    // bool gzip
    test('to test the property `gzip`', () async {
      // TODO
    });

    // Optional feature to block AI bots.
    // bool blockAi
    test('to test the property `blockAi`', () async {
      // TODO
    });

    // Optional feature to block potentially malicious bots.
    // bool blockBadBots
    test('to test the property `blockBadBots`', () async {
      // TODO
    });

    // A list of [Region ids](#operation/list-regions) for locations to be used for content delivery.
    // List<String> regions (default value: const [])
    test('to test the property `regions`', () async {
      // TODO
    });
  });
}
