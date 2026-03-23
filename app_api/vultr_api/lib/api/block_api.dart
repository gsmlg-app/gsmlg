//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class BlockApi {
  BlockApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Attach Block Storage
  ///
  /// Attach Block Storage to Instance `instance_id`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  ///
  /// * [AttachBlockRequest] attachBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachBlockWithHttpInfo(String blockId, { AttachBlockRequest? attachBlockRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks/{block-id}/attach'
      .replaceAll('{block-id}', blockId);

    // ignore: prefer_final_locals
    Object? postBody = attachBlockRequest;

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

  /// Attach Block Storage
  ///
  /// Attach Block Storage to Instance `instance_id`.
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  ///
  /// * [AttachBlockRequest] attachBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachBlock(String blockId, { AttachBlockRequest? attachBlockRequest, }) async {
    final response = await attachBlockWithHttpInfo(blockId,  attachBlockRequest: attachBlockRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create Block Storage
  ///
  /// Create new Block Storage in a `region` with a size of `size_gb`. Size may range between 10 and 40000 depending on the `block_type`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateBlockRequest] createBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createBlockWithHttpInfo({ CreateBlockRequest? createBlockRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks';

    // ignore: prefer_final_locals
    Object? postBody = createBlockRequest;

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

  /// Create Block Storage
  ///
  /// Create new Block Storage in a `region` with a size of `size_gb`. Size may range between 10 and 40000 depending on the `block_type`.
  ///
  /// Parameters:
  ///
  /// * [CreateBlockRequest] createBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateBlock202Response?> createBlock({ CreateBlockRequest? createBlockRequest, }) async {
    final response = await createBlockWithHttpInfo( createBlockRequest: createBlockRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateBlock202Response',) as CreateBlock202Response;
    
    }
    return null;
  }

  /// Delete Block Storage
  ///
  /// Delete Block Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  Future<Response> deleteBlockWithHttpInfo(String blockId,) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks/{block-id}'
      .replaceAll('{block-id}', blockId);

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

  /// Delete Block Storage
  ///
  /// Delete Block Storage.
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  Future<void> deleteBlock(String blockId,) async {
    final response = await deleteBlockWithHttpInfo(blockId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach Block Storage
  ///
  /// Detach Block Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  ///
  /// * [DetachBlockRequest] detachBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachBlockWithHttpInfo(String blockId, { DetachBlockRequest? detachBlockRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks/{block-id}/detach'
      .replaceAll('{block-id}', blockId);

    // ignore: prefer_final_locals
    Object? postBody = detachBlockRequest;

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

  /// Detach Block Storage
  ///
  /// Detach Block Storage.
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  ///
  /// * [DetachBlockRequest] detachBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachBlock(String blockId, { DetachBlockRequest? detachBlockRequest, }) async {
    final response = await detachBlockWithHttpInfo(blockId,  detachBlockRequest: detachBlockRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Block Storage
  ///
  /// Get information for Block Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  Future<Response> getBlockWithHttpInfo(String blockId,) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks/{block-id}'
      .replaceAll('{block-id}', blockId);

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

  /// Get Block Storage
  ///
  /// Get information for Block Storage.
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  Future<CreateBlock202Response?> getBlock(String blockId,) async {
    final response = await getBlockWithHttpInfo(blockId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateBlock202Response',) as CreateBlock202Response;
    
    }
    return null;
  }

  /// List Block storages
  ///
  /// List all Block Storage in your account.
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
  Future<Response> listBlocksWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks';

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

  /// List Block storages
  ///
  /// List all Block Storage in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListBlocks200Response?> listBlocks({ int? perPage, String? cursor, }) async {
    final response = await listBlocksWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListBlocks200Response',) as ListBlocks200Response;
    
    }
    return null;
  }

  /// Update Block Storage
  ///
  /// Update information for Block Storage. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  ///
  /// * [UpdateBlockRequest] updateBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateBlockWithHttpInfo(String blockId, { UpdateBlockRequest? updateBlockRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/blocks/{block-id}'
      .replaceAll('{block-id}', blockId);

    // ignore: prefer_final_locals
    Object? postBody = updateBlockRequest;

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

  /// Update Block Storage
  ///
  /// Update information for Block Storage. 
  ///
  /// Parameters:
  ///
  /// * [String] blockId (required):
  ///   The [Block Storage id](#operation/list-blocks).
  ///
  /// * [UpdateBlockRequest] updateBlockRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateBlock(String blockId, { UpdateBlockRequest? updateBlockRequest, }) async {
    final response = await updateBlockWithHttpInfo(blockId,  updateBlockRequest: updateBlockRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
