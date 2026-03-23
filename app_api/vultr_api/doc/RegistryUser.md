# openapi.model.RegistryUser

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** | The Numeric ID of this user. | [optional] 
**username** | **String** | The globally unique name of this user. | [optional] 
**password** | **String** | The password this user will use to authenticate. | [optional] 
**root** | **bool** | If true, this is a root user/registry owner meaning it cannot be deleted or renamed. If false, this is an additional user added to this registry that can be modified | [optional] 
**addedAt** | **String** | The date this User was added | [optional] 
**updatedAt** | **String** | The date this User was last updated | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


