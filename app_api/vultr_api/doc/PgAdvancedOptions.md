# openapi.model.PgAdvancedOptions

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**autovacuumAnalyzeScaleFactor** | **double** | Accepted values: 0 - 1 | [optional] 
**autovacuumAnalyzeThreshold** | **int** | Accepted values: 0 - 2147483647 | [optional] 
**autovacuumFreezeMaxAge** | **int** | Accepted values: 200000000 - 1500000000 | [optional] 
**autovacuumMaxWorkers** | **int** | Accepted values: 1 - 20 | [optional] 
**autovacuumNaptime** | **int** | Accepted values: 1 - 86400 | [optional] 
**autovacuumVacuumCostDelay** | **int** | Accepted values: -1 - 100 | [optional] 
**autovacuumVacuumCostLimit** | **int** | Accepted values: -1 - 10000 | [optional] 
**autovacuumVacuumScaleFactor** | **double** | Accepted values: 0 - 1 | [optional] 
**autovacuumVacuumThreshold** | **int** | Accepted values: 0 - 2147483647 | [optional] 
**bgwriterDelay** | **int** | Accepted values: 10 - 10000 | [optional] 
**bgwriterFlushAfter** | **int** | Accepted values: 0 - 2048 | [optional] 
**bgwriterLruMaxpages** | **int** | Accepted values: 0 - 1073741823 | [optional] 
**bgwriterLruMultiplier** | **double** | Accepted values: 0 - 10 | [optional] 
**deadlockTimeout** | **int** | Accepted values: 500 - 1800000 | [optional] 
**defaultToastCompression** | **String** |  | [optional] 
**idleInTransactionSessionTimeout** | **int** | Accepted values: 0 - 604800000 | [optional] 
**jit** | **bool** |  | [optional] 
**logAutovacuumMinDuration** | **int** | Accepted values: -1 - 2147483647 | [optional] 
**logErrorVerbosity** | **String** |  | [optional] 
**logLinePrefix** | **String** |  | [optional] 
**logMinDurationStatement** | **int** | Accepted values: -1 - 86400000 | [optional] 
**maxFilesPerProcess** | **int** | Accepted values: 1000 - 4096 | [optional] 
**maxLocksPerTransaction** | **int** | Accepted values: 64 - 6400 | [optional] 
**maxLogicalReplicationWorkers** | **int** | Accepted values: 4 - 64 | [optional] 
**maxParallelWorkers** | **int** | Accepted values: 0 - 96 | [optional] 
**maxParallelWorkersPerGather** | **int** | Accepted values: 0 - 96 | [optional] 
**maxPredLocksPerTransaction** | **int** | Accepted values: 64 - 5120 | [optional] 
**maxPreparedTransactions** | **int** | Accepted values: 0 - 10000 | [optional] 
**maxReplicationSlots** | **int** | Accepted values: 8 - 64 | [optional] 
**maxStackDepth** | **int** | Accepted values: 2097152 - 6291456 | [optional] 
**maxStandbyArchiveDelay** | **int** | Accepted values: 1 - 43200000 | [optional] 
**maxStandbyStreamingDelay** | **int** | Accepted values: 1 - 43200000 | [optional] 
**maxWalSenders** | **int** | Accepted values: 20 - 64 | [optional] 
**maxWorkerProcesses** | **int** | Accepted values: 8 - 96 | [optional] 
**pgPartmanBgwPeriodInterval** | **int** | Accepted values: 3600 - 604800 | [optional] 
**pgPartmanBgwPeriodRole** | **String** | Maximum length: 64 characters | [optional] 
**pgStatStatementsPeriodTrack** | **String** |  | [optional] 
**tempFileLimit** | **int** | Accepted values: -1 - 2147483647 | [optional] 
**trackActivityQuerySize** | **int** | Accepted values: 1024 - 10240 | [optional] 
**trackCommitTimestamp** | **String** |  | [optional] 
**trackFunctions** | **String** |  | [optional] 
**trackIoTiming** | **String** |  | [optional] 
**walSenderTimeout** | **int** | Accepted values: 0, 5000 - 10800000 | [optional] 
**walWriterDelay** | **int** | Accepted values: 10 - 200 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


