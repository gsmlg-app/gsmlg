# openapi.model.CreateKubernetesClusterRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**label** | **String** | The label for your Kubernetes cluster. | [optional] 
**region** | **String** | Region you want to deploy VKE in. See [Regions](#tag/region) for more information. | 
**version** | **String** | Version of Kubernetes you want to deploy. | 
**vpcId** | **String** | The [VPC id](#operation/list-vpcs) to use when deploying this VKE. Omitting or leaving this empty will configure a new VPC network with this deployment. | [optional] 
**haControlplanes** | **bool** | Whether a highly available control planes configuration should be deployed * true * false (default) | [optional] 
**enableFirewall** | **bool** | Whether a [Firewall Group](#tag/firewall) should be deployed and managed by this cluster * true * false (default) | [optional] 
**oidc** | [**CreateKubernetesClusterRequestOidc**](CreateKubernetesClusterRequestOidc.md) |  | [optional] 
**nodePools** | [**List<CreateKubernetesClusterRequestNodePoolsInner>**](CreateKubernetesClusterRequestNodePoolsInner.md) |  | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


