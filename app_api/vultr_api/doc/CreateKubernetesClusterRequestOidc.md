# openapi.model.CreateKubernetesClusterRequestOidc

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**issuerUrl** | **String** | The URL of the OIDC provider that issues authentication tokens. | 
**clientId** | **String** | The unique identifier assigned to your application by the OIDC provider. | 
**usernameClaim** | **String** | The claim in the OIDC token that identifies the end user's username. | [optional] 
**groupsClaim** | **String** | The claim in the OIDC token that contains the user's group memberships. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


