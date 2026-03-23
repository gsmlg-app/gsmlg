//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class VPCsApi {
  VPCsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a VPC
  ///
  /// Create a new VPC in a `region`. VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateVpcRequest] createVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createVpcWithHttpInfo({ CreateVpcRequest? createVpcRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpcs';

    // ignore: prefer_final_locals
    Object? postBody = createVpcRequest;

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

  /// Create a VPC
  ///
  /// Create a new VPC in a `region`. VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):      10.0.0.0    - 10.255.255.255  (10/8 prefix)     172.16.0.0  - 172.31.255.255  (172.16/12 prefix)     192.168.0.0 - 192.168.255.255 (192.168/16 prefix) 
  ///
  /// Parameters:
  ///
  /// * [CreateVpcRequest] createVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetVpc200Response?> createVpc({ CreateVpcRequest? createVpcRequest, }) async {
    final response = await createVpcWithHttpInfo( createVpcRequest: createVpcRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetVpc200Response',) as GetVpc200Response;
    
    }
    return null;
  }

  /// Delete a VPC
  ///
  /// Delete a VPC.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<Response> deleteVpcWithHttpInfo(String vpcId,) async {
    // ignore: prefer_const_declarations
    final path = r'/vpcs/{vpc-id}'
      .replaceAll('{vpc-id}', vpcId);

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

  /// Delete a VPC
  ///
  /// Delete a VPC.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<void> deleteVpc(String vpcId,) async {
    final response = await deleteVpcWithHttpInfo(vpcId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get a VPC
  ///
  /// Get information about a VPC.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<Response> getVpcWithHttpInfo(String vpcId,) async {
    // ignore: prefer_const_declarations
    final path = r'/vpcs/{vpc-id}'
      .replaceAll('{vpc-id}', vpcId);

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

  /// Get a VPC
  ///
  /// Get information about a VPC.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  Future<GetVpc200Response?> getVpc(String vpcId,) async {
    final response = await getVpcWithHttpInfo(vpcId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetVpc200Response',) as GetVpc200Response;
    
    }
    return null;
  }

  /// List VPC Attachments
  ///
  /// List VPC Attachments.
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
  Future<Response> listVpcAttachmentsWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpcs/{vpc-id}/attachments';

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

  /// List VPC Attachments
  ///
  /// List VPC Attachments.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListVpcAttachments200Response?> listVpcAttachments({ int? perPage, String? cursor, }) async {
    final response = await listVpcAttachmentsWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListVpcAttachments200Response',) as ListVpcAttachments200Response;
    
    }
    return null;
  }

  /// List VPCs
  ///
  /// Get a list of all VPCs in your account.
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
  Future<Response> listVpcsWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpcs';

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

  /// List VPCs
  ///
  /// Get a list of all VPCs in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListVpcs200Response?> listVpcs({ int? perPage, String? cursor, }) async {
    final response = await listVpcsWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListVpcs200Response',) as ListVpcs200Response;
    
    }
    return null;
  }

  /// Update a VPC
  ///
  /// Update information for a VPC.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [UpdateVpcRequest] updateVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateVpcWithHttpInfo(String vpcId, { UpdateVpcRequest? updateVpcRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/vpcs/{vpc-id}'
      .replaceAll('{vpc-id}', vpcId);

    // ignore: prefer_final_locals
    Object? postBody = updateVpcRequest;

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

  /// Update a VPC
  ///
  /// Update information for a VPC.
  ///
  /// Parameters:
  ///
  /// * [String] vpcId (required):
  ///   The [VPC ID](#operation/list-vpcs).
  ///
  /// * [UpdateVpcRequest] updateVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateVpc(String vpcId, { UpdateVpcRequest? updateVpcRequest, }) async {
    final response = await updateVpcWithHttpInfo(vpcId,  updateVpcRequest: updateVpcRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
