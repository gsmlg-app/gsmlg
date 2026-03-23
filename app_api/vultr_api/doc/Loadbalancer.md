# openapi.model.Loadbalancer

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Load Balancer. | [optional] 
**dateCreated** | **String** | Date this Load Balancer was created. | [optional] 
**region** | **String** | The [Region id](#operation/list-regions) where the Load Balancer is located. | [optional] 
**label** | **String** | The user-supplied label for this load-balancer. | [optional] 
**status** | **String** | The current status.  * active | [optional] 
**ipv4** | **String** | The IPv4 address of this Load Balancer. | [optional] 
**ipv6** | **String** | The IPv6 address of this Load Balancer. | [optional] 
**genericInfo** | [**LoadbalancerGenericInfo**](LoadbalancerGenericInfo.md) |  | [optional] 
**healthCheck** | [**LoadbalancerHealthCheck**](LoadbalancerHealthCheck.md) |  | [optional] 
**hasSsl** | **bool** | Indicates if this Load Balancer has an SSL certificate installed. | [optional] 
**http2** | **bool** | Indicates if this Load Balancer has HTTP2 enabled. | [optional] 
**http3** | **bool** | Indicates if this Load Balancer has HTTP3 enabled. | [optional] 
**nodes** | **int** | The number of nodes to add to the load balancer (1-99), must be an odd number. This defaults to 1. | [optional] 
**forwardRules** | [**List<LoadbalancerForwardRulesInner>**](LoadbalancerForwardRulesInner.md) | An array of forwarding rule objects. | [optional] [default to const []]
**instances** | **List<String>** | Array of [Instance ids](#operation/list-instances) attached to this Load Balancer. | [optional] [default to const []]
**firewallRules** | [**List<LoadbalancerFirewallRulesInner>**](LoadbalancerFirewallRulesInner.md) | An array of firewall rule objects. | [optional] [default to const []]
**nodeIps** | [**LoadbalancerNodeIps**](LoadbalancerNodeIps.md) |  | [optional] 
**autoSsl** | [**LoadbalancerAutoSsl**](LoadbalancerAutoSsl.md) |  | [optional] 
**globalParentId** | **String** | If this load balancer is a child of a global load balancer, this field will display the ID of the parent load balancer. | [optional] 
**globalRegions** | **List<String>** | Array of [Region ids](#operation/list-regions) to deploy child Load Balancers to. | [optional] [default to const []]
**globalChildrenIds** | **List<String>** | If this load balancer is the parent of a global load balancer, this filed will display an array of children load balancer ids | [optional] [default to const []]
**globalCname** | **String** | The Canonical Name (CNAME) record value | [optional] 
**sslCertB64** | **String** | Base64 encoded ssl certificate, private key, and chain | [optional] 
**pendingCharges** | **int** | Pending charges for the current billing period | [optional] 
**cname** | **String** | The Canonical Name (CNAME) record value | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


