# openapi.api.BlockApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**attachBlock**](BlockApi.md#attachblock) | **POST** /blocks/{block-id}/attach | Attach Block Storage
[**createBlock**](BlockApi.md#createblock) | **POST** /blocks | Create Block Storage
[**deleteBlock**](BlockApi.md#deleteblock) | **DELETE** /blocks/{block-id} | Delete Block Storage
[**detachBlock**](BlockApi.md#detachblock) | **POST** /blocks/{block-id}/detach | Detach Block Storage
[**getBlock**](BlockApi.md#getblock) | **GET** /blocks/{block-id} | Get Block Storage
[**listBlocks**](BlockApi.md#listblocks) | **GET** /blocks | List Block storages
[**updateBlock**](BlockApi.md#updateblock) | **PATCH** /blocks/{block-id} | Update Block Storage


# **attachBlock**
> attachBlock(blockId, attachBlockRequest)

Attach Block Storage

Attach Block Storage to Instance `instance_id`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final blockId = blockId_example; // String | The [Block Storage id](#operation/list-blocks).
final attachBlockRequest = AttachBlockRequest(); // AttachBlockRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachBlock(blockId, attachBlockRequest);
} catch (e) {
    print('Exception when calling BlockApi->attachBlock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blockId** | **String**| The [Block Storage id](#operation/list-blocks). | 
 **attachBlockRequest** | [**AttachBlockRequest**](AttachBlockRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBlock**
> CreateBlock202Response createBlock(createBlockRequest)

Create Block Storage

Create new Block Storage in a `region` with a size of `size_gb`. Size may range between 10 and 40000 depending on the `block_type`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final createBlockRequest = CreateBlockRequest(); // CreateBlockRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createBlock(createBlockRequest);
    print(result);
} catch (e) {
    print('Exception when calling BlockApi->createBlock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBlockRequest** | [**CreateBlockRequest**](CreateBlockRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateBlock202Response**](CreateBlock202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteBlock**
> deleteBlock(blockId)

Delete Block Storage

Delete Block Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final blockId = blockId_example; // String | The [Block Storage id](#operation/list-blocks).

try {
    api_instance.deleteBlock(blockId);
} catch (e) {
    print('Exception when calling BlockApi->deleteBlock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blockId** | **String**| The [Block Storage id](#operation/list-blocks). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachBlock**
> detachBlock(blockId, detachBlockRequest)

Detach Block Storage

Detach Block Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final blockId = blockId_example; // String | The [Block Storage id](#operation/list-blocks).
final detachBlockRequest = DetachBlockRequest(); // DetachBlockRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachBlock(blockId, detachBlockRequest);
} catch (e) {
    print('Exception when calling BlockApi->detachBlock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blockId** | **String**| The [Block Storage id](#operation/list-blocks). | 
 **detachBlockRequest** | [**DetachBlockRequest**](DetachBlockRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBlock**
> CreateBlock202Response getBlock(blockId)

Get Block Storage

Get information for Block Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final blockId = blockId_example; // String | The [Block Storage id](#operation/list-blocks).

try {
    final result = api_instance.getBlock(blockId);
    print(result);
} catch (e) {
    print('Exception when calling BlockApi->getBlock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blockId** | **String**| The [Block Storage id](#operation/list-blocks). | 

### Return type

[**CreateBlock202Response**](CreateBlock202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBlocks**
> ListBlocks200Response listBlocks(perPage, cursor)

List Block storages

List all Block Storage in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listBlocks(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling BlockApi->listBlocks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListBlocks200Response**](ListBlocks200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateBlock**
> updateBlock(blockId, updateBlockRequest)

Update Block Storage

Update information for Block Storage. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BlockApi();
final blockId = blockId_example; // String | The [Block Storage id](#operation/list-blocks).
final updateBlockRequest = UpdateBlockRequest(); // UpdateBlockRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateBlock(blockId, updateBlockRequest);
} catch (e) {
    print('Exception when calling BlockApi->updateBlock: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **blockId** | **String**| The [Block Storage id](#operation/list-blocks). | 
 **updateBlockRequest** | [**UpdateBlockRequest**](UpdateBlockRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

