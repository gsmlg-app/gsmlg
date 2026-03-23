# openapi.api.ContainerRegistryApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listRegistries**](ContainerRegistryApi.md#listregistries) | **GET** /registries | List Container Registries


# **listRegistries**
> ListRegistries200Response listRegistries()

List Container Registries

List All Container Registry Subscriptions for this account

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContainerRegistryApi();

try {
    final result = api_instance.listRegistries();
    print(result);
} catch (e) {
    print('Exception when calling ContainerRegistryApi->listRegistries: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListRegistries200Response**](ListRegistries200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

