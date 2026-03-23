# openapi.api.S3Api

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createObjectStorage**](S3Api.md#createobjectstorage) | **POST** /object-storage | Create Object Storage
[**deleteObjectStorage**](S3Api.md#deleteobjectstorage) | **DELETE** /object-storage/{object-storage-id} | Delete Object Storage
[**getObjectStorage**](S3Api.md#getobjectstorage) | **GET** /object-storage/{object-storage-id} | Get Object Storage
[**listObjectStorageClusterTiers**](S3Api.md#listobjectstorageclustertiers) | **GET** /object-storage/clusters/{cluster-id}/tiers | Get All Cluster Tiers
[**listObjectStorageClusters**](S3Api.md#listobjectstorageclusters) | **GET** /object-storage/clusters | Get All Clusters
[**listObjectStorageTiers**](S3Api.md#listobjectstoragetiers) | **GET** /object-storage/tiers | Get All Tiers
[**listObjectStorages**](S3Api.md#listobjectstorages) | **GET** /object-storage | List Object Storages
[**regenerateObjectStorageKeys**](S3Api.md#regenerateobjectstoragekeys) | **POST** /object-storage/{object-storage-id}/regenerate-keys | Regenerate Object Storage Keys
[**updateObjectStorage**](S3Api.md#updateobjectstorage) | **PUT** /object-storage/{object-storage-id} | Update Object Storage


# **createObjectStorage**
> CreateObjectStorage202Response createObjectStorage(createObjectStorageRequest)

Create Object Storage

Create new Object Storage. The `cluster_id` attribute is required.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = S3Api();
final createObjectStorageRequest = CreateObjectStorageRequest(); // CreateObjectStorageRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createObjectStorage(createObjectStorageRequest);
    print(result);
} catch (e) {
    print('Exception when calling S3Api->createObjectStorage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createObjectStorageRequest** | [**CreateObjectStorageRequest**](CreateObjectStorageRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateObjectStorage202Response**](CreateObjectStorage202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteObjectStorage**
> deleteObjectStorage(objectStorageId)

Delete Object Storage

Delete an Object Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = S3Api();
final objectStorageId = objectStorageId_example; // String | The [Object Storage id](#operation/list-object-storages).

try {
    api_instance.deleteObjectStorage(objectStorageId);
} catch (e) {
    print('Exception when calling S3Api->deleteObjectStorage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **objectStorageId** | **String**| The [Object Storage id](#operation/list-object-storages). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getObjectStorage**
> CreateObjectStorage202Response getObjectStorage(objectStorageId)

Get Object Storage

Get information about an Object Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = S3Api();
final objectStorageId = objectStorageId_example; // String | The [Object Storage id](#operation/list-object-storages).

try {
    final result = api_instance.getObjectStorage(objectStorageId);
    print(result);
} catch (e) {
    print('Exception when calling S3Api->getObjectStorage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **objectStorageId** | **String**| The [Object Storage id](#operation/list-object-storages). | 

### Return type

[**CreateObjectStorage202Response**](CreateObjectStorage202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listObjectStorageClusterTiers**
> ListObjectStorageClusterTiers200Response listObjectStorageClusterTiers(clusterId)

Get All Cluster Tiers

Get a list of all Object Storage Tiers for a given Cluster.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = S3Api();
final clusterId = clusterId_example; // String | The [Cluster id](#operation/list-object-storage-clusters).

try {
    final result = api_instance.listObjectStorageClusterTiers(clusterId);
    print(result);
} catch (e) {
    print('Exception when calling S3Api->listObjectStorageClusterTiers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **clusterId** | **String**| The [Cluster id](#operation/list-object-storage-clusters). | 

### Return type

[**ListObjectStorageClusterTiers200Response**](ListObjectStorageClusterTiers200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listObjectStorageClusters**
> ListObjectStorageClusters200Response listObjectStorageClusters(perPage, cursor)

Get All Clusters

Get a list of all Object Storage Clusters.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = S3Api();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listObjectStorageClusters(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling S3Api->listObjectStorageClusters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListObjectStorageClusters200Response**](ListObjectStorageClusters200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listObjectStorageTiers**
> ListObjectStorageTiers200Response listObjectStorageTiers()

Get All Tiers

Get a list of all Object Storage Tiers.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = S3Api();

try {
    final result = api_instance.listObjectStorageTiers();
    print(result);
} catch (e) {
    print('Exception when calling S3Api->listObjectStorageTiers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListObjectStorageTiers200Response**](ListObjectStorageTiers200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listObjectStorages**
> ListObjectStorages200Response listObjectStorages(perPage, cursor)

List Object Storages

Get a list of all Object Storage in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = S3Api();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listObjectStorages(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling S3Api->listObjectStorages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListObjectStorages200Response**](ListObjectStorages200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **regenerateObjectStorageKeys**
> RegenerateObjectStorageKeys201Response regenerateObjectStorageKeys(objectStorageId)

Regenerate Object Storage Keys

Regenerate the keys for an Object Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = S3Api();
final objectStorageId = objectStorageId_example; // String | The [Object Storage id](#operation/list-object-storages).

try {
    final result = api_instance.regenerateObjectStorageKeys(objectStorageId);
    print(result);
} catch (e) {
    print('Exception when calling S3Api->regenerateObjectStorageKeys: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **objectStorageId** | **String**| The [Object Storage id](#operation/list-object-storages). | 

### Return type

[**RegenerateObjectStorageKeys201Response**](RegenerateObjectStorageKeys201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateObjectStorage**
> updateObjectStorage(objectStorageId, updateObjectStorageRequest)

Update Object Storage

Update the label for an Object Storage.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = S3Api();
final objectStorageId = objectStorageId_example; // String | The [Object Storage id](#operation/list-object-storages).
final updateObjectStorageRequest = UpdateObjectStorageRequest(); // UpdateObjectStorageRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateObjectStorage(objectStorageId, updateObjectStorageRequest);
} catch (e) {
    print('Exception when calling S3Api->updateObjectStorage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **objectStorageId** | **String**| The [Object Storage id](#operation/list-object-storages). | 
 **updateObjectStorageRequest** | [**UpdateObjectStorageRequest**](UpdateObjectStorageRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

