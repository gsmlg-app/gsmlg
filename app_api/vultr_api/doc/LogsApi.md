# openapi.api.LogsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listLogs**](LogsApi.md#listlogs) | **GET** /logs | List Logs


# **listLogs**
> ListLogs200Response listLogs(startTime, endTime, logLevel, resourceType, resourceId)

List Logs

List the Logs for your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LogsApi();
final startTime = startTime_example; // String | A UTC timestamp for the start of the time period from which to return logs. `start_time` is an inclusive endpoint. Logs with a timestamp equal to, or after `start_time` are included in the response<br> <span style=\"color: red\">This field is required if the end_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *start_time must be after to the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no start_time is provided a time 30 days and 1 hour prior to the end_time will be used by default* 
final endTime = endTime_example; // String | A UTC timestamp for the end of the time period from which to return logs. `end_time` is an exclusive endpoint.  Only logs with a timestamp before the `end_time` are included in the response. <br> <span style=\"color: red\">This field is required if the start_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *end_time must be before the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no end_time is provided the current time will be used  by default*
final logLevel = logLevel_example; // String | Filter the logs by the level assigned to the log. * `info` * `debug` * `warning` * `error` * `critical`
final resourceType = resourceType_example; // String | Filter the logs by the type of a resource such as an instances, bare-metals, kubernetes, etc.<br> *resource_type must be an exact match to the value of the resource type set in the log.* 
final resourceId = resourceId_example; // String | Filter the logs by the UUID of a specific resource such as an instance.

try {
    final result = api_instance.listLogs(startTime, endTime, logLevel, resourceType, resourceId);
    print(result);
} catch (e) {
    print('Exception when calling LogsApi->listLogs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startTime** | **String**| A UTC timestamp for the start of the time period from which to return logs. `start_time` is an inclusive endpoint. Logs with a timestamp equal to, or after `start_time` are included in the response<br> <span style=\"color: red\">This field is required if the end_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *start_time must be after to the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no start_time is provided a time 30 days and 1 hour prior to the end_time will be used by default*  | [optional] 
 **endTime** | **String**| A UTC timestamp for the end of the time period from which to return logs. `end_time` is an exclusive endpoint.  Only logs with a timestamp before the `end_time` are included in the response. <br> <span style=\"color: red\">This field is required if the start_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *end_time must be before the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no end_time is provided the current time will be used  by default* | [optional] 
 **logLevel** | **String**| Filter the logs by the level assigned to the log. * `info` * `debug` * `warning` * `error` * `critical` | [optional] 
 **resourceType** | **String**| Filter the logs by the type of a resource such as an instances, bare-metals, kubernetes, etc.<br> *resource_type must be an exact match to the value of the resource type set in the log.*  | [optional] 
 **resourceId** | **String**| Filter the logs by the UUID of a specific resource such as an instance. | [optional] 

### Return type

[**ListLogs200Response**](ListLogs200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

