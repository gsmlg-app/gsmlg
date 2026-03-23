# openapi.model.FirewallRule

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** | A unique ID for the Firewall Rule. | [optional] 
**type** | **String** | This field is deprecated. Use `ip_type` instead.  The type of IP rule.  * v4 * v6 | [optional] 
**ipType** | **String** | The type of IP rule.  * v4 * v6 | [optional] 
**action** | **String** | Action to take when this rule is met.  * accept | [optional] 
**protocol** | **String** | The protocol for this rule.  * ICMP * TCP * UDP * GRE  | [optional] 
**port** | **String** | Port or port range for this rule. | [optional] 
**subnet** | **String** | IP address representing a subnet. The IP address format must match with the \"ip_type\" parameter value. | [optional] 
**subnetSize** | **int** | The number of bits for the netmask in CIDR notation. Example: 24 | [optional] 
**source_** | **String** | If the source string is given a value of \"cloudflare\" subnet and subnet_size will both be ignored. Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"\" | Use the value from `subnet` and `subnet_size`. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall | | [optional] 
**notes** | **String** | User-supplied notes for this rule. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


