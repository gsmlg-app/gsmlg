# openapi.model.Log

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**resourceId** | **String** | The UUID for the resource that was interacted with.  Only set if the logged interaction relates to a specific resource with a UUID. | 
**resourceType** | **String** | The type of resource that was interacted with. | 
**logLevel** | **String** | The type of the configuration option. * `info` * `debug` * `warning` * `error` * `critical` | 
**message** | **String** | A message relating to the event that is being logged. | 
**timestamp** | **String** | the UTC timestamp of the time at which the log was generated. | 
**metadata** | [**LogMetadata**](LogMetadata.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


