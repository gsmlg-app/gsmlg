# openapi.model.DbaasMigrationCredentials

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**host** | **String** | The host name of the source server. | [optional] 
**port** | **int** | The connection port of the source server. | [optional] 
**username** | **String** | The username of the source server. | [optional] 
**password** | **String** | The password of the source server. | [optional] 
**database** | **String** | The database of the source server. Excluded for Valkey engine types. | [optional] 
**ignoredDatabases** | **String** | Comma-separated list of ignored databases on the source server. Excluded for Valkey engine types. | [optional] 
**ssl** | **bool** | The true/false value for whether SSL is needed to connect to the source server. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


