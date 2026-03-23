# openapi.model.CreateInstanceBackupScheduleRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**type** | **String** | Type of backup schedule:  |   | Value | Description | | - | ------ | ------------- | |   | daily | Back up once per day at `hour`. | |   | weekly | Back up once per week on `dow` at `hour`. | |   | monthly | Back up each month at `dom` at `hour`. | |   | daily\\_alt\\_even | Back up on even dates at `hour`. | |   | daily\\_alt\\_odd | Back up on odd dates at `hour`. | | 
**hour** | **int** | Hour of day to run in UTC. | [optional] 
**dow** | **int** | Day of week to run.  |   | Value | Description | | - | ------ | ------------- | |   | 1 | Sunday | |   | 2 | Monday | |   | 3 | Tuesday | |   | 4 | Wednesday | |   | 5 | Thursday | |   | 6 | Friday | |   | 7 | Saturday | | [optional] 
**dom** | **int** | Day of month to run. Use values between 1 and 28. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


