# openapi.model.Vpc2

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the VPC. | 
**region** | **String** | The [Region id](#operation/list-regions) where the VPC is located. | [optional] 
**dateCreated** | **String** | Date the VPC was created. | [optional] 
**description** | **String** | A description of the VPC. | [optional] 
**ipBlock** | **String** | The VPC subnet IP address. For example: 10.99.0.0 | [optional] 
**prefixLength** | **int** | The number of bits for the netmask in CIDR notation. Example: 24 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


