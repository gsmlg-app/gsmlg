//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VPC2Api {
  VPC2Api([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Attach nodes to a VPC 2.0 network
  ///
  /// Attach nodes to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [AttachVpc2NodesRequest] attachVpc2NodesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachVpc2NodesWithHttpInfo(
    String vpcId, {
    AttachVpc2NodesRequest? attachVpc2NodesRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2/{vpc-id}/nodes/attach'.replaceAll('{vpc-id}', vpcId);

    // ignore: prefer_final_locals
    Object? postBody = attachVpc2NodesRequest;

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

  /// Attach nodes to a VPC 2.0 network
  ///
  /// Attach nodes to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [AttachVpc2NodesRequest] attachVpc2NodesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachVpc2Nodes(
    String vpcId, {
    AttachVpc2NodesRequest? attachVpc2NodesRequest,
  }) async {
    final response = await attachVpc2NodesWithHttpInfo(
      vpcId,
      attachVpc2NodesRequest: attachVpc2NodesRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create a VPC 2.0 network
  ///
  /// Create a new VPC 2.0 network in a `region`.  **Deprecated**: Migrate to VPC Networks and use [Create a VPC](#operation/create-vpc) instead.  VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateVpc2Request] createVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createVpc2WithHttpInfo({
    CreateVpc2Request? createVpc2Request,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2';

    // ignore: prefer_final_locals
    Object? postBody = createVpc2Request;

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

  /// Create a VPC 2.0 network
  ///
  /// Create a new VPC 2.0 network in a `region`.  **Deprecated**: Migrate to VPC Networks and use [Create a VPC](#operation/create-vpc) instead.  VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
  ///
  /// Parameters:
  ///
  /// * [CreateVpc2Request] createVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetVpc2200Response?> createVpc2({
    CreateVpc2Request? createVpc2Request,
  }) async {
    final response = await createVpc2WithHttpInfo(
      createVpc2Request: createVpc2Request,
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
        'GetVpc2200Response',
      ) as GetVpc2200Response;
    }
    return null;
  }

  /// Delete a VPC 2.0 network
  ///
  /// Delete a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Delete a VPC](#operation/delete-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<Response> deleteVpc2WithHttpInfo(
    String vpcId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2/{vpc-id}'.replaceAll('{vpc-id}', vpcId);

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

  /// Delete a VPC 2.0 network
  ///
  /// Delete a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Delete a VPC](#operation/delete-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<void> deleteVpc2(
    String vpcId,
  ) async {
    final response = await deleteVpc2WithHttpInfo(
      vpcId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Remove nodes from a VPC 2.0 network
  ///
  /// Remove nodes from a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [DetachVpc2NodesRequest] detachVpc2NodesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachVpc2NodesWithHttpInfo(
    String vpcId, {
    DetachVpc2NodesRequest? detachVpc2NodesRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2/{vpc-id}/nodes/detach'.replaceAll('{vpc-id}', vpcId);

    // ignore: prefer_final_locals
    Object? postBody = detachVpc2NodesRequest;

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

  /// Remove nodes from a VPC 2.0 network
  ///
  /// Remove nodes from a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [DetachVpc2NodesRequest] detachVpc2NodesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachVpc2Nodes(
    String vpcId, {
    DetachVpc2NodesRequest? detachVpc2NodesRequest,
  }) async {
    final response = await detachVpc2NodesWithHttpInfo(
      vpcId,
      detachVpc2NodesRequest: detachVpc2NodesRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get a VPC 2.0 network
  ///
  /// Get information about a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Get a VPC](#operation/get-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<Response> getVpc2WithHttpInfo(
    String vpcId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2/{vpc-id}'.replaceAll('{vpc-id}', vpcId);

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

  /// Get a VPC 2.0 network
  ///
  /// Get information about a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Get a VPC](#operation/get-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<GetVpc2200Response?> getVpc2(
    String vpcId,
  ) async {
    final response = await getVpc2WithHttpInfo(
      vpcId,
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
        'GetVpc2200Response',
      ) as GetVpc2200Response;
    }
    return null;
  }

  /// List VPC 2.0 networks
  ///
  /// Get a list of all VPC 2.0 networks in your account.<br><br>**Deprecated**: Migrate to VPC Networks and use [List VPCs](#operation/list-vpcs) instead.
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
  Future<Response> listVpc2WithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2';

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

  /// List VPC 2.0 networks
  ///
  /// Get a list of all VPC 2.0 networks in your account.<br><br>**Deprecated**: Migrate to VPC Networks and use [List VPCs](#operation/list-vpcs) instead.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListVpc2200Response?> listVpc2({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listVpc2WithHttpInfo(
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
        'ListVpc2200Response',
      ) as ListVpc2200Response;
    }
    return null;
  }

  /// Get a list of nodes attached to a VPC 2.0 network
  ///
  /// Get a list of nodes attached to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listVpc2NodesWithHttpInfo(
    String vpcId, {
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2/{vpc-id}/nodes'.replaceAll('{vpc-id}', vpcId);

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

  /// Get a list of nodes attached to a VPC 2.0 network
  ///
  /// Get a list of nodes attached to a VPC 2.0 network.<br><br>**Deprecated**: Use [VPCs](#tag/VPCs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListVpc2Nodes200Response?> listVpc2Nodes(
    String vpcId, {
    int? perPage,
    String? cursor,
  }) async {
    final response = await listVpc2NodesWithHttpInfo(
      vpcId,
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
        'ListVpc2Nodes200Response',
      ) as ListVpc2Nodes200Response;
    }
    return null;
  }

  /// Update a VPC 2.0 network
  ///
  /// Update information for a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Update a VPC](#operation/update-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [UpdateVpc2Request] updateVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateVpc2WithHttpInfo(
    String vpcId, {
    UpdateVpc2Request? updateVpc2Request,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpc2/{vpc-id}'.replaceAll('{vpc-id}', vpcId);

    // ignore: prefer_final_locals
    Object? postBody = updateVpc2Request;

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

  /// Update a VPC 2.0 network
  ///
  /// Update information for a VPC 2.0 network.<br><br>**Deprecated**: Migrate to VPC Networks and use [Update a VPC](#operation/update-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [UpdateVpc2Request] updateVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateVpc2(
    String vpcId, {
    UpdateVpc2Request? updateVpc2Request,
  }) async {
    final response = await updateVpc2WithHttpInfo(
      vpcId,
      updateVpc2Request: updateVpc2Request,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
