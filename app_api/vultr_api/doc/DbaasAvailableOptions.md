# openapi.model.DbaasAvailableOptions

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | The name of the configuration option. | [optional] 
**type** | **String** | The type of the configuration option. * `int` * `float` * `bool` * `enum` | [optional] 
**enumerals** | **List<String>** | Valid enumerals for `enum` type configuration options only. | [optional] [default to const []]
**minValue** | **num** | The smallest value accepted for the configuration option. | [optional] 
**maxValue** | **num** | The largest value accepted for the configuration option. | [optional] 
**altValues** | **List<int>** | Any alternate value accepted for the configuration option. | [optional] [default to const []]
**units** | **String** | The units associated with the configuration option. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


