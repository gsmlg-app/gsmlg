//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class FirewallApi {
  FirewallApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Firewall Group
  ///
  /// Create a new Firewall Group.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateFirewallGroupRequest] createFirewallGroupRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createFirewallGroupWithHttpInfo({ CreateFirewallGroupRequest? createFirewallGroupRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls';

    // ignore: prefer_final_locals
    Object? postBody = createFirewallGroupRequest;

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

  /// Create Firewall Group
  ///
  /// Create a new Firewall Group.
  ///
  /// Parameters:
  ///
  /// * [CreateFirewallGroupRequest] createFirewallGroupRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateFirewallGroup201Response?> createFirewallGroup({ CreateFirewallGroupRequest? createFirewallGroupRequest, }) async {
    final response = await createFirewallGroupWithHttpInfo( createFirewallGroupRequest: createFirewallGroupRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateFirewallGroup201Response',) as CreateFirewallGroup201Response;
    
    }
    return null;
  }

  /// Delete Firewall Group
  ///
  /// Delete a Firewall Group.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  Future<Response> deleteFirewallGroupWithHttpInfo(String firewallGroupId,) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}'
      .replaceAll('{firewall-group-id}', firewallGroupId);

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

  /// Delete Firewall Group
  ///
  /// Delete a Firewall Group.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  Future<void> deleteFirewallGroup(String firewallGroupId,) async {
    final response = await deleteFirewallGroupWithHttpInfo(firewallGroupId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Firewall Rule
  ///
  /// Delete a Firewall Rule.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [String] firewallRuleId (required):
  ///   The [Firewall Rule id](#operation/list-firewall-group-rules).
  Future<Response> deleteFirewallGroupRuleWithHttpInfo(String firewallGroupId, String firewallRuleId,) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}/rules/{firewall-rule-id}'
      .replaceAll('{firewall-group-id}', firewallGroupId)
      .replaceAll('{firewall-rule-id}', firewallRuleId);

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

  /// Delete Firewall Rule
  ///
  /// Delete a Firewall Rule.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [String] firewallRuleId (required):
  ///   The [Firewall Rule id](#operation/list-firewall-group-rules).
  Future<void> deleteFirewallGroupRule(String firewallGroupId, String firewallRuleId,) async {
    final response = await deleteFirewallGroupRuleWithHttpInfo(firewallGroupId, firewallRuleId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Firewall Group
  ///
  /// Get information for a Firewall Group.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  Future<Response> getFirewallGroupWithHttpInfo(String firewallGroupId,) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}'
      .replaceAll('{firewall-group-id}', firewallGroupId);

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

  /// Get Firewall Group
  ///
  /// Get information for a Firewall Group.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  Future<CreateFirewallGroup201Response?> getFirewallGroup(String firewallGroupId,) async {
    final response = await getFirewallGroupWithHttpInfo(firewallGroupId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateFirewallGroup201Response',) as CreateFirewallGroup201Response;
    
    }
    return null;
  }

  /// Get Firewall Rule
  ///
  /// Get a Firewall Rule.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [String] firewallRuleId (required):
  ///   The [Firewall Rule id](#operation/list-firewall-group-rules).
  Future<Response> getFirewallGroupRuleWithHttpInfo(String firewallGroupId, String firewallRuleId,) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}/rules/{firewall-rule-id}'
      .replaceAll('{firewall-group-id}', firewallGroupId)
      .replaceAll('{firewall-rule-id}', firewallRuleId);

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

  /// Get Firewall Rule
  ///
  /// Get a Firewall Rule.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [String] firewallRuleId (required):
  ///   The [Firewall Rule id](#operation/list-firewall-group-rules).
  Future<PostFirewallsFirewallGroupIdRules201Response?> getFirewallGroupRule(String firewallGroupId, String firewallRuleId,) async {
    final response = await getFirewallGroupRuleWithHttpInfo(firewallGroupId, firewallRuleId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PostFirewallsFirewallGroupIdRules201Response',) as PostFirewallsFirewallGroupIdRules201Response;
    
    }
    return null;
  }

  /// List Firewall Rules
  ///
  /// Get the Firewall Rules for a Firewall Group.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listFirewallGroupRulesWithHttpInfo(String firewallGroupId, { int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}/rules'
      .replaceAll('{firewall-group-id}', firewallGroupId);

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

  /// List Firewall Rules
  ///
  /// Get the Firewall Rules for a Firewall Group.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListFirewallGroupRules200Response?> listFirewallGroupRules(String firewallGroupId, { int? perPage, String? cursor, }) async {
    final response = await listFirewallGroupRulesWithHttpInfo(firewallGroupId,  perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListFirewallGroupRules200Response',) as ListFirewallGroupRules200Response;
    
    }
    return null;
  }

  /// List Firewall Groups
  ///
  /// Get a list of all Firewall Groups.
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
  Future<Response> listFirewallGroupsWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls';

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

  /// List Firewall Groups
  ///
  /// Get a list of all Firewall Groups.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListFirewallGroups200Response?> listFirewallGroups({ int? perPage, String? cursor, }) async {
    final response = await listFirewallGroupsWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListFirewallGroups200Response',) as ListFirewallGroups200Response;
    
    }
    return null;
  }

  /// Create Firewall Rules
  ///
  /// Create a Firewall Rule for a Firewall Group. The attributes `ip_type`, `protocol`, `subnet`, and `subnet_size` are required.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [PostFirewallsFirewallGroupIdRulesRequest] postFirewallsFirewallGroupIdRulesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> postFirewallsFirewallGroupIdRulesWithHttpInfo(String firewallGroupId, { PostFirewallsFirewallGroupIdRulesRequest? postFirewallsFirewallGroupIdRulesRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}/rules'
      .replaceAll('{firewall-group-id}', firewallGroupId);

    // ignore: prefer_final_locals
    Object? postBody = postFirewallsFirewallGroupIdRulesRequest;

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

  /// Create Firewall Rules
  ///
  /// Create a Firewall Rule for a Firewall Group. The attributes `ip_type`, `protocol`, `subnet`, and `subnet_size` are required.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [PostFirewallsFirewallGroupIdRulesRequest] postFirewallsFirewallGroupIdRulesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<PostFirewallsFirewallGroupIdRules201Response?> postFirewallsFirewallGroupIdRules(String firewallGroupId, { PostFirewallsFirewallGroupIdRulesRequest? postFirewallsFirewallGroupIdRulesRequest, }) async {
    final response = await postFirewallsFirewallGroupIdRulesWithHttpInfo(firewallGroupId,  postFirewallsFirewallGroupIdRulesRequest: postFirewallsFirewallGroupIdRulesRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PostFirewallsFirewallGroupIdRules201Response',) as PostFirewallsFirewallGroupIdRules201Response;
    
    }
    return null;
  }

  /// Update Firewall Group
  ///
  /// Update information for a Firewall Group.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [UpdateFirewallGroupRequest] updateFirewallGroupRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateFirewallGroupWithHttpInfo(String firewallGroupId, { UpdateFirewallGroupRequest? updateFirewallGroupRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/firewalls/{firewall-group-id}'
      .replaceAll('{firewall-group-id}', firewallGroupId);

    // ignore: prefer_final_locals
    Object? postBody = updateFirewallGroupRequest;

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

  /// Update Firewall Group
  ///
  /// Update information for a Firewall Group.
  ///
  /// Parameters:
  ///
  /// * [String] firewallGroupId (required):
  ///   The [Firewall Group id](#operation/list-firewall-groups).
  ///
  /// * [UpdateFirewallGroupRequest] updateFirewallGroupRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateFirewallGroup(String firewallGroupId, { UpdateFirewallGroupRequest? updateFirewallGroupRequest, }) async {
    final response = await updateFirewallGroupWithHttpInfo(firewallGroupId,  updateFirewallGroupRequest: updateFirewallGroupRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
