//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class LogsApi {
  LogsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// List Logs
  ///
  /// List the Logs for your account.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] startTime:
  ///   A UTC timestamp for the start of the time period from which to return logs. `start_time` is an inclusive endpoint. Logs with a timestamp equal to, or after `start_time` are included in the response<br> <span style=\"color: red\">This field is required if the end_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *start_time must be after to the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no start_time is provided a time 30 days and 1 hour prior to the end_time will be used by default* 
  ///
  /// * [String] endTime:
  ///   A UTC timestamp for the end of the time period from which to return logs. `end_time` is an exclusive endpoint.  Only logs with a timestamp before the `end_time` are included in the response. <br> <span style=\"color: red\">This field is required if the start_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *end_time must be before the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no end_time is provided the current time will be used  by default*
  ///
  /// * [String] logLevel:
  ///   Filter the logs by the level assigned to the log. * `info` * `debug` * `warning` * `error` * `critical`
  ///
  /// * [String] resourceType:
  ///   Filter the logs by the type of a resource such as an instances, bare-metals, kubernetes, etc.<br> *resource_type must be an exact match to the value of the resource type set in the log.* 
  ///
  /// * [String] resourceId:
  ///   Filter the logs by the UUID of a specific resource such as an instance.
  Future<Response> listLogsWithHttpInfo({ String? startTime, String? endTime, String? logLevel, String? resourceType, String? resourceId, }) async {
    // ignore: prefer_const_declarations
    final path = r'/logs';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (startTime != null) {
      queryParams.addAll(_queryParams('', 'start_time', startTime));
    }
    if (endTime != null) {
      queryParams.addAll(_queryParams('', 'end_time', endTime));
    }
    if (logLevel != null) {
      queryParams.addAll(_queryParams('', 'log_level', logLevel));
    }
    if (resourceType != null) {
      queryParams.addAll(_queryParams('', 'resource_type', resourceType));
    }
    if (resourceId != null) {
      queryParams.addAll(_queryParams('', 'resource_id', resourceId));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// List Logs
  ///
  /// List the Logs for your account.
  ///
  /// Parameters:
  ///
  /// * [String] startTime:
  ///   A UTC timestamp for the start of the time period from which to return logs. `start_time` is an inclusive endpoint. Logs with a timestamp equal to, or after `start_time` are included in the response<br> <span style=\"color: red\">This field is required if the end_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *start_time must be after to the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no start_time is provided a time 30 days and 1 hour prior to the end_time will be used by default* 
  ///
  /// * [String] endTime:
  ///   A UTC timestamp for the end of the time period from which to return logs. `end_time` is an exclusive endpoint.  Only logs with a timestamp before the `end_time` are included in the response. <br> <span style=\"color: red\">This field is required if the start_time field is not provided.</span></br> **Expected Format:** yyyy-mm-ddThh:mm:ssZ<br> **EX:** `2025-06-26T00:00:00Z`<br> *end_time must be before the date added for start_time*<br> *start_time and end_time may not be more than 30 days and 1 hour apart*<br> *If no end_time is provided the current time will be used  by default*
  ///
  /// * [String] logLevel:
  ///   Filter the logs by the level assigned to the log. * `info` * `debug` * `warning` * `error` * `critical`
  ///
  /// * [String] resourceType:
  ///   Filter the logs by the type of a resource such as an instances, bare-metals, kubernetes, etc.<br> *resource_type must be an exact match to the value of the resource type set in the log.* 
  ///
  /// * [String] resourceId:
  ///   Filter the logs by the UUID of a specific resource such as an instance.
  Future<ListLogs200Response?> listLogs({ String? startTime, String? endTime, String? logLevel, String? resourceType, String? resourceId, }) async {
    final response = await listLogsWithHttpInfo( startTime: startTime, endTime: endTime, logLevel: logLevel, resourceType: resourceType, resourceId: resourceId, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListLogs200Response',) as ListLogs200Response;
    
    }
    return null;
  }
}
