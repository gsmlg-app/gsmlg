# openapi.api.VFSApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createVFS**](VFSApi.md#createvfs) | **POST** /vfs | Create VFS
[**createVFSAttachment**](VFSApi.md#createvfsattachment) | **PUT** /vfs/{vfs_id}/attachments/{vps_id} | Attach VPS Instance to VFS
[**deleteVFS**](VFSApi.md#deletevfs) | **DELETE** /vfs/{vfs_id} | Delete VFS
[**deleteVFSAttachment**](VFSApi.md#deletevfsattachment) | **DELETE** /vfs/{vfs_id}/attachments/{vps_id} | Delete VFS Attachment
[**getVFS**](VFSApi.md#getvfs) | **GET** /vfs/{vfs_id} | Get VFS
[**getVFSAttachment**](VFSApi.md#getvfsattachment) | **GET** /vfs/{vfs_id}/attachments/{vps_id} | Get VFS Attachment
[**listRegions**](VFSApi.md#listregions) | **GET** /vfs/regions | List VFS Regions
[**listVFS**](VFSApi.md#listvfs) | **GET** /vfs | List VFSs
[**listVFSAttachments**](VFSApi.md#listvfsattachments) | **GET** /vfs/{vfs_id}/attachments | List VFS Attachments
[**updateVFS**](VFSApi.md#updatevfs) | **PUT** /vfs/{vfs_id} | Update VFS


# **createVFS**
> Vfs createVFS(createVFSRequest)

Create VFS

Create a new VFS subscription with the specified configuration

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final createVFSRequest = CreateVFSRequest(); // CreateVFSRequest | 

try {
    final result = api_instance.createVFS(createVFSRequest);
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->createVFS: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createVFSRequest** | [**CreateVFSRequest**](CreateVFSRequest.md)|  | 

### Return type

[**Vfs**](Vfs.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createVFSAttachment**
> VfsAttachment createVFSAttachment(vfsId, vpsId)

Attach VPS Instance to VFS

Attach a VPS instance to a VFS subscription

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final vfsId = 123e4567-e89b-12d3-a456-123ab4567c89; // String | ID of the VFS subscription
final vpsId = 123e4567-e89b-12d3-a456-123ab4567c89; // String | ID of the VPS subscription to attach

try {
    final result = api_instance.createVFSAttachment(vfsId, vpsId);
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->createVFSAttachment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vfsId** | **String**| ID of the VFS subscription | 
 **vpsId** | **String**| ID of the VPS subscription to attach | 

### Return type

[**VfsAttachment**](VfsAttachment.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteVFS**
> deleteVFS(vfsId)

Delete VFS

Delete a specific VFS subscription by ID

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final vfsId = vfs-123abc; // String | ID of the VFS subscription to retrieve

try {
    api_instance.deleteVFS(vfsId);
} catch (e) {
    print('Exception when calling VFSApi->deleteVFS: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vfsId** | **String**| ID of the VFS subscription to retrieve | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteVFSAttachment**
> deleteVFSAttachment(vfsId, vpsId)

Delete VFS Attachment

Detach a VPS instance from a VFS subscription

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final vfsId = 123e4567-e89b-12d3-a456-123ab4567c89; // String | ID of the VFS subscription
final vpsId = 123e4567-e89b-12d3-a456-123ab4567c89; // String | ID of the VPS subscription to attach

try {
    api_instance.deleteVFSAttachment(vfsId, vpsId);
} catch (e) {
    print('Exception when calling VFSApi->deleteVFSAttachment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vfsId** | **String**| ID of the VFS subscription | 
 **vpsId** | **String**| ID of the VPS subscription to attach | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVFS**
> Vfs getVFS(vfsId)

Get VFS

Retrieve a specific VFS subscription by ID

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final vfsId = vfs-123abc; // String | ID of the VFS subscription to retrieve

try {
    final result = api_instance.getVFS(vfsId);
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->getVFS: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vfsId** | **String**| ID of the VFS subscription to retrieve | 

### Return type

[**Vfs**](Vfs.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVFSAttachment**
> VfsAttachment getVFSAttachment(vfsId, vpsId)

Get VFS Attachment

Retrieve details about a specific VFS-VPS attachment

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final vfsId = 123e4567-e89b-12d3-a456-123ab4567c89; // String | ID of the VFS subscription
final vpsId = 123e4567-e89b-12d3-a456-123ab4567c89; // String | ID of the VPS subscription to attach

try {
    final result = api_instance.getVFSAttachment(vfsId, vpsId);
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->getVFSAttachment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vfsId** | **String**| ID of the VFS subscription | 
 **vpsId** | **String**| ID of the VPS subscription to attach | 

### Return type

[**VfsAttachment**](VfsAttachment.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRegions**
> ListRegions200Response listRegions()

List VFS Regions

Retrieve a list of all regions where VFS can be deployed

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();

try {
    final result = api_instance.listRegions();
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->listRegions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListRegions200Response**](ListRegions200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVFS**
> ListVFS200Response listVFS()

List VFSs

Retrieve a list of all VFS subscriptions for the account

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();

try {
    final result = api_instance.listVFS();
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->listVFS: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListVFS200Response**](ListVFS200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVFSAttachments**
> ListVFSAttachments200Response listVFSAttachments(vfsId)

List VFS Attachments

Retrieve a list of all attachments for a specific VFS subscription

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final vfsId = vfs-123abc; // String | ID of the VFS subscription

try {
    final result = api_instance.listVFSAttachments(vfsId);
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->listVFSAttachments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vfsId** | **String**| ID of the VFS subscription | 

### Return type

[**ListVFSAttachments200Response**](ListVFSAttachments200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateVFS**
> Vfs updateVFS(updateVFSRequest)

Update VFS

Update a VFS subscription's label or storage size

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = VFSApi();
final updateVFSRequest = UpdateVFSRequest(); // UpdateVFSRequest | 

try {
    final result = api_instance.updateVFS(updateVFSRequest);
    print(result);
} catch (e) {
    print('Exception when calling VFSApi->updateVFS: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateVFSRequest** | [**UpdateVFSRequest**](UpdateVFSRequest.md)|  | [optional] 

### Return type

[**Vfs**](Vfs.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

