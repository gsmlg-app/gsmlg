# openapi.model.KafkaAdvancedOptions

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**compressionType** | **String** |  | [optional] 
**groupInitialRebalanceDelayMs** | **int** | Accepted values: 1 - 300000 | [optional] 
**groupMinSessionTimeoutMs** | **int** | Accepted values: 1 - 60000 | [optional] 
**groupMaxSessionTimeoutMs** | **int** | Accepted values: 1 - 1800000 | [optional] 
**connectionsMaxIdleMs** | **int** | Accepted values: 1000 - 3600000 | [optional] 
**maxIncrementalFetchSessionCacheSlots** | **int** | Accepted values: 1000 - 10000 | [optional] 
**messageMaxBytes** | **int** | Accepted values: 1 - 100001200 | [optional] 
**offsetsRetentionMinutes** | **int** | Accepted values: 1 - 2147483647 | [optional] 
**logCleanerDeleteRetentionMs** | **int** | Accepted values: 1 - 315569260000 | [optional] 
**logCleanerMinCleanableRatio** | **double** | Accepted values: 0.2 - 0.9 | [optional] 
**logCleanerMaxCompactionLagMs** | **int** | Accepted values: 30000 - 922337203685477600 | [optional] 
**logCleanerMinCompactionLagMs** | **int** | Accepted values: 1 - 922337203685477600 | [optional] 
**logCleanupPolicy** | **String** | The default cleanup policy for segments beyond the retention window. | [optional] [default to 'delete']
**logFlushIntervalMessages** | **int** | Accepted values: 1 - 922337203685477600 | [optional] 
**logFlushIntervalMs** | **int** | Accepted values: 1 - 922337203685477600 | [optional] 
**logIndexIntervalBytes** | **int** | Accepted values: 1 - 104857600 | [optional] 
**logIndexSizeMaxBytes** | **int** | Accepted values: 1048576 - 104857600 | [optional] 
**logLocalRetentionMs** | **int** | TIf set to -2, the value of `log_retention_ms` is used. Accepted values: =2 - 922337203685477600 | [optional] [default to -2]
**logLocalRetentionBytes** | **int** | If set to -2, the value of `log_retention_bytes` is used. Accepted values: -2 - 922337203685477600 | [optional] [default to -2]
**logMessageDownconversionEnable** | **bool** |  | [optional] 
**logMessageTimestampType** | **String** | Define whether the timestamp in the message is message create time or log append time. | [optional] [default to 'CreateTime']
**logMessageTimestampDifferenceMaxMs** | **int** | Accepted values: 1 - 922337203685477600 | [optional] 
**logPreallocate** | **bool** |  | [optional] 
**logRetentionBytes** | **int** | Accepted values: -1 - 922337203685477600 | [optional] 
**logRetentionHours** | **int** | Accepted values: -1 - 2147483647 | [optional] 
**logRetentionMs** | **int** | Accepted values: -1 - 922337203685477600 | [optional] 
**logRollJitterMs** | **int** | Accepted values: 1 - 922337203685477600 | [optional] 
**logRollMs** | **int** | Accepted values: 1 - 922337203685477600 | [optional] 
**logSegmentBytes** | **int** | Accepted values: 10485760 - 1073741824 | [optional] 
**logSegmentDeleteDelayMs** | **int** | Accepted values: 1 - 3600000 | [optional] 
**autoCreateTopicsEnable** | **bool** |  | [optional] 
**minInsyncReplicas** | **int** | Accepted values: 1 - 7 | [optional] 
**numPartitions** | **int** | Accepted values: 1 - 1000 | [optional] 
**defaultReplicationFactor** | **int** | Accepted values: 1 - 10 | [optional] 
**replicaFetchMaxBytes** | **int** | Accepted values: 1048576 - 104857600 | [optional] 
**replicaFetchResponseMaxBytes** | **int** | Accepted values: 10485760 - 1048576000 | [optional] 
**maxConnectionsPerIp** | **int** | Accepted values: 256 - 2147483647 | [optional] 
**producerPurgatoryPurgeIntervalRequests** | **int** | Accepted values: 10 - 10000 | [optional] 
**saslOauthbearerExpectedAudience** | **String** | The (optional) comma-delimited setting for the broker to use to verify that the JWT was issued for one of the expected audiences. | [optional] 
**saslOauthbearerExpectedIssuer** | **String** | Optional setting for the broker to use to verify that the JWT was created by the expected issuer. | [optional] 
**saslOauthbearerJwksEndpointUrl** | **String** | OIDC JWKS endpoint URL. By setting this the SASL SSL OAuth2/OIDC authentication is enabled. | [optional] 
**saslOauthbearerSubClaimName** | **String** | Name of the scope from which to extract the subject claim from the JWT. | [optional] 
**socketRequestMaxBytes** | **int** | Accepted values: 10485760 - 209715200 | [optional] 
**transactionStateLogSegmentBytes** | **int** | Accepted values: 1048576 - 2147483647 | [optional] 
**transactionRemoveExpiredTransactionCleanupIntervalMs** | **int** | Accepted values: 600000 - 3600000 | [optional] 
**transactionPartitionVerificationEnable** | **bool** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


