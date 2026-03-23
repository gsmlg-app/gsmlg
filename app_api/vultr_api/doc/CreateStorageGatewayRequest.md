# openapi.model.CreateStorageGatewayRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**label** | **String** | The user-supplied label for this Storage Gateway. | 
**type** | **String** | The gateway type | 
**region** | **String** | The [Region id](#operation/list-regions) for this Storage Gateway. | 
**exportConfig** | [**List<StorageGatewayExport>**](StorageGatewayExport.md) |  | [default to const []]
**networkConfig** | [**List<StorageGatewayNetwork>**](StorageGatewayNetwork.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


