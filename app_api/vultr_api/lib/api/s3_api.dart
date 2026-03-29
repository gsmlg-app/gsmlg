//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class S3Api {
  S3Api([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Object Storage
  ///
  /// Create new Object Storage. The `cluster_id` attribute is required.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateObjectStorageRequest] createObjectStorageRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createObjectStorageWithHttpInfo({
    CreateObjectStorageRequest? createObjectStorageRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage';

    // ignore: prefer_final_locals
    Object? postBody = createObjectStorageRequest;

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

  /// Create Object Storage
  ///
  /// Create new Object Storage. The `cluster_id` attribute is required.
  ///
  /// Parameters:
  ///
  /// * [CreateObjectStorageRequest] createObjectStorageRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateObjectStorage202Response?> createObjectStorage({
    CreateObjectStorageRequest? createObjectStorageRequest,
  }) async {
    final response = await createObjectStorageWithHttpInfo(
      createObjectStorageRequest: createObjectStorageRequest,
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
        'CreateObjectStorage202Response',
      ) as CreateObjectStorage202Response;
    }
    return null;
  }

  /// Delete Object Storage
  ///
  /// Delete an Object Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  Future<Response> deleteObjectStorageWithHttpInfo(
    String objectStorageId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/{object-storage-id}'
        .replaceAll('{object-storage-id}', objectStorageId);

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

  /// Delete Object Storage
  ///
  /// Delete an Object Storage.
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  Future<void> deleteObjectStorage(
    String objectStorageId,
  ) async {
    final response = await deleteObjectStorageWithHttpInfo(
      objectStorageId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Object Storage
  ///
  /// Get information about an Object Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  Future<Response> getObjectStorageWithHttpInfo(
    String objectStorageId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/{object-storage-id}'
        .replaceAll('{object-storage-id}', objectStorageId);

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

  /// Get Object Storage
  ///
  /// Get information about an Object Storage.
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  Future<CreateObjectStorage202Response?> getObjectStorage(
    String objectStorageId,
  ) async {
    final response = await getObjectStorageWithHttpInfo(
      objectStorageId,
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
        'CreateObjectStorage202Response',
      ) as CreateObjectStorage202Response;
    }
    return null;
  }

  /// Get All Cluster Tiers
  ///
  /// Get a list of all Object Storage Tiers for a given Cluster.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] clusterId (required):
  ///   The [Cluster id](#operation/list-object-storage-clusters).
  Future<Response> listObjectStorageClusterTiersWithHttpInfo(
    String clusterId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/clusters/{cluster-id}/tiers'
        .replaceAll('{cluster-id}', clusterId);

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

  /// Get All Cluster Tiers
  ///
  /// Get a list of all Object Storage Tiers for a given Cluster.
  ///
  /// Parameters:
  ///
  /// * [String] clusterId (required):
  ///   The [Cluster id](#operation/list-object-storage-clusters).
  Future<ListObjectStorageClusterTiers200Response?>
      listObjectStorageClusterTiers(
    String clusterId,
  ) async {
    final response = await listObjectStorageClusterTiersWithHttpInfo(
      clusterId,
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
        'ListObjectStorageClusterTiers200Response',
      ) as ListObjectStorageClusterTiers200Response;
    }
    return null;
  }

  /// Get All Clusters
  ///
  /// Get a list of all Object Storage Clusters.
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
  Future<Response> listObjectStorageClustersWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/clusters';

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

  /// Get All Clusters
  ///
  /// Get a list of all Object Storage Clusters.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListObjectStorageClusters200Response?> listObjectStorageClusters({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listObjectStorageClustersWithHttpInfo(
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
        'ListObjectStorageClusters200Response',
      ) as ListObjectStorageClusters200Response;
    }
    return null;
  }

  /// Get All Tiers
  ///
  /// Get a list of all Object Storage Tiers.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listObjectStorageTiersWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/tiers';

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

  /// Get All Tiers
  ///
  /// Get a list of all Object Storage Tiers.
  Future<ListObjectStorageTiers200Response?> listObjectStorageTiers() async {
    final response = await listObjectStorageTiersWithHttpInfo();
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
        'ListObjectStorageTiers200Response',
      ) as ListObjectStorageTiers200Response;
    }
    return null;
  }

  /// List Object Storages
  ///
  /// Get a list of all Object Storage in your account.
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
  Future<Response> listObjectStoragesWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage';

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

  /// List Object Storages
  ///
  /// Get a list of all Object Storage in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListObjectStorages200Response?> listObjectStorages({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listObjectStoragesWithHttpInfo(
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
        'ListObjectStorages200Response',
      ) as ListObjectStorages200Response;
    }
    return null;
  }

  /// Regenerate Object Storage Keys
  ///
  /// Regenerate the keys for an Object Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  Future<Response> regenerateObjectStorageKeysWithHttpInfo(
    String objectStorageId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/{object-storage-id}/regenerate-keys'
        .replaceAll('{object-storage-id}', objectStorageId);

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

  /// Regenerate Object Storage Keys
  ///
  /// Regenerate the keys for an Object Storage.
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  Future<RegenerateObjectStorageKeys201Response?> regenerateObjectStorageKeys(
    String objectStorageId,
  ) async {
    final response = await regenerateObjectStorageKeysWithHttpInfo(
      objectStorageId,
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
        'RegenerateObjectStorageKeys201Response',
      ) as RegenerateObjectStorageKeys201Response;
    }
    return null;
  }

  /// Update Object Storage
  ///
  /// Update the label for an Object Storage.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  ///
  /// * [UpdateObjectStorageRequest] updateObjectStorageRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateObjectStorageWithHttpInfo(
    String objectStorageId, {
    UpdateObjectStorageRequest? updateObjectStorageRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/object-storage/{object-storage-id}'
        .replaceAll('{object-storage-id}', objectStorageId);

    // ignore: prefer_final_locals
    Object? postBody = updateObjectStorageRequest;

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

  /// Update Object Storage
  ///
  /// Update the label for an Object Storage.
  ///
  /// Parameters:
  ///
  /// * [String] objectStorageId (required):
  ///   The [Object Storage id](#operation/list-object-storages).
  ///
  /// * [UpdateObjectStorageRequest] updateObjectStorageRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateObjectStorage(
    String objectStorageId, {
    UpdateObjectStorageRequest? updateObjectStorageRequest,
  }) async {
    final response = await updateObjectStorageWithHttpInfo(
      objectStorageId,
      updateObjectStorageRequest: updateObjectStorageRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
