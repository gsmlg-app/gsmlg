# openapi.model.UpdateNodepoolRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**nodeQuantity** | **int** | Number of instances in the NodePool. Minimum of 1 is required, but at least 3 is recommended. | [optional] 
**tag** | **String** | Tag for your node pool | [optional] 
**autoScaler** | **bool** | Option to use the auto scaler for your cluster. Default false. | [optional] 
**minNodes** | **int** | Auto scaler field for minimum nodes you want for your cluster. Default 1. | [optional] 
**maxNodes** | **int** | Auto scaler field for maximum nodes you want for your cluster. Default 1. | [optional] 
**labels** | [**Object**](.md) | Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool. Labels will be applied to both new and existing nodes. Existing labels are not removed when adding or updating, but can be managed in the separate labels endpoints. | [optional] 
**taints** | [**List<NodepoolTaintReq>**](NodepoolTaintReq.md) | Array of objects containing key, value, and effect. Existing taints are not removed when adding or updating, but can be managed in the separate taints endpoints. | [optional] [default to const []]
**userData** | **String** | The user-supplied, base64 encoded user data for all nodes in nodepool (only applied on nodes created after user data is set). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


