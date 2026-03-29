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

/// tests for VPC2Api
void main() {
  // final instance = VPC2Api();

  group('tests for VPC2Api', () {
    // Attach nodes to a VPC 2.0 network
    //
    // Attach nodes to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
    //
    //Future attachVpc2Nodes(String vpcId, { AttachVpc2NodesRequest attachVpc2NodesRequest }) async
    test('test attachVpc2Nodes', () async {
      // TODO
    });

    // Create a VPC 2.0 network
    //
    // Create a new VPC 2.0 network in a `region`.  **Deprecated**: Migrate to VPC Networks and use [Create a VPC](#operation/create-vpc) instead.  VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
    //
    //Future<GetVpc2200Response> createVpc2({ CreateVpc2Request createVpc2Request }) async
    test('test createVpc2', () async {
      // TODO
    });

    // Delete a VPC 2.0 network
    //
    // Delete a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Delete a VPC](#operation/delete-vpc) instead.
    //
    //Future deleteVpc2(String vpcId) async
    test('test deleteVpc2', () async {
      // TODO
    });

    // Remove nodes from a VPC 2.0 network
    //
    // Remove nodes from a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
    //
    //Future detachVpc2Nodes(String vpcId, { DetachVpc2NodesRequest detachVpc2NodesRequest }) async
    test('test detachVpc2Nodes', () async {
      // TODO
    });

    // Get a VPC 2.0 network
    //
    // Get information about a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Get a VPC](#operation/get-vpc) instead.
    //
    //Future<GetVpc2200Response> getVpc2(String vpcId) async
    test('test getVpc2', () async {
      // TODO
    });

    // List VPC 2.0 networks
    //
    // Get a list of all VPC 2.0 networks in your account.<br><br>**Deprecated**: Migrate to VPC Networks and use [List VPCs](#operation/list-vpcs) instead.
    //
    //Future<ListVpc2200Response> listVpc2({ int perPage, String cursor }) async
    test('test listVpc2', () async {
      // TODO
    });

    // Get a list of nodes attached to a VPC 2.0 network
    //
    // Get a list of nodes attached to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
    //
    //Future<ListVpc2Nodes200Response> listVpc2Nodes(String vpcId, { int perPage, String cursor }) async
    test('test listVpc2Nodes', () async {
      // TODO
    });

    // Update a VPC 2.0 network
    //
    // Update information for a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Update a VPC](#operation/update-vpc) instead.
    //
    //Future updateVpc2(String vpcId, { UpdateVpc2Request updateVpc2Request }) async
    test('test updateVpc2', () async {
      // TODO
    });
  });
}
