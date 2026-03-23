# openapi.model.KafkaRestAdvancedOptions

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**producerAcks** | **String** | The number of acknowledgments the producer requires the leader to have received before considering a request complete. If set to `all` or `-1`, the leader will wait for the full set of in-sync replicas to acknowledge the record. | [optional] 
**producerCompressionType** | **String** |  | [optional] 
**producerLingerMs** | **int** | Accepted values: 1 - 5000 | [optional] 
**producerMaxRequestSize** | **int** | Accepted values: 1 - 2147483647 | [optional] 
**consumerEnableAutoCommit** | **bool** |  | [optional] 
**consumerRequestMaxBytes** | **int** | Accepted values: 1 - 671088640 | [optional] 
**consumerRequestTimeoutMs** | **int** | Accepted values: 1000 - 30000 | [optional] 
**nameStrategy** | **String** | Name strategy to use when selecting subject for storing schemas. | [optional] 
**nameStrategyValidation** | **bool** |  | [optional] 
**simpleconsumerPoolSizeMax** | **int** | Accepted values: 10 - 250 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


