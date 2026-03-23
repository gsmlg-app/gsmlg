# openapi.model.RetentionRuleTagSelectorsInner

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**decoration** | **String** | Specifies whether this selector is an inclusive or exclusive rule | [optional] 
**extras** | [**Object**](.md) | Extra options for the tag selector, for example, whether to include untagged | [optional] 
**kind** | **String** | The matching strategy for tag selection, typically 'doublestar' is used for glob matching | [optional] 
**pattern** | **String** | The pattern used to match tags, can be glob syntax such as 'myapp', 'myapp*', '**', etc. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


