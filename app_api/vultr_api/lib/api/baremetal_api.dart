//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class BaremetalApi {
  BaremetalApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Attach VPC 2.0 Network to Bare Metal Instance
  ///
  /// Attach a VPC 2.0 Network to a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC Network to Bare Metal Instance](#operation/attach-baremetals-vpcs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  ///
  /// * [AttachBaremetalsVpc2Request] attachBaremetalsVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachBaremetalsVpc2WithHttpInfo(String baremetalId, { AttachBaremetalsVpc2Request? attachBaremetalsVpc2Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vpc2/attach'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = attachBaremetalsVpc2Request;

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

  /// Attach VPC 2.0 Network to Bare Metal Instance
  ///
  /// Attach a VPC 2.0 Network to a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC Network to Bare Metal Instance](#operation/attach-baremetals-vpcs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  ///
  /// * [AttachBaremetalsVpc2Request] attachBaremetalsVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachBaremetalsVpc2(String baremetalId, { AttachBaremetalsVpc2Request? attachBaremetalsVpc2Request, }) async {
    final response = await attachBaremetalsVpc2WithHttpInfo(baremetalId,  attachBaremetalsVpc2Request: attachBaremetalsVpc2Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Attach VPC Network to Bare Metal Instance
  ///
  /// Attach a VPC Network to a Bare Metal Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  ///
  /// * [AttachBaremetalsVpcsRequest] attachBaremetalsVpcsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachBaremetalsVpcsWithHttpInfo(String baremetalId, { AttachBaremetalsVpcsRequest? attachBaremetalsVpcsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vpcs/attach'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = attachBaremetalsVpcsRequest;

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

  /// Attach VPC Network to Bare Metal Instance
  ///
  /// Attach a VPC Network to a Bare Metal Instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  ///
  /// * [AttachBaremetalsVpcsRequest] attachBaremetalsVpcsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachBaremetalsVpcs(String baremetalId, { AttachBaremetalsVpcsRequest? attachBaremetalsVpcsRequest, }) async {
    final response = await attachBaremetalsVpcsWithHttpInfo(baremetalId,  attachBaremetalsVpcsRequest: attachBaremetalsVpcsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create Bare Metal Instance
  ///
  /// Create a new Bare Metal instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateBaremetalRequest] createBaremetalRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createBaremetalWithHttpInfo({ CreateBaremetalRequest? createBaremetalRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals';

    // ignore: prefer_final_locals
    Object? postBody = createBaremetalRequest;

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

  /// Create Bare Metal Instance
  ///
  /// Create a new Bare Metal instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.
  ///
  /// Parameters:
  ///
  /// * [CreateBaremetalRequest] createBaremetalRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateBaremetal202Response?> createBaremetal({ CreateBaremetalRequest? createBaremetalRequest, }) async {
    final response = await createBaremetalWithHttpInfo( createBaremetalRequest: createBaremetalRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateBaremetal202Response',) as CreateBaremetal202Response;
    
    }
    return null;
  }

  /// Create Baremetal Reverse IPv4
  ///
  /// Create a reverse IPv4 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/baremetals).
  ///
  /// * [CreateBaremetalReverseIpv4Request] createBaremetalReverseIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createBaremetalReverseIpv4WithHttpInfo(String baremetalId, { CreateBaremetalReverseIpv4Request? createBaremetalReverseIpv4Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/ipv4/reverse'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = createBaremetalReverseIpv4Request;

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

  /// Create Baremetal Reverse IPv4
  ///
  /// Create a reverse IPv4 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. 
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/baremetals).
  ///
  /// * [CreateBaremetalReverseIpv4Request] createBaremetalReverseIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createBaremetalReverseIpv4(String baremetalId, { CreateBaremetalReverseIpv4Request? createBaremetalReverseIpv4Request, }) async {
    final response = await createBaremetalReverseIpv4WithHttpInfo(baremetalId,  createBaremetalReverseIpv4Request: createBaremetalReverseIpv4Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create Baremetal Reverse IPv6
  ///
  /// Create a reverse IPv6 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare metal ID](#operation/baremetals).
  ///
  /// * [CreateBaremetalReverseIpv6Request] createBaremetalReverseIpv6Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createBaremetalReverseIpv6WithHttpInfo(String baremetalId, { CreateBaremetalReverseIpv6Request? createBaremetalReverseIpv6Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/ipv6/reverse'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = createBaremetalReverseIpv6Request;

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

  /// Create Baremetal Reverse IPv6
  ///
  /// Create a reverse IPv6 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare metal ID](#operation/baremetals).
  ///
  /// * [CreateBaremetalReverseIpv6Request] createBaremetalReverseIpv6Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createBaremetalReverseIpv6(String baremetalId, { CreateBaremetalReverseIpv6Request? createBaremetalReverseIpv6Request, }) async {
    final response = await createBaremetalReverseIpv6WithHttpInfo(baremetalId,  createBaremetalReverseIpv6Request: createBaremetalReverseIpv6Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Bare Metal
  ///
  /// Delete a Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> deleteBaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Delete Bare Metal
  ///
  /// Delete a Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<void> deleteBaremetal(String baremetalId,) async {
    final response = await deleteBaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete BareMetal Reverse IPv6
  ///
  /// Delete the reverse IPv6 for a Bare metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [String] ipv6 (required):
  ///   The IPv6 address.
  Future<Response> deleteBaremetalReverseIpv6WithHttpInfo(String baremetalId, String ipv6,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/ipv6/reverse/{ipv6}'
      .replaceAll('{baremetal-id}', baremetalId)
      .replaceAll('{ipv6}', ipv6);

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

  /// Delete BareMetal Reverse IPv6
  ///
  /// Delete the reverse IPv6 for a Bare metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [String] ipv6 (required):
  ///   The IPv6 address.
  Future<void> deleteBaremetalReverseIpv6(String baremetalId, String ipv6,) async {
    final response = await deleteBaremetalReverseIpv6WithHttpInfo(baremetalId, ipv6,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach VPC 2.0 Network from Bare Metal Instance
  ///
  /// Detach a VPC 2.0 Network from an Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC Network from Bare Metal Instance](#operation/detach-baremetal-vpcs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [bare-metal ID](#operation/list-baremetals).
  ///
  /// * [DetachBaremetalVpc2Request] detachBaremetalVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachBaremetalVpc2WithHttpInfo(String baremetalId, { DetachBaremetalVpc2Request? detachBaremetalVpc2Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vpc2/detach'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = detachBaremetalVpc2Request;

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

  /// Detach VPC 2.0 Network from Bare Metal Instance
  ///
  /// Detach a VPC 2.0 Network from an Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC Network from Bare Metal Instance](#operation/detach-baremetal-vpcs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [bare-metal ID](#operation/list-baremetals).
  ///
  /// * [DetachBaremetalVpc2Request] detachBaremetalVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachBaremetalVpc2(String baremetalId, { DetachBaremetalVpc2Request? detachBaremetalVpc2Request, }) async {
    final response = await detachBaremetalVpc2WithHttpInfo(baremetalId,  detachBaremetalVpc2Request: detachBaremetalVpc2Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach VPC Network from Bare Metal Instance
  ///
  /// Detach a VPC Network from an Bare Metal Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [bare-metal ID](#operation/list-baremetals).
  ///
  /// * [DetachBaremetalVpcsRequest] detachBaremetalVpcsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachBaremetalVpcsWithHttpInfo(String baremetalId, { DetachBaremetalVpcsRequest? detachBaremetalVpcsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vpcs/detach'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = detachBaremetalVpcsRequest;

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

  /// Detach VPC Network from Bare Metal Instance
  ///
  /// Detach a VPC Network from an Bare Metal Instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [bare-metal ID](#operation/list-baremetals).
  ///
  /// * [DetachBaremetalVpcsRequest] detachBaremetalVpcsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachBaremetalVpcs(String baremetalId, { DetachBaremetalVpcsRequest? detachBaremetalVpcsRequest, }) async {
    final response = await detachBaremetalVpcsWithHttpInfo(baremetalId,  detachBaremetalVpcsRequest: detachBaremetalVpcsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Bare Metal Bandwidth
  ///
  /// Get bandwidth information for the Bare Metal instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. Bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> getBandwidthBaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/bandwidth'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Bare Metal Bandwidth
  ///
  /// Get bandwidth information for the Bare Metal instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. Bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<GetBandwidthBaremetal200Response?> getBandwidthBaremetal(String baremetalId,) async {
    final response = await getBandwidthBaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetBandwidthBaremetal200Response',) as GetBandwidthBaremetal200Response;
    
    }
    return null;
  }

  /// Get Bare Metal User Data
  ///
  /// Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for a Bare Metal.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> getBareMetalUserdataWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/user-data'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Get Bare Metal User Data
  ///
  /// Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for a Bare Metal.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<GetBareMetalUserdata200Response?> getBareMetalUserdata(String baremetalId,) async {
    final response = await getBareMetalUserdataWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetBareMetalUserdata200Response',) as GetBareMetalUserdata200Response;
    
    }
    return null;
  }

  /// Get VNC URL for a Bare Metal
  ///
  /// Get the VNC URL for a Bare Metal
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> getBareMetalVncWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vnc'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Get VNC URL for a Bare Metal
  ///
  /// Get the VNC URL for a Bare Metal
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<GetBareMetalVnc200Response?> getBareMetalVnc(String baremetalId,) async {
    final response = await getBareMetalVncWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetBareMetalVnc200Response',) as GetBareMetalVnc200Response;
    
    }
    return null;
  }

  /// Get Available Bare Metal Upgrades
  ///
  /// Get available upgrades for a Bare Metal
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [String] type:
  ///   Filter upgrade by type:  - all (applications, plans) - applications - os
  Future<Response> getBareMetalsUpgradesWithHttpInfo(String baremetalId, { String? type, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/upgrades'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (type != null) {
      queryParams.addAll(_queryParams('', 'type', type));
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

  /// Get Available Bare Metal Upgrades
  ///
  /// Get available upgrades for a Bare Metal
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [String] type:
  ///   Filter upgrade by type:  - all (applications, plans) - applications - os
  Future<GetBareMetalsUpgrades200Response?> getBareMetalsUpgrades(String baremetalId, { String? type, }) async {
    final response = await getBareMetalsUpgradesWithHttpInfo(baremetalId,  type: type, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetBareMetalsUpgrades200Response',) as GetBareMetalsUpgrades200Response;
    
    }
    return null;
  }

  /// Get Bare Metal
  ///
  /// Get information for a Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> getBaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Get Bare Metal
  ///
  /// Get information for a Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<GetBaremetal200Response?> getBaremetal(String baremetalId,) async {
    final response = await getBaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetBaremetal200Response',) as GetBaremetal200Response;
    
    }
    return null;
  }

  /// Bare Metal IPv4 Addresses
  ///
  /// Get the IPv4 information for the Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> getIpv4BaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/ipv4'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Bare Metal IPv4 Addresses
  ///
  /// Get the IPv4 information for the Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<GetIpv4Baremetal200Response?> getIpv4Baremetal(String baremetalId,) async {
    final response = await getIpv4BaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetIpv4Baremetal200Response',) as GetIpv4Baremetal200Response;
    
    }
    return null;
  }

  /// Bare Metal IPv6 Addresses
  ///
  /// Get the IPv6 information for the Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> getIpv6BaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/ipv6'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// Bare Metal IPv6 Addresses
  ///
  /// Get the IPv6 information for the Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<GetIpv6Baremetal200Response?> getIpv6Baremetal(String baremetalId,) async {
    final response = await getIpv6BaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetIpv6Baremetal200Response',) as GetIpv6Baremetal200Response;
    
    }
    return null;
  }

  /// Halt Bare Metal
  ///
  /// Halt the Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> haltBaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/halt'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Halt Bare Metal
  ///
  /// Halt the Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<void> haltBaremetal(String baremetalId,) async {
    final response = await haltBaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Halt Bare Metals
  ///
  /// Halt Bare Metals.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [HaltBaremetalsRequest] haltBaremetalsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> haltBaremetalsWithHttpInfo({ HaltBaremetalsRequest? haltBaremetalsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/halt';

    // ignore: prefer_final_locals
    Object? postBody = haltBaremetalsRequest;

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

  /// Halt Bare Metals
  ///
  /// Halt Bare Metals.
  ///
  /// Parameters:
  ///
  /// * [HaltBaremetalsRequest] haltBaremetalsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> haltBaremetals({ HaltBaremetalsRequest? haltBaremetalsRequest, }) async {
    final response = await haltBaremetalsWithHttpInfo( haltBaremetalsRequest: haltBaremetalsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// List Bare Metal Instance VPC 2.0 Networks
  ///
  /// List the VPC 2.0 networks for a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Bare Metal Instance VPC Networks](#operation/list-baremetal-vpcs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  Future<Response> listBaremetalVpc2WithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vpc2'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// List Bare Metal Instance VPC 2.0 Networks
  ///
  /// List the VPC 2.0 networks for a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Bare Metal Instance VPC Networks](#operation/list-baremetal-vpcs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  Future<ListBaremetalVpc2200Response?> listBaremetalVpc2(String baremetalId,) async {
    final response = await listBaremetalVpc2WithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListBaremetalVpc2200Response',) as ListBaremetalVpc2200Response;
    
    }
    return null;
  }

  /// List Bare Metal Instance VPC Networks
  ///
  /// List the VPC networks for a Bare Metal Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  Future<Response> listBaremetalVpcsWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/vpcs'
      .replaceAll('{baremetal-id}', baremetalId);

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

  /// List Bare Metal Instance VPC Networks
  ///
  /// List the VPC networks for a Bare Metal Instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  Future<ListBaremetalVpcs200Response?> listBaremetalVpcs(String baremetalId,) async {
    final response = await listBaremetalVpcsWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListBaremetalVpcs200Response',) as ListBaremetalVpcs200Response;
    
    }
    return null;
  }

  /// List Bare Metal Instances
  ///
  /// List all Bare Metal instances in your account.
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
  Future<Response> listBaremetalsWithHttpInfo({ int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals';

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

  /// List Bare Metal Instances
  ///
  /// List all Bare Metal instances in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500. 
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListBaremetals200Response?> listBaremetals({ int? perPage, String? cursor, }) async {
    final response = await listBaremetalsWithHttpInfo( perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListBaremetals200Response',) as ListBaremetals200Response;
    
    }
    return null;
  }

  /// Set Default Reverse DNS Entry
  ///
  /// Set a reverse DNS entry for an IPv4 address
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  ///
  /// * [PostBaremetalInstanceIdIpv4ReverseDefaultRequest] postBaremetalInstanceIdIpv4ReverseDefaultRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> postBaremetalInstanceIdIpv4ReverseDefaultWithHttpInfo(String baremetalId, { PostBaremetalInstanceIdIpv4ReverseDefaultRequest? postBaremetalInstanceIdIpv4ReverseDefaultRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/ipv4/reverse/default'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = postBaremetalInstanceIdIpv4ReverseDefaultRequest;

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

  /// Set Default Reverse DNS Entry
  ///
  /// Set a reverse DNS entry for an IPv4 address
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal ID](#operation/list-baremetals).
  ///
  /// * [PostBaremetalInstanceIdIpv4ReverseDefaultRequest] postBaremetalInstanceIdIpv4ReverseDefaultRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> postBaremetalInstanceIdIpv4ReverseDefault(String baremetalId, { PostBaremetalInstanceIdIpv4ReverseDefaultRequest? postBaremetalInstanceIdIpv4ReverseDefaultRequest, }) async {
    final response = await postBaremetalInstanceIdIpv4ReverseDefaultWithHttpInfo(baremetalId,  postBaremetalInstanceIdIpv4ReverseDefaultRequest: postBaremetalInstanceIdIpv4ReverseDefaultRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reboot Bare Metals
  ///
  /// Reboot Bare Metals.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [HaltBaremetalsRequest] haltBaremetalsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> rebootBareMetalsWithHttpInfo({ HaltBaremetalsRequest? haltBaremetalsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/reboot';

    // ignore: prefer_final_locals
    Object? postBody = haltBaremetalsRequest;

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

  /// Reboot Bare Metals
  ///
  /// Reboot Bare Metals.
  ///
  /// Parameters:
  ///
  /// * [HaltBaremetalsRequest] haltBaremetalsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> rebootBareMetals({ HaltBaremetalsRequest? haltBaremetalsRequest, }) async {
    final response = await rebootBareMetalsWithHttpInfo( haltBaremetalsRequest: haltBaremetalsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reboot Bare Metal
  ///
  /// Reboot the Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> rebootBaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/reboot'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Reboot Bare Metal
  ///
  /// Reboot the Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<void> rebootBaremetal(String baremetalId,) async {
    final response = await rebootBaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reinstall Bare Metal
  ///
  /// Reinstall the Bare Metal instance using an optional `hostname`.   **Note:** This action may take some time to complete.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [ReinstallBaremetalRequest] reinstallBaremetalRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> reinstallBaremetalWithHttpInfo(String baremetalId, { ReinstallBaremetalRequest? reinstallBaremetalRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/reinstall'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = reinstallBaremetalRequest;

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

  /// Reinstall Bare Metal
  ///
  /// Reinstall the Bare Metal instance using an optional `hostname`.   **Note:** This action may take some time to complete.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [ReinstallBaremetalRequest] reinstallBaremetalRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<UpdateBaremetal202Response?> reinstallBaremetal(String baremetalId, { ReinstallBaremetalRequest? reinstallBaremetalRequest, }) async {
    final response = await reinstallBaremetalWithHttpInfo(baremetalId,  reinstallBaremetalRequest: reinstallBaremetalRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UpdateBaremetal202Response',) as UpdateBaremetal202Response;
    
    }
    return null;
  }

  /// Start Bare Metals
  ///
  /// Start Bare Metals.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [HaltBaremetalsRequest] haltBaremetalsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> startBareMetalsWithHttpInfo({ HaltBaremetalsRequest? haltBaremetalsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/start';

    // ignore: prefer_final_locals
    Object? postBody = haltBaremetalsRequest;

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

  /// Start Bare Metals
  ///
  /// Start Bare Metals.
  ///
  /// Parameters:
  ///
  /// * [HaltBaremetalsRequest] haltBaremetalsRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> startBareMetals({ HaltBaremetalsRequest? haltBaremetalsRequest, }) async {
    final response = await startBareMetalsWithHttpInfo( haltBaremetalsRequest: haltBaremetalsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Start Bare Metal
  ///
  /// Start the Bare Metal instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<Response> startBaremetalWithHttpInfo(String baremetalId,) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}/start'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Start Bare Metal
  ///
  /// Start the Bare Metal instance.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  Future<void> startBaremetal(String baremetalId,) async {
    final response = await startBaremetalWithHttpInfo(baremetalId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Bare Metal
  ///
  /// Update a Bare Metal instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [UpdateBaremetalRequest] updateBaremetalRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateBaremetalWithHttpInfo(String baremetalId, { UpdateBaremetalRequest? updateBaremetalRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/bare-metals/{baremetal-id}'
      .replaceAll('{baremetal-id}', baremetalId);

    // ignore: prefer_final_locals
    Object? postBody = updateBaremetalRequest;

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

  /// Update Bare Metal
  ///
  /// Update a Bare Metal instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.
  ///
  /// Parameters:
  ///
  /// * [String] baremetalId (required):
  ///   The [Bare Metal id](#operation/list-baremetals).
  ///
  /// * [UpdateBaremetalRequest] updateBaremetalRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<UpdateBaremetal202Response?> updateBaremetal(String baremetalId, { UpdateBaremetalRequest? updateBaremetalRequest, }) async {
    final response = await updateBaremetalWithHttpInfo(baremetalId,  updateBaremetalRequest: updateBaremetalRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UpdateBaremetal202Response',) as UpdateBaremetal202Response;
    
    }
    return null;
  }
}
