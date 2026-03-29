//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SnapshotApi {
  SnapshotApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Snapshot
  ///
  /// Create a new Snapshot for `instance_id`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateSnapshotRequest] createSnapshotRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createSnapshotWithHttpInfo({
    CreateSnapshotRequest? createSnapshotRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/snapshots';

    // ignore: prefer_final_locals
    Object? postBody = createSnapshotRequest;

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

  /// Create Snapshot
  ///
  /// Create a new Snapshot for `instance_id`.
  ///
  /// Parameters:
  ///
  /// * [CreateSnapshotRequest] createSnapshotRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetSnapshot200Response?> createSnapshot({
    CreateSnapshotRequest? createSnapshotRequest,
  }) async {
    final response = await createSnapshotWithHttpInfo(
      createSnapshotRequest: createSnapshotRequest,
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
        'GetSnapshot200Response',
      ) as GetSnapshot200Response;
    }
    return null;
  }

  /// Create Snapshot from URL
  ///
  /// Create a new Snapshot from a RAW image located at `url`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateSnapshotCreateFromUrlRequest] createSnapshotCreateFromUrlRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createSnapshotCreateFromUrlWithHttpInfo({
    CreateSnapshotCreateFromUrlRequest? createSnapshotCreateFromUrlRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/snapshots/create-from-url';

    // ignore: prefer_final_locals
    Object? postBody = createSnapshotCreateFromUrlRequest;

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

  /// Create Snapshot from URL
  ///
  /// Create a new Snapshot from a RAW image located at `url`.
  ///
  /// Parameters:
  ///
  /// * [CreateSnapshotCreateFromUrlRequest] createSnapshotCreateFromUrlRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetSnapshot200Response?> createSnapshotCreateFromUrl({
    CreateSnapshotCreateFromUrlRequest? createSnapshotCreateFromUrlRequest,
  }) async {
    final response = await createSnapshotCreateFromUrlWithHttpInfo(
      createSnapshotCreateFromUrlRequest: createSnapshotCreateFromUrlRequest,
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
        'GetSnapshot200Response',
      ) as GetSnapshot200Response;
    }
    return null;
  }

  /// Delete Snapshot
  ///
  /// Delete a Snapshot.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] snapshotId (required):
  ///   The [Snapshot id](#operation/list-snapshots).
  Future<Response> deleteSnapshotWithHttpInfo(
    String snapshotId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/snapshots/{snapshot-id}'.replaceAll('{snapshot-id}', snapshotId);

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

  /// Delete Snapshot
  ///
  /// Delete a Snapshot.
  ///
  /// Parameters:
  ///
  /// * [String] snapshotId (required):
  ///   The [Snapshot id](#operation/list-snapshots).
  Future<void> deleteSnapshot(
    String snapshotId,
  ) async {
    final response = await deleteSnapshotWithHttpInfo(
      snapshotId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Snapshot
  ///
  /// Get information about a Snapshot.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] snapshotId (required):
  ///   The [Snapshot id](#operation/list-snapshots).
  Future<Response> getSnapshotWithHttpInfo(
    String snapshotId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/snapshots/{snapshot-id}'.replaceAll('{snapshot-id}', snapshotId);

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

  /// Get Snapshot
  ///
  /// Get information about a Snapshot.
  ///
  /// Parameters:
  ///
  /// * [String] snapshotId (required):
  ///   The [Snapshot id](#operation/list-snapshots).
  Future<GetSnapshot200Response?> getSnapshot(
    String snapshotId,
  ) async {
    final response = await getSnapshotWithHttpInfo(
      snapshotId,
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
        'GetSnapshot200Response',
      ) as GetSnapshot200Response;
    }
    return null;
  }

  /// List Snapshots
  ///
  /// Get information about all Snapshots in your account.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] description:
  ///   Filter the list of Snapshots by `description`
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listSnapshotsWithHttpInfo({
    String? description,
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/snapshots';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (description != null) {
      queryParams.addAll(_queryParams('', 'description', description));
    }
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

  /// List Snapshots
  ///
  /// Get information about all Snapshots in your account.
  ///
  /// Parameters:
  ///
  /// * [String] description:
  ///   Filter the list of Snapshots by `description`
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListSnapshots200Response?> listSnapshots({
    String? description,
    int? perPage,
    String? cursor,
  }) async {
    final response = await listSnapshotsWithHttpInfo(
      description: description,
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
        'ListSnapshots200Response',
      ) as ListSnapshots200Response;
    }
    return null;
  }

  /// Update Snapshot
  ///
  /// Update the description for a Snapshot.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] snapshotId (required):
  ///   The [Snapshot id](#operation/list-snapshots).
  ///
  /// * [PutSnapshotsSnapshotIdRequest] putSnapshotsSnapshotIdRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> putSnapshotsSnapshotIdWithHttpInfo(
    String snapshotId, {
    PutSnapshotsSnapshotIdRequest? putSnapshotsSnapshotIdRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path =
        r'/snapshots/{snapshot-id}'.replaceAll('{snapshot-id}', snapshotId);

    // ignore: prefer_final_locals
    Object? postBody = putSnapshotsSnapshotIdRequest;

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

  /// Update Snapshot
  ///
  /// Update the description for a Snapshot.
  ///
  /// Parameters:
  ///
  /// * [String] snapshotId (required):
  ///   The [Snapshot id](#operation/list-snapshots).
  ///
  /// * [PutSnapshotsSnapshotIdRequest] putSnapshotsSnapshotIdRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> putSnapshotsSnapshotId(
    String snapshotId, {
    PutSnapshotsSnapshotIdRequest? putSnapshotsSnapshotIdRequest,
  }) async {
    final response = await putSnapshotsSnapshotIdWithHttpInfo(
      snapshotId,
      putSnapshotsSnapshotIdRequest: putSnapshotsSnapshotIdRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
