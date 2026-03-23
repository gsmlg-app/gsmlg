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

// tests for UpdateBaremetalRequest
void main() {
  // final instance = UpdateBaremetalRequest();

  group('test UpdateBaremetalRequest', () {
    // The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance.
    // String userData
    test('to test the property `userData`', () async {
      // TODO
    });

    // The user-supplied label.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Use `tags` instead. The user-supplied tag.
    // String tag
    test('to test the property `tag`', () async {
      // TODO
    });

    // If supplied, reinstall the instance using this [Operating System id](#operation/list-os).
    // int osId
    test('to test the property `osId`', () async {
      // TODO
    });

    // If supplied, reinstall the instance using this [Application id](#operation/list-applications).
    // int appId
    test('to test the property `appId`', () async {
      // TODO
    });

    // If supplied, reinstall the instance using this [Application image_id](#operation/list-applications).
    // String imageId
    test('to test the property `imageId`', () async {
      // TODO
    });

    // Enable IPv6.  * true
    // bool enableIpv6
    test('to test the property `enableIpv6`', () async {
      // TODO
    });

    // An array of [VPC IDs](#operation/list-vpc2) to attach to this Bare Metal Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter.
    // List<String> attachVpc2 (default value: const [])
    test('to test the property `attachVpc2`', () async {
      // TODO
    });

    // An array of [VPC IDs](#operation/list-vpc2) to detach from this Bare Metal Instance. This parameter takes precedence over `enable_vpc2`.
    // List<String> detachVpc2 (default value: const [])
    test('to test the property `detachVpc2`', () async {
      // TODO
    });

    // If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a VPC 2.0 network.
    // bool enableVpc2
    test('to test the property `enableVpc2`', () async {
      // TODO
    });

    // Tags to apply to the instance.
    // List<String> tags (default value: const [])
    test('to test the property `tags`', () async {
      // TODO
    });

    // Linux-only: The user scheme used for logging into this instance. The instance must be reinstalled for this change to take effect.  * root * limited
    // String userScheme
    test('to test the property `userScheme`', () async {
      // TODO
    });

    // The RAID configuration used for the disks on this instance. The instance must be reinstalled for this change to take effect.  * raid1 * jbod * none (default)
    // String mdiskMode
    test('to test the property `mdiskMode`', () async {
      // TODO
    });

    // The URL location of the iPXE chainloader.
    // String ipxeChainUrl
    test('to test the property `ipxeChainUrl`', () async {
      // TODO
    });


  });

}
