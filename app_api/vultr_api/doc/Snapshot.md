# openapi.model.Snapshot

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Snapshot. | [optional] 
**dateCreated** | **String** | The date this snapshot was created. | [optional] 
**description** | **String** | The user-supplied description of the Snapshot. | [optional] 
**size** | **int** | The snapshot size in bytes. | [optional] 
**status** | **String** | The Snapshot status.  * pending * complete * deleted | [optional] 
**osId** | **int** | The [Operating System id](#operation/list-os) for this Snapshot. | [optional] 
**appId** | **int** | The [Application id](#operation/list-applications) for this snapshot. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


