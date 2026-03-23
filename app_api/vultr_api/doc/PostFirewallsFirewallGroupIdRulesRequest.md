# openapi.model.PostFirewallsFirewallGroupIdRulesRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**ipType** | **String** | The type of IP rule.  * v4 * v6 | 
**protocol** | **String** | The protocol for this rule.  * ICMP * TCP * UDP * GRE * ESP * AH  | 
**subnet** | **String** | IP address representing a subnet. The IP address format must match with the \"ip_type\" parameter value. | 
**subnetSize** | **int** | The number of bits for the netmask in CIDR notation. Example: 32 | 
**port** | **String** | TCP/UDP only. This field can be a specific port or a colon separated port range. | [optional] 
**source_** | **String** | If the source string is given a value of \"cloudflare\" subnet and subnet_size will both be ignored. Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"\" | Use the value from `subnet` and `subnet_size`. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall | |   | [Load Balancer id](#operation/list-load-balancers) | Provide a load balancer ID to use its IPs |  | [optional] 
**notes** | **String** | User-supplied notes for this rule. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


