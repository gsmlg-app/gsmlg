//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class IsoApi {
  IsoApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create ISO
  ///
  /// Create a new ISO in your account from `url`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateIsoRequest] createIsoRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createIsoWithHttpInfo({
    CreateIsoRequest? createIsoRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/iso';

    // ignore: prefer_final_locals
    Object? postBody = createIsoRequest;

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

  /// Create ISO
  ///
  /// Create a new ISO in your account from `url`.
  ///
  /// Parameters:
  ///
  /// * [CreateIsoRequest] createIsoRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateIso201Response?> createIso({
    CreateIsoRequest? createIsoRequest,
  }) async {
    final response = await createIsoWithHttpInfo(
      createIsoRequest: createIsoRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'CreateIso201Response',
      ) as CreateIso201Response;
    }
    return null;
  }

  /// Delete ISO
  ///
  /// Delete an ISO.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] isoId (required):
  ///   The [ISO id](#operation/list-isos).
  Future<Response> deleteIsoWithHttpInfo(
    String isoId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/iso/{iso-id}'.replaceAll('{iso-id}', isoId);

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

  /// Delete ISO
  ///
  /// Delete an ISO.
  ///
  /// Parameters:
  ///
  /// * [String] isoId (required):
  ///   The [ISO id](#operation/list-isos).
  Future<void> deleteIso(
    String isoId,
  ) async {
    final response = await deleteIsoWithHttpInfo(
      isoId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get ISO
  ///
  /// Get information for an ISO.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] isoId (required):
  ///   The [ISO id](#operation/list-isos).
  Future<Response> isoGetWithHttpInfo(
    String isoId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/iso/{iso-id}'.replaceAll('{iso-id}', isoId);

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

  /// Get ISO
  ///
  /// Get information for an ISO.
  ///
  /// Parameters:
  ///
  /// * [String] isoId (required):
  ///   The [ISO id](#operation/list-isos).
  Future<CreateIso201Response?> isoGet(
    String isoId,
  ) async {
    final response = await isoGetWithHttpInfo(
      isoId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'CreateIso201Response',
      ) as CreateIso201Response;
    }
    return null;
  }

  /// List ISOs
  ///
  /// Get the ISOs in your account.
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
  Future<Response> listIsosWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/iso';

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

  /// List ISOs
  ///
  /// Get the ISOs in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListIsos200Response?> listIsos({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listIsosWithHttpInfo(
      perPage: perPage,
      cursor: cursor,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'ListIsos200Response',
      ) as ListIsos200Response;
    }
    return null;
  }

  /// List Public ISOs
  ///
  /// List all Vultr Public ISOs.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listPublicIsosWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/iso-public';

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

  /// List Public ISOs
  ///
  /// List all Vultr Public ISOs.
  Future<ListPublicIsos200Response?> listPublicIsos() async {
    final response = await listPublicIsosWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'ListPublicIsos200Response',
      ) as ListPublicIsos200Response;
    }
    return null;
  }
}
