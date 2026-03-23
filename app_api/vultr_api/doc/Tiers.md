# openapi.model.Tiers

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** | Object Storage Tier ID. | [optional] 
**bwGbPrice** | **double** | Price per additional gigabyte of bandwidth. | [optional] 
**diskGbPrice** | **double** | Price per additional gigabyte of capacity. | [optional] 
**isDefault** | **String** | Is this tier the default? | [optional] 
**price** | **double** | Monthly price for this tier. | [optional] 
**ratelimitOpsBytes** | **int** | Rate limit on the number of bytes per second. | [optional] 
**ratelimitOpsSecs** | **int** | Rate limit on the number of operations per second. | [optional] 
**salesDesc** | **String** | Sales description. | [optional] 
**salesName** | **String** | Sales name. | [optional] 
**slug** | **String** | Slug, unique name. | [optional] 
**locations** | [**List<TiersLocationsInner>**](TiersLocationsInner.md) | Clusters where the tier is available. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


