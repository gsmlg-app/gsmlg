# openapi.api.IsoApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createIso**](IsoApi.md#createiso) | **POST** /iso | Create ISO
[**deleteIso**](IsoApi.md#deleteiso) | **DELETE** /iso/{iso-id} | Delete ISO
[**isoGet**](IsoApi.md#isoget) | **GET** /iso/{iso-id} | Get ISO
[**listIsos**](IsoApi.md#listisos) | **GET** /iso | List ISOs
[**listPublicIsos**](IsoApi.md#listpublicisos) | **GET** /iso-public | List Public ISOs


# **createIso**
> CreateIso201Response createIso(createIsoRequest)

Create ISO

Create a new ISO in your account from `url`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IsoApi();
final createIsoRequest = CreateIsoRequest(); // CreateIsoRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createIso(createIsoRequest);
    print(result);
} catch (e) {
    print('Exception when calling IsoApi->createIso: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createIsoRequest** | [**CreateIsoRequest**](CreateIsoRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateIso201Response**](CreateIso201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteIso**
> deleteIso(isoId)

Delete ISO

Delete an ISO.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IsoApi();
final isoId = isoId_example; // String | The [ISO id](#operation/list-isos).

try {
    api_instance.deleteIso(isoId);
} catch (e) {
    print('Exception when calling IsoApi->deleteIso: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **isoId** | **String**| The [ISO id](#operation/list-isos). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **isoGet**
> CreateIso201Response isoGet(isoId)

Get ISO

Get information for an ISO.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IsoApi();
final isoId = isoId_example; // String | The [ISO id](#operation/list-isos).

try {
    final result = api_instance.isoGet(isoId);
    print(result);
} catch (e) {
    print('Exception when calling IsoApi->isoGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **isoId** | **String**| The [ISO id](#operation/list-isos). | 

### Return type

[**CreateIso201Response**](CreateIso201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listIsos**
> ListIsos200Response listIsos(perPage, cursor)

List ISOs

Get the ISOs in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = IsoApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listIsos(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling IsoApi->listIsos: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListIsos200Response**](ListIsos200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPublicIsos**
> ListPublicIsos200Response listPublicIsos()

List Public ISOs

List all Vultr Public ISOs.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = IsoApi();

try {
    final result = api_instance.listPublicIsos();
    print(result);
} catch (e) {
    print('Exception when calling IsoApi->listPublicIsos: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListPublicIsos200Response**](ListPublicIsos200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

