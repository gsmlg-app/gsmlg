# openapi.model.CreateVpc2Request

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | Create the VPC in this [Region id](#operation/list-regions). | 
**description** | **String** | A description of the VPC. </br> Must be no longer than 255 characters and may include only letters, numbers, spaces, underscores and hyphens. | [optional] 
**ipType** | **String** | Accepted values: * `v4` | [optional] 
**ipBlock** | **String** | The VPC subnet IP address. For example: 10.99.0.0<br><span style=\"color: red\">If a prefix_length is specified then ip_block is a required field.</span> | [optional] 
**prefixLength** | **int** | The number of bits for the netmask in CIDR notation. Example: 24<br><span style=\"color: red\">If an ip_block is specified then prefix_length is a required field.</span> | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


