//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class UsersApi {
  UsersApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Add IP to User Whitelist
  ///
  /// Add an IP address or subnet to a User's whitelist. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [AddUserIpWhitelistRequest] addUserIpWhitelistRequest:
  Future<Response> addUserIpWhitelistWithHttpInfo(String userId, { AddUserIpWhitelistRequest? addUserIpWhitelistRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/ip-whitelist'
      .replaceAll('{user-id}', userId);

    // ignore: prefer_final_locals
    Object? postBody = addUserIpWhitelistRequest;

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

  /// Add IP to User Whitelist
  ///
  /// Add an IP address or subnet to a User's whitelist. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [AddUserIpWhitelistRequest] addUserIpWhitelistRequest:
  Future<void> addUserIpWhitelist(String userId, { AddUserIpWhitelistRequest? addUserIpWhitelistRequest, }) async {
    final response = await addUserIpWhitelistWithHttpInfo(userId,  addUserIpWhitelistRequest: addUserIpWhitelistRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create User
  ///
  /// Create a new User. The `email`, `first_name`, `last_name`, and `password` attributes are required.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateUserRequest] createUserRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createUserWithHttpInfo({ CreateUserRequest? createUserRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/users';

    // ignore: prefer_final_locals
    Object? postBody = createUserRequest;

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

  /// Create User
  ///
  /// Create a new User. The `email`, `first_name`, `last_name`, and `password` attributes are required.
  ///
  /// Parameters:
  ///
  /// * [CreateUserRequest] createUserRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<User?> createUser({ CreateUserRequest? createUserRequest, }) async {
    final response = await createUserWithHttpInfo( createUserRequest: createUserRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
    }
    return null;
  }

  /// Create User API Key
  ///
  /// Adds an API key to the target user's API key list. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [CreateUserApiKeyRequest] createUserApiKeyRequest:
  Future<Response> createUserApiKeyWithHttpInfo(String userId, { CreateUserApiKeyRequest? createUserApiKeyRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/apikeys'
      .replaceAll('{user-id}', userId);

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

  /// Create User API Key
  ///
  /// Adds an API key to the target user's API key list. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [CreateUserApiKeyRequest] createUserApiKeyRequest:
  Future<void> createUserApiKey(String userId, { CreateUserApiKeyRequest? createUserApiKeyRequest, }) async {
    final response = await createUserApiKeyWithHttpInfo(userId,  createUserApiKeyRequest: createUserApiKeyRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete User
  ///
  /// Delete a User.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<Response> deleteUserWithHttpInfo(String userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}'
      .replaceAll('{user-id}', userId);

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

  /// Delete User
  ///
  /// Delete a User.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<void> deleteUser(String userId,) async {
    final response = await deleteUserWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete User API Key
  ///
  /// Delete an API key from the target user's API key list. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [String] apikeyId (required):
  ///   The [API key id](#operation/list-user-api-keys).
  Future<Response> deleteUserApiKeyWithHttpInfo(String userId, String apikeyId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/apikeys/{apikey-id}'
      .replaceAll('{user-id}', userId)
      .replaceAll('{apikey-id}', apikeyId);

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

  /// Delete User API Key
  ///
  /// Delete an API key from the target user's API key list. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [String] apikeyId (required):
  ///   The [API key id](#operation/list-user-api-keys).
  Future<void> deleteUserApiKey(String userId, String apikeyId,) async {
    final response = await deleteUserApiKeyWithHttpInfo(userId, apikeyId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get User
  ///
  /// Get information about a User.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<Response> getUserWithHttpInfo(String userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}'
      .replaceAll('{user-id}', userId);

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

  /// Get User
  ///
  /// Get information about a User.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<User?> getUser(String userId,) async {
    final response = await getUserWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
    }
    return null;
  }

  /// Get User API Key
  ///
  /// Gets information about a user's API key. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [String] apikeyId (required):
  ///   The [API key id](#operation/list-user-api-keys).
  Future<Response> getUserApiKeyWithHttpInfo(String userId, String apikeyId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/apikeys/{apikey-id}'
      .replaceAll('{user-id}', userId)
      .replaceAll('{apikey-id}', apikeyId);

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

  /// Get User API Key
  ///
  /// Gets information about a user's API key. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [String] apikeyId (required):
  ///   The [API key id](#operation/list-user-api-keys).
  Future<GetUserApiKey200Response?> getUserApiKey(String userId, String apikeyId,) async {
    final response = await getUserApiKeyWithHttpInfo(userId, apikeyId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetUserApiKey200Response',) as GetUserApiKey200Response;
    
    }
    return null;
  }

  /// Get User IP Whitelist Entry
  ///
  /// Get a specific IP whitelist entry for a User. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [String] subnet (required):
  ///   The IP address or subnet.
  ///
  /// * [int] subnetSize (required):
  ///   The subnet size.
  Future<Response> getUserIpWhitelistEntryWithHttpInfo(String userId, String subnet, int subnetSize,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/ip-whitelist/entry'
      .replaceAll('{user-id}', userId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'subnet', subnet));
      queryParams.addAll(_queryParams('', 'subnet_size', subnetSize));

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

  /// Get User IP Whitelist Entry
  ///
  /// Get a specific IP whitelist entry for a User. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [String] subnet (required):
  ///   The IP address or subnet.
  ///
  /// * [int] subnetSize (required):
  ///   The subnet size.
  Future<GetUserIpWhitelistEntry200Response?> getUserIpWhitelistEntry(String userId, String subnet, int subnetSize,) async {
    final response = await getUserIpWhitelistEntryWithHttpInfo(userId, subnet, subnetSize,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetUserIpWhitelistEntry200Response',) as GetUserIpWhitelistEntry200Response;
    
    }
    return null;
  }

  /// List User API Keys
  ///
  /// Gets all API keys for the target user. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<Response> listUserApiKeysWithHttpInfo(String userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/apikeys'
      .replaceAll('{user-id}', userId);

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

  /// List User API Keys
  ///
  /// Gets all API keys for the target user. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<ListUserApiKeys200Response?> listUserApiKeys(String userId,) async {
    final response = await listUserApiKeysWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListUserApiKeys200Response',) as ListUserApiKeys200Response;
    
    }
    return null;
  }

  /// List User IP Whitelist
  ///
  /// Get the IP whitelist for a User. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<Response> listUserIpWhitelistWithHttpInfo(String userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/ip-whitelist'
      .replaceAll('{user-id}', userId);

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

  /// List User IP Whitelist
  ///
  /// Get the IP whitelist for a User. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  Future<ListUserIpWhitelist200Response?> listUserIpWhitelist(String userId,) async {
    final response = await listUserIpWhitelistWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListUserIpWhitelist200Response',) as ListUserIpWhitelist200Response;
    
    }
    return null;
  }

  /// Get Users
  ///
  /// Get a list of all Users in your account.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listUsersWithHttpInfo({ num? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/users';

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

  /// Get Users
  ///
  /// Get a list of all Users in your account.
  ///
  /// Parameters:
  ///
  /// * [num] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListUsers200Response?> listUsers({ num? perPage, String? cursor, }) async {
    final response = await listUsersWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListUsers200Response',) as ListUsers200Response;
    
    }
    return null;
  }

  /// Remove IP from User Whitelist
  ///
  /// Remove an IP address or subnet from a User's whitelist. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [RemoveUserIpWhitelistRequest] removeUserIpWhitelistRequest:
  Future<Response> removeUserIpWhitelistWithHttpInfo(String userId, { RemoveUserIpWhitelistRequest? removeUserIpWhitelistRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}/ip-whitelist'
      .replaceAll('{user-id}', userId);

    // ignore: prefer_final_locals
    Object? postBody = removeUserIpWhitelistRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


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

  /// Remove IP from User Whitelist
  ///
  /// Remove an IP address or subnet from a User's whitelist. Only root users or users with manage users permission can access this endpoint.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [RemoveUserIpWhitelistRequest] removeUserIpWhitelistRequest:
  Future<void> removeUserIpWhitelist(String userId, { RemoveUserIpWhitelistRequest? removeUserIpWhitelistRequest, }) async {
    final response = await removeUserIpWhitelistWithHttpInfo(userId,  removeUserIpWhitelistRequest: removeUserIpWhitelistRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update User
  ///
  /// Update information for a User. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [UpdateUserRequest] updateUserRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateUserWithHttpInfo(String userId, { UpdateUserRequest? updateUserRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{user-id}'
      .replaceAll('{user-id}', userId);

    // ignore: prefer_final_locals
    Object? postBody = updateUserRequest;

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

  /// Update User
  ///
  /// Update information for a User. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   The [User id](#operation/list-users).
  ///
  /// * [UpdateUserRequest] updateUserRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateUser(String userId, { UpdateUserRequest? updateUserRequest, }) async {
    final response = await updateUserWithHttpInfo(userId,  updateUserRequest: updateUserRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
