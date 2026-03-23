# openapi.api.ServerlessInferenceApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createInference**](ServerlessInferenceApi.md#createinference) | **POST** /inference | Create Serverless Inference
[**deleteInference**](ServerlessInferenceApi.md#deleteinference) | **DELETE** /inference/{inference-id} | Delete Serverless Inference
[**getInference**](ServerlessInferenceApi.md#getinference) | **GET** /inference/{inference-id} | Get Serverless Inference
[**getInferenceUsage**](ServerlessInferenceApi.md#getinferenceusage) | **GET** /inference/{inference-id}/usage | Get Serverless Inference Usage Information
[**listInference**](ServerlessInferenceApi.md#listinference) | **GET** /inference | List Serverless Inference
[**updateInference**](ServerlessInferenceApi.md#updateinference) | **PATCH** /inference/{inference-id} | Update Serverless Inference


# **createInference**
> CreateInference201Response createInference(createInferenceRequest)

Create Serverless Inference

Create a new Serverless Inference subscription.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerlessInferenceApi();
final createInferenceRequest = CreateInferenceRequest(); // CreateInferenceRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createInference(createInferenceRequest);
    print(result);
} catch (e) {
    print('Exception when calling ServerlessInferenceApi->createInference: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createInferenceRequest** | [**CreateInferenceRequest**](CreateInferenceRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateInference201Response**](CreateInference201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteInference**
> deleteInference(inferenceId)

Delete Serverless Inference

Delete a Serverless Inference subscription.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerlessInferenceApi();
final inferenceId = inferenceId_example; // String | The [Inference ID](#operation/list-inference).

try {
    api_instance.deleteInference(inferenceId);
} catch (e) {
    print('Exception when calling ServerlessInferenceApi->deleteInference: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inferenceId** | **String**| The [Inference ID](#operation/list-inference). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInference**
> CreateInference201Response getInference(inferenceId)

Get Serverless Inference

Get information about a Serverless Inference subscription.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerlessInferenceApi();
final inferenceId = inferenceId_example; // String | The [Inference ID](#operation/list-inference).

try {
    final result = api_instance.getInference(inferenceId);
    print(result);
} catch (e) {
    print('Exception when calling ServerlessInferenceApi->getInference: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inferenceId** | **String**| The [Inference ID](#operation/list-inference). | 

### Return type

[**CreateInference201Response**](CreateInference201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInferenceUsage**
> GetInferenceUsage200Response getInferenceUsage(inferenceId)

Get Serverless Inference Usage Information

Get usage information for a Serverless Inference subscription.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerlessInferenceApi();
final inferenceId = inferenceId_example; // String | The [Inference ID](#operation/list-inference).

try {
    final result = api_instance.getInferenceUsage(inferenceId);
    print(result);
} catch (e) {
    print('Exception when calling ServerlessInferenceApi->getInferenceUsage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inferenceId** | **String**| The [Inference ID](#operation/list-inference). | 

### Return type

[**GetInferenceUsage200Response**](GetInferenceUsage200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInference**
> ListInference200Response listInference()

List Serverless Inference

List all Serverless Inference subscriptions in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerlessInferenceApi();

try {
    final result = api_instance.listInference();
    print(result);
} catch (e) {
    print('Exception when calling ServerlessInferenceApi->listInference: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListInference200Response**](ListInference200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateInference**
> CreateInference201Response updateInference(inferenceId, updateInferenceRequest)

Update Serverless Inference

Update information for a Serverless Inference subscription.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerlessInferenceApi();
final inferenceId = inferenceId_example; // String | The [Inference ID](#operation/list-inference).
final updateInferenceRequest = UpdateInferenceRequest(); // UpdateInferenceRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.updateInference(inferenceId, updateInferenceRequest);
    print(result);
} catch (e) {
    print('Exception when calling ServerlessInferenceApi->updateInference: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inferenceId** | **String**| The [Inference ID](#operation/list-inference). | 
 **updateInferenceRequest** | [**UpdateInferenceRequest**](UpdateInferenceRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateInference201Response**](CreateInference201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

