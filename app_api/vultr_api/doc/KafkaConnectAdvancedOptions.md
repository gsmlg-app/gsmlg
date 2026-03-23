# openapi.model.KafkaConnectAdvancedOptions

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**connectorClientConfigOverridePolicy** | **String** | Defines what client configurations can be overridden by the connector. Default is None. | [optional] 
**consumerAutoOffsetReset** | **String** | What to do when there is no initial offset in Kafka or if the current offset does not exist any more on the server. Default is earliest. | [optional] 
**consumerFetchMaxBytes** | **int** | Accepted values: 1048576 - 104857600 | [optional] 
**consumerIsolationLevel** | **String** | Transaction read isolation level. `read_uncommitted` is the default, but `read_committed` can be used if consume-exactly-once behavior is desired. | [optional] 
**consumerMaxPartitionFetchBytes** | **int** | Accepted values: 1048576 - 104857600 | [optional] 
**consumerMaxPollIntervalMs** | **int** | Accepted values: 1 - 2147483647 | [optional] 
**consumerMaxPollRecords** | **int** | Accepted values: 1 - 10000 | [optional] 
**offsetFlushIntervalMs** | **int** | Accepted values: 1 - 100000000 | [optional] 
**offsetFlushTimeoutMs** | **int** | Accepted values: 1 - 2147483647 | [optional] 
**producerBatchSize** | **int** | Accepted values: 1 - 5242880 | [optional] 
**producerBufferMemory** | **int** | Accepted values: 5242880 - 134217728 | [optional] 
**producerCompressionType** | **String** |  | [optional] 
**producerLingerMs** | **int** | Accepted values: 1 - 5000 | [optional] 
**producerMaxRequestSize** | **int** | Accepted values: 131072 - 67108864 | [optional] 
**scheduledRebalanceMaxDelayMs** | **int** | Accepted values: 1 - 600000 | [optional] 
**sessionTimeoutMs** | **int** | Accepted values: 1 - 2147483647 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


