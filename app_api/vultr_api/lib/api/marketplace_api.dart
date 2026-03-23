//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MarketplaceApi {
  MarketplaceApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// List Marketplace App Variables
  ///
  /// List all user-supplied variables for a Marketplace App.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] imageId (required):
  ///   The application's [Image ID](#operation/list-applications).
  Future<Response> listMarketplaceAppVariablesWithHttpInfo(String imageId,) async {
    // ignore: prefer_const_declarations
    final path = r'/marketplace/apps/{image-id}/variables'
      .replaceAll('{image-id}', imageId);

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

  /// List Marketplace App Variables
  ///
  /// List all user-supplied variables for a Marketplace App.
  ///
  /// Parameters:
  ///
  /// * [String] imageId (required):
  ///   The application's [Image ID](#operation/list-applications).
  Future<ListMarketplaceAppVariables200Response?> listMarketplaceAppVariables(String imageId,) async {
    final response = await listMarketplaceAppVariablesWithHttpInfo(imageId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListMarketplaceAppVariables200Response',) as ListMarketplaceAppVariables200Response;
    
    }
    return null;
  }
}
