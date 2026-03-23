# openapi.model.CreateNodepoolsRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**nodeQuantity** | **int** | Number of instances in this nodepool | 
**label** | **String** | Label for the nodepool. You cannot change the label after a nodepool is created. You cannot have duplicate node pool labels in the same cluster. | 
**plan** | **String** | Plan that this nodepool will use | 
**tag** | **String** | Tag for node pool | [optional] 
**autoScaler** | **bool** | Option to use the auto scaler with your cluster. Default false. | [optional] 
**minNodes** | **int** | Auto scaler field for minimum nodes you want for your cluster. Default 1. | [optional] 
**maxNodes** | **int** | Auto scaler field for maximum nodes you want for your cluster. Default 1. | [optional] 
**labels** | [**Object**](.md) | Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool. Labels will be applied to both new and existing nodes. | [optional] 
**taints** | [**List<NodepoolTaintReq>**](NodepoolTaintReq.md) | Array of objects containing key, value, and effect. | [optional] [default to const []]
**userData** | **String** | The user-supplied, base64 encoded user data for all nodes in nodepool (only applied on nodes created after user data is set). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


