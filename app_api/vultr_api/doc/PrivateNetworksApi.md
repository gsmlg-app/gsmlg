# openapi.api.PrivateNetworksApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createNetwork**](PrivateNetworksApi.md#createnetwork) | **POST** /private-networks | Create a Private Network
[**deleteNetwork**](PrivateNetworksApi.md#deletenetwork) | **DELETE** /private-networks/{network-id} | Delete a private network
[**getNetwork**](PrivateNetworksApi.md#getnetwork) | **GET** /private-networks/{network-id} | Get a private network
[**listNetworks**](PrivateNetworksApi.md#listnetworks) | **GET** /private-networks | List Private Networks
[**updateNetwork**](PrivateNetworksApi.md#updatenetwork) | **PUT** /private-networks/{network-id} | Update a Private Network


# **createNetwork**
> GetNetwork200Response createNetwork(createNetworkRequest)

Create a Private Network

Create a new Private Network in a `region`.  **Deprecated**: Use [Create a VPC](#operation/create-vpc) instead.      Private networks should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrivateNetworksApi();
final createNetworkRequest = CreateNetworkRequest(); // CreateNetworkRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createNetwork(createNetworkRequest);
    print(result);
} catch (e) {
    print('Exception when calling PrivateNetworksApi->createNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createNetworkRequest** | [**CreateNetworkRequest**](CreateNetworkRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetNetwork200Response**](GetNetwork200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNetwork**
> deleteNetwork(networkId)

Delete a private network

Delete a Private Network.<br><br>**Deprecated**: Use [Delete a VPC](#operation/delete-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrivateNetworksApi();
final networkId = networkId_example; // String | The [Network id](#operation/list-networks).

try {
    api_instance.deleteNetwork(networkId);
} catch (e) {
    print('Exception when calling PrivateNetworksApi->deleteNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **String**| The [Network id](#operation/list-networks). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNetwork**
> GetNetwork200Response getNetwork(networkId)

Get a private network

Get information about a Private Network.<br><br>**Deprecated**: Use [Get a VPC](#operation/get-vpc) instead. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrivateNetworksApi();
final networkId = networkId_example; // String | The [Network id](#operation/list-networks).

try {
    final result = api_instance.getNetwork(networkId);
    print(result);
} catch (e) {
    print('Exception when calling PrivateNetworksApi->getNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **String**| The [Network id](#operation/list-networks). | 

### Return type

[**GetNetwork200Response**](GetNetwork200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNetworks**
> ListNetworks200Response listNetworks(perPage, cursor)

List Private Networks

Get a list of all Private Networks in your account.<br><br>**Deprecated**: Use [List VPCs](#operation/list-vpcs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrivateNetworksApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listNetworks(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling PrivateNetworksApi->listNetworks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListNetworks200Response**](ListNetworks200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateNetwork**
> updateNetwork(networkId, updateNetworkRequest)

Update a Private Network

Update information for a Private Network.<br><br>**Deprecated**: Use [Update a VPC](#operation/update-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrivateNetworksApi();
final networkId = networkId_example; // String | The [Network id](#operation/list-networks).
final updateNetworkRequest = UpdateNetworkRequest(); // UpdateNetworkRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateNetwork(networkId, updateNetworkRequest);
} catch (e) {
    print('Exception when calling PrivateNetworksApi->updateNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **networkId** | **String**| The [Network id](#operation/list-networks). | 
 **updateNetworkRequest** | [**UpdateNetworkRequest**](UpdateNetworkRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

