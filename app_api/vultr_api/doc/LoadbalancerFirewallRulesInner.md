# openapi.model.LoadbalancerFirewallRulesInner

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the firewall rule. | [optional] 
**port** | **int** | Port for this rule. | [optional] 
**source_** | **String** | If the source string is given a value of \"cloudflare\" then cloudflare IPs will be supplied. Otherwise enter a IP address with subnet size that you wish to permit through the firewall.    Possible values:    |   | Value | Description |   | - | ------ | ------------- |   |   | \"192.168.1.1/16\" | Ip address with a subnet size. |   |   | cloudflare | Allow all of Cloudflare's IP space through the firewall | | [optional] 
**ipType** | **String** | The type of IP rule.  * v4 * v6  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


