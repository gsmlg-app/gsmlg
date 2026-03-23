# openapi.model.CreateBlockRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | The [Region id](#operation/list-regions) where the Block Storage will be created. | 
**sizeGb** | **int** | Size in GB may range between 10 and 40000, depending on the `block_type`. | 
**label** | **String** | The user-supplied label. | [optional] 
**blockType** | **String** | An optional parameter, that determines on the type of block storage volume that will be created. Soon to become a required parameter.  * `high_perf` from 10GB to 10,000GB * `storage_opt` from 40GB to 40,000GB | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


