# openapi.model.Plans

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Plan. | [optional] 
**name** | **String** | The Plan name. | [optional] 
**vcpuCount** | **int** | The number of vCPUs in this Plan. | [optional] 
**ram** | **int** | The amount of RAM in MB. | [optional] 
**disk** | **int** | The disk size in GB. | [optional] 
**bandwidth** | **int** | The monthly bandwidth quota in GB. | [optional] 
**invoiceType** | [**Object**](.md) | The type of cost for the Plan.  * hourly * monthly | [optional] 
**monthlyCost** | **num** | The monthly cost in US Dollars. | [optional] 
**hourlyCost** | **num** | The hourly cost in US Dollars (hourly plans only). | [optional] 
**monthlyCostPreemptible** | **num** | The monthly cost in US Dollars for preemptible configurations. | [optional] 
**hourlyCostPreemptible** | **num** | The hourly cost in US Dollars (hourly plans only) for preemptible configurations. | [optional] 
**type** | **String** | The plan type.  |   | Type | Description | | - | ------ | ------------- | |   | vc2 | Cloud Compute | |   | vhf | High Frequency Compute | |   | vdc | Dedicated Cloud | | [optional] 
**locations** | **List<String>** | An array of Regions where this plan is valid for use. | [optional] [default to const []]
**diskCount** | **int** | The number of disks that this plan offers. | [optional] 
**locationCost** | [**Map<String, PlansLocationCostValue>**](PlansLocationCostValue.md) | An object containing location-specific pricing. Keys are region codes and values are objects with cost details. | [optional] [default to const {}]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


