# openapi.model.MysqlAdvancedOptions

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**connectTimeout** | **int** | Accepted values: 2 - 3600 | [optional] 
**groupConcatMaxLen** | **int** | Accepted values: 4 - 18446744073709552000 | [optional] 
**innodbChangeBufferMaxSize** | **int** | Accepted values: 0 - 50 | [optional] 
**innodbFlushNeighbors** | **int** | Accepted values: 0 - 2 (0: dirty pages in the same extent are not flushed, 1: flush contiguous dirty pages in the same extent [default], 2: flush dirty pages in the same extent) | [optional] 
**innodbFtMinTokenSize** | **int** | Accepted values: 0 - 16 | [optional] 
**innodbFtServerStopwordTable** | **String** | This option is used to specify your own InnoDB FULLTEXT index stopword list for all tables. | [optional] 
**innodbLockWaitTimeout** | **int** | Accepted values: 1 - 3600 | [optional] 
**innodbLogBufferSize** | **int** | Accepted values: 1048576 - 4294967295 | [optional] 
**innodbOnlineAlterLogMaxSize** | **int** | Accepted values: 65536 - 1099511627776 | [optional] 
**innodbPrintAllDeadlocks** | **bool** |  | [optional] 
**innodbReadIoThreads** | **int** | Accepted values: 1 - 64 | [optional] 
**innodbRollbackOnTimeout** | **bool** |  | [optional] 
**innodbThreadConcurrency** | **int** | Accepted values: 0 - 1000 | [optional] 
**innodbWriteIoThreads** | **int** | Accepted values: 1 - 64 | [optional] 
**internalTmpMemStorageEngine** | **String** |  | [optional] 
**netBufferLength** | **int** | Accepted values: 1024 - 1048576 | [optional] 
**netReadTimeout** | **int** | Accepted values: 1 - 3600 | [optional] 
**netWriteTimeout** | **int** | Accepted values: 1 - 3600 | [optional] 
**waitTimeout** | **int** | Accepted values: 1 - 2147483 | [optional] 
**maxAllowedPacket** | **int** | Accepted values: 102400 - 1073741824 | [optional] 
**maxHeapTableSize** | **int** | Accepted values: 1048576 - 1073741824 | [optional] 
**sortBufferSize** | **int** | Accepted values: 32768 - 1073741824 | [optional] 
**tmpTableSize** | **int** | Accepted values: 1048576 - 1073741824 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


