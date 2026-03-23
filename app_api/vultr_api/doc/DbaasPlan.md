# openapi.model.DbaasPlan

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the plan. | [optional] 
**numberOfNodes** | **int** | The total number of nodes for this plan. | [optional] 
**type** | **String** | The type of plan this is. | [optional] 
**vcpuCount** | **int** | Number of vCPUs. | [optional] 
**ram** | **int** | The amount of RAM in MB. | [optional] 
**disk** | **int** | The size of the disk in GB (excluded for Valkey engine types). | [optional] 
**monthlyCost** | **int** | The monthly cost of this Managed Database plan. | [optional] 
**supportedEngines** | [**Object**](.md) | A list of key/value pairs with database engine types and boolean values. | [optional] 
**maxConnections** | [**Object**](.md) | A list of key/value pairs with database engine types (excluding Valkey and Kafka) and integers of max connection values. | [optional] 
**locations** | **List<String>** | A list of available regions in which this plan is currently available. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


