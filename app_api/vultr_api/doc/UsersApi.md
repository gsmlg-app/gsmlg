# openapi.api.UsersApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addUserIpWhitelist**](UsersApi.md#adduseripwhitelist) | **POST** /users/{user-id}/ip-whitelist | Add IP to User Whitelist
[**createUser**](UsersApi.md#createuser) | **POST** /users | Create User
[**createUserApiKey**](UsersApi.md#createuserapikey) | **POST** /users/{user-id}/apikeys | Create User API Key
[**deleteUser**](UsersApi.md#deleteuser) | **DELETE** /users/{user-id} | Delete User
[**deleteUserApiKey**](UsersApi.md#deleteuserapikey) | **DELETE** /users/{user-id}/apikeys/{apikey-id} | Delete User API Key
[**getUser**](UsersApi.md#getuser) | **GET** /users/{user-id} | Get User
[**getUserApiKey**](UsersApi.md#getuserapikey) | **GET** /users/{user-id}/apikeys/{apikey-id} | Get User API Key
[**getUserIpWhitelistEntry**](UsersApi.md#getuseripwhitelistentry) | **GET** /users/{user-id}/ip-whitelist/entry | Get User IP Whitelist Entry
[**listUserApiKeys**](UsersApi.md#listuserapikeys) | **GET** /users/{user-id}/apikeys | List User API Keys
[**listUserIpWhitelist**](UsersApi.md#listuseripwhitelist) | **GET** /users/{user-id}/ip-whitelist | List User IP Whitelist
[**listUsers**](UsersApi.md#listusers) | **GET** /users | Get Users
[**removeUserIpWhitelist**](UsersApi.md#removeuseripwhitelist) | **DELETE** /users/{user-id}/ip-whitelist | Remove IP from User Whitelist
[**updateUser**](UsersApi.md#updateuser) | **PATCH** /users/{user-id} | Update User


# **addUserIpWhitelist**
> addUserIpWhitelist(userId, addUserIpWhitelistRequest)

Add IP to User Whitelist

Add an IP address or subnet to a User's whitelist. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final addUserIpWhitelistRequest = AddUserIpWhitelistRequest(); // AddUserIpWhitelistRequest | 

try {
    api_instance.addUserIpWhitelist(userId, addUserIpWhitelistRequest);
} catch (e) {
    print('Exception when calling UsersApi->addUserIpWhitelist: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **addUserIpWhitelistRequest** | [**AddUserIpWhitelistRequest**](AddUserIpWhitelistRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createUser**
> User createUser(createUserRequest)

Create User

Create a new User. The `email`, `first_name`, `last_name`, and `password` attributes are required.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final createUserRequest = CreateUserRequest(); // CreateUserRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createUser(createUserRequest);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->createUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createUserRequest** | [**CreateUserRequest**](CreateUserRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**User**](User.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createUserApiKey**
> createUserApiKey(userId, createUserApiKeyRequest)

Create User API Key

Adds an API key to the target user's API key list. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final createUserApiKeyRequest = CreateUserApiKeyRequest(); // CreateUserApiKeyRequest | 

try {
    api_instance.createUserApiKey(userId, createUserApiKeyRequest);
} catch (e) {
    print('Exception when calling UsersApi->createUserApiKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **createUserApiKeyRequest** | [**CreateUserApiKeyRequest**](CreateUserApiKeyRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteUser**
> deleteUser(userId)

Delete User

Delete a User.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).

try {
    api_instance.deleteUser(userId);
} catch (e) {
    print('Exception when calling UsersApi->deleteUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteUserApiKey**
> deleteUserApiKey(userId, apikeyId)

Delete User API Key

Delete an API key from the target user's API key list. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final apikeyId = apikeyId_example; // String | The [API key id](#operation/list-user-api-keys).

try {
    api_instance.deleteUserApiKey(userId, apikeyId);
} catch (e) {
    print('Exception when calling UsersApi->deleteUserApiKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **apikeyId** | **String**| The [API key id](#operation/list-user-api-keys). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUser**
> User getUser(userId)

Get User

Get information about a User.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).

try {
    final result = api_instance.getUser(userId);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->getUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 

### Return type

[**User**](User.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserApiKey**
> GetUserApiKey200Response getUserApiKey(userId, apikeyId)

Get User API Key

Gets information about a user's API key. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final apikeyId = apikeyId_example; // String | The [API key id](#operation/list-user-api-keys).

try {
    final result = api_instance.getUserApiKey(userId, apikeyId);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->getUserApiKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **apikeyId** | **String**| The [API key id](#operation/list-user-api-keys). | 

### Return type

[**GetUserApiKey200Response**](GetUserApiKey200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserIpWhitelistEntry**
> GetUserIpWhitelistEntry200Response getUserIpWhitelistEntry(userId, subnet, subnetSize)

Get User IP Whitelist Entry

Get a specific IP whitelist entry for a User. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final subnet = subnet_example; // String | The IP address or subnet.
final subnetSize = 56; // int | The subnet size.

try {
    final result = api_instance.getUserIpWhitelistEntry(userId, subnet, subnetSize);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->getUserIpWhitelistEntry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **subnet** | **String**| The IP address or subnet. | 
 **subnetSize** | **int**| The subnet size. | 

### Return type

[**GetUserIpWhitelistEntry200Response**](GetUserIpWhitelistEntry200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUserApiKeys**
> ListUserApiKeys200Response listUserApiKeys(userId)

List User API Keys

Gets all API keys for the target user. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).

try {
    final result = api_instance.listUserApiKeys(userId);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->listUserApiKeys: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 

### Return type

[**ListUserApiKeys200Response**](ListUserApiKeys200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUserIpWhitelist**
> ListUserIpWhitelist200Response listUserIpWhitelist(userId)

List User IP Whitelist

Get the IP whitelist for a User. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).

try {
    final result = api_instance.listUserIpWhitelist(userId);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->listUserIpWhitelist: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 

### Return type

[**ListUserIpWhitelist200Response**](ListUserIpWhitelist200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUsers**
> ListUsers200Response listUsers(perPage, cursor)

Get Users

Get a list of all Users in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final perPage = 8.14; // num | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listUsers(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling UsersApi->listUsers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **num**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListUsers200Response**](ListUsers200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeUserIpWhitelist**
> removeUserIpWhitelist(userId, removeUserIpWhitelistRequest)

Remove IP from User Whitelist

Remove an IP address or subnet from a User's whitelist. Only root users or users with manage users permission can access this endpoint.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final removeUserIpWhitelistRequest = RemoveUserIpWhitelistRequest(); // RemoveUserIpWhitelistRequest | 

try {
    api_instance.removeUserIpWhitelist(userId, removeUserIpWhitelistRequest);
} catch (e) {
    print('Exception when calling UsersApi->removeUserIpWhitelist: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **removeUserIpWhitelistRequest** | [**RemoveUserIpWhitelistRequest**](RemoveUserIpWhitelistRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUser**
> updateUser(userId, updateUserRequest)

Update User

Update information for a User. All attributes are optional. If not set, the attributes will retain their original values.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = UsersApi();
final userId = userId_example; // String | The [User id](#operation/list-users).
final updateUserRequest = UpdateUserRequest(); // UpdateUserRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateUser(userId, updateUserRequest);
} catch (e) {
    print('Exception when calling UsersApi->updateUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| The [User id](#operation/list-users). | 
 **updateUserRequest** | [**UpdateUserRequest**](UpdateUserRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

