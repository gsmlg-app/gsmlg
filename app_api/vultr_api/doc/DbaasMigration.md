# openapi.model.DbaasMigration

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**status** | **String** | The current status of the attached migration. * `complete` * `error` * `pending` * `running` | [optional] 
**method** | **String** | The type of migration performed (dump or replication). Only shows if status is `complete`. | [optional] 
**error** | **String** | The verbose error message output for migrations with an `error` status. | [optional] 
**credentials** | [**DbaasMigrationCredentials**](DbaasMigrationCredentials.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


