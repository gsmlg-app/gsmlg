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

// tests for CreateInstanceRequest
void main() {
  // final instance = CreateInstanceRequest();

  group('test CreateInstanceRequest', () {
    // The [Region id](#operation/list-regions) where the Instance is located.
    // String region
    test('to test the property `region`', () async {
      // TODO
    });

    // The [Plan id](#operation/list-plans) to use when deploying this instance.
    // String plan
    test('to test the property `plan`', () async {
      // TODO
    });

    // The [Operating System id](#operation/list-os) to use when deploying this instance.
    // int osId
    test('to test the property `osId`', () async {
      // TODO
    });

    // The URL location of the iPXE chainloader.
    // String ipxeChainUrl
    test('to test the property `ipxeChainUrl`', () async {
      // TODO
    });

    // The [ISO id](#operation/list-isos) to use when deploying this instance.
    // String isoId
    test('to test the property `isoId`', () async {
      // TODO
    });

    // The [Startup Script id](#operation/list-startup-scripts) to use when deploying this instance.
    // String scriptId
    test('to test the property `scriptId`', () async {
      // TODO
    });

    // The [Snapshot id](#operation/list-snapshots) to use when deploying the instance.
    // String snapshotId
    test('to test the property `snapshotId`', () async {
      // TODO
    });

    // Enable IPv6.  * true
    // bool enableIpv6
    test('to test the property `enableIpv6`', () async {
      // TODO
    });

    // Don't set up a public IPv4 address when IPv6 is enabled. Will not do anything unless `enable_ipv6` is also `true`.  * true
    // bool disablePublicIpv4
    test('to test the property `disablePublicIpv4`', () async {
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

    // A user-supplied label for this instance.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // The [SSH Key id](#operation/list-ssh-keys) to install on this instance.
    // List<String> sshkeyId (default value: const [])
    test('to test the property `sshkeyId`', () async {
      // TODO
    });

    // Enable automatic backups for the instance (does not work for VX1 block storage).  * enabled * disabled
    // String backups
    test('to test the property `backups`', () async {
      // TODO
    });

    // Available for VX1 instances: Define your block devices, create bootable block devices, use local storage (if plan has local storage) as scratch disk. Local Only: ``` \"block_devices\": [   {     \"block_id\": \"local\",     \"bootable\": true   } ] ``` Local Boot + New Block: ``` \"block_devices\": [   {     \"block_id\": \"local\",     \"bootable\": true   },   {     \"disk_size\": 50,     \"label\": \"New Block Label\"   } ] ``` Bootable Block (new): ``` \"block_devices\": [   {     \"disk_size\": 50,     \"label\": \"New Bootable Block\",     \"bootable\": true   } ] ``` Bootable Block (existing): ``` \"block_devices\": [   {     \"block_id\": \"BLOCK_DEVICE_UUID\",     \"bootable\": true   } ] ``` Bootable Block (existing) and Local NVMe: ``` \"block_devices\": [   {     \"block_id\": \"local\"   },   {     \"block_id\": \"BLOCK_DEVICE_UUID\",     \"bootable\": true   } ] ```
    // List<Object> blockDevices (default value: const [])
    test('to test the property `blockDevices`', () async {
      // TODO
    });

    // The [Application id](#operation/list-applications) to use when deploying this instance.
    // int appId
    test('to test the property `appId`', () async {
      // TODO
    });

    // The [Application image_id](#operation/list-applications) to use when deploying this instance.
    // String imageId
    test('to test the property `imageId`', () async {
      // TODO
    });

    // The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance.
    // String userData
    test('to test the property `userData`', () async {
      // TODO
    });

    // Enable DDoS protection (there is an additional charge for this).  * true * false
    // bool ddosProtection
    test('to test the property `ddosProtection`', () async {
      // TODO
    });

    // Notify by email after deployment.  * true * false (default)
    // bool activationEmail
    test('to test the property `activationEmail`', () async {
      // TODO
    });

    // The hostname to use when deploying this instance.
    // String hostname
    test('to test the property `hostname`', () async {
      // TODO
    });

    // Use `tags` instead. The user-supplied tag.
    // String tag
    test('to test the property `tag`', () async {
      // TODO
    });

    // The [Firewall Group id](#operation/list-firewall-groups) to attach to this Instance.
    // String firewallGroupId
    test('to test the property `firewallGroupId`', () async {
      // TODO
    });

    // ID of the floating IP to use as the main IP of this server.
    // String reservedIpv4
    test('to test the property `reservedIpv4`', () async {
      // TODO
    });

    // Use `enable_vpc` instead.  If `true`, private networking support will be added to the new server.  This parameter attaches a single network. When no network exists in the region, it will be automatically created.  If there are multiple private networks in the instance's region, use `attach_private_network` instead to specify a network.
    // bool enablePrivateNetwork
    test('to test the property `enablePrivateNetwork`', () async {
      // TODO
    });

    // If `true`, VPC support will be added to the new server.  This parameter attaches a single VPC. When no VPC exists in the region, it will be automatically created.  If there are multiple VPCs in the instance's region, use `attach_vpc` instead to specify a network.
    // bool enableVpc
    test('to test the property `enableVpc`', () async {
      // TODO
    });

    // Use `enable_vpc` instead.  If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a network.
    // bool enableVpc2
    test('to test the property `enableVpc2`', () async {
      // TODO
    });

    // if `true`, this VPS will not receive a public IP or public NIC.  A `vpc_id` will be required in the `attach_vpc` array. The first `vpc_id` provided must have a NAT Gateway attached.  This VPS will gain access to the internet via the NAT Gateway attached to the VPC.
    // bool vpcOnly
    test('to test the property `vpcOnly`', () async {
      // TODO
    });

    // Tags to apply to the instance
    // List<String> tags (default value: const [])
    test('to test the property `tags`', () async {
      // TODO
    });

    // Linux-only: The user scheme used for logging into this instance. By default, the \"root\" user is configured. Alternatively, a limited user with sudo permissions can be selected.  * root * limited
    // String userScheme
    test('to test the property `userScheme`', () async {
      // TODO
    });

    // The [app variable inputs](#operation/list-marketplace-app-variables) for configuring the marketplace app (name/value pairs).
    // Object appVariables
    test('to test the property `appVariables`', () async {
      // TODO
    });
  });
}
