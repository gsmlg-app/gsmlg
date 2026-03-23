# openapi.api.VPCsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createVpc**](VPCsApi.md#createvpc) | **POST** /vpcs | Create a VPC
[**deleteVpc**](VPCsApi.md#deletevpc) | **DELETE** /vpcs/{vpc-id} | Delete a VPC
[**getVpc**](VPCsApi.md#getvpc) | **GET** /vpcs/{vpc-id} | Get a VPC
[**listVpcAttachments**](VPCsApi.md#listvpcattachments) | **GET** /vpcs/{vpc-id}/attachments | List VPC Attachments
[**listVpcs**](VPCsApi.md#listvpcs) | **GET** /vpcs | List VPCs
[**updateVpc**](VPCsApi.md#updatevpc) | **PUT** /vpcs/{vpc-id} | Update a VPC


# **createVpc**
> GetVpc200Response createVpc(createVpcRequest)

Create a VPC

Create a new VPC in a `region`. VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPCsApi();
final createVpcRequest = CreateVpcRequest(); // CreateVpcRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createVpc(createVpcRequest);
    print(result);
} catch (e) {
    print('Exception when calling VPCsApi->createVpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createVpcRequest** | [**CreateVpcRequest**](CreateVpcRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetVpc200Response**](GetVpc200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteVpc**
> deleteVpc(vpcId)

Delete a VPC

Delete a VPC.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPCsApi();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).

try {
    api_instance.deleteVpc(vpcId);
} catch (e) {
    print('Exception when calling VPCsApi->deleteVpc: $e\n');
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

# **getVpc**
> GetVpc200Response getVpc(vpcId)

Get a VPC

Get information about a VPC.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPCsApi();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).

try {
    final result = api_instance.getVpc(vpcId);
    print(result);
} catch (e) {
    print('Exception when calling VPCsApi->getVpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 

### Return type

[**GetVpc200Response**](GetVpc200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVpcAttachments**
> ListVpcAttachments200Response listVpcAttachments(perPage, cursor)

List VPC Attachments

List VPC Attachments.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPCsApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listVpcAttachments(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling VPCsApi->listVpcAttachments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListVpcAttachments200Response**](ListVpcAttachments200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVpcs**
> ListVpcs200Response listVpcs(perPage, cursor)

List VPCs

Get a list of all VPCs in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPCsApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listVpcs(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling VPCsApi->listVpcs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListVpcs200Response**](ListVpcs200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateVpc**
> updateVpc(vpcId, updateVpcRequest)

Update a VPC

Update information for a VPC.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VPCsApi();
final vpcId = vpcId_example; // String | The [VPC ID](#operation/list-vpcs).
final updateVpcRequest = UpdateVpcRequest(); // UpdateVpcRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateVpc(vpcId, updateVpcRequest);
} catch (e) {
    print('Exception when calling VPCsApi->updateVpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vpcId** | **String**| The [VPC ID](#operation/list-vpcs). | 
 **updateVpcRequest** | [**UpdateVpcRequest**](UpdateVpcRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

