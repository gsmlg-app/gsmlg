# openapi.api.SshApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSshKey**](SshApi.md#createsshkey) | **POST** /ssh-keys | Create SSH key
[**deleteSshKey**](SshApi.md#deletesshkey) | **DELETE** /ssh-keys/{ssh-key-id} | Delete SSH Key
[**getSshKey**](SshApi.md#getsshkey) | **GET** /ssh-keys/{ssh-key-id} | Get SSH Key
[**listSshKeys**](SshApi.md#listsshkeys) | **GET** /ssh-keys | List SSH Keys
[**updateSshKey**](SshApi.md#updatesshkey) | **PATCH** /ssh-keys/{ssh-key-id} | Update SSH Key


# **createSshKey**
> GetSshKey200Response createSshKey(createSshKeyRequest)

Create SSH key

Create a new SSH Key for use with future instances. This does not update any running instances.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SshApi();
final createSshKeyRequest = CreateSshKeyRequest(); // CreateSshKeyRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createSshKey(createSshKeyRequest);
    print(result);
} catch (e) {
    print('Exception when calling SshApi->createSshKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createSshKeyRequest** | [**CreateSshKeyRequest**](CreateSshKeyRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetSshKey200Response**](GetSshKey200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSshKey**
> deleteSshKey(sshKeyId)

Delete SSH Key

Delete an SSH Key.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SshApi();
final sshKeyId = sshKeyId_example; // String | The [SSH Key id](#operation/list-ssh-keys).

try {
    api_instance.deleteSshKey(sshKeyId);
} catch (e) {
    print('Exception when calling SshApi->deleteSshKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sshKeyId** | **String**| The [SSH Key id](#operation/list-ssh-keys). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSshKey**
> GetSshKey200Response getSshKey(sshKeyId)

Get SSH Key

Get information about an SSH Key.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SshApi();
final sshKeyId = sshKeyId_example; // String | The [SSH Key id](#operation/list-ssh-keys).

try {
    final result = api_instance.getSshKey(sshKeyId);
    print(result);
} catch (e) {
    print('Exception when calling SshApi->getSshKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sshKeyId** | **String**| The [SSH Key id](#operation/list-ssh-keys). | 

### Return type

[**GetSshKey200Response**](GetSshKey200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSshKeys**
> ListSshKeys200Response listSshKeys(perPage, cursor)

List SSH Keys

List all SSH Keys in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SshApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500. 
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listSshKeys(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling SshApi->listSshKeys: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500.  | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListSshKeys200Response**](ListSshKeys200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSshKey**
> updateSshKey(sshKeyId, updateSshKeyRequest)

Update SSH Key

Update an SSH Key. The attributes `name` and `ssh_key` are optional. If not set, the attributes will retain their original values. New deployments will use the updated key, but this action does not update previously deployed instances.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SshApi();
final sshKeyId = sshKeyId_example; // String | The [SSH Key id](#operation/list-ssh-keys).
final updateSshKeyRequest = UpdateSshKeyRequest(); // UpdateSshKeyRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateSshKey(sshKeyId, updateSshKeyRequest);
} catch (e) {
    print('Exception when calling SshApi->updateSshKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sshKeyId** | **String**| The [SSH Key id](#operation/list-ssh-keys). | 
 **updateSshKeyRequest** | [**UpdateSshKeyRequest**](UpdateSshKeyRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

