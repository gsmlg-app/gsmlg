//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AccountApi {
  AccountApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Account Info
  ///
  /// Get your Vultr account, permission, and billing information.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAccountWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/account';

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

  /// Get Account Info
  ///
  /// Get your Vultr account, permission, and billing information.
  Future<GetAccount200Response?> getAccount() async {
    final response = await getAccountWithHttpInfo();
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
        'GetAccount200Response',
      ) as GetAccount200Response;
    }
    return null;
  }

  /// Get Account Bandwidth Info
  ///
  /// Get your Vultr account bandwidth information.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAccountBandwidthWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/account/bandwidth';

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

  /// Get Account Bandwidth Info
  ///
  /// Get your Vultr account bandwidth information.
  Future<GetAccountBandwidth200Response?> getAccountBandwidth() async {
    final response = await getAccountBandwidthWithHttpInfo();
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
        'GetAccountBandwidth200Response',
      ) as GetAccountBandwidth200Response;
    }
    return null;
  }

  /// Get Account BGP Info
  ///
  /// Get your Vultr account BGP information.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAccountBgpWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/account/bgp';

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

  /// Get Account BGP Info
  ///
  /// Get your Vultr account BGP information.
  Future<AccountBgp?> getAccountBgp() async {
    final response = await getAccountBgpWithHttpInfo();
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
        'AccountBgp',
      ) as AccountBgp;
    }
    return null;
  }
}
