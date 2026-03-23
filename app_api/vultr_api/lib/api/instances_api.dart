//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class InstancesApi {
  InstancesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Attach ISO to Instance
  ///
  /// Attach an ISO to an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///
  /// * [AttachInstanceIsoRequest] attachInstanceIsoRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachInstanceIsoWithHttpInfo(String instanceId, { AttachInstanceIsoRequest? attachInstanceIsoRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/iso/attach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = attachInstanceIsoRequest;

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

  /// Attach ISO to Instance
  ///
  /// Attach an ISO to an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///
  /// * [AttachInstanceIsoRequest] attachInstanceIsoRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<AttachInstanceIso202Response?> attachInstanceIso(String instanceId, { AttachInstanceIsoRequest? attachInstanceIsoRequest, }) async {
    final response = await attachInstanceIsoWithHttpInfo(instanceId,  attachInstanceIsoRequest: attachInstanceIsoRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AttachInstanceIso202Response',) as AttachInstanceIso202Response;
    
    }
    return null;
  }

  /// Attach Private Network to Instance
  ///
  /// Attach Private Network to an Instance.<br><br>**Deprecated**: use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [AttachInstanceNetworkRequest] attachInstanceNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachInstanceNetworkWithHttpInfo(String instanceId, { AttachInstanceNetworkRequest? attachInstanceNetworkRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/private-networks/attach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = attachInstanceNetworkRequest;

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

  /// Attach Private Network to Instance
  ///
  /// Attach Private Network to an Instance.<br><br>**Deprecated**: use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [AttachInstanceNetworkRequest] attachInstanceNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachInstanceNetwork(String instanceId, { AttachInstanceNetworkRequest? attachInstanceNetworkRequest, }) async {
    final response = await attachInstanceNetworkWithHttpInfo(instanceId,  attachInstanceNetworkRequest: attachInstanceNetworkRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Attach VPC to Instance
  ///
  /// Attach a VPC to an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [AttachInstanceVpcRequest] attachInstanceVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachInstanceVpcWithHttpInfo(String instanceId, { AttachInstanceVpcRequest? attachInstanceVpcRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/vpcs/attach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = attachInstanceVpcRequest;

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

  /// Attach VPC to Instance
  ///
  /// Attach a VPC to an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [AttachInstanceVpcRequest] attachInstanceVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachInstanceVpc(String instanceId, { AttachInstanceVpcRequest? attachInstanceVpcRequest, }) async {
    final response = await attachInstanceVpcWithHttpInfo(instanceId,  attachInstanceVpcRequest: attachInstanceVpcRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Attach VPC 2.0 Network to Instance
  ///
  /// Attach a VPC 2.0 Network to an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [AttachInstanceVpc2Request] attachInstanceVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> attachInstanceVpc2WithHttpInfo(String instanceId, { AttachInstanceVpc2Request? attachInstanceVpc2Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/vpc2/attach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = attachInstanceVpc2Request;

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

  /// Attach VPC 2.0 Network to Instance
  ///
  /// Attach a VPC 2.0 Network to an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [AttachInstanceVpc2Request] attachInstanceVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> attachInstanceVpc2(String instanceId, { AttachInstanceVpc2Request? attachInstanceVpc2Request, }) async {
    final response = await attachInstanceVpc2WithHttpInfo(instanceId,  attachInstanceVpc2Request: attachInstanceVpc2Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create Instance
  ///
  /// Create a new VPS Instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `iso_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateInstanceRequest] createInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createInstanceWithHttpInfo({ CreateInstanceRequest? createInstanceRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances';

    // ignore: prefer_final_locals
    Object? postBody = createInstanceRequest;

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

  /// Create Instance
  ///
  /// Create a new VPS Instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `iso_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.
  ///
  /// Parameters:
  ///
  /// * [CreateInstanceRequest] createInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateInstance202Response?> createInstance({ CreateInstanceRequest? createInstanceRequest, }) async {
    final response = await createInstanceWithHttpInfo( createInstanceRequest: createInstanceRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateInstance202Response',) as CreateInstance202Response;
    
    }
    return null;
  }

  /// Set Instance Backup Schedule
  ///
  /// Set the backup schedule for an Instance in UTC. The `type` is required.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateInstanceBackupScheduleRequest] createInstanceBackupScheduleRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createInstanceBackupScheduleWithHttpInfo(String instanceId, { CreateInstanceBackupScheduleRequest? createInstanceBackupScheduleRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/backup-schedule'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = createInstanceBackupScheduleRequest;

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

  /// Set Instance Backup Schedule
  ///
  /// Set the backup schedule for an Instance in UTC. The `type` is required.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateInstanceBackupScheduleRequest] createInstanceBackupScheduleRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createInstanceBackupSchedule(String instanceId, { CreateInstanceBackupScheduleRequest? createInstanceBackupScheduleRequest, }) async {
    final response = await createInstanceBackupScheduleWithHttpInfo(instanceId,  createInstanceBackupScheduleRequest: createInstanceBackupScheduleRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create IPv4
  ///
  /// Create an IPv4 address for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateInstanceIpv4Request] createInstanceIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createInstanceIpv4WithHttpInfo(String instanceId, { CreateInstanceIpv4Request? createInstanceIpv4Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv4'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = createInstanceIpv4Request;

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

  /// Create IPv4
  ///
  /// Create an IPv4 address for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateInstanceIpv4Request] createInstanceIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Object?> createInstanceIpv4(String instanceId, { CreateInstanceIpv4Request? createInstanceIpv4Request, }) async {
    final response = await createInstanceIpv4WithHttpInfo(instanceId,  createInstanceIpv4Request: createInstanceIpv4Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// Create Instance Reverse IPv4
  ///
  /// Create a reverse IPv4 entry for an Instance. The `ip` and `reverse` attributes are required. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateBaremetalReverseIpv4Request] createBaremetalReverseIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createInstanceReverseIpv4WithHttpInfo(String instanceId, { CreateBaremetalReverseIpv4Request? createBaremetalReverseIpv4Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv4/reverse'
      .replaceAll('{instance-id}', instanceId);

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

  /// Create Instance Reverse IPv4
  ///
  /// Create a reverse IPv4 entry for an Instance. The `ip` and `reverse` attributes are required. 
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateBaremetalReverseIpv4Request] createBaremetalReverseIpv4Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createInstanceReverseIpv4(String instanceId, { CreateBaremetalReverseIpv4Request? createBaremetalReverseIpv4Request, }) async {
    final response = await createInstanceReverseIpv4WithHttpInfo(instanceId,  createBaremetalReverseIpv4Request: createBaremetalReverseIpv4Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create Instance Reverse IPv6
  ///
  /// Create a reverse IPv6 entry for an Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateBaremetalReverseIpv6Request] createBaremetalReverseIpv6Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> createInstanceReverseIpv6WithHttpInfo(String instanceId, { CreateBaremetalReverseIpv6Request? createBaremetalReverseIpv6Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv6/reverse'
      .replaceAll('{instance-id}', instanceId);

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

  /// Create Instance Reverse IPv6
  ///
  /// Create a reverse IPv6 entry for an Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [CreateBaremetalReverseIpv6Request] createBaremetalReverseIpv6Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> createInstanceReverseIpv6(String instanceId, { CreateBaremetalReverseIpv6Request? createBaremetalReverseIpv6Request, }) async {
    final response = await createInstanceReverseIpv6WithHttpInfo(instanceId,  createBaremetalReverseIpv6Request: createBaremetalReverseIpv6Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Instance
  ///
  /// Delete an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> deleteInstanceWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}'
      .replaceAll('{instance-id}', instanceId);

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

  /// Delete Instance
  ///
  /// Delete an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<void> deleteInstance(String instanceId,) async {
    final response = await deleteInstanceWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete IPv4 Address
  ///
  /// Delete an IPv4 address from an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [String] ipv4 (required):
  ///   The IPv4 address.
  Future<Response> deleteInstanceIpv4WithHttpInfo(String instanceId, String ipv4,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv4/{ipv4}'
      .replaceAll('{instance-id}', instanceId)
      .replaceAll('{ipv4}', ipv4);

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

  /// Delete IPv4 Address
  ///
  /// Delete an IPv4 address from an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [String] ipv4 (required):
  ///   The IPv4 address.
  Future<void> deleteInstanceIpv4(String instanceId, String ipv4,) async {
    final response = await deleteInstanceIpv4WithHttpInfo(instanceId, ipv4,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Instance Reverse IPv6
  ///
  /// Delete the reverse IPv6 for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [String] ipv6 (required):
  ///   The IPv6 address.
  Future<Response> deleteInstanceReverseIpv6WithHttpInfo(String instanceId, String ipv6,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv6/reverse/{ipv6}'
      .replaceAll('{instance-id}', instanceId)
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

  /// Delete Instance Reverse IPv6
  ///
  /// Delete the reverse IPv6 for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [String] ipv6 (required):
  ///   The IPv6 address.
  Future<void> deleteInstanceReverseIpv6(String instanceId, String ipv6,) async {
    final response = await deleteInstanceReverseIpv6WithHttpInfo(instanceId, ipv6,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach ISO from instance
  ///
  /// Detach the ISO from an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> detachInstanceIsoWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/iso/detach'
      .replaceAll('{instance-id}', instanceId);

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

  /// Detach ISO from instance
  ///
  /// Detach the ISO from an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<DetachInstanceIso202Response?> detachInstanceIso(String instanceId,) async {
    final response = await detachInstanceIsoWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DetachInstanceIso202Response',) as DetachInstanceIso202Response;
    
    }
    return null;
  }

  /// Detach Private Network from Instance.
  ///
  /// Detach Private Network from an Instance.<br><br>**Deprecated**: use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [DetachInstanceNetworkRequest] detachInstanceNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachInstanceNetworkWithHttpInfo(String instanceId, { DetachInstanceNetworkRequest? detachInstanceNetworkRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/private-networks/detach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = detachInstanceNetworkRequest;

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

  /// Detach Private Network from Instance.
  ///
  /// Detach Private Network from an Instance.<br><br>**Deprecated**: use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [DetachInstanceNetworkRequest] detachInstanceNetworkRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachInstanceNetwork(String instanceId, { DetachInstanceNetworkRequest? detachInstanceNetworkRequest, }) async {
    final response = await detachInstanceNetworkWithHttpInfo(instanceId,  detachInstanceNetworkRequest: detachInstanceNetworkRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach VPC from Instance
  ///
  /// Detach a VPC from an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [DetachInstanceVpcRequest] detachInstanceVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachInstanceVpcWithHttpInfo(String instanceId, { DetachInstanceVpcRequest? detachInstanceVpcRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/vpcs/detach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = detachInstanceVpcRequest;

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

  /// Detach VPC from Instance
  ///
  /// Detach a VPC from an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [DetachInstanceVpcRequest] detachInstanceVpcRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachInstanceVpc(String instanceId, { DetachInstanceVpcRequest? detachInstanceVpcRequest, }) async {
    final response = await detachInstanceVpcWithHttpInfo(instanceId,  detachInstanceVpcRequest: detachInstanceVpcRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Detach VPC 2.0 Network from Instance
  ///
  /// Detach a VPC 2.0 Network from an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [DetachInstanceVpc2Request] detachInstanceVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> detachInstanceVpc2WithHttpInfo(String instanceId, { DetachInstanceVpc2Request? detachInstanceVpc2Request, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/vpc2/detach'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = detachInstanceVpc2Request;

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

  /// Detach VPC 2.0 Network from Instance
  ///
  /// Detach a VPC 2.0 Network from an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [DetachInstanceVpc2Request] detachInstanceVpc2Request:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> detachInstanceVpc2(String instanceId, { DetachInstanceVpc2Request? detachInstanceVpc2Request, }) async {
    final response = await detachInstanceVpc2WithHttpInfo(instanceId,  detachInstanceVpc2Request: detachInstanceVpc2Request, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Instance
  ///
  /// Get information about an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> getInstanceWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Instance
  ///
  /// Get information about an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<GetInstance200Response?> getInstance(String instanceId,) async {
    final response = await getInstanceWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstance200Response',) as GetInstance200Response;
    
    }
    return null;
  }

  /// Get Instance Backup Schedule
  ///
  /// Get the backup schedule for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> getInstanceBackupScheduleWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/backup-schedule'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Instance Backup Schedule
  ///
  /// Get the backup schedule for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<GetInstanceBackupSchedule200Response?> getInstanceBackupSchedule(String instanceId,) async {
    final response = await getInstanceBackupScheduleWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstanceBackupSchedule200Response',) as GetInstanceBackupSchedule200Response;
    
    }
    return null;
  }

  /// Instance Bandwidth
  ///
  /// Get bandwidth information about an Instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. The bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] dateRange:
  ///   The range of days to include, represented as the number of days relative to the current date. Default 30, Minimum 1 and Max 180.
  Future<Response> getInstanceBandwidthWithHttpInfo(String instanceId, { int? dateRange, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/bandwidth'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (dateRange != null) {
      queryParams.addAll(_queryParams('', 'date_range', dateRange));
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

  /// Instance Bandwidth
  ///
  /// Get bandwidth information about an Instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. The bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] dateRange:
  ///   The range of days to include, represented as the number of days relative to the current date. Default 30, Minimum 1 and Max 180.
  Future<GetBandwidthBaremetal200Response?> getInstanceBandwidth(String instanceId, { int? dateRange, }) async {
    final response = await getInstanceBandwidthWithHttpInfo(instanceId,  dateRange: dateRange, );
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

  /// List Instance IPv4 Information
  ///
  /// List the IPv4 information for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [bool] publicNetwork:
  ///   If `true`, includes information about the public network adapter (such as MAC address) with the `main_ip` entry.
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500. 
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> getInstanceIpv4WithHttpInfo(String instanceId, { bool? publicNetwork, int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv4'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (publicNetwork != null) {
      queryParams.addAll(_queryParams('', 'public_network', publicNetwork));
    }
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

  /// List Instance IPv4 Information
  ///
  /// List the IPv4 information for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [bool] publicNetwork:
  ///   If `true`, includes information about the public network adapter (such as MAC address) with the `main_ip` entry.
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500. 
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<GetIpv4Baremetal200Response?> getInstanceIpv4(String instanceId, { bool? publicNetwork, int? perPage, String? cursor, }) async {
    final response = await getInstanceIpv4WithHttpInfo(instanceId,  publicNetwork: publicNetwork, perPage: perPage, cursor: cursor, );
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

  /// Get Instance IPv6 Information
  ///
  /// Get the IPv6 information for an VPS Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> getInstanceIpv6WithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv6'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Instance IPv6 Information
  ///
  /// Get the IPv6 information for an VPS Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<GetIpv6Baremetal200Response?> getInstanceIpv6(String instanceId,) async {
    final response = await getInstanceIpv6WithHttpInfo(instanceId,);
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

  /// Get Instance ISO Status
  ///
  /// Get the ISO status for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> getInstanceIsoStatusWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/iso'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Instance ISO Status
  ///
  /// Get the ISO status for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<GetInstanceIsoStatus200Response?> getInstanceIsoStatus(String instanceId,) async {
    final response = await getInstanceIsoStatusWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstanceIsoStatus200Response',) as GetInstanceIsoStatus200Response;
    
    }
    return null;
  }

  /// Get Instance Job
  ///
  /// Get available information for an Instance job
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] jobId (required):
  ///   The [Job ID](#operation/update-instance).
  Future<Response> getInstanceJobWithHttpInfo(String jobId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/jobs/{job-id}'
      .replaceAll('{job-id}', jobId);

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

  /// Get Instance Job
  ///
  /// Get available information for an Instance job
  ///
  /// Parameters:
  ///
  /// * [String] jobId (required):
  ///   The [Job ID](#operation/update-instance).
  Future<GetInstanceJob200Response?> getInstanceJob(String jobId,) async {
    final response = await getInstanceJobWithHttpInfo(jobId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstanceJob200Response',) as GetInstanceJob200Response;
    
    }
    return null;
  }

  /// Get Instance neighbors
  ///
  /// Get a list of other instances in the same location as this Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> getInstanceNeighborsWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/neighbors'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Instance neighbors
  ///
  /// Get a list of other instances in the same location as this Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<GetInstanceNeighbors200Response?> getInstanceNeighbors(String instanceId,) async {
    final response = await getInstanceNeighborsWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstanceNeighbors200Response',) as GetInstanceNeighbors200Response;
    
    }
    return null;
  }

  /// Get Available Instance Upgrades
  ///
  /// Get available upgrades for an Instance
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [String] type:
  ///   Filter upgrade by type:  - all (applications, os, plans) - applications - os - plans
  Future<Response> getInstanceUpgradesWithHttpInfo(String instanceId, { String? type, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/upgrades'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Available Instance Upgrades
  ///
  /// Get available upgrades for an Instance
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [String] type:
  ///   Filter upgrade by type:  - all (applications, os, plans) - applications - os - plans
  Future<GetInstanceUpgrades200Response?> getInstanceUpgrades(String instanceId, { String? type, }) async {
    final response = await getInstanceUpgradesWithHttpInfo(instanceId,  type: type, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstanceUpgrades200Response',) as GetInstanceUpgrades200Response;
    
    }
    return null;
  }

  /// Get Instance User Data
  ///
  /// Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> getInstanceUserdataWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/user-data'
      .replaceAll('{instance-id}', instanceId);

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

  /// Get Instance User Data
  ///
  /// Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<GetInstanceUserdata200Response?> getInstanceUserdata(String instanceId,) async {
    final response = await getInstanceUserdataWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetInstanceUserdata200Response',) as GetInstanceUserdata200Response;
    
    }
    return null;
  }

  /// Halt Instance
  ///
  /// Halt an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> haltInstanceWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/halt'
      .replaceAll('{instance-id}', instanceId);

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

  /// Halt Instance
  ///
  /// Halt an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<void> haltInstance(String instanceId,) async {
    final response = await haltInstanceWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Halt Instances
  ///
  /// Halt Instances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [HaltInstancesRequest] haltInstancesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> haltInstancesWithHttpInfo({ HaltInstancesRequest? haltInstancesRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/halt';

    // ignore: prefer_final_locals
    Object? postBody = haltInstancesRequest;

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

  /// Halt Instances
  ///
  /// Halt Instances.
  ///
  /// Parameters:
  ///
  /// * [HaltInstancesRequest] haltInstancesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> haltInstances({ HaltInstancesRequest? haltInstancesRequest, }) async {
    final response = await haltInstancesWithHttpInfo( haltInstancesRequest: haltInstancesRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// List Instance IPv6 Reverse
  ///
  /// List the reverse IPv6 information for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> listInstanceIpv6ReverseWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv6/reverse'
      .replaceAll('{instance-id}', instanceId);

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

  /// List Instance IPv6 Reverse
  ///
  /// List the reverse IPv6 information for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<ListInstanceIpv6Reverse200Response?> listInstanceIpv6Reverse(String instanceId,) async {
    final response = await listInstanceIpv6ReverseWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListInstanceIpv6Reverse200Response',) as ListInstanceIpv6Reverse200Response;
    
    }
    return null;
  }

  /// List instance Private Networks
  ///
  /// **Deprecated**: use [List Instance VPCs](#operation/list-instance-vpcs) instead.<br><br>List the private networks for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listInstancePrivateNetworksWithHttpInfo(String instanceId, { int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/private-networks'
      .replaceAll('{instance-id}', instanceId);

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

  /// List instance Private Networks
  ///
  /// **Deprecated**: use [List Instance VPCs](#operation/list-instance-vpcs) instead.<br><br>List the private networks for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListInstancePrivateNetworks200Response?> listInstancePrivateNetworks(String instanceId, { int? perPage, String? cursor, }) async {
    final response = await listInstancePrivateNetworksWithHttpInfo(instanceId,  perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListInstancePrivateNetworks200Response',) as ListInstancePrivateNetworks200Response;
    
    }
    return null;
  }

  /// List Instance VPC 2.0 Networks
  ///
  /// List the VPC 2.0 networks for an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Instance VPCs](#operation/list-instance-vpcs) instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listInstanceVpc2WithHttpInfo(String instanceId, { int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/vpc2'
      .replaceAll('{instance-id}', instanceId);

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

  /// List Instance VPC 2.0 Networks
  ///
  /// List the VPC 2.0 networks for an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Instance VPCs](#operation/list-instance-vpcs) instead.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListInstanceVpc2200Response?> listInstanceVpc2(String instanceId, { int? perPage, String? cursor, }) async {
    final response = await listInstanceVpc2WithHttpInfo(instanceId,  perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListInstanceVpc2200Response',) as ListInstanceVpc2200Response;
    
    }
    return null;
  }

  /// List instance VPCs
  ///
  /// List the VPCs for an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<Response> listInstanceVpcsWithHttpInfo(String instanceId, { int? perPage, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/vpcs'
      .replaceAll('{instance-id}', instanceId);

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

  /// List instance VPCs
  ///
  /// List the VPCs for an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  Future<ListInstanceVpcs200Response?> listInstanceVpcs(String instanceId, { int? perPage, String? cursor, }) async {
    final response = await listInstanceVpcsWithHttpInfo(instanceId,  perPage: perPage, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListInstanceVpcs200Response',) as ListInstanceVpcs200Response;
    
    }
    return null;
  }

  /// List Instances
  ///
  /// List all VPS instances in your account.
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
  ///
  /// * [String] tag:
  ///   Filter by specific tag.
  ///
  /// * [String] label:
  ///   Filter by label.
  ///
  /// * [String] mainIp:
  ///   Filter by main ip address.
  ///
  /// * [String] region:
  ///   Filter by [Region id](#operation/list-regions).
  ///
  /// * [String] firewallGroupId:
  ///   Filter by [Firewall group id](#operation/list-firewall-groups).
  ///
  /// * [String] hostname:
  ///   Filter by hostname.
  ///
  /// * [bool] showPendingCharges:
  ///   Set to `true` to show pending charges.
  Future<Response> listInstancesWithHttpInfo({ int? perPage, String? cursor, String? tag, String? label, String? mainIp, String? region, String? firewallGroupId, String? hostname, bool? showPendingCharges, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances';

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
    if (tag != null) {
      queryParams.addAll(_queryParams('', 'tag', tag));
    }
    if (label != null) {
      queryParams.addAll(_queryParams('', 'label', label));
    }
    if (mainIp != null) {
      queryParams.addAll(_queryParams('', 'main_ip', mainIp));
    }
    if (region != null) {
      queryParams.addAll(_queryParams('', 'region', region));
    }
    if (firewallGroupId != null) {
      queryParams.addAll(_queryParams('', 'firewall_group_id', firewallGroupId));
    }
    if (hostname != null) {
      queryParams.addAll(_queryParams('', 'hostname', hostname));
    }
    if (showPendingCharges != null) {
      queryParams.addAll(_queryParams('', 'show_pending_charges', showPendingCharges));
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

  /// List Instances
  ///
  /// List all VPS instances in your account.
  ///
  /// Parameters:
  ///
  /// * [int] perPage:
  ///   Number of items requested per page. Default is 100 and Max is 500.
  ///
  /// * [String] cursor:
  ///   Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
  ///
  /// * [String] tag:
  ///   Filter by specific tag.
  ///
  /// * [String] label:
  ///   Filter by label.
  ///
  /// * [String] mainIp:
  ///   Filter by main ip address.
  ///
  /// * [String] region:
  ///   Filter by [Region id](#operation/list-regions).
  ///
  /// * [String] firewallGroupId:
  ///   Filter by [Firewall group id](#operation/list-firewall-groups).
  ///
  /// * [String] hostname:
  ///   Filter by hostname.
  ///
  /// * [bool] showPendingCharges:
  ///   Set to `true` to show pending charges.
  Future<ListInstances200Response?> listInstances({ int? perPage, String? cursor, String? tag, String? label, String? mainIp, String? region, String? firewallGroupId, String? hostname, bool? showPendingCharges, }) async {
    final response = await listInstancesWithHttpInfo( perPage: perPage, cursor: cursor, tag: tag, label: label, mainIp: mainIp, region: region, firewallGroupId: firewallGroupId, hostname: hostname, showPendingCharges: showPendingCharges, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListInstances200Response',) as ListInstances200Response;
    
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
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [PostBaremetalInstanceIdIpv4ReverseDefaultRequest] postBaremetalInstanceIdIpv4ReverseDefaultRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> postInstancesInstanceIdIpv4ReverseDefaultWithHttpInfo(String instanceId, { PostBaremetalInstanceIdIpv4ReverseDefaultRequest? postBaremetalInstanceIdIpv4ReverseDefaultRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/ipv4/reverse/default'
      .replaceAll('{instance-id}', instanceId);

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
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [PostBaremetalInstanceIdIpv4ReverseDefaultRequest] postBaremetalInstanceIdIpv4ReverseDefaultRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> postInstancesInstanceIdIpv4ReverseDefault(String instanceId, { PostBaremetalInstanceIdIpv4ReverseDefaultRequest? postBaremetalInstanceIdIpv4ReverseDefaultRequest, }) async {
    final response = await postInstancesInstanceIdIpv4ReverseDefaultWithHttpInfo(instanceId,  postBaremetalInstanceIdIpv4ReverseDefaultRequest: postBaremetalInstanceIdIpv4ReverseDefaultRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reboot Instance
  ///
  /// Reboot an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> rebootInstanceWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/reboot'
      .replaceAll('{instance-id}', instanceId);

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

  /// Reboot Instance
  ///
  /// Reboot an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<void> rebootInstance(String instanceId,) async {
    final response = await rebootInstanceWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reboot instances
  ///
  /// Reboot Instances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RebootInstancesRequest] rebootInstancesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> rebootInstancesWithHttpInfo({ RebootInstancesRequest? rebootInstancesRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/reboot';

    // ignore: prefer_final_locals
    Object? postBody = rebootInstancesRequest;

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

  /// Reboot instances
  ///
  /// Reboot Instances.
  ///
  /// Parameters:
  ///
  /// * [RebootInstancesRequest] rebootInstancesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> rebootInstances({ RebootInstancesRequest? rebootInstancesRequest, }) async {
    final response = await rebootInstancesWithHttpInfo( rebootInstancesRequest: rebootInstancesRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reinstall Instance
  ///
  /// Reinstall an Instance using an optional `hostname`.  **Note:** This action may take a few extra seconds to complete.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [ReinstallInstanceRequest] reinstallInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> reinstallInstanceWithHttpInfo(String instanceId, { ReinstallInstanceRequest? reinstallInstanceRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/reinstall'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = reinstallInstanceRequest;

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

  /// Reinstall Instance
  ///
  /// Reinstall an Instance using an optional `hostname`.  **Note:** This action may take a few extra seconds to complete.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [ReinstallInstanceRequest] reinstallInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateInstance202Response?> reinstallInstance(String instanceId, { ReinstallInstanceRequest? reinstallInstanceRequest, }) async {
    final response = await reinstallInstanceWithHttpInfo(instanceId,  reinstallInstanceRequest: reinstallInstanceRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateInstance202Response',) as CreateInstance202Response;
    
    }
    return null;
  }

  /// Restore Instance
  ///
  /// Restore an Instance from either `backup_id` or `snapshot_id`.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [RestoreInstanceRequest] restoreInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> restoreInstanceWithHttpInfo(String instanceId, { RestoreInstanceRequest? restoreInstanceRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/restore'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = restoreInstanceRequest;

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

  /// Restore Instance
  ///
  /// Restore an Instance from either `backup_id` or `snapshot_id`.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [RestoreInstanceRequest] restoreInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<RestoreInstance202Response?> restoreInstance(String instanceId, { RestoreInstanceRequest? restoreInstanceRequest, }) async {
    final response = await restoreInstanceWithHttpInfo(instanceId,  restoreInstanceRequest: restoreInstanceRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RestoreInstance202Response',) as RestoreInstance202Response;
    
    }
    return null;
  }

  /// Start instance
  ///
  /// Start an Instance.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> startInstanceWithHttpInfo(String instanceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}/start'
      .replaceAll('{instance-id}', instanceId);

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

  /// Start instance
  ///
  /// Start an Instance.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<void> startInstance(String instanceId,) async {
    final response = await startInstanceWithHttpInfo(instanceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Start instances
  ///
  /// Start Instances.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [StartInstancesRequest] startInstancesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> startInstancesWithHttpInfo({ StartInstancesRequest? startInstancesRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/start';

    // ignore: prefer_final_locals
    Object? postBody = startInstancesRequest;

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

  /// Start instances
  ///
  /// Start Instances.
  ///
  /// Parameters:
  ///
  /// * [StartInstancesRequest] startInstancesRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<void> startInstances({ StartInstancesRequest? startInstancesRequest, }) async {
    final response = await startInstancesWithHttpInfo( startInstancesRequest: startInstancesRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Instance
  ///
  /// Update information for an Instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [UpdateInstanceRequest] updateInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<Response> updateInstanceWithHttpInfo(String instanceId, { UpdateInstanceRequest? updateInstanceRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/instances/{instance-id}'
      .replaceAll('{instance-id}', instanceId);

    // ignore: prefer_final_locals
    Object? postBody = updateInstanceRequest;

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

  /// Update Instance
  ///
  /// Update information for an Instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.
  ///
  /// Parameters:
  ///
  /// * [String] instanceId (required):
  ///   The [Instance ID](#operation/list-instances).
  ///
  /// * [UpdateInstanceRequest] updateInstanceRequest:
  ///   Include a JSON object in the request body with a content type of **application/json**.
  Future<CreateInstance202Response?> updateInstance(String instanceId, { UpdateInstanceRequest? updateInstanceRequest, }) async {
    final response = await updateInstanceWithHttpInfo(instanceId,  updateInstanceRequest: updateInstanceRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateInstance202Response',) as CreateInstance202Response;
    
    }
    return null;
  }
}
