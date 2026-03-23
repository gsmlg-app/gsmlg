# openapi.model.Registry

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | The UUID to reference this registry | [optional] 
**name** | **String** | The globally unique name to reference this registry | [optional] 
**urn** | **String** | The base URN (the URL without the scheme [i.e. http:// or https://]) of this registry | [optional] 
**storage** | [**RegistryStorage**](RegistryStorage.md) |  | [optional] 
**dateCreated** | **String** | The date this Registry Subscription was created | [optional] 
**public** | **bool** | If true, this is a publically accessible registry allowing anyone to pull from it. If false, this registry is completely private | [optional] 
**rootUser** | [**RegistryUser**](RegistryUser.md) |  | [optional] 
**metadata** | [**RegistryMetadata**](RegistryMetadata.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


