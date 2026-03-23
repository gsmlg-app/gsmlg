# openapi.model.CreateObjectStorageRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clusterId** | **int** | The [Cluster id](#operation/list-object-storage-clusters) where the Object Storage will be created. | 
**tierId** | **int** | The [Tier id](#operation/list-object-storage-tiers) of the tier to set up for. Must be one of available tiers for the cluster. | 
**label** | **String** | The user-supplied label for this Object Storage. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


