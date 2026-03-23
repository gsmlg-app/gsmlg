# openapi.model.ObjectStorage

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Object Storage. | [optional] 
**dateCreated** | **String** | Date the Object Store was created. | [optional] 
**clusterId** | **int** | The [Cluster id](#operation/list-object-storage-clusters). | [optional] 
**region** | **String** | The [Region id](#operation/list-regions) for this Object Storage. | [optional] 
**label** | **String** | The user-supplied label for this Object Storage. | [optional] 
**status** | **String** | The status of this Object Storage.  * active * pending | [optional] 
**s3Hostname** | **String** | The [Cluster hostname](#operation/list-object-storage-clusters) for this Object Storage. | [optional] 
**s3AccessKey** | **String** | The Object Storage access key. | [optional] 
**s3SecretKey** | **String** | The Object Storage secret key. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


