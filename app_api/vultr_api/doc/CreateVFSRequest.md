# openapi.model.CreateVFSRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | Region identifier where to create the VFS | 
**label** | **String** | User-defined label for the VFS subscription | 
**storageSize** | [**CreateVFSRequestStorageSize**](CreateVFSRequestStorageSize.md) |  | 
**diskType** | **String** | Type of storage disk (defaults to nvme if not specified) | [optional] 
**tags** | **List<String>** | Optional tags to apply to the VFS subscription | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


