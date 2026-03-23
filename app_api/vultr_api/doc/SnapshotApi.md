# openapi.api.SnapshotApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSnapshot**](SnapshotApi.md#createsnapshot) | **POST** /snapshots | Create Snapshot
[**createSnapshotCreateFromUrl**](SnapshotApi.md#createsnapshotcreatefromurl) | **POST** /snapshots/create-from-url | Create Snapshot from URL
[**deleteSnapshot**](SnapshotApi.md#deletesnapshot) | **DELETE** /snapshots/{snapshot-id} | Delete Snapshot
[**getSnapshot**](SnapshotApi.md#getsnapshot) | **GET** /snapshots/{snapshot-id} | Get Snapshot
[**listSnapshots**](SnapshotApi.md#listsnapshots) | **GET** /snapshots | List Snapshots
[**putSnapshotsSnapshotId**](SnapshotApi.md#putsnapshotssnapshotid) | **PUT** /snapshots/{snapshot-id} | Update Snapshot


# **createSnapshot**
> GetSnapshot200Response createSnapshot(createSnapshotRequest)

Create Snapshot

Create a new Snapshot for `instance_id`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SnapshotApi();
final createSnapshotRequest = CreateSnapshotRequest(); // CreateSnapshotRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createSnapshot(createSnapshotRequest);
    print(result);
} catch (e) {
    print('Exception when calling SnapshotApi->createSnapshot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSnapshotRequest** | [**CreateSnapshotRequest**](CreateSnapshotRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetSnapshot200Response**](GetSnapshot200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSnapshotCreateFromUrl**
> GetSnapshot200Response createSnapshotCreateFromUrl(createSnapshotCreateFromUrlRequest)

Create Snapshot from URL

Create a new Snapshot from a RAW image located at `url`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SnapshotApi();
final createSnapshotCreateFromUrlRequest = CreateSnapshotCreateFromUrlRequest(); // CreateSnapshotCreateFromUrlRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createSnapshotCreateFromUrl(createSnapshotCreateFromUrlRequest);
    print(result);
} catch (e) {
    print('Exception when calling SnapshotApi->createSnapshotCreateFromUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSnapshotCreateFromUrlRequest** | [**CreateSnapshotCreateFromUrlRequest**](CreateSnapshotCreateFromUrlRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetSnapshot200Response**](GetSnapshot200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSnapshot**
> deleteSnapshot(snapshotId)

Delete Snapshot

Delete a Snapshot.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SnapshotApi();
final snapshotId = snapshotId_example; // String | The [Snapshot id](#operation/list-snapshots).

try {
    api_instance.deleteSnapshot(snapshotId);
} catch (e) {
    print('Exception when calling SnapshotApi->deleteSnapshot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **snapshotId** | **String**| The [Snapshot id](#operation/list-snapshots). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSnapshot**
> GetSnapshot200Response getSnapshot(snapshotId)

Get Snapshot

Get information about a Snapshot.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SnapshotApi();
final snapshotId = snapshotId_example; // String | The [Snapshot id](#operation/list-snapshots).

try {
    final result = api_instance.getSnapshot(snapshotId);
    print(result);
} catch (e) {
    print('Exception when calling SnapshotApi->getSnapshot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **snapshotId** | **String**| The [Snapshot id](#operation/list-snapshots). | 

### Return type

[**GetSnapshot200Response**](GetSnapshot200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSnapshots**
> ListSnapshots200Response listSnapshots(description, perPage, cursor)

List Snapshots

Get information about all Snapshots in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SnapshotApi();
final description = description_example; // String | Filter the list of Snapshots by `description`
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listSnapshots(description, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling SnapshotApi->listSnapshots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **description** | **String**| Filter the list of Snapshots by `description` | [optional] 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListSnapshots200Response**](ListSnapshots200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putSnapshotsSnapshotId**
> putSnapshotsSnapshotId(snapshotId, putSnapshotsSnapshotIdRequest)

Update Snapshot

Update the description for a Snapshot.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SnapshotApi();
final snapshotId = snapshotId_example; // String | The [Snapshot id](#operation/list-snapshots).
final putSnapshotsSnapshotIdRequest = PutSnapshotsSnapshotIdRequest(); // PutSnapshotsSnapshotIdRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.putSnapshotsSnapshotId(snapshotId, putSnapshotsSnapshotIdRequest);
} catch (e) {
    print('Exception when calling SnapshotApi->putSnapshotsSnapshotId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **snapshotId** | **String**| The [Snapshot id](#operation/list-snapshots). | 
 **putSnapshotsSnapshotIdRequest** | [**PutSnapshotsSnapshotIdRequest**](PutSnapshotsSnapshotIdRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

