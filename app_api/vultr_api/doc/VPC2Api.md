# openapi.api.VPC2Api

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**attachVpc2Nodes**](VPC2Api.md#attachvpc2nodes) | **POST** /vpc2/{vpc-id}/nodes/attach | Attach nodes to a VPC 2.0 network
[**createVpc2**](VPC2Api.md#createvpc2) | **POST** /vpc2 | Create a VPC 2.0 network
[**deleteVpc2**](VPC2Api.md#deletevpc2) | **DELETE** /vpc2/{vpc-id} | Delete a VPC 2.0 network
[**detachVpc2Nodes**](VPC2Api.md#detachvpc2nodes) | **POST** /vpc2/{vpc-id}/nodes/detach | Remove nodes from a VPC 2.0 network
[**getVpc2**](VPC2Api.md#getvpc2) | **GET** /vpc2/{vpc-id} | Get a VPC 2.0 network
[**listVpc2**](VPC2Api.md#listvpc2) | **GET** /vpc2 | List VPC 2.0 networks
[**listVpc2Nodes**](VPC2Api.md#listvpc2nodes) | **GET** /vpc2/{vpc-id}/nodes | Get a list of nodes attached to a VPC 2.0 network
[**updateVpc2**](VPC2Api.md#updatevpc2) | **PUT** /vpc2/{vpc-id} | Update a VPC 2.0 network


# **attachVpc2Nodes**
> attachVpc2Nodes(vpcId, attachVpc2NodesRequest)

Attach nodes to a VPC 2.0 network

Attach nodes to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).
final attachVpc2NodesRequest = AttachVpc2NodesRequest(); // AttachVpc2NodesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachVpc2Nodes(vpcId, attachVpc2NodesRequest);
} catch (e) {
    print('Exception when calling VPC2Api->attachVpc2Nodes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 
 **attachVpc2NodesRequest** | [**AttachVpc2NodesRequest**](AttachVpc2NodesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createVpc2**
> GetVpc2200Response createVpc2(createVpc2Request)

Create a VPC 2.0 network

Create a new VPC 2.0 network in a `region`.  **Deprecated**: Migrate to VPC Networks and use [Create a VPC](#operation/create-vpc) instead.  VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final createVpc2Request = CreateVpc2Request(); // CreateVpc2Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createVpc2(createVpc2Request);
    print(result);
} catch (e) {
    print('Exception when calling VPC2Api->createVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createVpc2Request** | [**CreateVpc2Request**](CreateVpc2Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetVpc2200Response**](GetVpc2200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteVpc2**
> deleteVpc2(vpcId)

Delete a VPC 2.0 network

Delete a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Delete a VPC](#operation/delete-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).

try {
    api_instance.deleteVpc2(vpcId);
} catch (e) {
    print('Exception when calling VPC2Api->deleteVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachVpc2Nodes**
> detachVpc2Nodes(vpcId, detachVpc2NodesRequest)

Remove nodes from a VPC 2.0 network

Remove nodes from a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).
final detachVpc2NodesRequest = DetachVpc2NodesRequest(); // DetachVpc2NodesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachVpc2Nodes(vpcId, detachVpc2NodesRequest);
} catch (e) {
    print('Exception when calling VPC2Api->detachVpc2Nodes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 
 **detachVpc2NodesRequest** | [**DetachVpc2NodesRequest**](DetachVpc2NodesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVpc2**
> GetVpc2200Response getVpc2(vpcId)

Get a VPC 2.0 network

Get information about a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Get a VPC](#operation/get-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).

try {
    final result = api_instance.getVpc2(vpcId);
    print(result);
} catch (e) {
    print('Exception when calling VPC2Api->getVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 

### Return type

[**GetVpc2200Response**](GetVpc2200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVpc2**
> ListVpc2200Response listVpc2(perPage, cursor)

List VPC 2.0 networks

Get a list of all VPC 2.0 networks in your account.<br><br>**Deprecated**: Migrate to VPC Networks and use [List VPCs](#operation/list-vpcs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listVpc2(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling VPC2Api->listVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListVpc2200Response**](ListVpc2200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVpc2Nodes**
> ListVpc2Nodes200Response listVpc2Nodes(vpcId, perPage, cursor)

Get a list of nodes attached to a VPC 2.0 network

Get a list of nodes attached to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listVpc2Nodes(vpcId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling VPC2Api->listVpc2Nodes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListVpc2Nodes200Response**](ListVpc2Nodes200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateVpc2**
> updateVpc2(vpcId, updateVpc2Request)

Update a VPC 2.0 network

Update information for a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Update a VPC](#operation/update-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPC2Api();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).
final updateVpc2Request = UpdateVpc2Request(); // UpdateVpc2Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateVpc2(vpcId, updateVpc2Request);
} catch (e) {
    print('Exception when calling VPC2Api->updateVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 
 **updateVpc2Request** | [**UpdateVpc2Request**](UpdateVpc2Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

