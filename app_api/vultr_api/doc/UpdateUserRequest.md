# openapi.model.UpdateUserRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**email** | **String** | The User's email address. | [optional] 
**name** | **String** | No longer supported as of 07/2025. | [optional] 
**firstName** | **String** | No longer supported as of 07/2025. | [optional] 
**lastName** | **String** | No longer supported as of 07/2025. | [optional] 
**password** | **String** | No longer supported as of 07/2025. | [optional] 
**apiEnabled** | **bool** | API access is permitted for this User.  * true (default) * false | [optional] 
**acls** | **List<String>** | An array of permission granted. Valid values:  * abuse * activity_logs * alerts * billing * dns * firewall * loadbalancer * manage\\_users * objstore * provisioning * subscriptions * subscriptions\\_view * support * upgrade | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


