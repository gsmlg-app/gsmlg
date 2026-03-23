# openapi.model.ReservedIp

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Reserved IP. | [optional] 
**region** | **String** | The [Region id](#operation/list-regions) where the Reserved IP is located. | [optional] 
**ipType** | **String** | The type of IP address.  * v4 * v6 | [optional] 
**subnet** | **String** | The IP subnet. | [optional] 
**subnetSize** | **int** | The IP network size in bits. | [optional] 
**label** | **String** | The user-supplied label. | [optional] 
**instanceId** | **String** | The [Instance id](#operation/list-instances) attached to this Reserved IP. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


