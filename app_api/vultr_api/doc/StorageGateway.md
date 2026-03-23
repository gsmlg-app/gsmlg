# openapi.model.StorageGateway

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Storage Gateway. | [optional] 
**dateCreated** | **String** | Date the Storage Gateway was created. | [optional] 
**status** | **String** | The status of this Storage Gateway. * active * pending | [optional] 
**type** | **String** | The type of Storage Gateway. | [optional] 
**label** | **String** | The user-supplied label for this Storage Gateway. | [optional] 
**pendingCharges** | **double** | The current charges for this subscription. | [optional] 
**tags** | **List<String>** | Tags to apply to the instance. | [optional] [default to const []]
**health** | **String** | Quick reference variable to ensure your gateway is running. | [optional] 
**networkConfig** | [**StorageGatewayNetwork**](StorageGatewayNetwork.md) |  | [optional] 
**exportConfig** | [**StorageGatewayExport**](StorageGatewayExport.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


