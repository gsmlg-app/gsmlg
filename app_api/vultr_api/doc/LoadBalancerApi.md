# openapi.api.LoadBalancerApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createLoadBalancer**](LoadBalancerApi.md#createloadbalancer) | **POST** /load-balancers | Create Load Balancer
[**createLoadBalancerForwardingRules**](LoadBalancerApi.md#createloadbalancerforwardingrules) | **POST** /load-balancers/{load-balancer-id}/forwarding-rules | Create Forwarding Rule
[**createLoadBalancerReverseDnsIpv4**](LoadBalancerApi.md#createloadbalancerreversednsipv4) | **PUT** /load-balancers/{load-balancer-id}/reverse-dns | Update Reverse DNS IPV4
[**createLoadBalancerReverseDnsIpv6**](LoadBalancerApi.md#createloadbalancerreversednsipv6) | **POST** /load-balancers/{load-balancer-id}/reverse-dns | Create Reverse DNS IPV6
[**deleteLoadBalancer**](LoadBalancerApi.md#deleteloadbalancer) | **DELETE** /load-balancers/{load-balancer-id} | Delete Load Balancer
[**deleteLoadBalancerAutoSsl**](LoadBalancerApi.md#deleteloadbalancerautossl) | **DELETE** /load-balancers/{load-balancer-id}/auto_ssl | Disable Load Balancer Auto SSL
[**deleteLoadBalancerForwardingRule**](LoadBalancerApi.md#deleteloadbalancerforwardingrule) | **DELETE** /load-balancers/{load-balancer-id}/forwarding-rules/{forwarding-rule-id} | Delete Forwarding Rule
[**deleteLoadBalancerReverseDns**](LoadBalancerApi.md#deleteloadbalancerreversedns) | **DELETE** /load-balancers/{load-balancer-id}/reverse-dns | Delete Reverse DNS
[**deleteLoadBalancerSsl**](LoadBalancerApi.md#deleteloadbalancerssl) | **DELETE** /load-balancers/{load-balancer-id}/ssl | Delete Load Balancer SSL
[**getLoadBalancer**](LoadBalancerApi.md#getloadbalancer) | **GET** /load-balancers/{load-balancer-id} | Get Load Balancer
[**getLoadBalancerForwardingRule**](LoadBalancerApi.md#getloadbalancerforwardingrule) | **GET** /load-balancers/{load-balancer-id}/forwarding-rules/{forwarding-rule-id} | Get Forwarding Rule
[**getLoadBalancerReverseDns**](LoadBalancerApi.md#getloadbalancerreversedns) | **GET** /load-balancers/{load-balancer-id}/reverse-dns | Get Reverse DNS
[**getLoadbalancerFirewallRule**](LoadBalancerApi.md#getloadbalancerfirewallrule) | **GET** /load-balancers/{loadbalancer-id}/firewall-rules/{firewall-rule-id} | Get Firewall Rule
[**listLoadBalancerForwardingRules**](LoadBalancerApi.md#listloadbalancerforwardingrules) | **GET** /load-balancers/{load-balancer-id}/forwarding-rules | List Forwarding Rules
[**listLoadBalancers**](LoadBalancerApi.md#listloadbalancers) | **GET** /load-balancers | List Load Balancers
[**listLoadbalancerFirewallRules**](LoadBalancerApi.md#listloadbalancerfirewallrules) | **GET** /load-balancers/{loadbalancer-id}/firewall-rules | List Firewall Rules
[**updateLoadBalancer**](LoadBalancerApi.md#updateloadbalancer) | **PATCH** /load-balancers/{load-balancer-id} | Update Load Balancer


# **createLoadBalancer**
> CreateLoadBalancer202Response createLoadBalancer(createLoadBalancerRequest)

Create Load Balancer

Create a new Load Balancer in a particular `region`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final createLoadBalancerRequest = CreateLoadBalancerRequest(); // CreateLoadBalancerRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createLoadBalancer(createLoadBalancerRequest);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->createLoadBalancer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createLoadBalancerRequest** | [**CreateLoadBalancerRequest**](CreateLoadBalancerRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateLoadBalancer202Response**](CreateLoadBalancer202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLoadBalancerForwardingRules**
> createLoadBalancerForwardingRules(loadBalancerId, createLoadBalancerForwardingRulesRequest)

Create Forwarding Rule

Create a new forwarding rule for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final createLoadBalancerForwardingRulesRequest = CreateLoadBalancerForwardingRulesRequest(); // CreateLoadBalancerForwardingRulesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createLoadBalancerForwardingRules(loadBalancerId, createLoadBalancerForwardingRulesRequest);
} catch (e) {
    print('Exception when calling LoadBalancerApi->createLoadBalancerForwardingRules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **createLoadBalancerForwardingRulesRequest** | [**CreateLoadBalancerForwardingRulesRequest**](CreateLoadBalancerForwardingRulesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLoadBalancerReverseDnsIpv4**
> createLoadBalancerReverseDnsIpv4(loadBalancerId, createLoadBalancerReverseDnsIpv4Request)

Update Reverse DNS IPV4

Update (ipv4) Reverse DNS for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final createLoadBalancerReverseDnsIpv4Request = CreateLoadBalancerReverseDnsIpv4Request(); // CreateLoadBalancerReverseDnsIpv4Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createLoadBalancerReverseDnsIpv4(loadBalancerId, createLoadBalancerReverseDnsIpv4Request);
} catch (e) {
    print('Exception when calling LoadBalancerApi->createLoadBalancerReverseDnsIpv4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **createLoadBalancerReverseDnsIpv4Request** | [**CreateLoadBalancerReverseDnsIpv4Request**](CreateLoadBalancerReverseDnsIpv4Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLoadBalancerReverseDnsIpv6**
> createLoadBalancerReverseDnsIpv6(loadBalancerId, createLoadBalancerReverseDnsIpv6Request)

Create Reverse DNS IPV6

Create Reverse DNS (ipv6) for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final createLoadBalancerReverseDnsIpv6Request = CreateLoadBalancerReverseDnsIpv6Request(); // CreateLoadBalancerReverseDnsIpv6Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createLoadBalancerReverseDnsIpv6(loadBalancerId, createLoadBalancerReverseDnsIpv6Request);
} catch (e) {
    print('Exception when calling LoadBalancerApi->createLoadBalancerReverseDnsIpv6: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **createLoadBalancerReverseDnsIpv6Request** | [**CreateLoadBalancerReverseDnsIpv6Request**](CreateLoadBalancerReverseDnsIpv6Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLoadBalancer**
> deleteLoadBalancer(loadBalancerId)

Delete Load Balancer

Delete a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).

try {
    api_instance.deleteLoadBalancer(loadBalancerId);
} catch (e) {
    print('Exception when calling LoadBalancerApi->deleteLoadBalancer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLoadBalancerAutoSsl**
> deleteLoadBalancerAutoSsl(loadBalancerId)

Disable Load Balancer Auto SSL

Disable a Load Balancer Auto SSL. This will not remove an ssl certificate from the load balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).

try {
    api_instance.deleteLoadBalancerAutoSsl(loadBalancerId);
} catch (e) {
    print('Exception when calling LoadBalancerApi->deleteLoadBalancerAutoSsl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLoadBalancerForwardingRule**
> deleteLoadBalancerForwardingRule(loadBalancerId, forwardingRuleId)

Delete Forwarding Rule

Delete a Forwarding Rule on a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final forwardingRuleId = forwardingRuleId_example; // String | The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules).

try {
    api_instance.deleteLoadBalancerForwardingRule(loadBalancerId, forwardingRuleId);
} catch (e) {
    print('Exception when calling LoadBalancerApi->deleteLoadBalancerForwardingRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **forwardingRuleId** | **String**| The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLoadBalancerReverseDns**
> deleteLoadBalancerReverseDns(loadBalancerId)

Delete Reverse DNS

Delete a ipv6 reverse dns entry on a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).

try {
    api_instance.deleteLoadBalancerReverseDns(loadBalancerId);
} catch (e) {
    print('Exception when calling LoadBalancerApi->deleteLoadBalancerReverseDns: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLoadBalancerSsl**
> deleteLoadBalancerSsl(loadBalancerId)

Delete Load Balancer SSL

Delete a Load Balancer SSL.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).

try {
    api_instance.deleteLoadBalancerSsl(loadBalancerId);
} catch (e) {
    print('Exception when calling LoadBalancerApi->deleteLoadBalancerSsl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLoadBalancer**
> CreateLoadBalancer202Response getLoadBalancer(loadBalancerId)

Get Load Balancer

Get information for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).

try {
    final result = api_instance.getLoadBalancer(loadBalancerId);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->getLoadBalancer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 

### Return type

[**CreateLoadBalancer202Response**](CreateLoadBalancer202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLoadBalancerForwardingRule**
> GetLoadBalancerForwardingRule200Response getLoadBalancerForwardingRule(loadBalancerId, forwardingRuleId)

Get Forwarding Rule

Get information for a Forwarding Rule on a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final forwardingRuleId = forwardingRuleId_example; // String | The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules).

try {
    final result = api_instance.getLoadBalancerForwardingRule(loadBalancerId, forwardingRuleId);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->getLoadBalancerForwardingRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **forwardingRuleId** | **String**| The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules). | 

### Return type

[**GetLoadBalancerForwardingRule200Response**](GetLoadBalancerForwardingRule200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLoadBalancerReverseDns**
> GetLoadBalancerReverseDns200Response getLoadBalancerReverseDns(loadBalancerId)

Get Reverse DNS

Get Reverse DNS information for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).

try {
    final result = api_instance.getLoadBalancerReverseDns(loadBalancerId);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->getLoadBalancerReverseDns: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 

### Return type

[**GetLoadBalancerReverseDns200Response**](GetLoadBalancerReverseDns200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLoadbalancerFirewallRule**
> LoadbalancerFirewallRule getLoadbalancerFirewallRule(loadbalancerId, firewallRuleId)

Get Firewall Rule

Get a firewall rule for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadbalancerId = loadbalancerId_example; // String | 
final firewallRuleId = firewallRuleId_example; // String | 

try {
    final result = api_instance.getLoadbalancerFirewallRule(loadbalancerId, firewallRuleId);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->getLoadbalancerFirewallRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadbalancerId** | **String**|  | 
 **firewallRuleId** | **String**|  | 

### Return type

[**LoadbalancerFirewallRule**](LoadbalancerFirewallRule.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLoadBalancerForwardingRules**
> ListLoadBalancerForwardingRules200Response listLoadBalancerForwardingRules(loadBalancerId, perPage, cursor)

List Forwarding Rules

List the fowarding rules for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listLoadBalancerForwardingRules(loadBalancerId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->listLoadBalancerForwardingRules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListLoadBalancerForwardingRules200Response**](ListLoadBalancerForwardingRules200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLoadBalancers**
> ListLoadBalancers200Response listLoadBalancers(perPage, cursor)

List Load Balancers

List the Load Balancers in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500. 
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listLoadBalancers(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->listLoadBalancers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500.  | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListLoadBalancers200Response**](ListLoadBalancers200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLoadbalancerFirewallRules**
> LoadbalancerFirewallRule listLoadbalancerFirewallRules(loadbalancerId, perPage, cursor)

List Firewall Rules

List the firewall rules for a Load Balancer.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadbalancerId = loadbalancerId_example; // String | 
final perPage = perPage_example; // String | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listLoadbalancerFirewallRules(loadbalancerId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling LoadBalancerApi->listLoadbalancerFirewallRules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadbalancerId** | **String**|  | 
 **perPage** | **String**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**LoadbalancerFirewallRule**](LoadbalancerFirewallRule.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateLoadBalancer**
> updateLoadBalancer(loadBalancerId, updateLoadBalancerRequest)

Update Load Balancer

Update information for a Load Balancer. All attributes are optional. If not set, the attributes will retain their original values.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LoadBalancerApi();
final loadBalancerId = loadBalancerId_example; // String | The [Load Balancer id](#operation/list-load-balancers).
final updateLoadBalancerRequest = UpdateLoadBalancerRequest(); // UpdateLoadBalancerRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateLoadBalancer(loadBalancerId, updateLoadBalancerRequest);
} catch (e) {
    print('Exception when calling LoadBalancerApi->updateLoadBalancer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loadBalancerId** | **String**| The [Load Balancer id](#operation/list-load-balancers). | 
 **updateLoadBalancerRequest** | [**UpdateLoadBalancerRequest**](UpdateLoadBalancerRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

