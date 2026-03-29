//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DnsApi {
  DnsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create DNS Domain
  ///
  /// Create a DNS Domain for `domain`. If no `ip` address is supplied a domain with no records will be created.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateDnsDomainRequest] createDnsDomainRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createDnsDomainWithHttpInfo({
    CreateDnsDomainRequest? createDnsDomainRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/domains';

    // ignore: prefer_final_locals
    Object? postBody = createDnsDomainRequest;

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

  /// Create DNS Domain
  ///
  /// Create a DNS Domain for `domain`. If no `ip` address is supplied a domain with no records will be created.
  ///
  /// Parameters:
  ///
  /// * [CreateDnsDomainRequest] createDnsDomainRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateDnsDomain200Response?> createDnsDomain({
    CreateDnsDomainRequest? createDnsDomainRequest,
  }) async {
    final response = await createDnsDomainWithHttpInfo(
      createDnsDomainRequest: createDnsDomainRequest,
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
        'CreateDnsDomain200Response',
      ) as CreateDnsDomain200Response;
    }
    return null;
  }

  /// Create Record
  ///
  /// Create a DNS record.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [CreateDnsDomainRecordRequest] createDnsDomainRecordRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createDnsDomainRecordWithHttpInfo(
    String dnsDomain, {
    CreateDnsDomainRecordRequest? createDnsDomainRecordRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path =
        r'/domains/{dns-domain}/records'.replaceAll('{dns-domain}', dnsDomain);

    // ignore: prefer_final_locals
    Object? postBody = createDnsDomainRecordRequest;

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

  /// Create Record
  ///
  /// Create a DNS record.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [CreateDnsDomainRecordRequest] createDnsDomainRecordRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateDnsDomainRecord201Response?> createDnsDomainRecord(
    String dnsDomain, {
    CreateDnsDomainRecordRequest? createDnsDomainRecordRequest,
  }) async {
    final response = await createDnsDomainRecordWithHttpInfo(
      dnsDomain,
      createDnsDomainRecordRequest: createDnsDomainRecordRequest,
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
        'CreateDnsDomainRecord201Response',
      ) as CreateDnsDomainRecord201Response;
    }
    return null;
  }

  /// Delete Domain
  ///
  /// Delete the DNS Domain.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<Response> deleteDnsDomainWithHttpInfo(
    String dnsDomain,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/domains/{dns-domain}'.replaceAll('{dns-domain}', dnsDomain);

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

  /// Delete Domain
  ///
  /// Delete the DNS Domain.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<void> deleteDnsDomain(
    String dnsDomain,
  ) async {
    final response = await deleteDnsDomainWithHttpInfo(
      dnsDomain,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Record
  ///
  /// Delete the DNS record.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [String] recordId (required):
  ///   The [DNS Record id](#operation/list-dns-domain-records).
  Future<Response> deleteDnsDomainRecordWithHttpInfo(
    String dnsDomain,
    String recordId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/domains/{dns-domain}/records/{record-id}'
        .replaceAll('{dns-domain}', dnsDomain)
        .replaceAll('{record-id}', recordId);

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

  /// Delete Record
  ///
  /// Delete the DNS record.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [String] recordId (required):
  ///   The [DNS Record id](#operation/list-dns-domain-records).
  Future<void> deleteDnsDomainRecord(
    String dnsDomain,
    String recordId,
  ) async {
    final response = await deleteDnsDomainRecordWithHttpInfo(
      dnsDomain,
      recordId,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get DNS Domain
  ///
  /// Get information for the DNS Domain.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<Response> getDnsDomainWithHttpInfo(
    String dnsDomain,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/domains/{dns-domain}'.replaceAll('{dns-domain}', dnsDomain);

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

  /// Get DNS Domain
  ///
  /// Get information for the DNS Domain.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<CreateDnsDomain200Response?> getDnsDomain(
    String dnsDomain,
  ) async {
    final response = await getDnsDomainWithHttpInfo(
      dnsDomain,
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
        'CreateDnsDomain200Response',
      ) as CreateDnsDomain200Response;
    }
    return null;
  }

  /// Get DNSSec Info
  ///
  /// Get the DNSSEC information for the DNS Domain.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<Response> getDnsDomainDnssecWithHttpInfo(
    String dnsDomain,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/domains/{dns-domain}/dnssec'.replaceAll('{dns-domain}', dnsDomain);

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

  /// Get DNSSec Info
  ///
  /// Get the DNSSEC information for the DNS Domain.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<GetDnsDomainDnssec200Response?> getDnsDomainDnssec(
    String dnsDomain,
  ) async {
    final response = await getDnsDomainDnssecWithHttpInfo(
      dnsDomain,
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
        'GetDnsDomainDnssec200Response',
      ) as GetDnsDomainDnssec200Response;
    }
    return null;
  }

  /// Get Record
  ///
  /// Get information for a DNS Record.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [String] recordId (required):
  ///   The [DNS Record id](#operation/list-dns-domain-records).
  Future<Response> getDnsDomainRecordWithHttpInfo(
    String dnsDomain,
    String recordId,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/domains/{dns-domain}/records/{record-id}'
        .replaceAll('{dns-domain}', dnsDomain)
        .replaceAll('{record-id}', recordId);

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

  /// Get Record
  ///
  /// Get information for a DNS Record.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [String] recordId (required):
  ///   The [DNS Record id](#operation/list-dns-domain-records).
  Future<CreateDnsDomainRecord201Response?> getDnsDomainRecord(
    String dnsDomain,
    String recordId,
  ) async {
    final response = await getDnsDomainRecordWithHttpInfo(
      dnsDomain,
      recordId,
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
        'CreateDnsDomainRecord201Response',
      ) as CreateDnsDomainRecord201Response;
    }
    return null;
  }

  /// Get SOA information
  ///
  /// Get SOA information for the DNS Domain.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<Response> getDnsDomainSoaWithHttpInfo(
    String dnsDomain,
  ) async {
    // ignore: prefer_const_declarations
    final path =
        r'/domains/{dns-domain}/soa'.replaceAll('{dns-domain}', dnsDomain);

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

  /// Get SOA information
  ///
  /// Get SOA information for the DNS Domain.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  Future<GetDnsDomainSoa200Response?> getDnsDomainSoa(
    String dnsDomain,
  ) async {
    final response = await getDnsDomainSoaWithHttpInfo(
      dnsDomain,
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
        'GetDnsDomainSoa200Response',
      ) as GetDnsDomainSoa200Response;
    }
    return null;
  }

  /// List Records
  ///
  /// Get the DNS records for the Domain.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listDnsDomainRecordsWithHttpInfo(
    String dnsDomain, {
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path =
        r'/domains/{dns-domain}/records'.replaceAll('{dns-domain}', dnsDomain);

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

  /// List Records
  ///
  /// Get the DNS records for the Domain.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListDnsDomainRecords200Response?> listDnsDomainRecords(
    String dnsDomain, {
    int? perPage,
    String? cursor,
  }) async {
    final response = await listDnsDomainRecordsWithHttpInfo(
      dnsDomain,
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
        'ListDnsDomainRecords200Response',
      ) as ListDnsDomainRecords200Response;
    }
    return null;
  }

  /// List DNS Domains
  ///
  /// List all DNS Domains in your account.
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
  Future<Response> listDnsDomainsWithHttpInfo({
    int? perPage,
    String? cursor,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/domains';

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

  /// List DNS Domains
  ///
  /// List all DNS Domains in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListDnsDomains200Response?> listDnsDomains({
    int? perPage,
    String? cursor,
  }) async {
    final response = await listDnsDomainsWithHttpInfo(
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
        'ListDnsDomains200Response',
      ) as ListDnsDomains200Response;
    }
    return null;
  }

  /// Update a DNS Domain
  ///
  /// Update the DNS Domain.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [UpdateDnsDomainRequest] updateDnsDomainRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateDnsDomainWithHttpInfo(
    String dnsDomain, {
    UpdateDnsDomainRequest? updateDnsDomainRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/domains/{dns-domain}'.replaceAll('{dns-domain}', dnsDomain);

    // ignore: prefer_final_locals
    Object? postBody = updateDnsDomainRequest;

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

  /// Update a DNS Domain
  ///
  /// Update the DNS Domain.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [UpdateDnsDomainRequest] updateDnsDomainRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateDnsDomain(
    String dnsDomain, {
    UpdateDnsDomainRequest? updateDnsDomainRequest,
  }) async {
    final response = await updateDnsDomainWithHttpInfo(
      dnsDomain,
      updateDnsDomainRequest: updateDnsDomainRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Record
  ///
  /// Update the information for a DNS record. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [String] recordId (required):
  ///   The [DNS Record id](#operation/list-dns-domain-records).
  ///
  /// * [UpdateDnsDomainRecordRequest] updateDnsDomainRecordRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateDnsDomainRecordWithHttpInfo(
    String dnsDomain,
    String recordId, {
    UpdateDnsDomainRecordRequest? updateDnsDomainRecordRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/domains/{dns-domain}/records/{record-id}'
        .replaceAll('{dns-domain}', dnsDomain)
        .replaceAll('{record-id}', recordId);

    // ignore: prefer_final_locals
    Object? postBody = updateDnsDomainRecordRequest;

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

  /// Update Record
  ///
  /// Update the information for a DNS record. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [String] recordId (required):
  ///   The [DNS Record id](#operation/list-dns-domain-records).
  ///
  /// * [UpdateDnsDomainRecordRequest] updateDnsDomainRecordRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateDnsDomainRecord(
    String dnsDomain,
    String recordId, {
    UpdateDnsDomainRecordRequest? updateDnsDomainRecordRequest,
  }) async {
    final response = await updateDnsDomainRecordWithHttpInfo(
      dnsDomain,
      recordId,
      updateDnsDomainRecordRequest: updateDnsDomainRecordRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update SOA information
  ///
  /// Update the SOA information for the DNS Domain. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [UpdateDnsDomainSoaRequest] updateDnsDomainSoaRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateDnsDomainSoaWithHttpInfo(
    String dnsDomain, {
    UpdateDnsDomainSoaRequest? updateDnsDomainSoaRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path =
        r'/domains/{dns-domain}/soa'.replaceAll('{dns-domain}', dnsDomain);

    // ignore: prefer_final_locals
    Object? postBody = updateDnsDomainSoaRequest;

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

  /// Update SOA information
  ///
  /// Update the SOA information for the DNS Domain. All attributes are optional. If not set, the attributes will retain their original values.
  ///
  /// Parameters:
  ///
  /// * [String] dnsDomain (required):
  ///   The [DNS Domain](#operation/list-dns-domains).
  ///
  /// * [UpdateDnsDomainSoaRequest] updateDnsDomainSoaRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> updateDnsDomainSoa(
    String dnsDomain, {
    UpdateDnsDomainSoaRequest? updateDnsDomainSoaRequest,
  }) async {
    final response = await updateDnsDomainSoaWithHttpInfo(
      dnsDomain,
      updateDnsDomainSoaRequest: updateDnsDomainSoaRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
