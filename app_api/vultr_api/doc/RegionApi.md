# openapi.api.RegionApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listAvailablePlansRegion**](RegionApi.md#listavailableplansregion) | **GET** /regions/{region-id}/availability | List available plans in region
[**listRegions**](RegionApi.md#listregions) | **GET** /regions | List Regions


# **listAvailablePlansRegion**
> ListAvailablePlansRegion200Response listAvailablePlansRegion(regionId, type)

List available plans in region

Get a list of the available plans in Region `region-id`. Not all plans are available in all regions.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = RegionApi();
final regionId = regionId_example; // String | The [Region id](#operation/list-regions).
final type = type_example; // String | Filter the results by type.  | **Type** | **Description** | |----------|-----------------| | all | All available types | | vc2 | Cloud Compute | | vdc | Dedicated Cloud | | vhf | High Frequency Compute | | vhp | High Performance | | voc | All Optimized Cloud types | | voc-g | General Purpose Optimized Cloud | | voc-c | CPU Optimized Cloud | | voc-m | Memory Optimized Cloud | | voc-s | Storage Optimized Cloud | | vbm | Bare Metal | | vcg | Cloud GPU | 

try {
    final result = api_instance.listAvailablePlansRegion(regionId, type);
    print(result);
} catch (e) {
    print('Exception when calling RegionApi->listAvailablePlansRegion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **regionId** | **String**| The [Region id](#operation/list-regions). | 
 **type** | **String**| Filter the results by type.  | **Type** | **Description** | |----------|-----------------| | all | All available types | | vc2 | Cloud Compute | | vdc | Dedicated Cloud | | vhf | High Frequency Compute | | vhp | High Performance | | voc | All Optimized Cloud types | | voc-g | General Purpose Optimized Cloud | | voc-c | CPU Optimized Cloud | | voc-m | Memory Optimized Cloud | | voc-s | Storage Optimized Cloud | | vbm | Bare Metal | | vcg | Cloud GPU |  | [optional] 

### Return type

[**ListAvailablePlansRegion200Response**](ListAvailablePlansRegion200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRegions**
> ListRegions200Response listRegions(perPage, cursor)

List Regions

List all Regions at Vultr.

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = RegionApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listRegions(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling RegionApi->listRegions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListRegions200Response**](ListRegions200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

