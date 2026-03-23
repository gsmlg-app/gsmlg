# openapi.api.ApplicationApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listApplications**](ApplicationApi.md#listapplications) | **GET** /applications | List Applications


# **listApplications**
> ListApplications200Response listApplications(type, perPage, cursor)

List Applications

Get a list of all available Applications.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = ApplicationApi();
final type = type_example; // String | Filter the results by type.  |   | Type | Description | | - | ------ | ------------- | |   | all | All available application types | |   | marketplace | Marketplace applications | |   | one-click | Vultr One-Click applications |
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listApplications(type, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling ApplicationApi->listApplications: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**| Filter the results by type.  |   | Type | Description | | - | ------ | ------------- | |   | all | All available application types | |   | marketplace | Marketplace applications | |   | one-click | Vultr One-Click applications | | [optional] 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListApplications200Response**](ListApplications200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

