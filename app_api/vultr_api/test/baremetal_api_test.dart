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

/// tests for BaremetalApi
void main() {
  // final instance = BaremetalApi();

  group('tests for BaremetalApi', () {
    // Attach VPC 2.0 Network to Bare Metal Instance
    //
    // Attach a VPC 2.0 Network to a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC Network to Bare Metal Instance](#operation/attach-baremetals-vpcs) instead.
    //
    //Future attachBaremetalsVpc2(String baremetalId, { AttachBaremetalsVpc2Request attachBaremetalsVpc2Request }) async
    test('test attachBaremetalsVpc2', () async {
      // TODO
    });

    // Attach VPC Network to Bare Metal Instance
    //
    // Attach a VPC Network to a Bare Metal Instance.
    //
    //Future attachBaremetalsVpcs(String baremetalId, { AttachBaremetalsVpcsRequest attachBaremetalsVpcsRequest }) async
    test('test attachBaremetalsVpcs', () async {
      // TODO
    });

    // Create Bare Metal Instance
    //
    // Create a new Bare Metal instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.
    //
    //Future<CreateBaremetal202Response> createBaremetal({ CreateBaremetalRequest createBaremetalRequest }) async
    test('test createBaremetal', () async {
      // TODO
    });

    // Create Baremetal Reverse IPv4
    //
    // Create a reverse IPv4 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required.
    //
    //Future createBaremetalReverseIpv4(String baremetalId, { CreateBaremetalReverseIpv4Request createBaremetalReverseIpv4Request }) async
    test('test createBaremetalReverseIpv4', () async {
      // TODO
    });

    // Create Baremetal Reverse IPv6
    //
    // Create a reverse IPv6 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.
    //
    //Future createBaremetalReverseIpv6(String baremetalId, { CreateBaremetalReverseIpv6Request createBaremetalReverseIpv6Request }) async
    test('test createBaremetalReverseIpv6', () async {
      // TODO
    });

    // Delete Bare Metal
    //
    // Delete a Bare Metal instance.
    //
    //Future deleteBaremetal(String baremetalId) async
    test('test deleteBaremetal', () async {
      // TODO
    });

    // Delete BareMetal Reverse IPv6
    //
    // Delete the reverse IPv6 for a Bare metal instance.
    //
    //Future deleteBaremetalReverseIpv6(String baremetalId, String ipv6) async
    test('test deleteBaremetalReverseIpv6', () async {
      // TODO
    });

    // Detach VPC 2.0 Network from Bare Metal Instance
    //
    // Detach a VPC 2.0 Network from an Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC Network from Bare Metal Instance](#operation/detach-baremetal-vpcs) instead.
    //
    //Future detachBaremetalVpc2(String baremetalId, { DetachBaremetalVpc2Request detachBaremetalVpc2Request }) async
    test('test detachBaremetalVpc2', () async {
      // TODO
    });

    // Detach VPC Network from Bare Metal Instance
    //
    // Detach a VPC Network from an Bare Metal Instance.
    //
    //Future detachBaremetalVpcs(String baremetalId, { DetachBaremetalVpcsRequest detachBaremetalVpcsRequest }) async
    test('test detachBaremetalVpcs', () async {
      // TODO
    });

    // Bare Metal Bandwidth
    //
    // Get bandwidth information for the Bare Metal instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. Bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.
    //
    //Future<GetBandwidthBaremetal200Response> getBandwidthBaremetal(String baremetalId) async
    test('test getBandwidthBaremetal', () async {
      // TODO
    });

    // Get Bare Metal User Data
    //
    // Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for a Bare Metal.
    //
    //Future<GetBareMetalUserdata200Response> getBareMetalUserdata(String baremetalId) async
    test('test getBareMetalUserdata', () async {
      // TODO
    });

    // Get VNC URL for a Bare Metal
    //
    // Get the VNC URL for a Bare Metal
    //
    //Future<GetBareMetalVnc200Response> getBareMetalVnc(String baremetalId) async
    test('test getBareMetalVnc', () async {
      // TODO
    });

    // Get Available Bare Metal Upgrades
    //
    // Get available upgrades for a Bare Metal
    //
    //Future<GetBareMetalsUpgrades200Response> getBareMetalsUpgrades(String baremetalId, { String type }) async
    test('test getBareMetalsUpgrades', () async {
      // TODO
    });

    // Get Bare Metal
    //
    // Get information for a Bare Metal instance.
    //
    //Future<GetBaremetal200Response> getBaremetal(String baremetalId) async
    test('test getBaremetal', () async {
      // TODO
    });

    // Bare Metal IPv4 Addresses
    //
    // Get the IPv4 information for the Bare Metal instance.
    //
    //Future<GetIpv4Baremetal200Response> getIpv4Baremetal(String baremetalId) async
    test('test getIpv4Baremetal', () async {
      // TODO
    });

    // Bare Metal IPv6 Addresses
    //
    // Get the IPv6 information for the Bare Metal instance.
    //
    //Future<GetIpv6Baremetal200Response> getIpv6Baremetal(String baremetalId) async
    test('test getIpv6Baremetal', () async {
      // TODO
    });

    // Halt Bare Metal
    //
    // Halt the Bare Metal instance.
    //
    //Future haltBaremetal(String baremetalId) async
    test('test haltBaremetal', () async {
      // TODO
    });

    // Halt Bare Metals
    //
    // Halt Bare Metals.
    //
    //Future haltBaremetals({ HaltBaremetalsRequest haltBaremetalsRequest }) async
    test('test haltBaremetals', () async {
      // TODO
    });

    // List Bare Metal Instance VPC 2.0 Networks
    //
    // List the VPC 2.0 networks for a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Bare Metal Instance VPC Networks](#operation/list-baremetal-vpcs) instead.
    //
    //Future<ListBaremetalVpc2200Response> listBaremetalVpc2(String baremetalId) async
    test('test listBaremetalVpc2', () async {
      // TODO
    });

    // List Bare Metal Instance VPC Networks
    //
    // List the VPC networks for a Bare Metal Instance.
    //
    //Future<ListBaremetalVpcs200Response> listBaremetalVpcs(String baremetalId) async
    test('test listBaremetalVpcs', () async {
      // TODO
    });

    // List Bare Metal Instances
    //
    // List all Bare Metal instances in your account.
    //
    //Future<ListBaremetals200Response> listBaremetals({ int perPage, String cursor }) async
    test('test listBaremetals', () async {
      // TODO
    });

    // Set Default Reverse DNS Entry
    //
    // Set a reverse DNS entry for an IPv4 address
    //
    //Future postBaremetalInstanceIdIpv4ReverseDefault(String baremetalId, { PostBaremetalInstanceIdIpv4ReverseDefaultRequest postBaremetalInstanceIdIpv4ReverseDefaultRequest }) async
    test('test postBaremetalInstanceIdIpv4ReverseDefault', () async {
      // TODO
    });

    // Reboot Bare Metals
    //
    // Reboot Bare Metals.
    //
    //Future rebootBareMetals({ HaltBaremetalsRequest haltBaremetalsRequest }) async
    test('test rebootBareMetals', () async {
      // TODO
    });

    // Reboot Bare Metal
    //
    // Reboot the Bare Metal instance.
    //
    //Future rebootBaremetal(String baremetalId) async
    test('test rebootBaremetal', () async {
      // TODO
    });

    // Reinstall Bare Metal
    //
    // Reinstall the Bare Metal instance using an optional `hostname`.   **Note:** This action may take some time to complete.
    //
    //Future<UpdateBaremetal202Response> reinstallBaremetal(String baremetalId, { ReinstallBaremetalRequest reinstallBaremetalRequest }) async
    test('test reinstallBaremetal', () async {
      // TODO
    });

    // Start Bare Metals
    //
    // Start Bare Metals.
    //
    //Future startBareMetals({ HaltBaremetalsRequest haltBaremetalsRequest }) async
    test('test startBareMetals', () async {
      // TODO
    });

    // Start Bare Metal
    //
    // Start the Bare Metal instance.
    //
    //Future startBaremetal(String baremetalId) async
    test('test startBaremetal', () async {
      // TODO
    });

    // Update Bare Metal
    //
    // Update a Bare Metal instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.
    //
    //Future<UpdateBaremetal202Response> updateBaremetal(String baremetalId, { UpdateBaremetalRequest updateBaremetalRequest }) async
    test('test updateBaremetal', () async {
      // TODO
    });
  });
}
