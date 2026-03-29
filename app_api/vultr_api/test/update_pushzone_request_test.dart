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

// tests for UpdatePushzoneRequest
void main() {
  // final instance = UpdatePushzoneRequest();

  group('test UpdatePushzoneRequest', () {
    // The user-supplied label.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // An optional domain name that can be used to access the cached files in adition to the domain that is automaticaly created.  This vanity domain will need to have a CNAME DNS record created to point it at the standard CDN domain that is automaticaly generated on creation of the CDN.
    // String vanityDomain
    test('to test the property `vanityDomain`', () async {
      // TODO
    });

    // Base 64 encoded file content for an ssl/tls certificate associated with the optional vanity_domain.  This field is required if a vanity domain is provided.
    // String sslCert
    test('to test the property `sslCert`', () async {
      // TODO
    });

    // Base 64 encoded file content for the private key associated with the ssl_cert.  This field is required if a vanity domain is provided.
    // String sslCertKey
    test('to test the property `sslCertKey`', () async {
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

    // a list of [Region ids](#operation/list-regions) for locations to be used for content delivery.
    // List<String> regions (default value: const [])
    test('to test the property `regions`', () async {
      // TODO
    });
  });
}
