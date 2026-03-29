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

// tests for CreatePullzoneRequest
void main() {
  // final instance = CreatePullzoneRequest();

  group('test CreatePullzoneRequest', () {
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

    // An optional domain name that can be used to access the cached files in adition to the domain that is automaticaly created.  This vanity domain will need to have a CNAME DNS record created to point it at the standard CDN domain that is automaticaly generated on creation of the CDN.
    // String vanityDomain
    test('to test the property `vanityDomain`', () async {
      // TODO
    });

    // Base 64 encoded file content for an ssl/tls certificate associated with the optional vanity_domain.  This field is required if a vanity domain is provided and the origin_scheme is https.
    // String sslCert
    test('to test the property `sslCert`', () async {
      // TODO
    });

    // Base 64 encoded file content for the private key associated with the ssl_cert.  This field is required if a vanity domain is provided and the origin_scheme is https.
    // String sslCertKey
    test('to test the property `sslCertKey`', () async {
      // TODO
    });

    // Enable Cross-origin resource sharing.  CORS is a content validation mechanism used by web browsers to validate file access permissions. The Vultr CDN CORS policy protects your static assets from hotlinking threats by only accepting requests associated with your Origin URL.
    // bool cors
    test('to test the property `cors`', () async {
      // TODO
    });

    // Enable Gzip compression to reduce the static content size to speed up the delivery process.
    // bool gzip
    test('to test the property `gzip`', () async {
      // TODO
    });

    // Block AI bots.
    // bool blockAi
    test('to test the property `blockAi`', () async {
      // TODO
    });

    // Block potentially malicious bots.
    // bool blockBadBots
    test('to test the property `blockBadBots`', () async {
      // TODO
    });
  });
}
