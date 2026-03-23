# openapi.api.FirewallApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createFirewallGroup**](FirewallApi.md#createfirewallgroup) | **POST** /firewalls | Create Firewall Group
[**deleteFirewallGroup**](FirewallApi.md#deletefirewallgroup) | **DELETE** /firewalls/{firewall-group-id} | Delete Firewall Group
[**deleteFirewallGroupRule**](FirewallApi.md#deletefirewallgrouprule) | **DELETE** /firewalls/{firewall-group-id}/rules/{firewall-rule-id} | Delete Firewall Rule
[**getFirewallGroup**](FirewallApi.md#getfirewallgroup) | **GET** /firewalls/{firewall-group-id} | Get Firewall Group
[**getFirewallGroupRule**](FirewallApi.md#getfirewallgrouprule) | **GET** /firewalls/{firewall-group-id}/rules/{firewall-rule-id} | Get Firewall Rule
[**listFirewallGroupRules**](FirewallApi.md#listfirewallgrouprules) | **GET** /firewalls/{firewall-group-id}/rules | List Firewall Rules
[**listFirewallGroups**](FirewallApi.md#listfirewallgroups) | **GET** /firewalls | List Firewall Groups
[**postFirewallsFirewallGroupIdRules**](FirewallApi.md#postfirewallsfirewallgroupidrules) | **POST** /firewalls/{firewall-group-id}/rules | Create Firewall Rules
[**updateFirewallGroup**](FirewallApi.md#updatefirewallgroup) | **PUT** /firewalls/{firewall-group-id} | Update Firewall Group


# **createFirewallGroup**
> CreateFirewallGroup201Response createFirewallGroup(createFirewallGroupRequest)

Create Firewall Group

Create a new Firewall Group.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final createFirewallGroupRequest = CreateFirewallGroupRequest(); // CreateFirewallGroupRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createFirewallGroup(createFirewallGroupRequest);
    print(result);
} catch (e) {
    print('Exception when calling FirewallApi->createFirewallGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createFirewallGroupRequest** | [**CreateFirewallGroupRequest**](CreateFirewallGroupRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateFirewallGroup201Response**](CreateFirewallGroup201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteFirewallGroup**
> deleteFirewallGroup(firewallGroupId)

Delete Firewall Group

Delete a Firewall Group.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).

try {
    api_instance.deleteFirewallGroup(firewallGroupId);
} catch (e) {
    print('Exception when calling FirewallApi->deleteFirewallGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteFirewallGroupRule**
> deleteFirewallGroupRule(firewallGroupId, firewallRuleId)

Delete Firewall Rule

Delete a Firewall Rule.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).
final firewallRuleId = firewallRuleId_example; // String | The [Firewall Rule id](#operation/list-firewall-group-rules).

try {
    api_instance.deleteFirewallGroupRule(firewallGroupId, firewallRuleId);
} catch (e) {
    print('Exception when calling FirewallApi->deleteFirewallGroupRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 
 **firewallRuleId** | **String**| The [Firewall Rule id](#operation/list-firewall-group-rules). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFirewallGroup**
> CreateFirewallGroup201Response getFirewallGroup(firewallGroupId)

Get Firewall Group

Get information for a Firewall Group.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).

try {
    final result = api_instance.getFirewallGroup(firewallGroupId);
    print(result);
} catch (e) {
    print('Exception when calling FirewallApi->getFirewallGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 

### Return type

[**CreateFirewallGroup201Response**](CreateFirewallGroup201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFirewallGroupRule**
> PostFirewallsFirewallGroupIdRules201Response getFirewallGroupRule(firewallGroupId, firewallRuleId)

Get Firewall Rule

Get a Firewall Rule.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).
final firewallRuleId = firewallRuleId_example; // String | The [Firewall Rule id](#operation/list-firewall-group-rules).

try {
    final result = api_instance.getFirewallGroupRule(firewallGroupId, firewallRuleId);
    print(result);
} catch (e) {
    print('Exception when calling FirewallApi->getFirewallGroupRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 
 **firewallRuleId** | **String**| The [Firewall Rule id](#operation/list-firewall-group-rules). | 

### Return type

[**PostFirewallsFirewallGroupIdRules201Response**](PostFirewallsFirewallGroupIdRules201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFirewallGroupRules**
> ListFirewallGroupRules200Response listFirewallGroupRules(firewallGroupId, perPage, cursor)

List Firewall Rules

Get the Firewall Rules for a Firewall Group.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listFirewallGroupRules(firewallGroupId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling FirewallApi->listFirewallGroupRules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListFirewallGroupRules200Response**](ListFirewallGroupRules200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFirewallGroups**
> ListFirewallGroups200Response listFirewallGroups(perPage, cursor)

List Firewall Groups

Get a list of all Firewall Groups.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listFirewallGroups(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling FirewallApi->listFirewallGroups: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListFirewallGroups200Response**](ListFirewallGroups200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postFirewallsFirewallGroupIdRules**
> PostFirewallsFirewallGroupIdRules201Response postFirewallsFirewallGroupIdRules(firewallGroupId, postFirewallsFirewallGroupIdRulesRequest)

Create Firewall Rules

Create a Firewall Rule for a Firewall Group. The attributes `ip_type`, `protocol`, `subnet`, and `subnet_size` are required.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).
final postFirewallsFirewallGroupIdRulesRequest = PostFirewallsFirewallGroupIdRulesRequest(); // PostFirewallsFirewallGroupIdRulesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.postFirewallsFirewallGroupIdRules(firewallGroupId, postFirewallsFirewallGroupIdRulesRequest);
    print(result);
} catch (e) {
    print('Exception when calling FirewallApi->postFirewallsFirewallGroupIdRules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 
 **postFirewallsFirewallGroupIdRulesRequest** | [**PostFirewallsFirewallGroupIdRulesRequest**](PostFirewallsFirewallGroupIdRulesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**PostFirewallsFirewallGroupIdRules201Response**](PostFirewallsFirewallGroupIdRules201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateFirewallGroup**
> updateFirewallGroup(firewallGroupId, updateFirewallGroupRequest)

Update Firewall Group

Update information for a Firewall Group.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FirewallApi();
final firewallGroupId = firewallGroupId_example; // String | The [Firewall Group id](#operation/list-firewall-groups).
final updateFirewallGroupRequest = UpdateFirewallGroupRequest(); // UpdateFirewallGroupRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateFirewallGroup(firewallGroupId, updateFirewallGroupRequest);
} catch (e) {
    print('Exception when calling FirewallApi->updateFirewallGroup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firewallGroupId** | **String**| The [Firewall Group id](#operation/list-firewall-groups). | 
 **updateFirewallGroupRequest** | [**UpdateFirewallGroupRequest**](UpdateFirewallGroupRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

