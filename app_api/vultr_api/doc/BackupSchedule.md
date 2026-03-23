# openapi.model.BackupSchedule

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**enabled** | **bool** | Indicates if backup is enabled:  * true * false | [optional] 
**type** | **String** | Type of backup schedule:  |   | Value | Description | | - | ------ | ------------- | |   | daily | Back up once per day at `hour`. | |   | weekly | Back up once per week on `dow` at `hour`. | |   | monthly | Back up each month at `dom` at `hour`. | |   | daily\\_alt\\_even | Back up on even dates at `hour`. | |   | daily\\_alt\\_odd | Back up on odd dates at `hour`. | | [optional] 
**nextScheduledTimeUtc** | **String** | Time of next backup run in UTC. | [optional] 
**hour** | **int** | Scheduled hour of day in UTC. | [optional] 
**dow** | **int** | Day of week to run.  |   | Value | Description | | - | ------ | ------------- | |   | 1 | Sunday | |   | 2 | Monday | |   | 3 | Tuesday | |   | 4 | Wednesday | |   | 5 | Thursday | |   | 6 | Friday | |   | 7 | Saturday | | [optional] 
**dom** | **int** | Day of month to run. Use values between 1 and 28. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


