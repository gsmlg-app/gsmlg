//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:vultr_api/api.dart';
import 'package:test/test.dart';

// tests for Database
void main() {
  // final instance = Database();

  group('test Database', () {
    // A unique ID for the Managed Database.
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // The date this database was created.
    // String dateCreated
    test('to test the property `dateCreated`', () async {
      // TODO
    });

    // The name of the Managed Database plan.
    // String plan
    test('to test the property `plan`', () async {
      // TODO
    });

    // The size of the disk in GB (excluded for Valkey engine types).
    // int planDisk
    test('to test the property `planDisk`', () async {
      // TODO
    });

    // The amount of RAM in MB.
    // int planRam
    test('to test the property `planRam`', () async {
      // TODO
    });

    // Number of vCPUs.
    // int planVcpus
    test('to test the property `planVcpus`', () async {
      // TODO
    });

    // Number of replica nodes (excluded for Kafka engine types).
    // int planReplicas
    test('to test the property `planReplicas`', () async {
      // TODO
    });

    // Number of brokers (Kafka engine types only).
    // int planBrokers
    test('to test the property `planBrokers`', () async {
      // TODO
    });

    // The [Region id](#operation/list-regions) where the Managed Database is located.
    // String region
    test('to test the property `region`', () async {
      // TODO
    });

    // The database engine type (MySQL, PostgreSQL, Valkey, Kafka).
    // String databaseEngine
    test('to test the property `databaseEngine`', () async {
      // TODO
    });

    // The version number of the database engine in use.
    // String databaseEngineVersion
    test('to test the property `databaseEngineVersion`', () async {
      // TODO
    });

    // The ID of the [VPC Network](#operation/get-vpc) attached to the Managed Database.
    // String vpcId
    test('to test the property `vpcId`', () async {
      // TODO
    });

    // The current status.  * Rebuilding * Rebalancing * Running
    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // The user-supplied label for this managed database.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // The user-supplied tag for this managed database.
    // String tag
    test('to test the property `tag`', () async {
      // TODO
    });

    // The default database name.
    // String dbname
    test('to test the property `dbname`', () async {
      // TODO
    });

    // The public hostname for database connections, or private hostname if this managed database is attached to a VPC network.
    // String host
    test('to test the property `host`', () async {
      // TODO
    });

    // The public hostname for database connections. Only visible when the managed database is attached to a VPC network.
    // String publicHost
    test('to test the property `publicHost`', () async {
      // TODO
    });

    // The default user configured on creation.
    // String user
    test('to test the property `user`', () async {
      // TODO
    });

    // The default user's secure password generated on creation.
    // String password
    test('to test the property `password`', () async {
      // TODO
    });

    // The private key to authenticate the default user (Kafka engine types only).
    // String accessKey
    test('to test the property `accessKey`', () async {
      // TODO
    });

    // The certificate to authenticate the default user (Kafka engine types only).
    // String accessCert
    test('to test the property `accessCert`', () async {
      // TODO
    });

    // The assigned port for connecting to the Managed Database.
    // String port
    test('to test the property `port`', () async {
      // TODO
    });

    // The port for connecting to the Managed Database via SASL (Kafka engine types only).
    // String saslPort
    test('to test the property `saslPort`', () async {
      // TODO
    });

    // Configuration value for Kafka REST support on the Managed Database (Kafka engine types only on business plans or higher).
    // bool enableKafkaRest
    test('to test the property `enableKafkaRest`', () async {
      // TODO
    });

    // The URI to access the RESTful interface of your Kafka cluster if Kafka REST is enabled. For more information on how to interact with your cluster's RESTful interface, please refer to the [Confluent REST Proxy API v2 documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html#rest-proxy-v2).
    // bool kafkaRestUri
    test('to test the property `kafkaRestUri`', () async {
      // TODO
    });

    // Configuration value for Schema Registry support on the Managed Database (Kafka engine types only on business plans or higher).
    // bool enableSchemaRegistry
    test('to test the property `enableSchemaRegistry`', () async {
      // TODO
    });

    // The URI to access the Schema Registry service of your Kafka cluster if Schema Registry is enabled. For more information on how to interact with your cluster's Schema Registry, please refer to the [Confluent Schema Registry API Reference](https://docs.confluent.io/platform/current/schema-registry/develop/api.html).
    // bool schemaRegistryUri
    test('to test the property `schemaRegistryUri`', () async {
      // TODO
    });

    // Configuration value for Kafka Connect support on the Managed Database (Kafka engine types only on business plans or higher).
    // bool enableKafkaConnect
    test('to test the property `enableKafkaConnect`', () async {
      // TODO
    });

    // The chosen date of week for routine maintenance updates.
    // String maintenanceDow
    test('to test the property `maintenanceDow`', () async {
      // TODO
    });

    // The chosen hour for routine maintenance updates.
    // String maintenanceTime
    test('to test the property `maintenanceTime`', () async {
      // TODO
    });

    // The chosen hour for daily backups to take place. Excluded for Kafka engine types.
    // String backupHour
    test('to test the property `backupHour`', () async {
      // TODO
    });

    // The chosen minute of the backup hour for daily backups to take place. Excluded for Kafka engine types.
    // String backupMinute
    test('to test the property `backupMinute`', () async {
      // TODO
    });

    // The date for the latest backup stored on the Managed Database.
    // String latestBackup
    test('to test the property `latestBackup`', () async {
      // TODO
    });

    // A list of trusted IP addresses for connecting to this Managed Database (in CIDR notation).
    // List<String> trustedIps (default value: const [])
    test('to test the property `trustedIps`', () async {
      // TODO
    });

    // The CA certificate for Managed Databases on this account.
    // String caCertificate
    test('to test the property `caCertificate`', () async {
      // TODO
    });

    // A list names of enabled SQL Modes (MySQL engine types only).
    // List<String> mysqlSqlModes (default value: const [])
    test('to test the property `mysqlSqlModes`', () async {
      // TODO
    });

    // Configuration value for requiring table primary keys (MySQL engine types only).
    // bool mysqlRequirePrimaryKey
    test('to test the property `mysqlRequirePrimaryKey`', () async {
      // TODO
    });

    // Configuration value for slow query logging on the Managed Database (MySQL engine types only).
    // bool mysqlSlowQueryLog
    test('to test the property `mysqlSlowQueryLog`', () async {
      // TODO
    });

    // The number of seconds to denote a slow query when logging is enabled (MySQL engine types only).
    // int mysqlLongQueryTime
    test('to test the property `mysqlLongQueryTime`', () async {
      // TODO
    });

    // A list of objects containing names and versions (when applicable) of available extensions for PostgreSQL engine types only.
    // List<Object> pgAvailableExtensions (default value: const [])
    test('to test the property `pgAvailableExtensions`', () async {
      // TODO
    });

    // The current configured data eviction policy for Redis engine types only.
    // String redisEvictionPolicy
    test('to test the property `redisEvictionPolicy`', () async {
      // TODO
    });

    // The current configured data eviction policy for Valkey engine types only.
    // String evictionPolicy
    test('to test the property `evictionPolicy`', () async {
      // TODO
    });

    // The configured time zone of the Managed Database in TZ database format.
    // String clusterTimeZone
    test('to test the property `clusterTimeZone`', () async {
      // TODO
    });

    // A list of database objects containing details for all attached read-only replica nodes.
    // List<Object> readReplicas (default value: const [])
    test('to test the property `readReplicas`', () async {
      // TODO
    });


  });

}
