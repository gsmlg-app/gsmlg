//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiKeysApi {
  ApiKeysApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create API Key
  ///
  /// Adds an API key to the currently authenticated user's API key list.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateUserApiKeyRequest] createUserApiKeyRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createApiKeyWithHttpInfo({
    CreateUserApiKeyRequest? createUserApiKeyRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/apikeys';

    // ignore: prefer_final_locals
    Object? postBody = createUserApiKeyRequest;

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

  /// Create API Key
  ///
  /// Adds an API key to the currently authenticated user's API key list.
  ///
  /// Parameters:
  ///
  /// * [CreateUserApiKeyRequest] createUserApiKeyRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<GetUserApiKey200Response?> createApiKey({
    CreateUserApiKeyRequest? createUserApiKeyRequest,
  }) async {
    final response = await createApiKeyWithHttpInfo(
      createUserApiKeyRequest: createUserApiKeyRequest,
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
        'GetUserApiKey200Response',
      ) as GetUserApiKey200Response;
    }
    return null;
  }

  /// Delete API Key
  ///
  /// Delete an API key from the currently authenticated user's API key list.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> deleteApiKeyWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/apikeys/{apikey-id}';

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

  /// Delete API Key
  ///
  /// Delete an API key from the currently authenticated user's API key list.
  Future<void> deleteApiKey() async {
    final response = await deleteApiKeyWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get API Key
  ///
  /// Gets information about an API key for the currently authenticated user. API keys returned by this method are masked.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getApiKeyWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/apikeys/{apikey-id}';

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

  /// Get API Key
  ///
  /// Gets information about an API key for the currently authenticated user. API keys returned by this method are masked.
  Future<GetUserApiKey200Response?> getApiKey() async {
    final response = await getApiKeyWithHttpInfo();
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
        'GetUserApiKey200Response',
      ) as GetUserApiKey200Response;
    }
    return null;
  }

  /// List API Keys
  ///
  /// Gets all API keys for the currently authenticated user. API keys returned by this method are masked.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listApiKeysWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/apikeys';

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

  /// List API Keys
  ///
  /// Gets all API keys for the currently authenticated user. API keys returned by this method are masked.
  Future<ListUserApiKeys200Response?> listApiKeys() async {
    final response = await listApiKeysWithHttpInfo();
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
        'ListUserApiKeys200Response',
      ) as ListUserApiKeys200Response;
    }
    return null;
  }
}
