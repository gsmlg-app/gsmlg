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

// tests for UpdateInstanceRequest
void main() {
  // final instance = UpdateInstanceRequest();

  group('test UpdateInstanceRequest', () {
    // Reinstall the instance with this [Application id](#operation/list-applications).
    // int appId
    test('to test the property `appId`', () async {
      // TODO
    });

    // Reinstall the instance with this [Application image_id](#operation/list-applications).
    // String imageId
    test('to test the property `imageId`', () async {
      // TODO
    });

    // Enable automatic backups for the instance.  * enabled * disabled
    // String backups
    test('to test the property `backups`', () async {
      // TODO
    });

    // The [Firewall Group id](#operation/list-firewall-groups) to attach to this Instance.
    // String firewallGroupId
    test('to test the property `firewallGroupId`', () async {
      // TODO
    });

    // Enable IPv6.  * true
    // bool enableIpv6
    test('to test the property `enableIpv6`', () async {
      // TODO
    });

    // Reinstall the instance with this [ISO id](#operation/list-isos).
    // String osId
    test('to test the property `osId`', () async {
      // TODO
    });

    // The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance.
    // String userData
    test('to test the property `userData`', () async {
      // TODO
    });

    // Use `tags` instead. The user-supplied tag.
    // String tag
    test('to test the property `tag`', () async {
      // TODO
    });

    // Upgrade the instance with this [Plan id](#operation/list-plans).
    // String plan
    test('to test the property `plan`', () async {
      // TODO
    });

    // Enable DDoS Protection (there is an additional charge for this).  * true * false
    // bool ddosProtection
    test('to test the property `ddosProtection`', () async {
      // TODO
    });

    // Use `attach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to attach to this Instance. This parameter takes precedence over `enable_private_network`. Please choose one parameter.
    // List<String> attachPrivateNetwork (default value: const [])
    test('to test the property `attachPrivateNetwork`', () async {
      // TODO
    });

    // An array of [VPC IDs](#operation/list-vpcs) to attach to this Instance. This parameter takes precedence over `enable_vpc`. Please choose one parameter.
    // List<String> attachVpc (default value: const [])
    test('to test the property `attachVpc`', () async {
      // TODO
    });

    // Use `attach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to attach to this Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter.
    // List<String> attachVpc2 (default value: const [])
    test('to test the property `attachVpc2`', () async {
      // TODO
    });

    // Use `detach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to detach from this Instance. This parameter takes precedence over `enable_private_network`.
    // List<String> detachPrivateNetwork (default value: const [])
    test('to test the property `detachPrivateNetwork`', () async {
      // TODO
    });

    // An array of [VPC IDs](#operation/list-vpcs) to detach from this Instance. This parameter takes precedence over `enable_vpc`.
    // List<String> detachVpc (default value: const [])
    test('to test the property `detachVpc`', () async {
      // TODO
    });

    // Use `detach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to detach from this Instance. This parameter takes precedence over `enable_vpc2`.
    // List<String> detachVpc2 (default value: const [])
    test('to test the property `detachVpc2`', () async {
      // TODO
    });

    // Use `enable_vpc` instead.  If `true`, private networking support will be added to the new server.  This parameter attaches a single network. When no network exists in the region, it will be automatically created.  If there are multiple private networks in the instance's region, use `attach_private_network` instead to specify a network.
    // bool enablePrivateNetwork
    test('to test the property `enablePrivateNetwork`', () async {
      // TODO
    });

    // If `true`, VPC support will be added to the new server.  This parameter attaches a single VPC. When no VPC exists in the region, it will be automatically created.  If there are multiple VPCs in the instance's region, use `attach_vpc` instead to specify a VPC.
    // bool enableVpc
    test('to test the property `enableVpc`', () async {
      // TODO
    });

    // Use `enable_vpc` instead.  If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a VPC 2.0 network.
    // bool enableVpc2
    test('to test the property `enableVpc2`', () async {
      // TODO
    });

    // The user supplied label.
    // String label
    test('to test the property `label`', () async {
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


  });

}
