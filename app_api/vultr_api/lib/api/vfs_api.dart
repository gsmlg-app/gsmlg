//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VFSApi {
  VFSApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create VFS
  ///
  /// Create a new VFS subscription with the specified configuration
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateVFSRequest] createVFSRequest (required):
  Future<Response> createVFSWithHttpInfo(
    CreateVFSRequest createVFSRequest,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs';

    // ignore: prefer_final_locals
    Object? postBody = createVFSRequest;

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

  /// Create VFS
  ///
  /// Create a new VFS subscription with the specified configuration
  ///
  /// Parameters:
  ///
  /// * [CreateVFSRequest] createVFSRequest (required):
  Future<Vfs?> createVFS(
    CreateVFSRequest createVFSRequest,
  ) async {
    final response = await createVFSWithHttpInfo(
      createVFSRequest,
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
        'Vfs',
      ) as Vfs;
    }
    return null;
  }

  /// Attach VPS Instance to VFS
  ///
  /// Attach a VPS instance to a VFS subscription
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  ///
  /// * [String] vpsId (required):
  ///   ID of the VPS subscription to attach
  Future<Response> createVFSAttachmentWithHttpInfo(
    String vfsId,
    String vpsId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}/attachments/{vps_id}'
        .replaceAll('{vfs_id}', vfsId)
        .replaceAll('{vps_id}', vpsId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];

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

  /// Attach VPS Instance to VFS
  ///
  /// Attach a VPS instance to a VFS subscription
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  ///
  /// * [String] vpsId (required):
  ///   ID of the VPS subscription to attach
  Future<VfsAttachment?> createVFSAttachment(
    String vfsId,
    String vpsId,
  ) async {
    final response = await createVFSAttachmentWithHttpInfo(
      vfsId,
      vpsId,
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
        'VfsAttachment',
      ) as VfsAttachment;
    }
    return null;
  }

  /// Delete VFS
  ///
  /// Delete a specific VFS subscription by ID
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription to retrieve
  Future<Response> deleteVFSWithHttpInfo(
    String vfsId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}'.replaceAll('{vfs_id}', vfsId);

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

  /// Delete VFS
  ///
  /// Delete a specific VFS subscription by ID
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription to retrieve
  Future<void> deleteVFS(
    String vfsId,
  ) async {
    final response = await deleteVFSWithHttpInfo(
      vfsId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete VFS Attachment
  ///
  /// Detach a VPS instance from a VFS subscription
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  ///
  /// * [String] vpsId (required):
  ///   ID of the VPS subscription to attach
  Future<Response> deleteVFSAttachmentWithHttpInfo(
    String vfsId,
    String vpsId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}/attachments/{vps_id}'
        .replaceAll('{vfs_id}', vfsId)
        .replaceAll('{vps_id}', vpsId);

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

  /// Delete VFS Attachment
  ///
  /// Detach a VPS instance from a VFS subscription
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  ///
  /// * [String] vpsId (required):
  ///   ID of the VPS subscription to attach
  Future<void> deleteVFSAttachment(
    String vfsId,
    String vpsId,
  ) async {
    final response = await deleteVFSAttachmentWithHttpInfo(
      vfsId,
      vpsId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get VFS
  ///
  /// Retrieve a specific VFS subscription by ID
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription to retrieve
  Future<Response> getVFSWithHttpInfo(
    String vfsId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}'.replaceAll('{vfs_id}', vfsId);

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

  /// Get VFS
  ///
  /// Retrieve a specific VFS subscription by ID
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription to retrieve
  Future<Vfs?> getVFS(
    String vfsId,
  ) async {
    final response = await getVFSWithHttpInfo(
      vfsId,
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
        'Vfs',
      ) as Vfs;
    }
    return null;
  }

  /// Get VFS Attachment
  ///
  /// Retrieve details about a specific VFS-VPS attachment
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  ///
  /// * [String] vpsId (required):
  ///   ID of the VPS subscription to attach
  Future<Response> getVFSAttachmentWithHttpInfo(
    String vfsId,
    String vpsId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}/attachments/{vps_id}'
        .replaceAll('{vfs_id}', vfsId)
        .replaceAll('{vps_id}', vpsId);

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

  /// Get VFS Attachment
  ///
  /// Retrieve details about a specific VFS-VPS attachment
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  ///
  /// * [String] vpsId (required):
  ///   ID of the VPS subscription to attach
  Future<VfsAttachment?> getVFSAttachment(
    String vfsId,
    String vpsId,
  ) async {
    final response = await getVFSAttachmentWithHttpInfo(
      vfsId,
      vpsId,
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
        'VfsAttachment',
      ) as VfsAttachment;
    }
    return null;
  }

  /// List VFS Regions
  ///
  /// Retrieve a list of all regions where VFS can be deployed
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listRegionsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/regions';

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

  /// List VFS Regions
  ///
  /// Retrieve a list of all regions where VFS can be deployed
  Future<ListRegions200Response?> listRegions() async {
    final response = await listRegionsWithHttpInfo();
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
        'ListRegions200Response',
      ) as ListRegions200Response;
    }
    return null;
  }

  /// List VFSs
  ///
  /// Retrieve a list of all VFS subscriptions for the account
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listVFSWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/vfs';

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

  /// List VFSs
  ///
  /// Retrieve a list of all VFS subscriptions for the account
  Future<ListVFS200Response?> listVFS() async {
    final response = await listVFSWithHttpInfo();
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
        'ListVFS200Response',
      ) as ListVFS200Response;
    }
    return null;
  }

  /// List VFS Attachments
  ///
  /// Retrieve a list of all attachments for a specific VFS subscription
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  Future<Response> listVFSAttachmentsWithHttpInfo(
    String vfsId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}/attachments'.replaceAll('{vfs_id}', vfsId);

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

  /// List VFS Attachments
  ///
  /// Retrieve a list of all attachments for a specific VFS subscription
  ///
  /// Parameters:
  ///
  /// * [String] vfsId (required):
  ///   ID of the VFS subscription
  Future<ListVFSAttachments200Response?> listVFSAttachments(
    String vfsId,
  ) async {
    final response = await listVFSAttachmentsWithHttpInfo(
      vfsId,
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
        'ListVFSAttachments200Response',
      ) as ListVFSAttachments200Response;
    }
    return null;
  }

  /// Update VFS
  ///
  /// Update a VFS subscription's label or storage size
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UpdateVFSRequest] updateVFSRequest:
  Future<Response> updateVFSWithHttpInfo({
    UpdateVFSRequest? updateVFSRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/vfs/{vfs_id}';

    // ignore: prefer_final_locals
    Object? postBody = updateVFSRequest;

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

  /// Update VFS
  ///
  /// Update a VFS subscription's label or storage size
  ///
  /// Parameters:
  ///
  /// * [UpdateVFSRequest] updateVFSRequest:
  Future<Vfs?> updateVFS({
    UpdateVFSRequest? updateVFSRequest,
  }) async {
    final response = await updateVFSWithHttpInfo(
      updateVFSRequest: updateVFSRequest,
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
        'Vfs',
      ) as Vfs;
    }
    return null;
  }
}
