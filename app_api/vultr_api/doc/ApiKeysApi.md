# openapi.api.ApiKeysApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createApiKey**](ApiKeysApi.md#createapikey) | **POST** /apikeys | Create API Key
[**deleteApiKey**](ApiKeysApi.md#deleteapikey) | **DELETE** /apikeys/{apikey-id} | Delete API Key
[**getApiKey**](ApiKeysApi.md#getapikey) | **GET** /apikeys/{apikey-id} | Get API Key
[**listApiKeys**](ApiKeysApi.md#listapikeys) | **GET** /apikeys | List API Keys


# **createApiKey**
> GetUserApiKey200Response createApiKey(createUserApiKeyRequest)

Create API Key

Adds an API key to the currently authenticated user's API key list.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ApiKeysApi();
final createUserApiKeyRequest = CreateUserApiKeyRequest(); // CreateUserApiKeyRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createApiKey(createUserApiKeyRequest);
    print(result);
} catch (e) {
    print('Exception when calling ApiKeysApi->createApiKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createUserApiKeyRequest** | [**CreateUserApiKeyRequest**](CreateUserApiKeyRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetUserApiKey200Response**](GetUserApiKey200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteApiKey**
> deleteApiKey()

Delete API Key

Delete an API key from the currently authenticated user's API key list.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ApiKeysApi();

try {
    api_instance.deleteApiKey();
} catch (e) {
    print('Exception when calling ApiKeysApi->deleteApiKey: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getApiKey**
> GetUserApiKey200Response getApiKey()

Get API Key

Gets information about an API key for the currently authenticated user. API keys returned by this method are masked.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ApiKeysApi();

try {
    final result = api_instance.getApiKey();
    print(result);
} catch (e) {
    print('Exception when calling ApiKeysApi->getApiKey: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetUserApiKey200Response**](GetUserApiKey200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listApiKeys**
> ListUserApiKeys200Response listApiKeys()

List API Keys

Gets all API keys for the currently authenticated user. API keys returned by this method are masked.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ApiKeysApi();

try {
    final result = api_instance.listApiKeys();
    print(result);
} catch (e) {
    print('Exception when calling ApiKeysApi->listApiKeys: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListUserApiKeys200Response**](ListUserApiKeys200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

