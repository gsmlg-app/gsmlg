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

// tests for LogMeta
void main() {
  // final instance = LogMeta();

  group('test LogMeta', () {
    // In the event that there are more logs found for a specified time period than can be returned, this field will contain a URL that can be used to request the next block of logs for the time period.  The new request is inclusive of the timestamp for the last logs from the previous request. This is done to avoid skipping over any logs that may have the same timestamp as the last log in the previous request, but which may not have been included in that response.  **Be aware that because of this there will be boundary duplicates between this new request and the previous one.** 
    // String nextPageUrl
    test('to test the property `nextPageUrl`', () async {
      // TODO
    });

    // In the event that there are more logs found for a specified time period that can be returned, this field will be set with a UTC timestamp of where the logs were left off. 
    // String continueTime
    test('to test the property `continueTime`', () async {
      // TODO
    });

    // The number of log records that were returned. There is a maximum limit of 5,000 logs returned by any request.
    // int returnedCount
    test('to test the property `returnedCount`', () async {
      // TODO
    });

    // The number of log records from the specified time period that were not returned due to the maximum return limit of 5,000 logs.
    // int unreturnedCount
    test('to test the property `unreturnedCount`', () async {
      // TODO
    });

    // The total number of records that were found for the specified time period.
    // int totalCount
    test('to test the property `totalCount`', () async {
      // TODO
    });


  });

}
