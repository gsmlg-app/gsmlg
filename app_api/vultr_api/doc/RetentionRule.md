# openapi.model.RetentionRule

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** | The Retention rule's ID | [optional] 
**disabled** | **bool** | Indicates whether the Retention rule is currently disabled | [optional] 
**action** | **String** | Specifies the action to be taken on the selected artifacts | [optional] 
**params** | [**RetentionRuleParams**](RetentionRuleParams.md) |  | [optional] 
**scopeSelectors** | [**RetentionRuleScopeSelectors**](RetentionRuleScopeSelectors.md) |  | [optional] 
**tagSelectors** | [**List<RetentionRuleTagSelectorsInner>**](RetentionRuleTagSelectorsInner.md) | A list of tag selector rules that determine which tags or untagged artifacts the retention rule should apply to | [optional] [default to const []]
**template** | **String** | Specifies the rule logic template to use.  Possible templates:  * latestPushedK * latestPulledN * nDaysSinceLastPull * nDaysSinceLastPush * always | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


