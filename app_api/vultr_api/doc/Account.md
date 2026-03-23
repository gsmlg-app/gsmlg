# openapi.model.Account

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | Your user name. | [optional] 
**email** | **String** | Your email address. | [optional] 
**acls** | **List<String>** | An array of permission granted. * manage\\_users * subscriptions_view * subscriptions * billing * support * provisioning * dns * abuse * upgrade * firewall * alerts * objstore * loadbalancer | [optional] [default to const []]
**balance** | **num** | Your current account balance. | [optional] 
**pendingCharges** | **num** | Unbilled charges for this month. | [optional] 
**lastPaymentDate** | **String** | Date of your last payment. | [optional] 
**lastPaymentAmount** | **num** | The amount of your last payment. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


