# openapi.model.LogMeta

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**nextPageUrl** | **String** | In the event that there are more logs found for a specified time period than can be returned, this field will contain a URL that can be used to request the next block of logs for the time period.  The new request is inclusive of the timestamp for the last logs from the previous request. This is done to avoid skipping over any logs that may have the same timestamp as the last log in the previous request, but which may not have been included in that response.  **Be aware that because of this there will be boundary duplicates between this new request and the previous one.**  | 
**continueTime** | **String** | In the event that there are more logs found for a specified time period that can be returned, this field will be set with a UTC timestamp of where the logs were left off.  | 
**returnedCount** | **int** | The number of log records that were returned. There is a maximum limit of 5,000 logs returned by any request. | 
**unreturnedCount** | **int** | The number of log records from the specified time period that were not returned due to the maximum return limit of 5,000 logs. | 
**totalCount** | **int** | The total number of records that were found for the specified time period. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


