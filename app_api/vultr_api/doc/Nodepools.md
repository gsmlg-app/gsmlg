# openapi.model.Nodepools

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | The [NodePool ID](#operation/get-nodepools). | [optional] 
**dateCreated** | **String** | Date of creation | [optional] 
**label** | **String** | Label for nodepool | [optional] 
**tag** | **String** | Tag for node pool | [optional] 
**plan** | **String** | Plan used for nodepool | [optional] 
**status** | **String** | Status for nodepool | [optional] 
**nodeQuantity** | **int** | Number of nodes in nodepool | [optional] 
**nodes** | [**List<NodepoolInstances>**](NodepoolInstances.md) |  | [optional] [default to const []]
**dateUpdated** | **String** | Date the nodepool was updated. | [optional] 
**autoScaler** | **bool** | Displays if the auto scaler is enabled or disabled for your cluster. | [optional] 
**minNodes** | **int** | Auto scaler field that displays the minimum nodes you want for your cluster. | [optional] 
**maxNodes** | [**Object**](.md) | Auto scaler field that displays the maximum nodes you want for your cluster. | [optional] 
**labels** | [**Object**](.md) | Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool. | [optional] 
**taints** | [**List<NodepoolTaintReq>**](NodepoolTaintReq.md) | Array of objects containing key, value, and effect. | [optional] [default to const []]
**userData** | **String** | The user-supplied, base64 encoded user data for all nodes in nodepool (only applied on nodes created after user data is set). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


