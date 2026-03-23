# openapi.api.ReservedIpApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**attachReservedIp**](ReservedIpApi.md#attachreservedip) | **POST** /reserved-ips/{reserved-ip}/attach | Attach Reserved IP
[**convertReservedIp**](ReservedIpApi.md#convertreservedip) | **POST** /reserved-ips/convert | Convert Instance IP to Reserved IP
[**createReservedIp**](ReservedIpApi.md#createreservedip) | **POST** /reserved-ips | Create Reserved IP
[**deleteReservedIp**](ReservedIpApi.md#deletereservedip) | **DELETE** /reserved-ips/{reserved-ip} | Delete Reserved IP
[**detachReservedIp**](ReservedIpApi.md#detachreservedip) | **POST** /reserved-ips/{reserved-ip}/detach | Detach Reserved IP
[**getReservedIp**](ReservedIpApi.md#getreservedip) | **GET** /reserved-ips/{reserved-ip} | Get Reserved IP
[**listReservedIps**](ReservedIpApi.md#listreservedips) | **GET** /reserved-ips | List Reserved IPs
[**patchReservedIpsReservedIp**](ReservedIpApi.md#patchreservedipsreservedip) | **PATCH** /reserved-ips/{reserved-ip} | Update Reserved IP


# **attachReservedIp**
> attachReservedIp(reservedIp, attachReservedIpRequest)

Attach Reserved IP

Attach a Reserved IP to an compute instance or a baremetal instance - `instance_id`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final reservedIp = reservedIp_example; // String | The [Reserved IP id](#operation/list-reserved-ips)
final attachReservedIpRequest = AttachReservedIpRequest(); // AttachReservedIpRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachReservedIp(reservedIp, attachReservedIpRequest);
} catch (e) {
    print('Exception when calling ReservedIpApi->attachReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservedIp** | **String**| The [Reserved IP id](#operation/list-reserved-ips) | 
 **attachReservedIpRequest** | [**AttachReservedIpRequest**](AttachReservedIpRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **convertReservedIp**
> GetReservedIp200Response convertReservedIp(convertReservedIpRequest)

Convert Instance IP to Reserved IP

Convert the `ip_address` of an existing [instance](#operation/list-instances) into a Reserved IP.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final convertReservedIpRequest = ConvertReservedIpRequest(); // ConvertReservedIpRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.convertReservedIp(convertReservedIpRequest);
    print(result);
} catch (e) {
    print('Exception when calling ReservedIpApi->convertReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **convertReservedIpRequest** | [**ConvertReservedIpRequest**](ConvertReservedIpRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetReservedIp200Response**](GetReservedIp200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createReservedIp**
> GetReservedIp200Response createReservedIp(createReservedIpRequest)

Create Reserved IP

Create a new Reserved IP. The `region` and `ip_type` attributes are required.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final createReservedIpRequest = CreateReservedIpRequest(); // CreateReservedIpRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createReservedIp(createReservedIpRequest);
    print(result);
} catch (e) {
    print('Exception when calling ReservedIpApi->createReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createReservedIpRequest** | [**CreateReservedIpRequest**](CreateReservedIpRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetReservedIp200Response**](GetReservedIp200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteReservedIp**
> deleteReservedIp(reservedIp)

Delete Reserved IP

Delete a Reserved IP.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final reservedIp = reservedIp_example; // String | The [Reserved IP id](#operation/list-reserved-ips).

try {
    api_instance.deleteReservedIp(reservedIp);
} catch (e) {
    print('Exception when calling ReservedIpApi->deleteReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservedIp** | **String**| The [Reserved IP id](#operation/list-reserved-ips). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachReservedIp**
> detachReservedIp(reservedIp)

Detach Reserved IP

Detach a Reserved IP.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final reservedIp = reservedIp_example; // String | The [Reserved IP id](#operation/list-reserved-ips)

try {
    api_instance.detachReservedIp(reservedIp);
} catch (e) {
    print('Exception when calling ReservedIpApi->detachReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservedIp** | **String**| The [Reserved IP id](#operation/list-reserved-ips) | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReservedIp**
> GetReservedIp200Response getReservedIp(reservedIp)

Get Reserved IP

Get information about a Reserved IP.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final reservedIp = reservedIp_example; // String | The [Reserved IP id](#operation/list-reserved-ips).

try {
    final result = api_instance.getReservedIp(reservedIp);
    print(result);
} catch (e) {
    print('Exception when calling ReservedIpApi->getReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservedIp** | **String**| The [Reserved IP id](#operation/list-reserved-ips). | 

### Return type

[**GetReservedIp200Response**](GetReservedIp200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReservedIps**
> ListReservedIps200Response listReservedIps(perPage, cursor)

List Reserved IPs

List all Reserved IPs in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listReservedIps(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling ReservedIpApi->listReservedIps: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListReservedIps200Response**](ListReservedIps200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchReservedIpsReservedIp**
> GetReservedIp200Response patchReservedIpsReservedIp(reservedIp, patchReservedIpsReservedIpRequest)

Update Reserved IP

Update information on a Reserved IP.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReservedIpApi();
final reservedIp = reservedIp_example; // String | The [Reserved IP id](#operation/list-reserved-ips).
final patchReservedIpsReservedIpRequest = PatchReservedIpsReservedIpRequest(); // PatchReservedIpsReservedIpRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.patchReservedIpsReservedIp(reservedIp, patchReservedIpsReservedIpRequest);
    print(result);
} catch (e) {
    print('Exception when calling ReservedIpApi->patchReservedIpsReservedIp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reservedIp** | **String**| The [Reserved IP id](#operation/list-reserved-ips). | 
 **patchReservedIpsReservedIpRequest** | [**PatchReservedIpsReservedIpRequest**](PatchReservedIpsReservedIpRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetReservedIp200Response**](GetReservedIp200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

