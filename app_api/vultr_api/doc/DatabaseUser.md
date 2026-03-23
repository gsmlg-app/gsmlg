# openapi.model.DatabaseUser

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**username** | **String** | The username for the database user. | [optional] 
**password** | **String** | The password for the database user. | [optional] 
**encryption** | **String** | The password encryption for the database user (MySQL engine types only). * `Default (MySQL 8+)` * `Legacy (MySQL 5.x)` | [optional] 
**accessControl** | [**DatabaseUserAccessControl**](DatabaseUserAccessControl.md) |  | [optional] 
**permission** | **String** | The permission level for the database user (Kafka engine types only). | [optional] 
**accessKey** | **String** | The private key to authenticate the database user (Kafka engine types only). | [optional] 
**accessCert** | **String** | The certificate to authenticate the database user (Kafka engine types only). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


