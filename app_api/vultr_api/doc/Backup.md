# openapi.model.Backup

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the backup. | [optional] 
**dateCreated** | **String** | The date the backup was created. | [optional] 
**description** | **String** | The user-supplied description of this backup. | [optional] 
**size** | **int** | The size of the backup in Bytes. | [optional] 
**status** | **String** | The Backup status.  * complete * pending | [optional] 
**osId** | **int** | The [Operating System id](#operation/list-os) for this Backup. | [optional] 
**appId** | **int** | The [Application id](#operation/list-applications) for this Backup. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


