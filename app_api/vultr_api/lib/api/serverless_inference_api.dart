//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ServerlessInferenceApi {
  ServerlessInferenceApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Serverless Inference
  ///
  /// Create a new Serverless Inference subscription.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateInferenceRequest] createInferenceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createInferenceWithHttpInfo({
    CreateInferenceRequest? createInferenceRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/inference';

    // ignore: prefer_final_locals
    Object? postBody = createInferenceRequest;

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

  /// Create Serverless Inference
  ///
  /// Create a new Serverless Inference subscription.
  ///
  /// Parameters:
  ///
  /// * [CreateInferenceRequest] createInferenceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateInference201Response?> createInference({
    CreateInferenceRequest? createInferenceRequest,
  }) async {
    final response = await createInferenceWithHttpInfo(
      createInferenceRequest: createInferenceRequest,
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
        'CreateInference201Response',
      ) as CreateInference201Response;
    }
    return null;
  }

  /// Delete Serverless Inference
  ///
  /// Delete a Serverless Inference subscription.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  Future<Response> deleteInferenceWithHttpInfo(
    String inferenceId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/inference/{inference-id}'.replaceAll('{inference-id}', inferenceId);

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

  /// Delete Serverless Inference
  ///
  /// Delete a Serverless Inference subscription.
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  Future<void> deleteInference(
    String inferenceId,
  ) async {
    final response = await deleteInferenceWithHttpInfo(
      inferenceId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Serverless Inference
  ///
  /// Get information about a Serverless Inference subscription.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  Future<Response> getInferenceWithHttpInfo(
    String inferenceId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/inference/{inference-id}'.replaceAll('{inference-id}', inferenceId);

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

  /// Get Serverless Inference
  ///
  /// Get information about a Serverless Inference subscription.
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  Future<CreateInference201Response?> getInference(
    String inferenceId,
  ) async {
    final response = await getInferenceWithHttpInfo(
      inferenceId,
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
        'CreateInference201Response',
      ) as CreateInference201Response;
    }
    return null;
  }

  /// Get Serverless Inference Usage Information
  ///
  /// Get usage information for a Serverless Inference subscription.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  Future<Response> getInferenceUsageWithHttpInfo(
    String inferenceId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/inference/{inference-id}/usage'
        .replaceAll('{inference-id}', inferenceId);

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

  /// Get Serverless Inference Usage Information
  ///
  /// Get usage information for a Serverless Inference subscription.
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  Future<GetInferenceUsage200Response?> getInferenceUsage(
    String inferenceId,
  ) async {
    final response = await getInferenceUsageWithHttpInfo(
      inferenceId,
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
        'GetInferenceUsage200Response',
      ) as GetInferenceUsage200Response;
    }
    return null;
  }

  /// List Serverless Inference
  ///
  /// List all Serverless Inference subscriptions in your account.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listInferenceWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/inference';

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

  /// List Serverless Inference
  ///
  /// List all Serverless Inference subscriptions in your account.
  Future<ListInference200Response?> listInference() async {
    final response = await listInferenceWithHttpInfo();
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
        'ListInference200Response',
      ) as ListInference200Response;
    }
    return null;
  }

  /// Update Serverless Inference
  ///
  /// Update information for a Serverless Inference subscription.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  ///
  /// * [UpdateInferenceRequest] updateInferenceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateInferenceWithHttpInfo(
    String inferenceId, {
    UpdateInferenceRequest? updateInferenceRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path =
        r'/inference/{inference-id}'.replaceAll('{inference-id}', inferenceId);

    // ignore: prefer_final_locals
    Object? postBody = updateInferenceRequest;

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

  /// Update Serverless Inference
  ///
  /// Update information for a Serverless Inference subscription.
  ///
  /// Parameters:
  ///
  /// * [String] inferenceId (required):
  ///   The [Inference ID](#operation/list-inference).
  ///
  /// * [UpdateInferenceRequest] updateInferenceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateInference201Response?> updateInference(
    String inferenceId, {
    UpdateInferenceRequest? updateInferenceRequest,
  }) async {
    final response = await updateInferenceWithHttpInfo(
      inferenceId,
      updateInferenceRequest: updateInferenceRequest,
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
        'CreateInference201Response',
      ) as CreateInference201Response;
    }
    return null;
  }
}
