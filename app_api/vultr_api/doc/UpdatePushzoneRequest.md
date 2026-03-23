# openapi.model.UpdatePushzoneRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**label** | **String** | The user-supplied label. | [optional] 
**vanityDomain** | **String** | An optional domain name that can be used to access the cached files in adition to the domain that is automaticaly created.  This vanity domain will need to have a CNAME DNS record created to point it at the standard CDN domain that is automaticaly generated on creation of the CDN. | [optional] 
**sslCert** | **String** | Base 64 encoded file content for an ssl/tls certificate associated with the optional vanity_domain.  This field is required if a vanity domain is provided. | [optional] 
**sslCertKey** | **String** | Base 64 encoded file content for the private key associated with the ssl_cert.  This field is required if a vanity domain is provided. | [optional] 
**cors** | **bool** | Cross-origin resource sharing. | [optional] 
**gzip** | **bool** | Optional feature to compress files, reduce the amount of data that's transferred. | [optional] 
**blockAi** | **bool** | Optional feature to block AI bots. | [optional] 
**blockBadBots** | **bool** | Optional feature to block potentially malicious bots. | [optional] 
**regions** | **List<String>** | a list of [Region ids](#operation/list-regions) for locations to be used for content delivery. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


