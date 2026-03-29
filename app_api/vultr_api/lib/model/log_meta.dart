//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LogMeta {
  /// Returns a new [LogMeta] instance.
  LogMeta({
    required this.nextPageUrl,
    required this.continueTime,
    required this.returnedCount,
    required this.unreturnedCount,
    required this.totalCount,
  });

  /// In the event that there are more logs found for a specified time period than can be returned, this field will contain a URL that can be used to request the next block of logs for the time period.  The new request is inclusive of the timestamp for the last logs from the previous request. This is done to avoid skipping over any logs that may have the same timestamp as the last log in the previous request, but which may not have been included in that response.  **Be aware that because of this there will be boundary duplicates between this new request and the previous one.**
  String nextPageUrl;

  /// In the event that there are more logs found for a specified time period that can be returned, this field will be set with a UTC timestamp of where the logs were left off.
  String continueTime;

  /// The number of log records that were returned. There is a maximum limit of 5,000 logs returned by any request.
  int returnedCount;

  /// The number of log records from the specified time period that were not returned due to the maximum return limit of 5,000 logs.
  int unreturnedCount;

  /// The total number of records that were found for the specified time period.
  int totalCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogMeta &&
          other.nextPageUrl == nextPageUrl &&
          other.continueTime == continueTime &&
          other.returnedCount == returnedCount &&
          other.unreturnedCount == unreturnedCount &&
          other.totalCount == totalCount;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (nextPageUrl.hashCode) +
      (continueTime.hashCode) +
      (returnedCount.hashCode) +
      (unreturnedCount.hashCode) +
      (totalCount.hashCode);

  @override
  String toString() =>
      'LogMeta[nextPageUrl=$nextPageUrl, continueTime=$continueTime, returnedCount=$returnedCount, unreturnedCount=$unreturnedCount, totalCount=$totalCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'next_page_url'] = this.nextPageUrl;
    json[r'continue_time'] = this.continueTime;
    json[r'returned_count'] = this.returnedCount;
    json[r'unreturned_count'] = this.unreturnedCount;
    json[r'total_count'] = this.totalCount;
    return json;
  }

  /// Returns a new [LogMeta] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LogMeta? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "LogMeta[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "LogMeta[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LogMeta(
        nextPageUrl: mapValueOfType<String>(json, r'next_page_url')!,
        continueTime: mapValueOfType<String>(json, r'continue_time')!,
        returnedCount: mapValueOfType<int>(json, r'returned_count')!,
        unreturnedCount: mapValueOfType<int>(json, r'unreturned_count')!,
        totalCount: mapValueOfType<int>(json, r'total_count')!,
      );
    }
    return null;
  }

  static List<LogMeta> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <LogMeta>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LogMeta.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LogMeta> mapFromJson(dynamic json) {
    final map = <String, LogMeta>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LogMeta.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LogMeta-objects as value to a dart map
  static Map<String, List<LogMeta>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<LogMeta>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LogMeta.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'next_page_url',
    'continue_time',
    'returned_count',
    'unreturned_count',
    'total_count',
  };
}
