# openapi.model.Network

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Private Network. | 
**region** | **String** | The [Region id](#operation/list-regions) where the network is located. | [optional] 
**dateCreated** | **String** | Date the network was created. | [optional] 
**description** | **String** | A description of the private network. | [optional] 
**v4Subnet** | **String** | The IPv4 network address. For example: 10.99.0.0 | [optional] 
**v4SubnetMask** | **int** | The number of bits for the netmask in CIDR notation. Example: 24 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


