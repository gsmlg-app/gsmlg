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

// tests for DbaasAlerts
void main() {
  // final instance = DbaasAlerts();

  group('test DbaasAlerts', () {
    // The date and time in which the alert was sent.
    // String timestamp
    test('to test the property `timestamp`', () async {
      // TODO
    });

    // The category of alert that was sent. * `DB MASTER PROMOTION` * `MAINTENANCE SCHEDULED` * `MISSING MYSQL PRIMARY KEYS` * `RESOURCE USAGE DISK` * `RESOURCE USAGE OOM KILLED` * `RESOURCE USAGE PG REPLICATION SLOTS`
    // String messageType
    test('to test the property `messageType`', () async {
      // TODO
    });

    // A verbose description of the associated alert category.
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // A description of the recommended action the customer should take. Only included for certain alert types.
    // String recommendation
    test('to test the property `recommendation`', () async {
      // TODO
    });

    // The time in which mandatory maintenance has been scheduled with the associated alert. Only included for certain alert types.
    // String maintenanceScheduled
    test('to test the property `maintenanceScheduled`', () async {
      // TODO
    });

    // The affected resource related to the associated alert. Only included for certain alert types.
    // String resourceType
    test('to test the property `resourceType`', () async {
      // TODO
    });

    // The number of affected tables related to the associated alert. Only included for certain alert types.
    // int tableCount
    test('to test the property `tableCount`', () async {
      // TODO
    });


  });

}
