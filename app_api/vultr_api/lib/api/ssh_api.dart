//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SshApi {
  SshApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create SSH key
  ///
  /// Create a new SSH Key for use with future instances. This does not update any running instances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateSshKeyRequest] createSshKeyRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createSshKeyWithHttpInfo({
    CreateSshKeyRequest? createSshKeyRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/ssh-keys';

    // ignore: prefer_final_locals
    Object? postBody = createSshKeyRequest;

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

  /// Create SSH key
  ///
  /// Create a new SSH Key for use with future instances. This does not update any running instances.
  ///
  /// Parameters:
  ///
  /// * [CreateSshKeyRequest] createSshKeyRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetSshKey200Response?> createSshKey({
    CreateSshKeyRequest? createSshKeyRequest,
  }) async {
    final response = await createSshKeyWithHttpInfo(
      createSshKeyRequest: createSshKeyRequest,
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
        'GetSshKey200Response',
      ) as GetSshKey200Response;
    }
    return null;
  }

  /// Delete SSH Key
  ///
  /// Delete an SSH Key.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sshKeyId (required):
  ///   The [SSH Key id](#operation/list-ssh-keys).
  Future<Response> deleteSshKeyWithHttpInfo(
    String sshKeyId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/ssh-keys/{ssh-key-id}'.replaceAll('{ssh-key-id}', sshKeyId);

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

  /// Delete SSH Key
  ///
  /// Delete an SSH Key.
  ///
  /// Parameters:
  ///
  /// * [String] sshKeyId (required):
  ///   The [SSH Key id](#operation/list-ssh-keys).
  Future<void> deleteSshKey(
    String sshKeyId,
  ) async {
    final response = await deleteSshKeyWithHttpInfo(
      sshKeyId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get SSH Key
  ///
  /// Get information about an SSH Key.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sshKeyId (required):
  ///   The [SSH Key id](#operation/list-ssh-keys).
  Future<Response> getSshKeyWithHttpInfo(
    String sshKeyId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/ssh-keys/{ssh-key-id}'.replaceAll('{ssh-key-id}', sshKeyId);

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

  /// Get SSH Key
  ///
  /// Get information about an SSH Key.
  ///
  /// Parameters:
  ///
  /// * [String] sshKeyId (required):
  ///   The [SSH Key id](#operation/list-ssh-keys).
  Future<GetSshKey200Response?> getSshKey(
    String sshKeyId,
  ) async {
    final response = await getSshKeyWithHttpInfo(
      sshKeyId,
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
        'GetSshKey200Response',
      ) as GetSshKey200Response;
    }
    return null;
  }

  /// List SSH Keys
  ///
  /// List all SSH Keys in your account.
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
  Future<Response> listSshKeysWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/ssh-keys';

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

  /// List SSH Keys
  ///
  /// List all SSH Keys in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListSshKeys200Response?> listSshKeys({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listSshKeysWithHttpInfo(
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
        'ListSshKeys200Response',
      ) as ListSshKeys200Response;
    }
    return null;
  }

  /// Update SSH Key
  ///
  /// Update an SSH Key. The attributes `name` and `ssh_key` are optional. If not set, the attributes will retain their original values. New deployments will use the updated key, but this action does not update previously deployed instances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sshKeyId (required):
  ///   The [SSH Key id](#operation/list-ssh-keys).
  ///
  /// * [UpdateSshKeyRequest] updateSshKeyRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateSshKeyWithHttpInfo(
    String sshKeyId, {
    UpdateSshKeyRequest? updateSshKeyRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/ssh-keys/{ssh-key-id}'.replaceAll('{ssh-key-id}', sshKeyId);

    // ignore: prefer_final_locals
    Object? postBody = updateSshKeyRequest;

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

  /// Update SSH Key
  ///
  /// Update an SSH Key. The attributes `name` and `ssh_key` are optional. If not set, the attributes will retain their original values. New deployments will use the updated key, but this action does not update previously deployed instances.
  ///
  /// Parameters:
  ///
  /// * [String] sshKeyId (required):
  ///   The [SSH Key id](#operation/list-ssh-keys).
  ///
  /// * [UpdateSshKeyRequest] updateSshKeyRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateSshKey(
    String sshKeyId, {
    UpdateSshKeyRequest? updateSshKeyRequest,
  }) async {
    final response = await updateSshKeyWithHttpInfo(
      sshKeyId,
      updateSshKeyRequest: updateSshKeyRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
