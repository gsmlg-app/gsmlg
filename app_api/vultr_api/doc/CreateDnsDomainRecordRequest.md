# openapi.model.CreateDnsDomainRecordRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | The hostname for this DNS record. | 
**type** | **String** | The DNS record type.  * A * AAAA * CNAME * NS * MX * SRV * TXT * CAA * SSHFP | 
**data** | **String** | The DNS data for this record type. | 
**ttl** | **int** | Time to Live in seconds. | [optional] 
**priority** | **int** | DNS priority. Does not apply to all record types. (Only required for MX and SRV) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


