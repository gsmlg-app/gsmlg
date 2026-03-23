# openapi.model.RegistryRepositoryArtifact

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**artifactType** | **String** | The specific type or format of the artifact | [optional] 
**digest** | **String** | Cryptographic hash (SHA256) artifact reference | [optional] 
**manifestMediaType** | **String** | The artifact's manifest | [optional] 
**mediaType** | **String** | The media type (MIME type) of the artifact that specifies the format of the artifact itself | [optional] 
**pullTime** | **String** | Timestamp when the artifact was pulled | [optional] 
**pushTime** | **String** | Timestamp when the artifact was pushed | [optional] 
**repositoryName** | **String** | The repository the artifact is attached to | [optional] 
**size** | **int** | Size of the artifact it bytes | [optional] 
**type** | **String** | Represents the type of the artifact (\"IMAGE\", \"HELM\", \"CHART\", etc) | [optional] 
**tags** | **List<String>** | Tags associated with a specific artifact that represent the different versions of the artifact | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


