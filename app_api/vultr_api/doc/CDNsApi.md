# openapi.api.CDNsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPullzone**](CDNsApi.md#createpullzone) | **POST** /cdns/pull-zones | Create CDN Pull Zones
[**createPushzone**](CDNsApi.md#createpushzone) | **POST** /cdns/push-zones | Create CDN Push Zones
[**createPushzoneUpload**](CDNsApi.md#createpushzoneupload) | **POST** /cdns/push-zones/{pushzone-id}/files | Create CDN Push Zone File Upload Endpoint
[**deletePullzone**](CDNsApi.md#deletepullzone) | **DELETE** /cdns/pull-zones/{pullzone-id} | Delete CDN Pullzone
[**deletePushzone**](CDNsApi.md#deletepushzone) | **DELETE** /cdns/push-zones/{pushzone-id} | Delete CDN Pushzone
[**deletePushzoneFile**](CDNsApi.md#deletepushzonefile) | **DELETE** /cdns/push-zones/{pushzone-id}/files/{file-name} | Delete CDN Pushzone File
[**getPullzone**](CDNsApi.md#getpullzone) | **GET** /cdns/pull-zones/{pullzone-id} | Get CDN Pull Zone
[**getPushzone**](CDNsApi.md#getpushzone) | **GET** /cdns/push-zones/{pushzone-id} | Get CDN Push Zone
[**getPushzoneFiles**](CDNsApi.md#getpushzonefiles) | **GET** /cdns/push-zones/{pushzone-id}/files | List CDN Push Zone Files
[**getPushzone_0**](CDNsApi.md#getpushzone_0) | **GET** /cdns/push-zones/{pushzone-id}/files/{file-name} | Get CDN Push Zone File
[**listPullzones**](CDNsApi.md#listpullzones) | **GET** /cdns/pull-zones | List CDN Pull Zones
[**listPushzones**](CDNsApi.md#listpushzones) | **GET** /cdns/push-zones | List CDN Push Zones
[**purgePullzone**](CDNsApi.md#purgepullzone) | **GET** /cdns/pull-zones/{pullzone-id}/purge | Purge CDN Pull Zone
[**updatePullzone**](CDNsApi.md#updatepullzone) | **PUT** /cdns/pull-zones/{pullzone-id} | Update CDN Pull Zone
[**updatePushzone**](CDNsApi.md#updatepushzone) | **PUT** /cdns/push-zones/{pushzone-id} | Update CDN Push Zone


# **createPullzone**
> CreatePullzone201Response createPullzone(createPullzoneRequest)

Create CDN Pull Zones

Create a new CDN Pull Zone.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final createPullzoneRequest = CreatePullzoneRequest(); // CreatePullzoneRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createPullzone(createPullzoneRequest);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->createPullzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createPullzoneRequest** | [**CreatePullzoneRequest**](CreatePullzoneRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreatePullzone201Response**](CreatePullzone201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPushzone**
> CreatePushzone201Response createPushzone(createPushzoneRequest)

Create CDN Push Zones

Create a new CDN Push Zone.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final createPushzoneRequest = CreatePushzoneRequest(); // CreatePushzoneRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createPushzone(createPushzoneRequest);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->createPushzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createPushzoneRequest** | [**CreatePushzoneRequest**](CreatePushzoneRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreatePushzone201Response**](CreatePushzone201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPushzoneUpload**
> CreatePushzoneUpload201Response createPushzoneUpload(pushzoneId, createPushzoneUploadRequest)

Create CDN Push Zone File Upload Endpoint

Create a presigned post endpoint that can be used to upload a file to your Push Zone.  After sending this request you must send a second POST request to the returned URL. Include all of the returned inputs as form-data fields using the same key and value.  You must also include a field named \"file\" that holds the file to be uploaded.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).
final createPushzoneUploadRequest = CreatePushzoneUploadRequest(); // CreatePushzoneUploadRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createPushzoneUpload(pushzoneId, createPushzoneUploadRequest);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->createPushzoneUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 
 **createPushzoneUploadRequest** | [**CreatePushzoneUploadRequest**](CreatePushzoneUploadRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreatePushzoneUpload201Response**](CreatePushzoneUpload201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePullzone**
> deletePullzone(pullzoneId)

Delete CDN Pullzone

Delete a CDN Pull Zone.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pullzoneId = pullzoneId_example; // String | The [Pull Zone ID](#operation/list-pullzones).

try {
    api_instance.deletePullzone(pullzoneId);
} catch (e) {
    print('Exception when calling CDNsApi->deletePullzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pullzoneId** | **String**| The [Pull Zone ID](#operation/list-pullzones). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePushzone**
> deletePushzone(pushzoneId)

Delete CDN Pushzone

Delete a CDN Push Zone.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).

try {
    api_instance.deletePushzone(pushzoneId);
} catch (e) {
    print('Exception when calling CDNsApi->deletePushzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePushzoneFile**
> deletePushzoneFile(pushzoneId, fileName)

Delete CDN Pushzone File

Delete a CDN Push Zone file.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).
final fileName = fileName_example; // String | The [File Name](#operation/list-pushzone-files).

try {
    api_instance.deletePushzoneFile(pushzoneId, fileName);
} catch (e) {
    print('Exception when calling CDNsApi->deletePushzoneFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 
 **fileName** | **String**| The [File Name](#operation/list-pushzone-files). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPullzone**
> CreatePullzone201Response getPullzone(pullzoneId)

Get CDN Pull Zone

Get information about a CDN Pull Zones

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pullzoneId = pullzoneId_example; // String | The [Pull Zone ID](#operation/list-pullzones).

try {
    final result = api_instance.getPullzone(pullzoneId);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->getPullzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pullzoneId** | **String**| The [Pull Zone ID](#operation/list-pullzones). | 

### Return type

[**CreatePullzone201Response**](CreatePullzone201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPushzone**
> CreatePushzone201Response getPushzone(pushzoneId)

Get CDN Push Zone

Get information about a CDN Push Zone

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).

try {
    final result = api_instance.getPushzone(pushzoneId);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->getPushzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 

### Return type

[**CreatePushzone201Response**](CreatePushzone201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPushzoneFiles**
> GetPushzoneFiles200Response getPushzoneFiles(pushzoneId)

List CDN Push Zone Files

Get a list of files that have been uploaded to a specific CDN Push Zones

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).

try {
    final result = api_instance.getPushzoneFiles(pushzoneId);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->getPushzoneFiles: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 

### Return type

[**GetPushzoneFiles200Response**](GetPushzoneFiles200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPushzone_0**
> GetPushzone200Response getPushzone_0(pushzoneId, fileName)

Get CDN Push Zone File

Get information about a CDN Push Zone file

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).
final fileName = fileName_example; // String | The [File Name](#operation/list-pushzone-files).

try {
    final result = api_instance.getPushzone_0(pushzoneId, fileName);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->getPushzone_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 
 **fileName** | **String**| The [File Name](#operation/list-pushzone-files). | 

### Return type

[**GetPushzone200Response**](GetPushzone200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPullzones**
> ListPullzones200Response listPullzones()

List CDN Pull Zones

List CDN Pull Zones

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();

try {
    final result = api_instance.listPullzones();
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->listPullzones: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListPullzones200Response**](ListPullzones200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPushzones**
> ListPushzones200Response listPushzones()

List CDN Push Zones

List CDN Push Zones

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();

try {
    final result = api_instance.listPushzones();
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->listPushzones: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListPushzones200Response**](ListPushzones200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **purgePullzone**
> List<String> purgePullzone(pullzoneId)

Purge CDN Pull Zone

Clears cached content on server proxies so that visitors can get the latest page versions.  **Note:** This action may only be performed once every six hours.  **Note:** This action may take a few extra seconds to complete.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pullzoneId = pullzoneId_example; // String | The [Pull Zone ID](#operation/list-pullzones).

try {
    final result = api_instance.purgePullzone(pullzoneId);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->purgePullzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pullzoneId** | **String**| The [Pull Zone ID](#operation/list-pullzones). | 

### Return type

**List<String>**

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePullzone**
> CreatePullzone201Response updatePullzone(pullzoneId, updatePullzoneRequest)

Update CDN Pull Zone

Update information for a CDN Pullzone. All attributes are optional. If not set, the attributes will retain their original values.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pullzoneId = pullzoneId_example; // String | The [Pull Zone ID](#operation/list-pullzones).
final updatePullzoneRequest = UpdatePullzoneRequest(); // UpdatePullzoneRequest | 

try {
    final result = api_instance.updatePullzone(pullzoneId, updatePullzoneRequest);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->updatePullzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pullzoneId** | **String**| The [Pull Zone ID](#operation/list-pullzones). | 
 **updatePullzoneRequest** | [**UpdatePullzoneRequest**](UpdatePullzoneRequest.md)|  | [optional] 

### Return type

[**CreatePullzone201Response**](CreatePullzone201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePushzone**
> CreatePushzone201Response updatePushzone(pushzoneId, updatePushzoneRequest)

Update CDN Push Zone

Update information for a CDN Pushzone. All attributes are optional. If not set, the attributes will retain their original values.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CDNsApi();
final pushzoneId = pushzoneId_example; // String | The [Push Zone ID](#operation/list-pushzones).
final updatePushzoneRequest = UpdatePushzoneRequest(); // UpdatePushzoneRequest | 

try {
    final result = api_instance.updatePushzone(pushzoneId, updatePushzoneRequest);
    print(result);
} catch (e) {
    print('Exception when calling CDNsApi->updatePushzone: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushzoneId** | **String**| The [Push Zone ID](#operation/list-pushzones). | 
 **updatePushzoneRequest** | [**UpdatePushzoneRequest**](UpdatePushzoneRequest.md)|  | [optional] 

### Return type

[**CreatePushzone201Response**](CreatePushzone201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

