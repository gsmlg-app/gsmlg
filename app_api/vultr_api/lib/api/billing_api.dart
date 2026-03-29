//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BillingApi {
  BillingApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Invoice
  ///
  /// Retrieve specified invoice
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] invoiceId (required):
  ///   ID of invoice
  Future<Response> getInvoiceWithHttpInfo(
    String invoiceId,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/billing/invoices/{invoice-id}'.replaceAll('{invoice-id}', invoiceId);

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

  /// Get Invoice
  ///
  /// Retrieve specified invoice
  ///
  /// Parameters:
  ///
  /// * [String] invoiceId (required):
  ///   ID of invoice
  Future<GetInvoice200Response?> getInvoice(
    String invoiceId,
  ) async {
    final response = await getInvoiceWithHttpInfo(
      invoiceId,
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
        'GetInvoice200Response',
      ) as GetInvoice200Response;
    }
    return null;
  }

  /// Get Invoice Items
  ///
  /// Retrieve full specified invoice
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] invoiceId (required):
  ///   ID of invoice
  Future<Response> getInvoiceItemsWithHttpInfo(
    String invoiceId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/invoices/{invoice-id}/items'
        .replaceAll('{invoice-id}', invoiceId);

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

  /// Get Invoice Items
  ///
  /// Retrieve full specified invoice
  ///
  /// Parameters:
  ///
  /// * [String] invoiceId (required):
  ///   ID of invoice
  Future<GetInvoiceItems200Response?> getInvoiceItems(
    String invoiceId,
  ) async {
    final response = await getInvoiceItemsWithHttpInfo(
      invoiceId,
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
        'GetInvoiceItems200Response',
      ) as GetInvoiceItems200Response;
    }
    return null;
  }

  /// List Billing History
  ///
  /// Retrieve list of billing history
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listBillingHistoryWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/billing/history';

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

  /// List Billing History
  ///
  /// Retrieve list of billing history
  Future<ListBillingHistory200Response?> listBillingHistory() async {
    final response = await listBillingHistoryWithHttpInfo();
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
        'ListBillingHistory200Response',
      ) as ListBillingHistory200Response;
    }
    return null;
  }

  /// List Invoices
  ///
  /// Retrieve a list of invoices
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listInvoicesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/billing/invoices';

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

  /// List Invoices
  ///
  /// Retrieve a list of invoices
  Future<ListInvoices200Response?> listInvoices() async {
    final response = await listInvoicesWithHttpInfo();
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
        'ListInvoices200Response',
      ) as ListInvoices200Response;
    }
    return null;
  }

  /// List Pending Charges
  ///
  /// Retrieve list of billing pending charges
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> pendingChargesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/billing/pending-charges';

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

  /// List Pending Charges
  ///
  /// Retrieve list of billing pending charges
  Future<PendingCharges200Response?> pendingCharges() async {
    final response = await pendingChargesWithHttpInfo();
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
        'PendingCharges200Response',
      ) as PendingCharges200Response;
    }
    return null;
  }

  /// Get Pending Charges CSV
  ///
  /// Get pending charges as CSV file. Returns all current month charges.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> pendingChargesCsvWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/billing/pending-charges/csv';

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

  /// Get Pending Charges CSV
  ///
  /// Get pending charges as CSV file. Returns all current month charges.
  Future<MultipartFile?> pendingChargesCsv() async {
    final response = await pendingChargesCsvWithHttpInfo();
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
        'MultipartFile',
      ) as MultipartFile;
    }
    return null;
  }
}
