# openapi.model.Vfs

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Unique identifier for the VFS subscription | [optional] 
**region** | **String** | Region identifier where the VFS is located | [optional] 
**dateCreated** | [**DateTime**](DateTime.md) | Creation timestamp of the VFS subscription | [optional] 
**status** | **String** | Current status of the VFS subscription | [optional] 
**label** | **String** | User-defined label for the VFS subscription | [optional] 
**tags** | **List<String>** | List of tags associated with the VFS subscription | [optional] [default to const []]
**diskType** | **String** | Type of storage disk | [optional] 
**storageSize** | [**VfsStorageSize**](VfsStorageSize.md) |  | [optional] 
**storageUsed** | [**VfsStorageSize**](VfsStorageSize.md) |  | [optional] 
**billing** | [**VfsBilling**](VfsBilling.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


