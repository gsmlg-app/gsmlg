# openapi.model.CreateUserRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**email** | **String** | The User's email address. | 
**name** | **String** | Use `first_name`, `last_name` instead. The User's full name. | [optional] 
**firstName** | **String** | The User's first name. | 
**lastName** | **String** | The User's last name. | 
**password** | **String** | The User's password. | 
**apiEnabled** | **bool** | API access is permitted for this User.  * true (default) * false | [optional] 
**acls** | **List<String>** | An array of permissions granted.  * abuse * activity_logs * alerts * billing * dns * firewall * loadbalancer * manage\\_users * objstore * provisioning * subscriptions * subscriptions\\_view * support * upgrade | [optional] [default to const []]
**serviceUser** | **bool** | Create this user as a service user (API-only access, no portal login). Service users will receive their API key upon creation.  * true * false (default) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


