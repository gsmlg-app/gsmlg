# openapi.model.Database

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the Managed Database. | [optional] 
**dateCreated** | **String** | The date this database was created. | [optional] 
**plan** | **String** | The name of the Managed Database plan. | [optional] 
**planDisk** | **int** | The size of the disk in GB (excluded for Valkey engine types). | [optional] 
**planRam** | **int** | The amount of RAM in MB. | [optional] 
**planVcpus** | **int** | Number of vCPUs. | [optional] 
**planReplicas** | **int** | Number of replica nodes (excluded for Kafka engine types). | [optional] 
**planBrokers** | **int** | Number of brokers (Kafka engine types only). | [optional] 
**region** | **String** | The [Region id](#operation/list-regions) where the Managed Database is located. | [optional] 
**databaseEngine** | **String** | The database engine type (MySQL, PostgreSQL, Valkey, Kafka). | [optional] 
**databaseEngineVersion** | **String** | The version number of the database engine in use. | [optional] 
**vpcId** | **String** | The ID of the [VPC Network](#operation/get-vpc) attached to the Managed Database. | [optional] 
**status** | **String** | The current status.  * Rebuilding * Rebalancing * Running | [optional] 
**label** | **String** | The user-supplied label for this managed database. | [optional] 
**tag** | **String** | The user-supplied tag for this managed database. | [optional] 
**dbname** | **String** | The default database name. | [optional] 
**host** | **String** | The public hostname for database connections, or private hostname if this managed database is attached to a VPC network. | [optional] 
**publicHost** | **String** | The public hostname for database connections. Only visible when the managed database is attached to a VPC network. | [optional] 
**user** | **String** | The default user configured on creation. | [optional] 
**password** | **String** | The default user's secure password generated on creation. | [optional] 
**accessKey** | **String** | The private key to authenticate the default user (Kafka engine types only). | [optional] 
**accessCert** | **String** | The certificate to authenticate the default user (Kafka engine types only). | [optional] 
**port** | **String** | The assigned port for connecting to the Managed Database. | [optional] 
**saslPort** | **String** | The port for connecting to the Managed Database via SASL (Kafka engine types only). | [optional] 
**enableKafkaRest** | **bool** | Configuration value for Kafka REST support on the Managed Database (Kafka engine types only on business plans or higher). | [optional] 
**kafkaRestUri** | **bool** | The URI to access the RESTful interface of your Kafka cluster if Kafka REST is enabled. For more information on how to interact with your cluster's RESTful interface, please refer to the [Confluent REST Proxy API v2 documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html#rest-proxy-v2). | [optional] 
**enableSchemaRegistry** | **bool** | Configuration value for Schema Registry support on the Managed Database (Kafka engine types only on business plans or higher). | [optional] 
**schemaRegistryUri** | **bool** | The URI to access the Schema Registry service of your Kafka cluster if Schema Registry is enabled. For more information on how to interact with your cluster's Schema Registry, please refer to the [Confluent Schema Registry API Reference](https://docs.confluent.io/platform/current/schema-registry/develop/api.html). | [optional] 
**enableKafkaConnect** | **bool** | Configuration value for Kafka Connect support on the Managed Database (Kafka engine types only on business plans or higher). | [optional] 
**maintenanceDow** | **String** | The chosen date of week for routine maintenance updates. | [optional] 
**maintenanceTime** | **String** | The chosen hour for routine maintenance updates. | [optional] 
**backupHour** | **String** | The chosen hour for daily backups to take place. Excluded for Kafka engine types. | [optional] 
**backupMinute** | **String** | The chosen minute of the backup hour for daily backups to take place. Excluded for Kafka engine types. | [optional] 
**latestBackup** | **String** | The date for the latest backup stored on the Managed Database. | [optional] 
**trustedIps** | **List<String>** | A list of trusted IP addresses for connecting to this Managed Database (in CIDR notation). | [optional] [default to const []]
**caCertificate** | **String** | The CA certificate for Managed Databases on this account. | [optional] 
**mysqlSqlModes** | **List<String>** | A list names of enabled SQL Modes (MySQL engine types only). | [optional] [default to const []]
**mysqlRequirePrimaryKey** | **bool** | Configuration value for requiring table primary keys (MySQL engine types only). | [optional] 
**mysqlSlowQueryLog** | **bool** | Configuration value for slow query logging on the Managed Database (MySQL engine types only). | [optional] 
**mysqlLongQueryTime** | **int** | The number of seconds to denote a slow query when logging is enabled (MySQL engine types only). | [optional] 
**pgAvailableExtensions** | [**List<Object>**](Object.md) | A list of objects containing names and versions (when applicable) of available extensions for PostgreSQL engine types only. | [optional] [default to const []]
**redisEvictionPolicy** | **String** | The current configured data eviction policy for Redis engine types only. | [optional] 
**evictionPolicy** | **String** | The current configured data eviction policy for Valkey engine types only. | [optional] 
**clusterTimeZone** | **String** | The configured time zone of the Managed Database in TZ database format. | [optional] 
**readReplicas** | [**List<Object>**](Object.md) | A list of database objects containing details for all attached read-only replica nodes. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


