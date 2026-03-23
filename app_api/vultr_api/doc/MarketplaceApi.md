# openapi.api.MarketplaceApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listMarketplaceAppVariables**](MarketplaceApi.md#listmarketplaceappvariables) | **GET** /marketplace/apps/{image-id}/variables | List Marketplace App Variables


# **listMarketplaceAppVariables**
> ListMarketplaceAppVariables200Response listMarketplaceAppVariables(imageId)

List Marketplace App Variables

List all user-supplied variables for a Marketplace App.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MarketplaceApi();
final imageId = imageId_example; // String | The application's [Image ID](#operation/list-applications).

try {
    final result = api_instance.listMarketplaceAppVariables(imageId);
    print(result);
} catch (e) {
    print('Exception when calling MarketplaceApi->listMarketplaceAppVariables: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **imageId** | **String**| The application's [Image ID](#operation/list-applications). | 

### Return type

[**ListMarketplaceAppVariables200Response**](ListMarketplaceAppVariables200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

