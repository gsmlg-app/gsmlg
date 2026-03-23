# openapi.model.UpdateLoadBalancerRequestHealthCheck

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**protocol** | **String** | The protocol to use for health checks.  * HTTPS * HTTP * TCP | [optional] 
**port** | **int** | The port to use for health checks. | [optional] 
**path** | **String** | HTTP Path to check. Only applies if protocol is HTTP, or HTTPS. | [optional] 
**checkInterval** | **String** | Interval between health checks. | [optional] 
**responseTimeout** | **String** | Timeout before health check fails. | [optional] 
**unhealthyThreshold** | **String** | Number times a check must fail before becoming unhealthy. | [optional] 
**healthyThreshold** | **String** | Number of times a check must succeed before returning to healthy status. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


