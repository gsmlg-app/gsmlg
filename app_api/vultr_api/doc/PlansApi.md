# openapi.api.PlansApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listMetalPlans**](PlansApi.md#listmetalplans) | **GET** /plans-metal | List Bare Metal Plans
[**listPlans**](PlansApi.md#listplans) | **GET** /plans | List Plans


# **listMetalPlans**
> ListMetalPlans200Response listMetalPlans(perPage, cursor)

List Bare Metal Plans

Get a list of all Bare Metal plans at Vultr.  The response is an array of JSON `plan` objects, with unique `id` with sub-fields in the general format of:    <type>-<number of cores>-<memory size>-<optional modifier>  For example: `vc2-24c-96gb-sc1`  More about the sub-fields:  * `<type>`: The Vultr type code. For example, `vc2`, `vhf`, `vdc`, etc. * `<number of cores>`: The number of cores, such as `4c` for \"4 cores\", `8c` for \"8 cores\", etc. * `<memory size>`: Size in GB, such as `32gb`. * `<optional modifier>`: Some plans include a modifier for internal identification purposes, such as CPU type or location surcharges.  > Note: This information about plan id format is for general education. Vultr may change the sub-field format or values at any time. You should not attempt to parse the plan ID sub-fields in your code for any specific purpose. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = PlansApi();
final perPage = perPage_example; // String | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listMetalPlans(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling PlansApi->listMetalPlans: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **String**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListMetalPlans200Response**](ListMetalPlans200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlans**
> ListPlans200Response listPlans(type, perPage, cursor, os)

List Plans

Get a list of all VPS plans at Vultr.  The response is an array of JSON `plan` objects, with unique `id` with sub-fields in the general format of:    <type>-<number of cores>-<memory size>-<optional modifier>  For example: `vc2-24c-96gb-sc1`  More about the sub-fields:  * `<type>`: The Vultr type code. For example, `vc2`, `vhf`, `vdc`, etc. * `<number of cores>`: The number of cores, such as `4c` for \"4 cores\", `8c` for \"8 cores\", etc. * `<memory size>`: Size in GB, such as `32gb`. * `<optional modifier>`: Some plans include a modifier for internal identification purposes, such as CPU type or location surcharges.  > Note: This information about plan id format is for general education. Vultr may change the sub-field format or values at any time. You should not attempt to parse the plan ID sub-fields in your code for any specific purpose. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = PlansApi();
final type = type_example; // String | Filter the results by type.  | **Type** | **Description** | |----------|-----------------| | all | All available types | | vc2 | Cloud Compute | | vdc | Dedicated Cloud | | vhf | High Frequency Compute | | vhp | High Performance | | voc | All Optimized Cloud types | | voc-g | General Purpose Optimized Cloud | | voc-c | CPU Optimized Cloud | | voc-m | Memory Optimized Cloud | | voc-s | Storage Optimized Cloud | | vcg | Cloud GPU |
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
final os = os_example; // String | Filter the results by operating system.  |   | Type | Description | | - | ------ | ------------- | |   | windows | All available plans that support windows |

try {
    final result = api_instance.listPlans(type, perPage, cursor, os);
    print(result);
} catch (e) {
    print('Exception when calling PlansApi->listPlans: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**| Filter the results by type.  | **Type** | **Description** | |----------|-----------------| | all | All available types | | vc2 | Cloud Compute | | vdc | Dedicated Cloud | | vhf | High Frequency Compute | | vhp | High Performance | | voc | All Optimized Cloud types | | voc-g | General Purpose Optimized Cloud | | voc-c | CPU Optimized Cloud | | voc-m | Memory Optimized Cloud | | voc-s | Storage Optimized Cloud | | vcg | Cloud GPU | | [optional] 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 
 **os** | **String**| Filter the results by operating system.  |   | Type | Description | | - | ------ | ------------- | |   | windows | All available plans that support windows | | [optional] 

### Return type

[**ListPlans200Response**](ListPlans200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

