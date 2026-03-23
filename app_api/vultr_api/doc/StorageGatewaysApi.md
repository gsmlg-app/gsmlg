# openapi.api.StorageGatewaysApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addStorageGatewayExport**](StorageGatewaysApi.md#addstoragegatewayexport) | **POST** /storage-gateways/{storage-gateway-id}/exports | Add a new export to this storage gateway
[**createStorageGateway**](StorageGatewaysApi.md#createstoragegateway) | **POST** /storage-gateways | Create Storage Gateway
[**deleteStorageGateway**](StorageGatewaysApi.md#deletestoragegateway) | **DELETE** /storage-gateways/{storage-gateway-id} | Delete Storage Gateway
[**deleteStorageGatewayExport**](StorageGatewaysApi.md#deletestoragegatewayexport) | **DELETE** /storage-gateways/{storage-gateway-id}/exports/{export-id} | Delete Storage Gateway Export
[**getStorageGateway**](StorageGatewaysApi.md#getstoragegateway) | **GET** /storage-gateways/{storage-gateway-id} | Get Storage Gateway
[**listStorageGateways**](StorageGatewaysApi.md#liststoragegateways) | **GET** /storage-gateways | List storage gateways
[**updateStorageGateway**](StorageGatewaysApi.md#updatestoragegateway) | **PUT** /storage-gateways/{storage-gateway-id} | Update Storage Gateway


# **addStorageGatewayExport**
> AddStorageGatewayExport200Response addStorageGatewayExport(storageGatewayId, storageGatewayExport)

Add a new export to this storage gateway

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final storageGatewayId = storageGatewayId_example; // String | The [Storage Gateway id](#operation/list-storage-gateways).
final storageGatewayExport = [List<StorageGatewayExport>()]; // List<StorageGatewayExport> | 

try {
    final result = api_instance.addStorageGatewayExport(storageGatewayId, storageGatewayExport);
    print(result);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->addStorageGatewayExport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storageGatewayId** | **String**| The [Storage Gateway id](#operation/list-storage-gateways). | 
 **storageGatewayExport** | [**List<StorageGatewayExport>**](StorageGatewayExport.md)|  | [optional] 

### Return type

[**AddStorageGatewayExport200Response**](AddStorageGatewayExport200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createStorageGateway**
> CreateStorageGateway202Response createStorageGateway(createStorageGatewayRequest)

Create Storage Gateway

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final createStorageGatewayRequest = CreateStorageGatewayRequest(); // CreateStorageGatewayRequest | 

try {
    final result = api_instance.createStorageGateway(createStorageGatewayRequest);
    print(result);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->createStorageGateway: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createStorageGatewayRequest** | [**CreateStorageGatewayRequest**](CreateStorageGatewayRequest.md)|  | [optional] 

### Return type

[**CreateStorageGateway202Response**](CreateStorageGateway202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteStorageGateway**
> deleteStorageGateway(storageGatewayId)

Delete Storage Gateway

Delete a Storage Gateway.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final storageGatewayId = storageGatewayId_example; // String | The [Storage Gateway id](#operation/list-storage-gateways).

try {
    api_instance.deleteStorageGateway(storageGatewayId);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->deleteStorageGateway: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storageGatewayId** | **String**| The [Storage Gateway id](#operation/list-storage-gateways). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteStorageGatewayExport**
> deleteStorageGatewayExport(UNKNOWN_PARAMETER_NAME, UNKNOWN_PARAMETER_NAME2)

Delete Storage Gateway Export

Delete a Storage Gateway Export.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final UNKNOWN_PARAMETER_NAME = ; //  | The [Storage Gateway id](#operation/list-storage-gateways).
final UNKNOWN_PARAMETER_NAME2 = ; //  | The [Storage Gateway export id](#operation/list-storage-gateways).

try {
    api_instance.deleteStorageGatewayExport(UNKNOWN_PARAMETER_NAME, UNKNOWN_PARAMETER_NAME2);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->deleteStorageGatewayExport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **UNKNOWN_PARAMETER_NAME** | [****](.md)| The [Storage Gateway id](#operation/list-storage-gateways). | 
 **UNKNOWN_PARAMETER_NAME2** | [****](.md)| The [Storage Gateway export id](#operation/list-storage-gateways). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStorageGateway**
> CreateStorageGateway202Response getStorageGateway(storageGatewayId)

Get Storage Gateway

Get information about a Storage Gateway.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final storageGatewayId = storageGatewayId_example; // String | The [Storage Gateway id](#operation/list-storage-gateways).

try {
    final result = api_instance.getStorageGateway(storageGatewayId);
    print(result);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->getStorageGateway: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storageGatewayId** | **String**| The [Storage Gateway id](#operation/list-storage-gateways). | 

### Return type

[**CreateStorageGateway202Response**](CreateStorageGateway202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listStorageGateways**
> ListStorageGateways200Response listStorageGateways(perPage, cursor)

List storage gateways

Get a list of all Storage Gateways in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listStorageGateways(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->listStorageGateways: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListStorageGateways200Response**](ListStorageGateways200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateStorageGateway**
> updateStorageGateway(storageGatewayId, updateStorageGatewayRequest)

Update Storage Gateway

Update the label for a Storage Gateway.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StorageGatewaysApi();
final storageGatewayId = storageGatewayId_example; // String | The [Storage Gateway id](#operation/list-storage-gateways).
final updateStorageGatewayRequest = UpdateStorageGatewayRequest(); // UpdateStorageGatewayRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateStorageGateway(storageGatewayId, updateStorageGatewayRequest);
} catch (e) {
    print('Exception when calling StorageGatewaysApi->updateStorageGateway: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **storageGatewayId** | **String**| The [Storage Gateway id](#operation/list-storage-gateways). | 
 **updateStorageGatewayRequest** | [**UpdateStorageGatewayRequest**](UpdateStorageGatewayRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

