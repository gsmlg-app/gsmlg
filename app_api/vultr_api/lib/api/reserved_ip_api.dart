//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ReservedIpApi {
  ReservedIpApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Attach Reserved IP
  ///
  /// Attach a Reserved IP to an compute instance or a baremetal instance - `instance_id`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips)
  ///
  /// * [AttachReservedIpRequest] attachReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachReservedIpWithHttpInfo(String reservedIp, { AttachReservedIpRequest? attachReservedIpRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips/{reserved-ip}/attach'
      .replaceAll('{reserved-ip}', reservedIp);

    // ignore: prefer_final_locals
    Object? postBody = attachReservedIpRequest;

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

  /// Attach Reserved IP
  ///
  /// Attach a Reserved IP to an compute instance or a baremetal instance - `instance_id`.
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips)
  ///
  /// * [AttachReservedIpRequest] attachReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachReservedIp(String reservedIp, { AttachReservedIpRequest? attachReservedIpRequest, }) async {
    final response = await attachReservedIpWithHttpInfo(reservedIp,  attachReservedIpRequest: attachReservedIpRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Convert Instance IP to Reserved IP
  ///
  /// Convert the `ip_address` of an existing [instance](#operation/list-instances) into a Reserved IP.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ConvertReservedIpRequest] convertReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> convertReservedIpWithHttpInfo({ ConvertReservedIpRequest? convertReservedIpRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips/convert';

    // ignore: prefer_final_locals
    Object? postBody = convertReservedIpRequest;

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

  /// Convert Instance IP to Reserved IP
  ///
  /// Convert the `ip_address` of an existing [instance](#operation/list-instances) into a Reserved IP.
  ///
  /// Parameters:
  ///
  /// * [ConvertReservedIpRequest] convertReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetReservedIp200Response?> convertReservedIp({ ConvertReservedIpRequest? convertReservedIpRequest, }) async {
    final response = await convertReservedIpWithHttpInfo( convertReservedIpRequest: convertReservedIpRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetReservedIp200Response',) as GetReservedIp200Response;
    
    }
    return null;
  }

  /// Create Reserved IP
  ///
  /// Create a new Reserved IP. The `region` and `ip_type` attributes are required.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateReservedIpRequest] createReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createReservedIpWithHttpInfo({ CreateReservedIpRequest? createReservedIpRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips';

    // ignore: prefer_final_locals
    Object? postBody = createReservedIpRequest;

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

  /// Create Reserved IP
  ///
  /// Create a new Reserved IP. The `region` and `ip_type` attributes are required.
  ///
  /// Parameters:
  ///
  /// * [CreateReservedIpRequest] createReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetReservedIp200Response?> createReservedIp({ CreateReservedIpRequest? createReservedIpRequest, }) async {
    final response = await createReservedIpWithHttpInfo( createReservedIpRequest: createReservedIpRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetReservedIp200Response',) as GetReservedIp200Response;
    
    }
    return null;
  }

  /// Delete Reserved IP
  ///
  /// Delete a Reserved IP.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips).
  Future<Response> deleteReservedIpWithHttpInfo(String reservedIp,) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips/{reserved-ip}'
      .replaceAll('{reserved-ip}', reservedIp);

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

  /// Delete Reserved IP
  ///
  /// Delete a Reserved IP.
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips).
  Future<void> deleteReservedIp(String reservedIp,) async {
    final response = await deleteReservedIpWithHttpInfo(reservedIp,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach Reserved IP
  ///
  /// Detach a Reserved IP.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips)
  Future<Response> detachReservedIpWithHttpInfo(String reservedIp,) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips/{reserved-ip}/detach'
      .replaceAll('{reserved-ip}', reservedIp);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Detach Reserved IP
  ///
  /// Detach a Reserved IP.
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips)
  Future<void> detachReservedIp(String reservedIp,) async {
    final response = await detachReservedIpWithHttpInfo(reservedIp,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Reserved IP
  ///
  /// Get information about a Reserved IP.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips).
  Future<Response> getReservedIpWithHttpInfo(String reservedIp,) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips/{reserved-ip}'
      .replaceAll('{reserved-ip}', reservedIp);

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

  /// Get Reserved IP
  ///
  /// Get information about a Reserved IP.
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips).
  Future<GetReservedIp200Response?> getReservedIp(String reservedIp,) async {
    final response = await getReservedIpWithHttpInfo(reservedIp,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetReservedIp200Response',) as GetReservedIp200Response;
    
    }
    return null;
  }

  /// List Reserved IPs
  ///
  /// List all Reserved IPs in your account.
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
  Future<Response> listReservedIpsWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips';

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

  /// List Reserved IPs
  ///
  /// List all Reserved IPs in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListReservedIps200Response?> listReservedIps({ int? perPage, String? cursor, }) async {
    final response = await listReservedIpsWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListReservedIps200Response',) as ListReservedIps200Response;
    
    }
    return null;
  }

  /// Update Reserved IP
  ///
  /// Update information on a Reserved IP.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips).
  ///
  /// * [PatchReservedIpsReservedIpRequest] patchReservedIpsReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> patchReservedIpsReservedIpWithHttpInfo(String reservedIp, { PatchReservedIpsReservedIpRequest? patchReservedIpsReservedIpRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reserved-ips/{reserved-ip}'
      .replaceAll('{reserved-ip}', reservedIp);

    // ignore: prefer_final_locals
    Object? postBody = patchReservedIpsReservedIpRequest;

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

  /// Update Reserved IP
  ///
  /// Update information on a Reserved IP.
  ///
  /// Parameters:
  ///
  /// * [String] reservedIp (required):
  ///   The [Reserved IP id](#operation/list-reserved-ips).
  ///
  /// * [PatchReservedIpsReservedIpRequest] patchReservedIpsReservedIpRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetReservedIp200Response?> patchReservedIpsReservedIp(String reservedIp, { PatchReservedIpsReservedIpRequest? patchReservedIpsReservedIpRequest, }) async {
    final response = await patchReservedIpsReservedIpWithHttpInfo(reservedIp,  patchReservedIpsReservedIpRequest: patchReservedIpsReservedIpRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetReservedIp200Response',) as GetReservedIp200Response;
    
    }
    return null;
  }
}
