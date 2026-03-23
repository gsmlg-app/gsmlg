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

// tests for CreateKubernetesClusterRequest
void main() {
  // final instance = CreateKubernetesClusterRequest();

  group('test CreateKubernetesClusterRequest', () {
    // The label for your Kubernetes cluster.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Region you want to deploy VKE in. See [Regions](#tag/region) for more information.
    // String region
    test('to test the property `region`', () async {
      // TODO
    });

    // Version of Kubernetes you want to deploy.
    // String version
    test('to test the property `version`', () async {
      // TODO
    });

    // The [VPC id](#operation/list-vpcs) to use when deploying this VKE. Omitting or leaving this empty will configure a new VPC network with this deployment.
    // String vpcId
    test('to test the property `vpcId`', () async {
      // TODO
    });

    // Whether a highly available control planes configuration should be deployed * true * false (default)
    // bool haControlplanes
    test('to test the property `haControlplanes`', () async {
      // TODO
    });

    // Whether a [Firewall Group](#tag/firewall) should be deployed and managed by this cluster * true * false (default)
    // bool enableFirewall
    test('to test the property `enableFirewall`', () async {
      // TODO
    });

    // CreateKubernetesClusterRequestOidc oidc
    test('to test the property `oidc`', () async {
      // TODO
    });

    // List<CreateKubernetesClusterRequestNodePoolsInner> nodePools (default value: const [])
    test('to test the property `nodePools`', () async {
      // TODO
    });


  });

}
