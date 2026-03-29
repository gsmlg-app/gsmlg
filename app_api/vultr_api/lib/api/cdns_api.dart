//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CDNsApi {
  CDNsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create CDN Pull Zones
  ///
  /// Create a new CDN Pull Zone.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreatePullzoneRequest] createPullzoneRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createPullzoneWithHttpInfo({
    CreatePullzoneRequest? createPullzoneRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/pull-zones';

    // ignore: prefer_final_locals
    Object? postBody = createPullzoneRequest;

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

  /// Create CDN Pull Zones
  ///
  /// Create a new CDN Pull Zone.
  ///
  /// Parameters:
  ///
  /// * [CreatePullzoneRequest] createPullzoneRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreatePullzone201Response?> createPullzone({
    CreatePullzoneRequest? createPullzoneRequest,
  }) async {
    final response = await createPullzoneWithHttpInfo(
      createPullzoneRequest: createPullzoneRequest,
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
        'CreatePullzone201Response',
      ) as CreatePullzone201Response;
    }
    return null;
  }

  /// Create CDN Push Zones
  ///
  /// Create a new CDN Push Zone.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreatePushzoneRequest] createPushzoneRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createPushzoneWithHttpInfo({
    CreatePushzoneRequest? createPushzoneRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones';

    // ignore: prefer_final_locals
    Object? postBody = createPushzoneRequest;

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

  /// Create CDN Push Zones
  ///
  /// Create a new CDN Push Zone.
  ///
  /// Parameters:
  ///
  /// * [CreatePushzoneRequest] createPushzoneRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreatePushzone201Response?> createPushzone({
    CreatePushzoneRequest? createPushzoneRequest,
  }) async {
    final response = await createPushzoneWithHttpInfo(
      createPushzoneRequest: createPushzoneRequest,
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
        'CreatePushzone201Response',
      ) as CreatePushzone201Response;
    }
    return null;
  }

  /// Create CDN Push Zone File Upload Endpoint
  ///
  /// Create a presigned post endpoint that can be used to upload a file to your Push Zone.  After sending this request you must send a second POST request to the returned URL. Include all of the returned inputs as form-data fields using the same key and value.  You must also include a field named \"file\" that holds the file to be uploaded.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [CreatePushzoneUploadRequest] createPushzoneUploadRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createPushzoneUploadWithHttpInfo(
    String pushzoneId, {
    CreatePushzoneUploadRequest? createPushzoneUploadRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}/files'
        .replaceAll('{pushzone-id}', pushzoneId);

    // ignore: prefer_final_locals
    Object? postBody = createPushzoneUploadRequest;

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

  /// Create CDN Push Zone File Upload Endpoint
  ///
  /// Create a presigned post endpoint that can be used to upload a file to your Push Zone.  After sending this request you must send a second POST request to the returned URL. Include all of the returned inputs as form-data fields using the same key and value.  You must also include a field named \"file\" that holds the file to be uploaded.
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [CreatePushzoneUploadRequest] createPushzoneUploadRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreatePushzoneUpload201Response?> createPushzoneUpload(
    String pushzoneId, {
    CreatePushzoneUploadRequest? createPushzoneUploadRequest,
  }) async {
    final response = await createPushzoneUploadWithHttpInfo(
      pushzoneId,
      createPushzoneUploadRequest: createPushzoneUploadRequest,
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
        'CreatePushzoneUpload201Response',
      ) as CreatePushzoneUpload201Response;
    }
    return null;
  }

  /// Delete CDN Pullzone
  ///
  /// Delete a CDN Pull Zone.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  Future<Response> deletePullzoneWithHttpInfo(
    String pullzoneId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/pull-zones/{pullzone-id}'
        .replaceAll('{pullzone-id}', pullzoneId);

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

  /// Delete CDN Pullzone
  ///
  /// Delete a CDN Pull Zone.
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  Future<void> deletePullzone(
    String pullzoneId,
  ) async {
    final response = await deletePullzoneWithHttpInfo(
      pullzoneId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete CDN Pushzone
  ///
  /// Delete a CDN Push Zone.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  Future<Response> deletePushzoneWithHttpInfo(
    String pushzoneId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}'
        .replaceAll('{pushzone-id}', pushzoneId);

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

  /// Delete CDN Pushzone
  ///
  /// Delete a CDN Push Zone.
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  Future<void> deletePushzone(
    String pushzoneId,
  ) async {
    final response = await deletePushzoneWithHttpInfo(
      pushzoneId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete CDN Pushzone File
  ///
  /// Delete a CDN Push Zone file.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [String] fileName (required):
  ///   The [File Name](#operation/list-pushzone-files).
  Future<Response> deletePushzoneFileWithHttpInfo(
    String pushzoneId,
    String fileName,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}/files/{file-name}'
        .replaceAll('{pushzone-id}', pushzoneId)
        .replaceAll('{file-name}', fileName);

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

  /// Delete CDN Pushzone File
  ///
  /// Delete a CDN Push Zone file.
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [String] fileName (required):
  ///   The [File Name](#operation/list-pushzone-files).
  Future<void> deletePushzoneFile(
    String pushzoneId,
    String fileName,
  ) async {
    final response = await deletePushzoneFileWithHttpInfo(
      pushzoneId,
      fileName,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get CDN Pull Zone
  ///
  /// Get information about a CDN Pull Zones
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  Future<Response> getPullzoneWithHttpInfo(
    String pullzoneId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/pull-zones/{pullzone-id}'
        .replaceAll('{pullzone-id}', pullzoneId);

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

  /// Get CDN Pull Zone
  ///
  /// Get information about a CDN Pull Zones
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  Future<CreatePullzone201Response?> getPullzone(
    String pullzoneId,
  ) async {
    final response = await getPullzoneWithHttpInfo(
      pullzoneId,
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
        'CreatePullzone201Response',
      ) as CreatePullzone201Response;
    }
    return null;
  }

  /// Get CDN Push Zone
  ///
  /// Get information about a CDN Push Zone
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  Future<Response> getPushzoneWithHttpInfo(
    String pushzoneId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}'
        .replaceAll('{pushzone-id}', pushzoneId);

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

  /// Get CDN Push Zone
  ///
  /// Get information about a CDN Push Zone
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  Future<CreatePushzone201Response?> getPushzone(
    String pushzoneId,
  ) async {
    final response = await getPushzoneWithHttpInfo(
      pushzoneId,
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
        'CreatePushzone201Response',
      ) as CreatePushzone201Response;
    }
    return null;
  }

  /// List CDN Push Zone Files
  ///
  /// Get a list of files that have been uploaded to a specific CDN Push Zones
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  Future<Response> getPushzoneFilesWithHttpInfo(
    String pushzoneId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}/files'
        .replaceAll('{pushzone-id}', pushzoneId);

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

  /// List CDN Push Zone Files
  ///
  /// Get a list of files that have been uploaded to a specific CDN Push Zones
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  Future<GetPushzoneFiles200Response?> getPushzoneFiles(
    String pushzoneId,
  ) async {
    final response = await getPushzoneFilesWithHttpInfo(
      pushzoneId,
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
        'GetPushzoneFiles200Response',
      ) as GetPushzoneFiles200Response;
    }
    return null;
  }

  /// Get CDN Push Zone File
  ///
  /// Get information about a CDN Push Zone file
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [String] fileName (required):
  ///   The [File Name](#operation/list-pushzone-files).
  Future<Response> getPushzone_1WithHttpInfo(
    String pushzoneId,
    String fileName,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}/files/{file-name}'
        .replaceAll('{pushzone-id}', pushzoneId)
        .replaceAll('{file-name}', fileName);

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

  /// Get CDN Push Zone File
  ///
  /// Get information about a CDN Push Zone file
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [String] fileName (required):
  ///   The [File Name](#operation/list-pushzone-files).
  Future<GetPushzone200Response?> getPushzone_1(
    String pushzoneId,
    String fileName,
  ) async {
    final response = await getPushzone_1WithHttpInfo(
      pushzoneId,
      fileName,
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
        'GetPushzone200Response',
      ) as GetPushzone200Response;
    }
    return null;
  }

  /// List CDN Pull Zones
  ///
  /// List CDN Pull Zones
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listPullzonesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/pull-zones';

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

  /// List CDN Pull Zones
  ///
  /// List CDN Pull Zones
  Future<ListPullzones200Response?> listPullzones() async {
    final response = await listPullzonesWithHttpInfo();
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
        'ListPullzones200Response',
      ) as ListPullzones200Response;
    }
    return null;
  }

  /// List CDN Push Zones
  ///
  /// List CDN Push Zones
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listPushzonesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones';

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

  /// List CDN Push Zones
  ///
  /// List CDN Push Zones
  Future<ListPushzones200Response?> listPushzones() async {
    final response = await listPushzonesWithHttpInfo();
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
        'ListPushzones200Response',
      ) as ListPushzones200Response;
    }
    return null;
  }

  /// Purge CDN Pull Zone
  ///
  /// Clears cached content on server proxies so that visitors can get the latest page versions.  **Note:** This action may only be performed once every six hours.  **Note:** This action may take a few extra seconds to complete.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  Future<Response> purgePullzoneWithHttpInfo(
    String pullzoneId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/pull-zones/{pullzone-id}/purge'
        .replaceAll('{pullzone-id}', pullzoneId);

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

  /// Purge CDN Pull Zone
  ///
  /// Clears cached content on server proxies so that visitors can get the latest page versions.  **Note:** This action may only be performed once every six hours.  **Note:** This action may take a few extra seconds to complete.
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  Future<List<String>?> purgePullzone(
    String pullzoneId,
  ) async {
    final response = await purgePullzoneWithHttpInfo(
      pullzoneId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<String>')
              as List)
          .cast<String>()
          .toList(growable: false);
    }
    return null;
  }

  /// Update CDN Pull Zone
  ///
  /// Update information for a CDN Pullzone. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  ///
  /// * [UpdatePullzoneRequest] updatePullzoneRequest:
  Future<Response> updatePullzoneWithHttpInfo(
    String pullzoneId, {
    UpdatePullzoneRequest? updatePullzoneRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/pull-zones/{pullzone-id}'
        .replaceAll('{pullzone-id}', pullzoneId);

    // ignore: prefer_final_locals
    Object? postBody = updatePullzoneRequest;

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

  /// Update CDN Pull Zone
  ///
  /// Update information for a CDN Pullzone. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Parameters:
  ///
  /// * [String] pullzoneId (required):
  ///   The [Pull Zone ID](#operation/list-pullzones).
  ///
  /// * [UpdatePullzoneRequest] updatePullzoneRequest:
  Future<CreatePullzone201Response?> updatePullzone(
    String pullzoneId, {
    UpdatePullzoneRequest? updatePullzoneRequest,
  }) async {
    final response = await updatePullzoneWithHttpInfo(
      pullzoneId,
      updatePullzoneRequest: updatePullzoneRequest,
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
        'CreatePullzone201Response',
      ) as CreatePullzone201Response;
    }
    return null;
  }

  /// Update CDN Push Zone
  ///
  /// Update information for a CDN Pushzone. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [UpdatePushzoneRequest] updatePushzoneRequest:
  Future<Response> updatePushzoneWithHttpInfo(
    String pushzoneId, {
    UpdatePushzoneRequest? updatePushzoneRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/cdns/push-zones/{pushzone-id}'
        .replaceAll('{pushzone-id}', pushzoneId);

    // ignore: prefer_final_locals
    Object? postBody = updatePushzoneRequest;

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

  /// Update CDN Push Zone
  ///
  /// Update information for a CDN Pushzone. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Parameters:
  ///
  /// * [String] pushzoneId (required):
  ///   The [Push Zone ID](#operation/list-pushzones).
  ///
  /// * [UpdatePushzoneRequest] updatePushzoneRequest:
  Future<CreatePushzone201Response?> updatePushzone(
    String pushzoneId, {
    UpdatePushzoneRequest? updatePushzoneRequest,
  }) async {
    final response = await updatePushzoneWithHttpInfo(
      pushzoneId,
      updatePushzoneRequest: updatePushzoneRequest,
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
        'CreatePushzone201Response',
      ) as CreatePushzone201Response;
    }
    return null;
  }
}
