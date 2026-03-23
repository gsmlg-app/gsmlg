# openapi.model.Pushzone

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the CDN Push Zone. | [optional] 
**dateCreated** | **String** | The date this CDN Push Zone was created. | [optional] 
**status** | **String** | The current status.  * active * pending | [optional] 
**label** | **String** | The user-supplied label. | [optional] 
**cdnUrl** | **String** | The Vultr CDN endpoint to access your cached files. | [optional] 
**vanityDomain** | **String** | A custom domain provided by the user which can be used to access the cached files. | [optional] 
**cacheSize** | **num** | How much data may be cached on each CDN node. | [optional] 
**requests** | **num** | The amount of requests to limit to the CDN. | [optional] 
**inBytes** | **num** | The amount of inbound bytes allowed to the CDN. | [optional] 
**outBytes** | **num** | The amount of outbound bytes allowed from the CDN. | [optional] 
**packetsPerSec** | **num** | Per CDN rate limiting per requests/sec. | [optional] 
**cors** | **bool** | Cross-origin resource sharing. | [optional] 
**gzip** | **bool** | Optional feature to compress files, reduce the amount of data that's transferred. | [optional] 
**blockAi** | **bool** | Optional feature to block AI bots. | [optional] 
**blockBadBots** | **bool** | Optional feature to block potentially malicious bots. | [optional] 
**regions** | **List<String>** | A list of [Region ids](#operation/list-regions) for locations to be used for content delivery. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


