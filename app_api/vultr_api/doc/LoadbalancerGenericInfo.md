# openapi.model.LoadbalancerGenericInfo

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**balancingAlgorithm** | **String** | The balancing algorithm.  * roundrobin (default) * leastconn | [optional] 
**sslRedirect** | **bool** | If `true`, this will redirect all HTTP traffic to HTTPS. You must have an HTTPS rule and SSL certificate installed on the load balancer to enable this option.  * true * false | [optional] 
**stickySessions** | [**LoadbalancerGenericInfoStickySessions**](LoadbalancerGenericInfoStickySessions.md) |  | [optional] 
**proxyProtocol** | **bool** | \"If `true`, you must configure backend nodes to accept Proxy protocol. \\n\\n* true\\n* false (Default)\" | [optional] 
**timeout** | **int** | The maximum time allowed for the connection to remain inactive before timing out in seconds. This defaults to 600. | [optional] 
**privateNetwork** | **String** | Use `vpc` instead. ID of the private network you wish to use. If private_network is omitted it will default to the public network. | [optional] 
**vpc** | **String** | ID of the VPC you wish to use. If a VPC ID is omitted it will default to the public network. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


