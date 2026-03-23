# openapi.model.CreateKubernetesClusterRequestNodePoolsInner

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**nodeQuantity** | **int** | Number of instances to deploy in this nodepool. Minimum of 1 node required, but at least 3 is recommended. | 
**label** | **String** | Label for this nodepool. You cannot change the label after a nodepool is created. You cannot have duplicate node pool labels in the same cluster. | 
**plan** | **String** | Plan you want this nodepool to use. Note: minimum plan must be $10 | 
**tag** | **String** | Tag for node pool | [optional] 
**autoScaler** | **bool** | Option to use the auto scaler with your cluster. Default false. | [optional] 
**minNodes** | **int** | Auto scaler field for minimum nodes you want for your cluster. Default 1. | [optional] 
**maxNodes** | **int** | Auto scaler field for maximum nodes you want for your cluster. Default 1. | [optional] 
**userData** | **String** | The user-supplied, base64 encoded user data for all nodes in nodepool (only applied on nodes created after user data is set). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


