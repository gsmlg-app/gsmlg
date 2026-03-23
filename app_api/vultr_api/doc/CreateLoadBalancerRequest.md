# openapi.model.CreateLoadBalancerRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | The [Region id](#operation/list-regions) to create this Load Balancer. | [optional] 
**balancingAlgorithm** | **String** | The balancing algorithm.  * roundrobin (default) * leastconn | [optional] 
**sslRedirect** | **bool** | If `true`, this will redirect all HTTP traffic to HTTPS. You must have an HTTPS rule and SSL certificate installed on the load balancer to enable this option.  * true * false | [optional] 
**http2** | **bool** | If `true`, this will enable HTTP2 traffic. You must have an HTTPS forwarding rule combo (HTTPS -> HTTPS) to enable this option.  * true * false | [optional] 
**http3** | **bool** | If `true`, this will enable HTTP3/QUIC traffic. You must have HTTP2 enabled.  * true * false | [optional] 
**nodes** | **int** | The number of nodes to add to the load balancer (1-99), must be an odd number. This defaults to 1. | [optional] 
**proxyProtocol** | **bool** | If `true`, you must configure backend nodes to accept Proxy protocol.  * true * false (Default) | [optional] 
**timeout** | **int** | The maximum time allowed for the connection to remain inactive before timing out in seconds. This defaults to 600. | [optional] 
**healthCheck** | [**CreateLoadBalancerRequestHealthCheck**](CreateLoadBalancerRequestHealthCheck.md) |  | [optional] 
**forwardingRules** | [**List<CreateLoadBalancerRequestForwardingRulesInner>**](CreateLoadBalancerRequestForwardingRulesInner.md) | An array of forwarding rule objects. | [optional] [default to const []]
**stickySession** | [**CreateLoadBalancerRequestStickySession**](CreateLoadBalancerRequestStickySession.md) |  | [optional] 
**ssl** | [**CreateLoadBalancerRequestSsl**](CreateLoadBalancerRequestSsl.md) |  | [optional] 
**label** | **String** | Label for your Load Balancer. | [optional] 
**instances** | **List<String>** | An array of instances IDs that you want attached to the load balancer. | [optional] [default to const []]
**firewallRules** | [**List<CreateLoadBalancerRequestFirewallRulesInner>**](CreateLoadBalancerRequestFirewallRulesInner.md) | An array of firewall rule objects. | [optional] [default to const []]
**privateNetwork** | **String** | Use `vpc` instead. ID of the private network you wish to use. If private_network is omitted it will default to the public network. | [optional] 
**vpc** | **String** | ID of the VPC you wish to use. If a VPC ID is omitted it will default to the public network. | [optional] 
**autoSsl** | [**CreateLoadBalancerRequestAutoSsl**](CreateLoadBalancerRequestAutoSsl.md) |  | [optional] 
**globalRegions** | [**List<CreateLoadBalancerRequestGlobalRegionsInner>**](CreateLoadBalancerRequestGlobalRegionsInner.md) | List of region objects with VPC information. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


