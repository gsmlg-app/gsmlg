//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class StartupApi {
  StartupApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Startup Script
  ///
  /// Create a new Startup Script. The `name` and `script` attributes are required, and scripts are base-64 encoded.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateStartupScriptRequest] createStartupScriptRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createStartupScriptWithHttpInfo({ CreateStartupScriptRequest? createStartupScriptRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/startup-scripts';

    // ignore: prefer_final_locals
    Object? postBody = createStartupScriptRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create Startup Script
  ///
  /// Create a new Startup Script. The `name` and `script` attributes are required, and scripts are base-64 encoded.
  ///
  /// Parameters:
  ///
  /// * [CreateStartupScriptRequest] createStartupScriptRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetStartupScript200Response?> createStartupScript({ CreateStartupScriptRequest? createStartupScriptRequest, }) async {
    final response = await createStartupScriptWithHttpInfo( createStartupScriptRequest: createStartupScriptRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStartupScript200Response',) as GetStartupScript200Response;
    
    }
    return null;
  }

  /// Delete Startup Script
  ///
  /// Delete a Startup Script.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] startupId (required):
  ///   The [Startup Script id](#operation/list-startup-scripts).
  Future<Response> deleteStartupScriptWithHttpInfo(String startupId,) async {
    // ignore: prefer_const_declarations
    final path = r'/startup-scripts/{startup-id}'
      .replaceAll('{startup-id}', startupId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete Startup Script
  ///
  /// Delete a Startup Script.
  ///
  /// Parameters:
  ///
  /// * [String] startupId (required):
  ///   The [Startup Script id](#operation/list-startup-scripts).
  Future<void> deleteStartupScript(String startupId,) async {
    final response = await deleteStartupScriptWithHttpInfo(startupId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Startup Script
  ///
  /// Get information for a Startup Script.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] startupId (required):
  ///   The [Startup Script id](#operation/list-startup-scripts).
  Future<Response> getStartupScriptWithHttpInfo(String startupId,) async {
    // ignore: prefer_const_declarations
    final path = r'/startup-scripts/{startup-id}'
      .replaceAll('{startup-id}', startupId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Get Startup Script
  ///
  /// Get information for a Startup Script.
  ///
  /// Parameters:
  ///
  /// * [String] startupId (required):
  ///   The [Startup Script id](#operation/list-startup-scripts).
  Future<GetStartupScript200Response?> getStartupScript(String startupId,) async {
    final response = await getStartupScriptWithHttpInfo(startupId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStartupScript200Response',) as GetStartupScript200Response;
    
    }
    return null;
  }

  /// List Startup Scripts
  ///
  /// Get a list of all Startup Scripts.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listStartupScriptsWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/startup-scripts';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (perPage != null) {
      queryParams.addAll(_queryParams('', 'per_page', perPage));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
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

  /// List Startup Scripts
  ///
  /// Get a list of all Startup Scripts.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListStartupScripts200Response?> listStartupScripts({ int? perPage, String? cursor, }) async {
    final response = await listStartupScriptsWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListStartupScripts200Response',) as ListStartupScripts200Response;
    
    }
    return null;
  }

  /// Update Startup Script
  ///
  /// Update a Startup Script. The attributes `name` and `script` are optional. If not set, the attributes will retain their original values. The `script` attribute is base-64 encoded. New deployments will use the updated script, but this action does not update previously deployed instances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] startupId (required):
  ///   The [Startup Script id](#operation/list-startup-scripts).
  ///
  /// * [UpdateStartupScriptRequest] updateStartupScriptRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateStartupScriptWithHttpInfo(String startupId, { UpdateStartupScriptRequest? updateStartupScriptRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/startup-scripts/{startup-id}'
      .replaceAll('{startup-id}', startupId);

    // ignore: prefer_final_locals
    Object? postBody = updateStartupScriptRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update Startup Script
  ///
  /// Update a Startup Script. The attributes `name` and `script` are optional. If not set, the attributes will retain their original values. The `script` attribute is base-64 encoded. New deployments will use the updated script, but this action does not update previously deployed instances.
  ///
  /// Parameters:
  ///
  /// * [String] startupId (required):
  ///   The [Startup Script id](#operation/list-startup-scripts).
  ///
  /// * [UpdateStartupScriptRequest] updateStartupScriptRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateStartupScript(String startupId, { UpdateStartupScriptRequest? updateStartupScriptRequest, }) async {
    final response = await updateStartupScriptWithHttpInfo(startupId,  updateStartupScriptRequest: updateStartupScriptRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
