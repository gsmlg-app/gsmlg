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

/// tests for InstancesApi
void main() {
  // final instance = InstancesApi();

  group('tests for InstancesApi', () {
    // Attach ISO to Instance
    //
    // Attach an ISO to an Instance.
    //
    //Future<AttachInstanceIso202Response> attachInstanceIso(String instanceId, { AttachInstanceIsoRequest attachInstanceIsoRequest }) async
    test('test attachInstanceIso', () async {
      // TODO
    });

    // Attach Private Network to Instance
    //
    // Attach Private Network to an Instance.<br><br>**Deprecated**: use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.
    //
    //Future attachInstanceNetwork(String instanceId, { AttachInstanceNetworkRequest attachInstanceNetworkRequest }) async
    test('test attachInstanceNetwork', () async {
      // TODO
    });

    // Attach VPC to Instance
    //
    // Attach a VPC to an Instance.
    //
    //Future attachInstanceVpc(String instanceId, { AttachInstanceVpcRequest attachInstanceVpcRequest }) async
    test('test attachInstanceVpc', () async {
      // TODO
    });

    // Attach VPC 2.0 Network to Instance
    //
    // Attach a VPC 2.0 Network to an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.
    //
    //Future attachInstanceVpc2(String instanceId, { AttachInstanceVpc2Request attachInstanceVpc2Request }) async
    test('test attachInstanceVpc2', () async {
      // TODO
    });

    // Create Instance
    //
    // Create a new VPS Instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `iso_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.
    //
    //Future<CreateInstance202Response> createInstance({ CreateInstanceRequest createInstanceRequest }) async
    test('test createInstance', () async {
      // TODO
    });

    // Set Instance Backup Schedule
    //
    // Set the backup schedule for an Instance in UTC. The `type` is required.
    //
    //Future createInstanceBackupSchedule(String instanceId, { CreateInstanceBackupScheduleRequest createInstanceBackupScheduleRequest }) async
    test('test createInstanceBackupSchedule', () async {
      // TODO
    });

    // Create IPv4
    //
    // Create an IPv4 address for an Instance.
    //
    //Future<Object> createInstanceIpv4(String instanceId, { CreateInstanceIpv4Request createInstanceIpv4Request }) async
    test('test createInstanceIpv4', () async {
      // TODO
    });

    // Create Instance Reverse IPv4
    //
    // Create a reverse IPv4 entry for an Instance. The `ip` and `reverse` attributes are required.
    //
    //Future createInstanceReverseIpv4(String instanceId, { CreateBaremetalReverseIpv4Request createBaremetalReverseIpv4Request }) async
    test('test createInstanceReverseIpv4', () async {
      // TODO
    });

    // Create Instance Reverse IPv6
    //
    // Create a reverse IPv6 entry for an Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.
    //
    //Future createInstanceReverseIpv6(String instanceId, { CreateBaremetalReverseIpv6Request createBaremetalReverseIpv6Request }) async
    test('test createInstanceReverseIpv6', () async {
      // TODO
    });

    // Delete Instance
    //
    // Delete an Instance.
    //
    //Future deleteInstance(String instanceId) async
    test('test deleteInstance', () async {
      // TODO
    });

    // Delete IPv4 Address
    //
    // Delete an IPv4 address from an Instance.
    //
    //Future deleteInstanceIpv4(String instanceId, String ipv4) async
    test('test deleteInstanceIpv4', () async {
      // TODO
    });

    // Delete Instance Reverse IPv6
    //
    // Delete the reverse IPv6 for an Instance.
    //
    //Future deleteInstanceReverseIpv6(String instanceId, String ipv6) async
    test('test deleteInstanceReverseIpv6', () async {
      // TODO
    });

    // Detach ISO from instance
    //
    // Detach the ISO from an Instance.
    //
    //Future<DetachInstanceIso202Response> detachInstanceIso(String instanceId) async
    test('test detachInstanceIso', () async {
      // TODO
    });

    // Detach Private Network from Instance.
    //
    // Detach Private Network from an Instance.<br><br>**Deprecated**: use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.
    //
    //Future detachInstanceNetwork(String instanceId, { DetachInstanceNetworkRequest detachInstanceNetworkRequest }) async
    test('test detachInstanceNetwork', () async {
      // TODO
    });

    // Detach VPC from Instance
    //
    // Detach a VPC from an Instance.
    //
    //Future detachInstanceVpc(String instanceId, { DetachInstanceVpcRequest detachInstanceVpcRequest }) async
    test('test detachInstanceVpc', () async {
      // TODO
    });

    // Detach VPC 2.0 Network from Instance
    //
    // Detach a VPC 2.0 Network from an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.
    //
    //Future detachInstanceVpc2(String instanceId, { DetachInstanceVpc2Request detachInstanceVpc2Request }) async
    test('test detachInstanceVpc2', () async {
      // TODO
    });

    // Get Instance
    //
    // Get information about an Instance.
    //
    //Future<GetInstance200Response> getInstance(String instanceId) async
    test('test getInstance', () async {
      // TODO
    });

    // Get Instance Backup Schedule
    //
    // Get the backup schedule for an Instance.
    //
    //Future<GetInstanceBackupSchedule200Response> getInstanceBackupSchedule(String instanceId) async
    test('test getInstanceBackupSchedule', () async {
      // TODO
    });

    // Instance Bandwidth
    //
    // Get bandwidth information about an Instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. The bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.
    //
    //Future<GetBandwidthBaremetal200Response> getInstanceBandwidth(String instanceId, { int dateRange }) async
    test('test getInstanceBandwidth', () async {
      // TODO
    });

    // List Instance IPv4 Information
    //
    // List the IPv4 information for an Instance.
    //
    //Future<GetIpv4Baremetal200Response> getInstanceIpv4(String instanceId, { bool publicNetwork, int perPage, String cursor }) async
    test('test getInstanceIpv4', () async {
      // TODO
    });

    // Get Instance IPv6 Information
    //
    // Get the IPv6 information for an VPS Instance.
    //
    //Future<GetIpv6Baremetal200Response> getInstanceIpv6(String instanceId) async
    test('test getInstanceIpv6', () async {
      // TODO
    });

    // Get Instance ISO Status
    //
    // Get the ISO status for an Instance.
    //
    //Future<GetInstanceIsoStatus200Response> getInstanceIsoStatus(String instanceId) async
    test('test getInstanceIsoStatus', () async {
      // TODO
    });

    // Get Instance Job
    //
    // Get available information for an Instance job
    //
    //Future<GetInstanceJob200Response> getInstanceJob(String jobId) async
    test('test getInstanceJob', () async {
      // TODO
    });

    // Get Instance neighbors
    //
    // Get a list of other instances in the same location as this Instance.
    //
    //Future<GetInstanceNeighbors200Response> getInstanceNeighbors(String instanceId) async
    test('test getInstanceNeighbors', () async {
      // TODO
    });

    // Get Available Instance Upgrades
    //
    // Get available upgrades for an Instance
    //
    //Future<GetInstanceUpgrades200Response> getInstanceUpgrades(String instanceId, { String type }) async
    test('test getInstanceUpgrades', () async {
      // TODO
    });

    // Get Instance User Data
    //
    // Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for an Instance.
    //
    //Future<GetInstanceUserdata200Response> getInstanceUserdata(String instanceId) async
    test('test getInstanceUserdata', () async {
      // TODO
    });

    // Halt Instance
    //
    // Halt an Instance.
    //
    //Future haltInstance(String instanceId) async
    test('test haltInstance', () async {
      // TODO
    });

    // Halt Instances
    //
    // Halt Instances.
    //
    //Future haltInstances({ HaltInstancesRequest haltInstancesRequest }) async
    test('test haltInstances', () async {
      // TODO
    });

    // List Instance IPv6 Reverse
    //
    // List the reverse IPv6 information for an Instance.
    //
    //Future<ListInstanceIpv6Reverse200Response> listInstanceIpv6Reverse(String instanceId) async
    test('test listInstanceIpv6Reverse', () async {
      // TODO
    });

    // List instance Private Networks
    //
    // **Deprecated**: use [List Instance VPCs](#operation/list-instance-vpcs) instead.<br><br>List the private networks for an Instance.
    //
    //Future<ListInstancePrivateNetworks200Response> listInstancePrivateNetworks(String instanceId, { int perPage, String cursor }) async
    test('test listInstancePrivateNetworks', () async {
      // TODO
    });

    // List Instance VPC 2.0 Networks
    //
    // List the VPC 2.0 networks for an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Instance VPCs](#operation/list-instance-vpcs) instead.
    //
    //Future<ListInstanceVpc2200Response> listInstanceVpc2(String instanceId, { int perPage, String cursor }) async
    test('test listInstanceVpc2', () async {
      // TODO
    });

    // List instance VPCs
    //
    // List the VPCs for an Instance.
    //
    //Future<ListInstanceVpcs200Response> listInstanceVpcs(String instanceId, { int perPage, String cursor }) async
    test('test listInstanceVpcs', () async {
      // TODO
    });

    // List Instances
    //
    // List all VPS instances in your account.
    //
    //Future<ListInstances200Response> listInstances({ int perPage, String cursor, String tag, String label, String mainIp, String region, String firewallGroupId, String hostname, bool showPendingCharges }) async
    test('test listInstances', () async {
      // TODO
    });

    // Set Default Reverse DNS Entry
    //
    // Set a reverse DNS entry for an IPv4 address
    //
    //Future postInstancesInstanceIdIpv4ReverseDefault(String instanceId, { PostBaremetalInstanceIdIpv4ReverseDefaultRequest postBaremetalInstanceIdIpv4ReverseDefaultRequest }) async
    test('test postInstancesInstanceIdIpv4ReverseDefault', () async {
      // TODO
    });

    // Reboot Instance
    //
    // Reboot an Instance.
    //
    //Future rebootInstance(String instanceId) async
    test('test rebootInstance', () async {
      // TODO
    });

    // Reboot instances
    //
    // Reboot Instances.
    //
    //Future rebootInstances({ RebootInstancesRequest rebootInstancesRequest }) async
    test('test rebootInstances', () async {
      // TODO
    });

    // Reinstall Instance
    //
    // Reinstall an Instance using an optional `hostname`.  **Note:** This action may take a few extra seconds to complete.
    //
    //Future<CreateInstance202Response> reinstallInstance(String instanceId, { ReinstallInstanceRequest reinstallInstanceRequest }) async
    test('test reinstallInstance', () async {
      // TODO
    });

    // Restore Instance
    //
    // Restore an Instance from either `backup_id` or `snapshot_id`.
    //
    //Future<RestoreInstance202Response> restoreInstance(String instanceId, { RestoreInstanceRequest restoreInstanceRequest }) async
    test('test restoreInstance', () async {
      // TODO
    });

    // Start instance
    //
    // Start an Instance.
    //
    //Future startInstance(String instanceId) async
    test('test startInstance', () async {
      // TODO
    });

    // Start instances
    //
    // Start Instances.
    //
    //Future startInstances({ StartInstancesRequest startInstancesRequest }) async
    test('test startInstances', () async {
      // TODO
    });

    // Update Instance
    //
    // Update information for an Instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.
    //
    //Future<CreateInstance202Response> updateInstance(String instanceId, { UpdateInstanceRequest updateInstanceRequest }) async
    test('test updateInstance', () async {
      // TODO
    });
  });
}
