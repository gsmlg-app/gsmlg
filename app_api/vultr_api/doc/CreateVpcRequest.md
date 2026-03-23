# openapi.model.CreateVpcRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | Create the VPC in this [Region id](#operation/list-regions). | 
**description** | **String** | A description of the VPC. | [optional] 
**v4Subnet** | **String** | The IPv4 VPC address. For example: 10.99.0.0<br><span style=\"color: red\">If v4_subnet_mask is specified then v4_subnet is a required field.</span> | [optional] 
**v4SubnetMask** | **int** | The number of bits for the netmask in CIDR notation. Example: 24<br><span style=\"color: red\">If v4_subnet is specified then v4_subnet_mask is a required field.</span> | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


