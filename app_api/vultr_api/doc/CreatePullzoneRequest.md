# openapi.model.CreatePullzoneRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**label** | **String** | The user-supplied label. | 
**originScheme** | **String** | The URI scheme of the origin domain. | 
**originDomain** | **String** | The domain name from which the content stored in the CDN will be pulled. | 
**vanityDomain** | **String** | An optional domain name that can be used to access the cached files in adition to the domain that is automaticaly created.  This vanity domain will need to have a CNAME DNS record created to point it at the standard CDN domain that is automaticaly generated on creation of the CDN. | [optional] 
**sslCert** | **String** | Base 64 encoded file content for an ssl/tls certificate associated with the optional vanity_domain.  This field is required if a vanity domain is provided and the origin_scheme is https. | [optional] 
**sslCertKey** | **String** | Base 64 encoded file content for the private key associated with the ssl_cert.  This field is required if a vanity domain is provided and the origin_scheme is https. | [optional] 
**cors** | **bool** | Enable Cross-origin resource sharing.  CORS is a content validation mechanism used by web browsers to validate file access permissions. The Vultr CDN CORS policy protects your static assets from hotlinking threats by only accepting requests associated with your Origin URL. | [optional] 
**gzip** | **bool** | Enable Gzip compression to reduce the static content size to speed up the delivery process. | [optional] 
**blockAi** | **bool** | Block AI bots. | [optional] 
**blockBadBots** | **bool** | Block potentially malicious bots. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


