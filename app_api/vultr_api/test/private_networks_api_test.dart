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


/// tests for PrivateNetworksApi
void main() {
  // final instance = PrivateNetworksApi();

  group('tests for PrivateNetworksApi', () {
    // Create a Private Network
    //
    // Create a new Private Network in a `region`.  **Deprecated**: Use [Create a VPC](#operation/create-vpc) instead.      Private networks should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 
    //
    //Future<GetNetwork200Response> createNetwork({ CreateNetworkRequest createNetworkRequest }) async
    test('test createNetwork', () async {
      // TODO
    });

    // Delete a private network
    //
    // Delete a Private Network.<br><br>**Deprecated**: Use [Delete a VPC](#operation/delete-vpc) instead.
    //
    //Future deleteNetwork(String networkId) async
    test('test deleteNetwork', () async {
      // TODO
    });

    // Get a private network
    //
    // Get information about a Private Network.<br><br>**Deprecated**: Use [Get a VPC](#operation/get-vpc) instead. 
    //
    //Future<GetNetwork200Response> getNetwork(String networkId) async
    test('test getNetwork', () async {
      // TODO
    });

    // List Private Networks
    //
    // Get a list of all Private Networks in your account.<br><br>**Deprecated**: Use [List VPCs](#operation/list-vpcs) instead.
    //
    //Future<ListNetworks200Response> listNetworks({ int perPage, String cursor }) async
    test('test listNetworks', () async {
      // TODO
    });

    // Update a Private Network
    //
    // Update information for a Private Network.<br><br>**Deprecated**: Use [Update a VPC](#operation/update-vpc) instead.
    //
    //Future updateNetwork(String networkId, { UpdateNetworkRequest updateNetworkRequest }) async
    test('test updateNetwork', () async {
      // TODO
    });

  });
}
