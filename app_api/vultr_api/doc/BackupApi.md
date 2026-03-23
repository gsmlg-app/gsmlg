# openapi.api.BackupApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getBackup**](BackupApi.md#getbackup) | **GET** /backups/{backup-id} | Get a Backup
[**listBackups**](BackupApi.md#listbackups) | **GET** /backups | List Backups


# **getBackup**
> GetBackup200Response getBackup(backupId)

Get a Backup

Get the information for the Backup.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BackupApi();
final backupId = backupId_example; // String | The [Backup id](#operation/list-backups).

try {
    final result = api_instance.getBackup(backupId);
    print(result);
} catch (e) {
    print('Exception when calling BackupApi->getBackup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **backupId** | **String**| The [Backup id](#operation/list-backups). | 

### Return type

[**GetBackup200Response**](GetBackup200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBackups**
> ListBackups200Response listBackups(instanceId, perPage, cursor)

List Backups

Get information about Backups in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BackupApi();
final instanceId = instanceId_example; // String | Filter the backup list by [Instance id](#operation/list-instances).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listBackups(instanceId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling BackupApi->listBackups: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| Filter the backup list by [Instance id](#operation/list-instances). | [optional] 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListBackups200Response**](ListBackups200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

