# openapi.model.UserUser

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | The User's id. | [optional] 
**name** | **String** | The User's full name. | [optional] 
**firstName** | **String** | The User's first name. | [optional] 
**lastName** | **String** | The User's last name. | [optional] 
**apiEnabled** | **bool** | Permit API access for this User.  * true * false | [optional] 
**email** | **String** | The User's email address. | [optional] 
**password** | **String** | The User's password. | [optional] 
**acls** | **List<String>** | An array of permission granted.  * abuse * activity_logs * alerts * billing * dns * firewall * loadbalancer * manage\\_users * objstore * provisioning * subscriptions * subscriptions\\_view * support * upgrade | [optional] [default to const []]
**serviceUser** | **bool** | Indicates if this is a service user (API-only access, no portal login).  * true * false | [optional] 
**apiKey** | **String** | The API key for this user. Only returned when creating service users. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


