# openapi.model.PlansMetal

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Bare Metal Plan. | [optional] 
**cpuCount** | **int** | The number of CPUs in this Plan. | [optional] 
**cpuModel** | **String** | The CPU model type for this instance. | [optional] 
**cpuThreads** | **int** | The numner of supported threads for this instance. | [optional] 
**ram** | **int** | The amount of RAM in MB. | [optional] 
**disk** | **String** | The disk size in GB. | [optional] 
**bandwidth** | **int** | The monthly bandwidth quota in GB. | [optional] 
**invoiceType** | [**Object**](.md) | The type of cost for the Plan.  * hourly * monthly | [optional] 
**monthlyCost** | **num** | The monthly cost in US Dollars. | [optional] 
**hourlyCost** | **num** | The hourly cost in US Dollars (hourly plans only). | [optional] 
**monthlyCostPreemptible** | **num** | The monthly cost in US Dollars for preemptible configurations. | [optional] 
**hourlyCostPreemptible** | **num** | The hourly cost in US Dollars (hourly plans only) for preemptible configurations. | [optional] 
**locations** | **List<String>** | An array of Regions where this plan is valid for use. | [optional] [default to const []]
**type** | **String** | The plan type.  * SSD | [optional] 
**diskCount** | **int** | The number of disks that this plan offers. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


