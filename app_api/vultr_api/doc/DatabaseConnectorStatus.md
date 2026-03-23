# openapi.model.DatabaseConnectorStatus

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**state** | **String** | The current status of the database connector. * `FAILED` * `PAUSED` * `RUNNING` * `UNASSIGNED` | [optional] 
**tasks** | [**List<DatabaseConnectorStatusTask>**](DatabaseConnectorStatusTask.md) | List of currently running tasks for the database connector. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


