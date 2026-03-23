# openapi.model.DbaasAlerts

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**timestamp** | **String** | The date and time in which the alert was sent. | [optional] 
**messageType** | **String** | The category of alert that was sent. * `DB MASTER PROMOTION` * `MAINTENANCE SCHEDULED` * `MISSING MYSQL PRIMARY KEYS` * `RESOURCE USAGE DISK` * `RESOURCE USAGE OOM KILLED` * `RESOURCE USAGE PG REPLICATION SLOTS` | [optional] 
**description** | **String** | A verbose description of the associated alert category. | [optional] 
**recommendation** | **String** | A description of the recommended action the customer should take. Only included for certain alert types. | [optional] 
**maintenanceScheduled** | **String** | The time in which mandatory maintenance has been scheduled with the associated alert. Only included for certain alert types. | [optional] 
**resourceType** | **String** | The affected resource related to the associated alert. Only included for certain alert types. | [optional] 
**tableCount** | **int** | The number of affected tables related to the associated alert. Only included for certain alert types. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


