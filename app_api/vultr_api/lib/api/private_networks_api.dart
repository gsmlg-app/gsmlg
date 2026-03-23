//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PrivateNetworksApi {
  PrivateNetworksApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a Private Network
  ///
  /// Create a new Private Network in a `region`.  **Deprecated**: Use [Create a VPC](#operation/create-vpc) instead.      Private networks should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateNetworkRequest] createNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createNetworkWithHttpInfo({ CreateNetworkRequest? createNetworkRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/private-networks';

    // ignore: prefer_final_locals
    Object? postBody = createNetworkRequest;

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

  /// Create a Private Network
  ///
  /// Create a new Private Network in a `region`.  **Deprecated**: Use [Create a VPC](#operation/create-vpc) instead.      Private networks should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 
  ///
  /// Parameters:
  ///
  /// * [CreateNetworkRequest] createNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetNetwork200Response?> createNetwork({ CreateNetworkRequest? createNetworkRequest, }) async {
    final response = await createNetworkWithHttpInfo( createNetworkRequest: createNetworkRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetNetwork200Response',) as GetNetwork200Response;
    
    }
    return null;
  }

  /// Delete a private network
  ///
  /// Delete a Private Network.<br><br>**Deprecated**: Use [Delete a VPC](#operation/delete-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] networkId (required):
  ///   The [Network id](#operation/list-networks).
  Future<Response> deleteNetworkWithHttpInfo(String networkId,) async {
    // ignore: prefer_const_declarations
    final path = r'/private-networks/{network-id}'
      .replaceAll('{network-id}', networkId);

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

  /// Delete a private network
  ///
  /// Delete a Private Network.<br><br>**Deprecated**: Use [Delete a VPC](#operation/delete-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] networkId (required):
  ///   The [Network id](#operation/list-networks).
  Future<void> deleteNetwork(String networkId,) async {
    final response = await deleteNetworkWithHttpInfo(networkId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get a private network
  ///
  /// Get information about a Private Network.<br><br>**Deprecated**: Use [Get a VPC](#operation/get-vpc) instead. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] networkId (required):
  ///   The [Network id](#operation/list-networks).
  Future<Response> getNetworkWithHttpInfo(String networkId,) async {
    // ignore: prefer_const_declarations
    final path = r'/private-networks/{network-id}'
      .replaceAll('{network-id}', networkId);

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

  /// Get a private network
  ///
  /// Get information about a Private Network.<br><br>**Deprecated**: Use [Get a VPC](#operation/get-vpc) instead. 
  ///
  /// Parameters:
  ///
  /// * [String] networkId (required):
  ///   The [Network id](#operation/list-networks).
  Future<GetNetwork200Response?> getNetwork(String networkId,) async {
    final response = await getNetworkWithHttpInfo(networkId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetNetwork200Response',) as GetNetwork200Response;
    
    }
    return null;
  }

  /// List Private Networks
  ///
  /// Get a list of all Private Networks in your account.<br><br>**Deprecated**: Use [List VPCs](#operation/list-vpcs) instead.
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
  Future<Response> listNetworksWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/private-networks';

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

  /// List Private Networks
  ///
  /// Get a list of all Private Networks in your account.<br><br>**Deprecated**: Use [List VPCs](#operation/list-vpcs) instead.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListNetworks200Response?> listNetworks({ int? perPage, String? cursor, }) async {
    final response = await listNetworksWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListNetworks200Response',) as ListNetworks200Response;
    
    }
    return null;
  }

  /// Update a Private Network
  ///
  /// Update information for a Private Network.<br><br>**Deprecated**: Use [Update a VPC](#operation/update-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] networkId (required):
  ///   The [Network id](#operation/list-networks).
  ///
  /// * [UpdateNetworkRequest] updateNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateNetworkWithHttpInfo(String networkId, { UpdateNetworkRequest? updateNetworkRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/private-networks/{network-id}'
      .replaceAll('{network-id}', networkId);

    // ignore: prefer_final_locals
    Object? postBody = updateNetworkRequest;

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

  /// Update a Private Network
  ///
  /// Update information for a Private Network.<br><br>**Deprecated**: Use [Update a VPC](#operation/update-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] networkId (required):
  ///   The [Network id](#operation/list-networks).
  ///
  /// * [UpdateNetworkRequest] updateNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateNetwork(String networkId, { UpdateNetworkRequest? updateNetworkRequest, }) async {
    final response = await updateNetworkWithHttpInfo(networkId,  updateNetworkRequest: updateNetworkRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
