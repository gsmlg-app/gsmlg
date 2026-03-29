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

// tests for BackupSchedule
void main() {
  // final instance = BackupSchedule();

  group('test BackupSchedule', () {
    // Indicates if backup is enabled:  * true * false
    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // Type of backup schedule:  |   | Value | Description | | - | ------ | ------------- | |   | daily | Back up once per day at `hour`. | |   | weekly | Back up once per week on `dow` at `hour`. | |   | monthly | Back up each month at `dom` at `hour`. | |   | daily\\_alt\\_even | Back up on even dates at `hour`. | |   | daily\\_alt\\_odd | Back up on odd dates at `hour`. |
    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // Time of next backup run in UTC.
    // String nextScheduledTimeUtc
    test('to test the property `nextScheduledTimeUtc`', () async {
      // TODO
    });

    // Scheduled hour of day in UTC.
    // int hour
    test('to test the property `hour`', () async {
      // TODO
    });

    // Day of week to run.  |   | Value | Description | | - | ------ | ------------- | |   | 1 | Sunday | |   | 2 | Monday | |   | 3 | Tuesday | |   | 4 | Wednesday | |   | 5 | Thursday | |   | 6 | Friday | |   | 7 | Saturday |
    // int dow
    test('to test the property `dow`', () async {
      // TODO
    });

    // Day of month to run. Use values between 1 and 28.
    // int dom
    test('to test the property `dom`', () async {
      // TODO
    });
  });
}
