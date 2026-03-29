//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoadBalancerApi {
  LoadBalancerApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Load Balancer
  ///
  /// Create a new Load Balancer in a particular `region`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateLoadBalancerRequest] createLoadBalancerRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createLoadBalancerWithHttpInfo({
    CreateLoadBalancerRequest? createLoadBalancerRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers';

    // ignore: prefer_final_locals
    Object? postBody = createLoadBalancerRequest;

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

  /// Create Load Balancer
  ///
  /// Create a new Load Balancer in a particular `region`.
  ///
  /// Parameters:
  ///
  /// * [CreateLoadBalancerRequest] createLoadBalancerRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateLoadBalancer202Response?> createLoadBalancer({
    CreateLoadBalancerRequest? createLoadBalancerRequest,
  }) async {
    final response = await createLoadBalancerWithHttpInfo(
      createLoadBalancerRequest: createLoadBalancerRequest,
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
        'CreateLoadBalancer202Response',
      ) as CreateLoadBalancer202Response;
    }
    return null;
  }

  /// Create Forwarding Rule
  ///
  /// Create a new forwarding rule for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [CreateLoadBalancerForwardingRulesRequest] createLoadBalancerForwardingRulesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createLoadBalancerForwardingRulesWithHttpInfo(
    String loadBalancerId, {
    CreateLoadBalancerForwardingRulesRequest?
        createLoadBalancerForwardingRulesRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/forwarding-rules'
        .replaceAll('{load-balancer-id}', loadBalancerId);

    // ignore: prefer_final_locals
    Object? postBody = createLoadBalancerForwardingRulesRequest;

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

  /// Create Forwarding Rule
  ///
  /// Create a new forwarding rule for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [CreateLoadBalancerForwardingRulesRequest] createLoadBalancerForwardingRulesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createLoadBalancerForwardingRules(
    String loadBalancerId, {
    CreateLoadBalancerForwardingRulesRequest?
        createLoadBalancerForwardingRulesRequest,
  }) async {
    final response = await createLoadBalancerForwardingRulesWithHttpInfo(
      loadBalancerId,
      createLoadBalancerForwardingRulesRequest:
          createLoadBalancerForwardingRulesRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Reverse DNS IPV4
  ///
  /// Update (ipv4) Reverse DNS for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [CreateLoadBalancerReverseDnsIpv4Request] createLoadBalancerReverseDnsIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createLoadBalancerReverseDnsIpv4WithHttpInfo(
    String loadBalancerId, {
    CreateLoadBalancerReverseDnsIpv4Request?
        createLoadBalancerReverseDnsIpv4Request,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/reverse-dns'
        .replaceAll('{load-balancer-id}', loadBalancerId);

    // ignore: prefer_final_locals
    Object? postBody = createLoadBalancerReverseDnsIpv4Request;

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

  /// Update Reverse DNS IPV4
  ///
  /// Update (ipv4) Reverse DNS for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [CreateLoadBalancerReverseDnsIpv4Request] createLoadBalancerReverseDnsIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createLoadBalancerReverseDnsIpv4(
    String loadBalancerId, {
    CreateLoadBalancerReverseDnsIpv4Request?
        createLoadBalancerReverseDnsIpv4Request,
  }) async {
    final response = await createLoadBalancerReverseDnsIpv4WithHttpInfo(
      loadBalancerId,
      createLoadBalancerReverseDnsIpv4Request:
          createLoadBalancerReverseDnsIpv4Request,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create Reverse DNS IPV6
  ///
  /// Create Reverse DNS (ipv6) for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [CreateLoadBalancerReverseDnsIpv6Request] createLoadBalancerReverseDnsIpv6Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createLoadBalancerReverseDnsIpv6WithHttpInfo(
    String loadBalancerId, {
    CreateLoadBalancerReverseDnsIpv6Request?
        createLoadBalancerReverseDnsIpv6Request,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/reverse-dns'
        .replaceAll('{load-balancer-id}', loadBalancerId);

    // ignore: prefer_final_locals
    Object? postBody = createLoadBalancerReverseDnsIpv6Request;

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

  /// Create Reverse DNS IPV6
  ///
  /// Create Reverse DNS (ipv6) for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [CreateLoadBalancerReverseDnsIpv6Request] createLoadBalancerReverseDnsIpv6Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createLoadBalancerReverseDnsIpv6(
    String loadBalancerId, {
    CreateLoadBalancerReverseDnsIpv6Request?
        createLoadBalancerReverseDnsIpv6Request,
  }) async {
    final response = await createLoadBalancerReverseDnsIpv6WithHttpInfo(
      loadBalancerId,
      createLoadBalancerReverseDnsIpv6Request:
          createLoadBalancerReverseDnsIpv6Request,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Load Balancer
  ///
  /// Delete a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<Response> deleteLoadBalancerWithHttpInfo(
    String loadBalancerId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// Delete Load Balancer
  ///
  /// Delete a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<void> deleteLoadBalancer(
    String loadBalancerId,
  ) async {
    final response = await deleteLoadBalancerWithHttpInfo(
      loadBalancerId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Disable Load Balancer Auto SSL
  ///
  /// Disable a Load Balancer Auto SSL. This will not remove an ssl certificate from the load balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<Response> deleteLoadBalancerAutoSslWithHttpInfo(
    String loadBalancerId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/auto_ssl'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// Disable Load Balancer Auto SSL
  ///
  /// Disable a Load Balancer Auto SSL. This will not remove an ssl certificate from the load balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<void> deleteLoadBalancerAutoSsl(
    String loadBalancerId,
  ) async {
    final response = await deleteLoadBalancerAutoSslWithHttpInfo(
      loadBalancerId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Forwarding Rule
  ///
  /// Delete a Forwarding Rule on a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [String] forwardingRuleId (required):
  ///   The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules).
  Future<Response> deleteLoadBalancerForwardingRuleWithHttpInfo(
    String loadBalancerId,
    String forwardingRuleId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/load-balancers/{load-balancer-id}/forwarding-rules/{forwarding-rule-id}'
            .replaceAll('{load-balancer-id}', loadBalancerId)
            .replaceAll('{forwarding-rule-id}', forwardingRuleId);

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

  /// Delete Forwarding Rule
  ///
  /// Delete a Forwarding Rule on a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [String] forwardingRuleId (required):
  ///   The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules).
  Future<void> deleteLoadBalancerForwardingRule(
    String loadBalancerId,
    String forwardingRuleId,
  ) async {
    final response = await deleteLoadBalancerForwardingRuleWithHttpInfo(
      loadBalancerId,
      forwardingRuleId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Reverse DNS
  ///
  /// Delete a ipv6 reverse dns entry on a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<Response> deleteLoadBalancerReverseDnsWithHttpInfo(
    String loadBalancerId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/reverse-dns'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// Delete Reverse DNS
  ///
  /// Delete a ipv6 reverse dns entry on a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<void> deleteLoadBalancerReverseDns(
    String loadBalancerId,
  ) async {
    final response = await deleteLoadBalancerReverseDnsWithHttpInfo(
      loadBalancerId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Load Balancer SSL
  ///
  /// Delete a Load Balancer SSL.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<Response> deleteLoadBalancerSslWithHttpInfo(
    String loadBalancerId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/ssl'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// Delete Load Balancer SSL
  ///
  /// Delete a Load Balancer SSL.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<void> deleteLoadBalancerSsl(
    String loadBalancerId,
  ) async {
    final response = await deleteLoadBalancerSslWithHttpInfo(
      loadBalancerId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Load Balancer
  ///
  /// Get information for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<Response> getLoadBalancerWithHttpInfo(
    String loadBalancerId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// Get Load Balancer
  ///
  /// Get information for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<CreateLoadBalancer202Response?> getLoadBalancer(
    String loadBalancerId,
  ) async {
    final response = await getLoadBalancerWithHttpInfo(
      loadBalancerId,
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
        'CreateLoadBalancer202Response',
      ) as CreateLoadBalancer202Response;
    }
    return null;
  }

  /// Get Forwarding Rule
  ///
  /// Get information for a Forwarding Rule on a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [String] forwardingRuleId (required):
  ///   The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules).
  Future<Response> getLoadBalancerForwardingRuleWithHttpInfo(
    String loadBalancerId,
    String forwardingRuleId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/load-balancers/{load-balancer-id}/forwarding-rules/{forwarding-rule-id}'
            .replaceAll('{load-balancer-id}', loadBalancerId)
            .replaceAll('{forwarding-rule-id}', forwardingRuleId);

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

  /// Get Forwarding Rule
  ///
  /// Get information for a Forwarding Rule on a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [String] forwardingRuleId (required):
  ///   The [Forwarding Rule id](#operation/list-load-balancer-forwarding-rules).
  Future<GetLoadBalancerForwardingRule200Response?>
      getLoadBalancerForwardingRule(
    String loadBalancerId,
    String forwardingRuleId,
  ) async {
    final response = await getLoadBalancerForwardingRuleWithHttpInfo(
      loadBalancerId,
      forwardingRuleId,
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
        'GetLoadBalancerForwardingRule200Response',
      ) as GetLoadBalancerForwardingRule200Response;
    }
    return null;
  }

  /// Get Reverse DNS
  ///
  /// Get Reverse DNS information for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<Response> getLoadBalancerReverseDnsWithHttpInfo(
    String loadBalancerId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/reverse-dns'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// Get Reverse DNS
  ///
  /// Get Reverse DNS information for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  Future<GetLoadBalancerReverseDns200Response?> getLoadBalancerReverseDns(
    String loadBalancerId,
  ) async {
    final response = await getLoadBalancerReverseDnsWithHttpInfo(
      loadBalancerId,
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
        'GetLoadBalancerReverseDns200Response',
      ) as GetLoadBalancerReverseDns200Response;
    }
    return null;
  }

  /// Get Firewall Rule
  ///
  /// Get a firewall rule for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadbalancerId (required):
  ///
  /// * [String] firewallRuleId (required):
  Future<Response> getLoadbalancerFirewallRuleWithHttpInfo(
    String loadbalancerId,
    String firewallRuleId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/load-balancers/{loadbalancer-id}/firewall-rules/{firewall-rule-id}'
            .replaceAll('{loadbalancer-id}', loadbalancerId)
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
  /// Get a firewall rule for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadbalancerId (required):
  ///
  /// * [String] firewallRuleId (required):
  Future<LoadbalancerFirewallRule?> getLoadbalancerFirewallRule(
    String loadbalancerId,
    String firewallRuleId,
  ) async {
    final response = await getLoadbalancerFirewallRuleWithHttpInfo(
      loadbalancerId,
      firewallRuleId,
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
        'LoadbalancerFirewallRule',
      ) as LoadbalancerFirewallRule;
    }
    return null;
  }

  /// List Forwarding Rules
  ///
  /// List the fowarding rules for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listLoadBalancerForwardingRulesWithHttpInfo(
    String loadBalancerId, {
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}/forwarding-rules'
        .replaceAll('{load-balancer-id}', loadBalancerId);

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

  /// List Forwarding Rules
  ///
  /// List the fowarding rules for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListLoadBalancerForwardingRules200Response?>
      listLoadBalancerForwardingRules(
    String loadBalancerId, {
    int? perPage,
    String? cursor,
  }) async {
    final response = await listLoadBalancerForwardingRulesWithHttpInfo(
      loadBalancerId,
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
        'ListLoadBalancerForwardingRules200Response',
      ) as ListLoadBalancerForwardingRules200Response;
    }
    return null;
  }

  /// List Load Balancers
  ///
  /// List the Load Balancers in your account.
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
  Future<Response> listLoadBalancersWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers';

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

  /// List Load Balancers
  ///
  /// List the Load Balancers in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListLoadBalancers200Response?> listLoadBalancers({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listLoadBalancersWithHttpInfo(
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
        'ListLoadBalancers200Response',
      ) as ListLoadBalancers200Response;
    }
    return null;
  }

  /// List Firewall Rules
  ///
  /// List the firewall rules for a Load Balancer.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadbalancerId (required):
  ///
  /// * [String] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listLoadbalancerFirewallRulesWithHttpInfo(
    String loadbalancerId, {
    String? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{loadbalancer-id}/firewall-rules'
        .replaceAll('{loadbalancer-id}', loadbalancerId);

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
  /// List the firewall rules for a Load Balancer.
  ///
  /// Parameters:
  ///
  /// * [String] loadbalancerId (required):
  ///
  /// * [String] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<LoadbalancerFirewallRule?> listLoadbalancerFirewallRules(
    String loadbalancerId, {
    String? perPage,
    String? cursor,
  }) async {
    final response = await listLoadbalancerFirewallRulesWithHttpInfo(
      loadbalancerId,
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
        'LoadbalancerFirewallRule',
      ) as LoadbalancerFirewallRule;
    }
    return null;
  }

  /// Update Load Balancer
  ///
  /// Update information for a Load Balancer. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [UpdateLoadBalancerRequest] updateLoadBalancerRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateLoadBalancerWithHttpInfo(
    String loadBalancerId, {
    UpdateLoadBalancerRequest? updateLoadBalancerRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/load-balancers/{load-balancer-id}'
        .replaceAll('{load-balancer-id}', loadBalancerId);

    // ignore: prefer_final_locals
    Object? postBody = updateLoadBalancerRequest;

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

  /// Update Load Balancer
  ///
  /// Update information for a Load Balancer. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Parameters:
  ///
  /// * [String] loadBalancerId (required):
  ///   The [Load Balancer id](#operation/list-load-balancers).
  ///
  /// * [UpdateLoadBalancerRequest] updateLoadBalancerRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateLoadBalancer(
    String loadBalancerId, {
    UpdateLoadBalancerRequest? updateLoadBalancerRequest,
  }) async {
    final response = await updateLoadBalancerWithHttpInfo(
      loadBalancerId,
      updateLoadBalancerRequest: updateLoadBalancerRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
