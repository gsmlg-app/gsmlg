# openapi.model.DnsRecord

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the DNS Record. | [optional] 
**type** | **String** | The DNS record type.  * A * AAAA * CNAME * NS * MX * SRV * TXT * CAA * SSHFP | [optional] 
**name** | **String** | The hostname for this DNS record. | [optional] 
**data** | **String** | The DNS data for this record type. | [optional] 
**priority** | **int** | DNS priority. Does not apply to all record types. | [optional] 
**ttl** | **int** | Time to Live in seconds. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


