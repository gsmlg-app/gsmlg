//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StorageGatewaysApi {
  StorageGatewaysApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Add a new export to this storage gateway
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  ///
  /// * [List<StorageGatewayExport>] storageGatewayExport:
  Future<Response> addStorageGatewayExportWithHttpInfo(
    String storageGatewayId, {
    List<StorageGatewayExport>? storageGatewayExport,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways/{storage-gateway-id}/exports'
        .replaceAll('{storage-gateway-id}', storageGatewayId);

    // ignore: prefer_final_locals
    Object? postBody = storageGatewayExport;

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

  /// Add a new export to this storage gateway
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  ///
  /// * [List<StorageGatewayExport>] storageGatewayExport:
  Future<AddStorageGatewayExport200Response?> addStorageGatewayExport(
    String storageGatewayId, {
    List<StorageGatewayExport>? storageGatewayExport,
  }) async {
    final response = await addStorageGatewayExportWithHttpInfo(
      storageGatewayId,
      storageGatewayExport: storageGatewayExport,
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
        'AddStorageGatewayExport200Response',
      ) as AddStorageGatewayExport200Response;
    }
    return null;
  }

  /// Create Storage Gateway
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateStorageGatewayRequest] createStorageGatewayRequest:
  Future<Response> createStorageGatewayWithHttpInfo({
    CreateStorageGatewayRequest? createStorageGatewayRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways';

    // ignore: prefer_final_locals
    Object? postBody = createStorageGatewayRequest;

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

  /// Create Storage Gateway
  ///
  /// Parameters:
  ///
  /// * [CreateStorageGatewayRequest] createStorageGatewayRequest:
  Future<CreateStorageGateway202Response?> createStorageGateway({
    CreateStorageGatewayRequest? createStorageGatewayRequest,
  }) async {
    final response = await createStorageGatewayWithHttpInfo(
      createStorageGatewayRequest: createStorageGatewayRequest,
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
        'CreateStorageGateway202Response',
      ) as CreateStorageGateway202Response;
    }
    return null;
  }

  /// Delete Storage Gateway
  ///
  /// Delete a Storage Gateway.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  Future<Response> deleteStorageGatewayWithHttpInfo(
    String storageGatewayId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways/{storage-gateway-id}'
        .replaceAll('{storage-gateway-id}', storageGatewayId);

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

  /// Delete Storage Gateway
  ///
  /// Delete a Storage Gateway.
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  Future<void> deleteStorageGateway(
    String storageGatewayId,
  ) async {
    final response = await deleteStorageGatewayWithHttpInfo(
      storageGatewayId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Storage Gateway Export
  ///
  /// Delete a Storage Gateway Export.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [] UNKNOWN_PARAMETER_NAME (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  ///
  /// * [] UNKNOWN_PARAMETER_NAME2 (required):
  ///   The [Storage Gateway export id](#operation/list-storage-gateways).
  Future<Response> deleteStorageGatewayExportWithHttpInfo(
    UNKNOWN_PARAMETER_NAME,
    UNKNOWN_PARAMETER_NAME2,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways/{storage-gateway-id}/exports/{export-id}'
        .replaceAll('{storage-gateway-id}', UNKNOWN_PARAMETER_NAME.toString())
        .replaceAll('{export-id}', UNKNOWN_PARAMETER_NAME2.toString());

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

  /// Delete Storage Gateway Export
  ///
  /// Delete a Storage Gateway Export.
  ///
  /// Parameters:
  ///
  /// * [] UNKNOWN_PARAMETER_NAME (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  ///
  /// * [] UNKNOWN_PARAMETER_NAME2 (required):
  ///   The [Storage Gateway export id](#operation/list-storage-gateways).
  Future<void> deleteStorageGatewayExport(
    UNKNOWN_PARAMETER_NAME,
    UNKNOWN_PARAMETER_NAME2,
  ) async {
    final response = await deleteStorageGatewayExportWithHttpInfo(
      UNKNOWN_PARAMETER_NAME,
      UNKNOWN_PARAMETER_NAME2,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Storage Gateway
  ///
  /// Get information about a Storage Gateway.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  Future<Response> getStorageGatewayWithHttpInfo(
    String storageGatewayId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways/{storage-gateway-id}'
        .replaceAll('{storage-gateway-id}', storageGatewayId);

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

  /// Get Storage Gateway
  ///
  /// Get information about a Storage Gateway.
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  Future<CreateStorageGateway202Response?> getStorageGateway(
    String storageGatewayId,
  ) async {
    final response = await getStorageGatewayWithHttpInfo(
      storageGatewayId,
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
        'CreateStorageGateway202Response',
      ) as CreateStorageGateway202Response;
    }
    return null;
  }

  /// List storage gateways
  ///
  /// Get a list of all Storage Gateways in your account.
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
  Future<Response> listStorageGatewaysWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways';

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

  /// List storage gateways
  ///
  /// Get a list of all Storage Gateways in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListStorageGateways200Response?> listStorageGateways({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listStorageGatewaysWithHttpInfo(
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
        'ListStorageGateways200Response',
      ) as ListStorageGateways200Response;
    }
    return null;
  }

  /// Update Storage Gateway
  ///
  /// Update the label for a Storage Gateway.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  ///
  /// * [UpdateStorageGatewayRequest] updateStorageGatewayRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateStorageGatewayWithHttpInfo(
    String storageGatewayId, {
    UpdateStorageGatewayRequest? updateStorageGatewayRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/storage-gateways/{storage-gateway-id}'
        .replaceAll('{storage-gateway-id}', storageGatewayId);

    // ignore: prefer_final_locals
    Object? postBody = updateStorageGatewayRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];

    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update Storage Gateway
  ///
  /// Update the label for a Storage Gateway.
  ///
  /// Parameters:
  ///
  /// * [String] storageGatewayId (required):
  ///   The [Storage Gateway id](#operation/list-storage-gateways).
  ///
  /// * [UpdateStorageGatewayRequest] updateStorageGatewayRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateStorageGateway(
    String storageGatewayId, {
    UpdateStorageGatewayRequest? updateStorageGatewayRequest,
  }) async {
    final response = await updateStorageGatewayWithHttpInfo(
      storageGatewayId,
      updateStorageGatewayRequest: updateStorageGatewayRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
