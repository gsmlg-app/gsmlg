# openapi.api.StartupApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createStartupScript**](StartupApi.md#createstartupscript) | **POST** /startup-scripts | Create Startup Script
[**deleteStartupScript**](StartupApi.md#deletestartupscript) | **DELETE** /startup-scripts/{startup-id} | Delete Startup Script
[**getStartupScript**](StartupApi.md#getstartupscript) | **GET** /startup-scripts/{startup-id} | Get Startup Script
[**listStartupScripts**](StartupApi.md#liststartupscripts) | **GET** /startup-scripts | List Startup Scripts
[**updateStartupScript**](StartupApi.md#updatestartupscript) | **PATCH** /startup-scripts/{startup-id} | Update Startup Script


# **createStartupScript**
> GetStartupScript200Response createStartupScript(createStartupScriptRequest)

Create Startup Script

Create a new Startup Script. The `name` and `script` attributes are required, and scripts are base-64 encoded.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StartupApi();
final createStartupScriptRequest = CreateStartupScriptRequest(); // CreateStartupScriptRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createStartupScript(createStartupScriptRequest);
    print(result);
} catch (e) {
    print('Exception when calling StartupApi->createStartupScript: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createStartupScriptRequest** | [**CreateStartupScriptRequest**](CreateStartupScriptRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**GetStartupScript200Response**](GetStartupScript200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteStartupScript**
> deleteStartupScript(startupId)

Delete Startup Script

Delete a Startup Script.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StartupApi();
final startupId = startupId_example; // String | The [Startup Script id](#operation/list-startup-scripts).

try {
    api_instance.deleteStartupScript(startupId);
} catch (e) {
    print('Exception when calling StartupApi->deleteStartupScript: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startupId** | **String**| The [Startup Script id](#operation/list-startup-scripts). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStartupScript**
> GetStartupScript200Response getStartupScript(startupId)

Get Startup Script

Get information for a Startup Script.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StartupApi();
final startupId = startupId_example; // String | The [Startup Script id](#operation/list-startup-scripts).

try {
    final result = api_instance.getStartupScript(startupId);
    print(result);
} catch (e) {
    print('Exception when calling StartupApi->getStartupScript: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startupId** | **String**| The [Startup Script id](#operation/list-startup-scripts). | 

### Return type

[**GetStartupScript200Response**](GetStartupScript200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listStartupScripts**
> ListStartupScripts200Response listStartupScripts(perPage, cursor)

List Startup Scripts

Get a list of all Startup Scripts.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StartupApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listStartupScripts(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling StartupApi->listStartupScripts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListStartupScripts200Response**](ListStartupScripts200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateStartupScript**
> updateStartupScript(startupId, updateStartupScriptRequest)

Update Startup Script

Update a Startup Script. The attributes `name` and `script` are optional. If not set, the attributes will retain their original values. The `script` attribute is base-64 encoded. New deployments will use the updated script, but this action does not update previously deployed instances.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StartupApi();
final startupId = startupId_example; // String | The [Startup Script id](#operation/list-startup-scripts).
final updateStartupScriptRequest = UpdateStartupScriptRequest(); // UpdateStartupScriptRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateStartupScript(startupId, updateStartupScriptRequest);
} catch (e) {
    print('Exception when calling StartupApi->updateStartupScript: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startupId** | **String**| The [Startup Script id](#operation/list-startup-scripts). | 
 **updateStartupScriptRequest** | [**UpdateStartupScriptRequest**](UpdateStartupScriptRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

