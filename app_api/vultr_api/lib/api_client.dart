//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiClient {
  ApiClient({this.basePath = 'https://api.vultr.com/v2', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType,
  ) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = StreamedRequest(method, uri);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = MultipartRequest(method, uri);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      switch(method) {
        case 'POST': return await _client.post(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PUT': return await _client.put(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'DELETE': return await _client.delete(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PATCH': return await _client.patch(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'HEAD': return await _client.head(uri, headers: nullableHeaderParams,);
        case 'GET': return await _client.get(uri, headers: nullableHeaderParams,);
      }
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }

    throw ApiException(
      HttpStatus.badRequest,
      'Invalid HTTP operation: $method $path',
    );
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'Account':
          return Account.fromJson(value);
        case 'AccountBandwidth':
          return AccountBandwidth.fromJson(value);
        case 'AccountBandwidthCurrentMonthProjected':
          return AccountBandwidthCurrentMonthProjected.fromJson(value);
        case 'AccountBandwidthCurrentMonthToDate':
          return AccountBandwidthCurrentMonthToDate.fromJson(value);
        case 'AccountBandwidthPreviousMonth':
          return AccountBandwidthPreviousMonth.fromJson(value);
        case 'AccountBgp':
          return AccountBgp.fromJson(value);
        case 'AddStorageGatewayExport200Response':
          return AddStorageGatewayExport200Response.fromJson(value);
        case 'AddUserIpWhitelistRequest':
          return AddUserIpWhitelistRequest.fromJson(value);
        case 'Apikey':
          return Apikey.fromJson(value);
        case 'AppVariable':
          return AppVariable.fromJson(value);
        case 'Application':
          return Application.fromJson(value);
        case 'AttachBaremetalsVpc2Request':
          return AttachBaremetalsVpc2Request.fromJson(value);
        case 'AttachBaremetalsVpcsRequest':
          return AttachBaremetalsVpcsRequest.fromJson(value);
        case 'AttachBlockRequest':
          return AttachBlockRequest.fromJson(value);
        case 'AttachInstanceIso202Response':
          return AttachInstanceIso202Response.fromJson(value);
        case 'AttachInstanceIso202ResponseIsoStatus':
          return AttachInstanceIso202ResponseIsoStatus.fromJson(value);
        case 'AttachInstanceIsoRequest':
          return AttachInstanceIsoRequest.fromJson(value);
        case 'AttachInstanceNetworkRequest':
          return AttachInstanceNetworkRequest.fromJson(value);
        case 'AttachInstanceVpc2Request':
          return AttachInstanceVpc2Request.fromJson(value);
        case 'AttachInstanceVpcRequest':
          return AttachInstanceVpcRequest.fromJson(value);
        case 'AttachReservedIpRequest':
          return AttachReservedIpRequest.fromJson(value);
        case 'AttachVpc2NodesRequest':
          return AttachVpc2NodesRequest.fromJson(value);
        case 'AttachedVpcs':
          return AttachedVpcs.fromJson(value);
        case 'Backup':
          return Backup.fromJson(value);
        case 'BackupSchedule':
          return BackupSchedule.fromJson(value);
        case 'Bandwidth':
          return Bandwidth.fromJson(value);
        case 'Baremetal':
          return Baremetal.fromJson(value);
        case 'BaremetalGet':
          return BaremetalGet.fromJson(value);
        case 'BaremetalIpv4':
          return BaremetalIpv4.fromJson(value);
        case 'BaremetalIpv6':
          return BaremetalIpv6.fromJson(value);
        case 'Billing':
          return Billing.fromJson(value);
        case 'Blockstorage':
          return Blockstorage.fromJson(value);
        case 'ClusterTiers':
          return ClusterTiers.fromJson(value);
        case 'Clusters':
          return Clusters.fromJson(value);
        case 'ConvertReservedIpRequest':
          return ConvertReservedIpRequest.fromJson(value);
        case 'CreateBaremetal202Response':
          return CreateBaremetal202Response.fromJson(value);
        case 'CreateBaremetalRequest':
          return CreateBaremetalRequest.fromJson(value);
        case 'CreateBaremetalReverseIpv4Request':
          return CreateBaremetalReverseIpv4Request.fromJson(value);
        case 'CreateBaremetalReverseIpv6Request':
          return CreateBaremetalReverseIpv6Request.fromJson(value);
        case 'CreateBlock202Response':
          return CreateBlock202Response.fromJson(value);
        case 'CreateBlockRequest':
          return CreateBlockRequest.fromJson(value);
        case 'CreateDnsDomain200Response':
          return CreateDnsDomain200Response.fromJson(value);
        case 'CreateDnsDomainRecord201Response':
          return CreateDnsDomainRecord201Response.fromJson(value);
        case 'CreateDnsDomainRecordRequest':
          return CreateDnsDomainRecordRequest.fromJson(value);
        case 'CreateDnsDomainRequest':
          return CreateDnsDomainRequest.fromJson(value);
        case 'CreateFirewallGroup201Response':
          return CreateFirewallGroup201Response.fromJson(value);
        case 'CreateFirewallGroupRequest':
          return CreateFirewallGroupRequest.fromJson(value);
        case 'CreateInference201Response':
          return CreateInference201Response.fromJson(value);
        case 'CreateInferenceRequest':
          return CreateInferenceRequest.fromJson(value);
        case 'CreateInstance202Response':
          return CreateInstance202Response.fromJson(value);
        case 'CreateInstanceBackupScheduleRequest':
          return CreateInstanceBackupScheduleRequest.fromJson(value);
        case 'CreateInstanceIpv4Request':
          return CreateInstanceIpv4Request.fromJson(value);
        case 'CreateInstanceRequest':
          return CreateInstanceRequest.fromJson(value);
        case 'CreateIso201Response':
          return CreateIso201Response.fromJson(value);
        case 'CreateIsoRequest':
          return CreateIsoRequest.fromJson(value);
        case 'CreateKubernetesCluster201Response':
          return CreateKubernetesCluster201Response.fromJson(value);
        case 'CreateKubernetesClusterRequest':
          return CreateKubernetesClusterRequest.fromJson(value);
        case 'CreateKubernetesClusterRequestNodePoolsInner':
          return CreateKubernetesClusterRequestNodePoolsInner.fromJson(value);
        case 'CreateKubernetesClusterRequestOidc':
          return CreateKubernetesClusterRequestOidc.fromJson(value);
        case 'CreateLoadBalancer202Response':
          return CreateLoadBalancer202Response.fromJson(value);
        case 'CreateLoadBalancerForwardingRulesRequest':
          return CreateLoadBalancerForwardingRulesRequest.fromJson(value);
        case 'CreateLoadBalancerRequest':
          return CreateLoadBalancerRequest.fromJson(value);
        case 'CreateLoadBalancerRequestAutoSsl':
          return CreateLoadBalancerRequestAutoSsl.fromJson(value);
        case 'CreateLoadBalancerRequestFirewallRulesInner':
          return CreateLoadBalancerRequestFirewallRulesInner.fromJson(value);
        case 'CreateLoadBalancerRequestForwardingRulesInner':
          return CreateLoadBalancerRequestForwardingRulesInner.fromJson(value);
        case 'CreateLoadBalancerRequestGlobalRegionsInner':
          return CreateLoadBalancerRequestGlobalRegionsInner.fromJson(value);
        case 'CreateLoadBalancerRequestHealthCheck':
          return CreateLoadBalancerRequestHealthCheck.fromJson(value);
        case 'CreateLoadBalancerRequestSsl':
          return CreateLoadBalancerRequestSsl.fromJson(value);
        case 'CreateLoadBalancerRequestStickySession':
          return CreateLoadBalancerRequestStickySession.fromJson(value);
        case 'CreateLoadBalancerReverseDnsIpv4Request':
          return CreateLoadBalancerReverseDnsIpv4Request.fromJson(value);
        case 'CreateLoadBalancerReverseDnsIpv6Request':
          return CreateLoadBalancerReverseDnsIpv6Request.fromJson(value);
        case 'CreateLoadBalancerReverseDnsIpv6RequestV6Inner':
          return CreateLoadBalancerReverseDnsIpv6RequestV6Inner.fromJson(value);
        case 'CreateNetworkRequest':
          return CreateNetworkRequest.fromJson(value);
        case 'CreateNodepoolLabel201Response':
          return CreateNodepoolLabel201Response.fromJson(value);
        case 'CreateNodepoolTaint201Response':
          return CreateNodepoolTaint201Response.fromJson(value);
        case 'CreateNodepools201Response':
          return CreateNodepools201Response.fromJson(value);
        case 'CreateNodepoolsRequest':
          return CreateNodepoolsRequest.fromJson(value);
        case 'CreateObjectStorage202Response':
          return CreateObjectStorage202Response.fromJson(value);
        case 'CreateObjectStorageRequest':
          return CreateObjectStorageRequest.fromJson(value);
        case 'CreatePullzone201Response':
          return CreatePullzone201Response.fromJson(value);
        case 'CreatePullzoneRequest':
          return CreatePullzoneRequest.fromJson(value);
        case 'CreatePushzone201Response':
          return CreatePushzone201Response.fromJson(value);
        case 'CreatePushzoneRequest':
          return CreatePushzoneRequest.fromJson(value);
        case 'CreatePushzoneUpload201Response':
          return CreatePushzoneUpload201Response.fromJson(value);
        case 'CreatePushzoneUploadRequest':
          return CreatePushzoneUploadRequest.fromJson(value);
        case 'CreateReservedIpRequest':
          return CreateReservedIpRequest.fromJson(value);
        case 'CreateSnapshotCreateFromUrlRequest':
          return CreateSnapshotCreateFromUrlRequest.fromJson(value);
        case 'CreateSnapshotRequest':
          return CreateSnapshotRequest.fromJson(value);
        case 'CreateSshKeyRequest':
          return CreateSshKeyRequest.fromJson(value);
        case 'CreateStartupScriptRequest':
          return CreateStartupScriptRequest.fromJson(value);
        case 'CreateStorageGateway202Response':
          return CreateStorageGateway202Response.fromJson(value);
        case 'CreateStorageGatewayRequest':
          return CreateStorageGatewayRequest.fromJson(value);
        case 'CreateSubaccount201Response':
          return CreateSubaccount201Response.fromJson(value);
        case 'CreateSubaccountRequest':
          return CreateSubaccountRequest.fromJson(value);
        case 'CreateUserApiKeyRequest':
          return CreateUserApiKeyRequest.fromJson(value);
        case 'CreateUserRequest':
          return CreateUserRequest.fromJson(value);
        case 'CreateVFSRequest':
          return CreateVFSRequest.fromJson(value);
        case 'CreateVFSRequestStorageSize':
          return CreateVFSRequestStorageSize.fromJson(value);
        case 'CreateVpc2Request':
          return CreateVpc2Request.fromJson(value);
        case 'CreateVpcRequest':
          return CreateVpcRequest.fromJson(value);
        case 'DbaasMeta':
          return DbaasMeta.fromJson(value);
        case 'DetachBaremetalVpc2Request':
          return DetachBaremetalVpc2Request.fromJson(value);
        case 'DetachBaremetalVpcsRequest':
          return DetachBaremetalVpcsRequest.fromJson(value);
        case 'DetachBlockRequest':
          return DetachBlockRequest.fromJson(value);
        case 'DetachInstanceIso202Response':
          return DetachInstanceIso202Response.fromJson(value);
        case 'DetachInstanceIso202ResponseIsoStatus':
          return DetachInstanceIso202ResponseIsoStatus.fromJson(value);
        case 'DetachInstanceNetworkRequest':
          return DetachInstanceNetworkRequest.fromJson(value);
        case 'DetachInstanceVpc2Request':
          return DetachInstanceVpc2Request.fromJson(value);
        case 'DetachInstanceVpcRequest':
          return DetachInstanceVpcRequest.fromJson(value);
        case 'DetachVpc2NodesRequest':
          return DetachVpc2NodesRequest.fromJson(value);
        case 'DnsRecord':
          return DnsRecord.fromJson(value);
        case 'DnsSoa':
          return DnsSoa.fromJson(value);
        case 'Domain':
          return Domain.fromJson(value);
        case 'FirewallGroup':
          return FirewallGroup.fromJson(value);
        case 'FirewallRule':
          return FirewallRule.fromJson(value);
        case 'ForwardingRule':
          return ForwardingRule.fromJson(value);
        case 'GetAccount200Response':
          return GetAccount200Response.fromJson(value);
        case 'GetAccountBandwidth200Response':
          return GetAccountBandwidth200Response.fromJson(value);
        case 'GetBackup200Response':
          return GetBackup200Response.fromJson(value);
        case 'GetBandwidthBaremetal200Response':
          return GetBandwidthBaremetal200Response.fromJson(value);
        case 'GetBareMetalUserdata200Response':
          return GetBareMetalUserdata200Response.fromJson(value);
        case 'GetBareMetalUserdata200ResponseUserData':
          return GetBareMetalUserdata200ResponseUserData.fromJson(value);
        case 'GetBareMetalVnc200Response':
          return GetBareMetalVnc200Response.fromJson(value);
        case 'GetBareMetalVnc200ResponseVnc':
          return GetBareMetalVnc200ResponseVnc.fromJson(value);
        case 'GetBareMetalsUpgrades200Response':
          return GetBareMetalsUpgrades200Response.fromJson(value);
        case 'GetBareMetalsUpgrades200ResponseUpgrades':
          return GetBareMetalsUpgrades200ResponseUpgrades.fromJson(value);
        case 'GetBaremetal200Response':
          return GetBaremetal200Response.fromJson(value);
        case 'GetDnsDomainDnssec200Response':
          return GetDnsDomainDnssec200Response.fromJson(value);
        case 'GetDnsDomainSoa200Response':
          return GetDnsDomainSoa200Response.fromJson(value);
        case 'GetInferenceUsage200Response':
          return GetInferenceUsage200Response.fromJson(value);
        case 'GetInstance200Response':
          return GetInstance200Response.fromJson(value);
        case 'GetInstanceBackupSchedule200Response':
          return GetInstanceBackupSchedule200Response.fromJson(value);
        case 'GetInstanceIsoStatus200Response':
          return GetInstanceIsoStatus200Response.fromJson(value);
        case 'GetInstanceIsoStatus200ResponseIsoStatus':
          return GetInstanceIsoStatus200ResponseIsoStatus.fromJson(value);
        case 'GetInstanceJob200Response':
          return GetInstanceJob200Response.fromJson(value);
        case 'GetInstanceJob200ResponseJob':
          return GetInstanceJob200ResponseJob.fromJson(value);
        case 'GetInstanceNeighbors200Response':
          return GetInstanceNeighbors200Response.fromJson(value);
        case 'GetInstanceUpgrades200Response':
          return GetInstanceUpgrades200Response.fromJson(value);
        case 'GetInstanceUpgrades200ResponseUpgrades':
          return GetInstanceUpgrades200ResponseUpgrades.fromJson(value);
        case 'GetInstanceUserdata200Response':
          return GetInstanceUserdata200Response.fromJson(value);
        case 'GetInstanceUserdata200ResponseUserData':
          return GetInstanceUserdata200ResponseUserData.fromJson(value);
        case 'GetInvoice200Response':
          return GetInvoice200Response.fromJson(value);
        case 'GetInvoiceItems200Response':
          return GetInvoiceItems200Response.fromJson(value);
        case 'GetInvoiceItems200ResponseInvoiceItemsInner':
          return GetInvoiceItems200ResponseInvoiceItemsInner.fromJson(value);
        case 'GetInvoiceItems200ResponseMeta':
          return GetInvoiceItems200ResponseMeta.fromJson(value);
        case 'GetInvoiceItems200ResponseMetaLinks':
          return GetInvoiceItems200ResponseMetaLinks.fromJson(value);
        case 'GetIpv4Baremetal200Response':
          return GetIpv4Baremetal200Response.fromJson(value);
        case 'GetIpv6Baremetal200Response':
          return GetIpv6Baremetal200Response.fromJson(value);
        case 'GetKubernetesAvailableUpgrades200Response':
          return GetKubernetesAvailableUpgrades200Response.fromJson(value);
        case 'GetKubernetesClustersConfig200Response':
          return GetKubernetesClustersConfig200Response.fromJson(value);
        case 'GetKubernetesResources200Response':
          return GetKubernetesResources200Response.fromJson(value);
        case 'GetKubernetesResources200ResponseResources':
          return GetKubernetesResources200ResponseResources.fromJson(value);
        case 'GetKubernetesResources200ResponseResourcesBlockStorageInner':
          return GetKubernetesResources200ResponseResourcesBlockStorageInner.fromJson(value);
        case 'GetKubernetesResources200ResponseResourcesLoadBalancerInner':
          return GetKubernetesResources200ResponseResourcesLoadBalancerInner.fromJson(value);
        case 'GetKubernetesVersions200Response':
          return GetKubernetesVersions200Response.fromJson(value);
        case 'GetLoadBalancerForwardingRule200Response':
          return GetLoadBalancerForwardingRule200Response.fromJson(value);
        case 'GetLoadBalancerReverseDns200Response':
          return GetLoadBalancerReverseDns200Response.fromJson(value);
        case 'GetNetwork200Response':
          return GetNetwork200Response.fromJson(value);
        case 'GetNodepools200Response':
          return GetNodepools200Response.fromJson(value);
        case 'GetPushzone200Response':
          return GetPushzone200Response.fromJson(value);
        case 'GetPushzoneFiles200Response':
          return GetPushzoneFiles200Response.fromJson(value);
        case 'GetReservedIp200Response':
          return GetReservedIp200Response.fromJson(value);
        case 'GetSnapshot200Response':
          return GetSnapshot200Response.fromJson(value);
        case 'GetSshKey200Response':
          return GetSshKey200Response.fromJson(value);
        case 'GetStartupScript200Response':
          return GetStartupScript200Response.fromJson(value);
        case 'GetUserApiKey200Response':
          return GetUserApiKey200Response.fromJson(value);
        case 'GetUserIpWhitelistEntry200Response':
          return GetUserIpWhitelistEntry200Response.fromJson(value);
        case 'GetVpc200Response':
          return GetVpc200Response.fromJson(value);
        case 'GetVpc2200Response':
          return GetVpc2200Response.fromJson(value);
        case 'HaltBaremetalsRequest':
          return HaltBaremetalsRequest.fromJson(value);
        case 'HaltInstancesRequest':
          return HaltInstancesRequest.fromJson(value);
        case 'InferenceSubscription':
          return InferenceSubscription.fromJson(value);
        case 'InferenceUsage':
          return InferenceUsage.fromJson(value);
        case 'InferenceUsageAudio':
          return InferenceUsageAudio.fromJson(value);
        case 'InferenceUsageChat':
          return InferenceUsageChat.fromJson(value);
        case 'Instance':
          return Instance.fromJson(value);
        case 'InstanceGet':
          return InstanceGet.fromJson(value);
        case 'InstanceV6NetworksInner':
          return InstanceV6NetworksInner.fromJson(value);
        case 'InstanceVpc':
          return InstanceVpc.fromJson(value);
        case 'InstanceVpc2':
          return InstanceVpc2.fromJson(value);
        case 'Invoice':
          return Invoice.fromJson(value);
        case 'IpWhitelistEntry':
          return IpWhitelistEntry.fromJson(value);
        case 'Iso':
          return Iso.fromJson(value);
        case 'IsoPublic':
          return IsoPublic.fromJson(value);
        case 'ListApplications200Response':
          return ListApplications200Response.fromJson(value);
        case 'ListAvailablePlansRegion200Response':
          return ListAvailablePlansRegion200Response.fromJson(value);
        case 'ListBackups200Response':
          return ListBackups200Response.fromJson(value);
        case 'ListBaremetalVpc2200Response':
          return ListBaremetalVpc2200Response.fromJson(value);
        case 'ListBaremetalVpcs200Response':
          return ListBaremetalVpcs200Response.fromJson(value);
        case 'ListBaremetals200Response':
          return ListBaremetals200Response.fromJson(value);
        case 'ListBillingHistory200Response':
          return ListBillingHistory200Response.fromJson(value);
        case 'ListBlocks200Response':
          return ListBlocks200Response.fromJson(value);
        case 'ListDnsDomainRecords200Response':
          return ListDnsDomainRecords200Response.fromJson(value);
        case 'ListDnsDomains200Response':
          return ListDnsDomains200Response.fromJson(value);
        case 'ListFirewallGroupRules200Response':
          return ListFirewallGroupRules200Response.fromJson(value);
        case 'ListFirewallGroups200Response':
          return ListFirewallGroups200Response.fromJson(value);
        case 'ListInference200Response':
          return ListInference200Response.fromJson(value);
        case 'ListInstanceIpv6Reverse200Response':
          return ListInstanceIpv6Reverse200Response.fromJson(value);
        case 'ListInstanceIpv6Reverse200ResponseReverseIpv6sInner':
          return ListInstanceIpv6Reverse200ResponseReverseIpv6sInner.fromJson(value);
        case 'ListInstancePrivateNetworks200Response':
          return ListInstancePrivateNetworks200Response.fromJson(value);
        case 'ListInstanceVpc2200Response':
          return ListInstanceVpc2200Response.fromJson(value);
        case 'ListInstanceVpcs200Response':
          return ListInstanceVpcs200Response.fromJson(value);
        case 'ListInstances200Response':
          return ListInstances200Response.fromJson(value);
        case 'ListInvoices200Response':
          return ListInvoices200Response.fromJson(value);
        case 'ListIsos200Response':
          return ListIsos200Response.fromJson(value);
        case 'ListKubernetesClusters200Response':
          return ListKubernetesClusters200Response.fromJson(value);
        case 'ListLoadBalancerForwardingRules200Response':
          return ListLoadBalancerForwardingRules200Response.fromJson(value);
        case 'ListLoadBalancers200Response':
          return ListLoadBalancers200Response.fromJson(value);
        case 'ListLogs200Response':
          return ListLogs200Response.fromJson(value);
        case 'ListMarketplaceAppVariables200Response':
          return ListMarketplaceAppVariables200Response.fromJson(value);
        case 'ListMetalPlans200Response':
          return ListMetalPlans200Response.fromJson(value);
        case 'ListNetworks200Response':
          return ListNetworks200Response.fromJson(value);
        case 'ListNodepoolLabels200Response':
          return ListNodepoolLabels200Response.fromJson(value);
        case 'ListNodepoolTaints200Response':
          return ListNodepoolTaints200Response.fromJson(value);
        case 'ListObjectStorageClusterTiers200Response':
          return ListObjectStorageClusterTiers200Response.fromJson(value);
        case 'ListObjectStorageClusters200Response':
          return ListObjectStorageClusters200Response.fromJson(value);
        case 'ListObjectStorageTiers200Response':
          return ListObjectStorageTiers200Response.fromJson(value);
        case 'ListObjectStorages200Response':
          return ListObjectStorages200Response.fromJson(value);
        case 'ListOs200Response':
          return ListOs200Response.fromJson(value);
        case 'ListPlans200Response':
          return ListPlans200Response.fromJson(value);
        case 'ListPublicIsos200Response':
          return ListPublicIsos200Response.fromJson(value);
        case 'ListPullzones200Response':
          return ListPullzones200Response.fromJson(value);
        case 'ListPushzones200Response':
          return ListPushzones200Response.fromJson(value);
        case 'ListRegions200Response':
          return ListRegions200Response.fromJson(value);
        case 'ListReservedIps200Response':
          return ListReservedIps200Response.fromJson(value);
        case 'ListSnapshots200Response':
          return ListSnapshots200Response.fromJson(value);
        case 'ListSshKeys200Response':
          return ListSshKeys200Response.fromJson(value);
        case 'ListStartupScripts200Response':
          return ListStartupScripts200Response.fromJson(value);
        case 'ListStorageGateways200Response':
          return ListStorageGateways200Response.fromJson(value);
        case 'ListSubaccounts200Response':
          return ListSubaccounts200Response.fromJson(value);
        case 'ListUserApiKeys200Response':
          return ListUserApiKeys200Response.fromJson(value);
        case 'ListUserIpWhitelist200Response':
          return ListUserIpWhitelist200Response.fromJson(value);
        case 'ListUsers200Response':
          return ListUsers200Response.fromJson(value);
        case 'ListVFS200Response':
          return ListVFS200Response.fromJson(value);
        case 'ListVFSAttachments200Response':
          return ListVFSAttachments200Response.fromJson(value);
        case 'ListVpc2200Response':
          return ListVpc2200Response.fromJson(value);
        case 'ListVpc2Nodes200Response':
          return ListVpc2Nodes200Response.fromJson(value);
        case 'ListVpcAttachments200Response':
          return ListVpcAttachments200Response.fromJson(value);
        case 'ListVpcs200Response':
          return ListVpcs200Response.fromJson(value);
        case 'Loadbalancer':
          return Loadbalancer.fromJson(value);
        case 'LoadbalancerAutoSsl':
          return LoadbalancerAutoSsl.fromJson(value);
        case 'LoadbalancerFirewallRule':
          return LoadbalancerFirewallRule.fromJson(value);
        case 'LoadbalancerFirewallRulesInner':
          return LoadbalancerFirewallRulesInner.fromJson(value);
        case 'LoadbalancerForwardRulesInner':
          return LoadbalancerForwardRulesInner.fromJson(value);
        case 'LoadbalancerGenericInfo':
          return LoadbalancerGenericInfo.fromJson(value);
        case 'LoadbalancerGenericInfoStickySessions':
          return LoadbalancerGenericInfoStickySessions.fromJson(value);
        case 'LoadbalancerHealthCheck':
          return LoadbalancerHealthCheck.fromJson(value);
        case 'LoadbalancerNodeIps':
          return LoadbalancerNodeIps.fromJson(value);
        case 'Log':
          return Log.fromJson(value);
        case 'LogMeta':
          return LogMeta.fromJson(value);
        case 'LogMetadata':
          return LogMetadata.fromJson(value);
        case 'Meta':
          return Meta.fromJson(value);
        case 'MetaLinks':
          return MetaLinks.fromJson(value);
        case 'Network':
          return Network.fromJson(value);
        case 'NodepoolInstances':
          return NodepoolInstances.fromJson(value);
        case 'NodepoolLabel':
          return NodepoolLabel.fromJson(value);
        case 'NodepoolLabelReq':
          return NodepoolLabelReq.fromJson(value);
        case 'NodepoolTaint':
          return NodepoolTaint.fromJson(value);
        case 'NodepoolTaintReq':
          return NodepoolTaintReq.fromJson(value);
        case 'Nodepools':
          return Nodepools.fromJson(value);
        case 'ObjectStorage':
          return ObjectStorage.fromJson(value);
        case 'ObjectStorages':
          return ObjectStorages.fromJson(value);
        case 'ObjectStoragesTier':
          return ObjectStoragesTier.fromJson(value);
        case 'Os':
          return Os.fromJson(value);
        case 'PatchReservedIpsReservedIpRequest':
          return PatchReservedIpsReservedIpRequest.fromJson(value);
        case 'PendingCharges200Response':
          return PendingCharges200Response.fromJson(value);
        case 'Plans':
          return Plans.fromJson(value);
        case 'PlansLocationCostValue':
          return PlansLocationCostValue.fromJson(value);
        case 'PlansMetal':
          return PlansMetal.fromJson(value);
        case 'PostBaremetalInstanceIdIpv4ReverseDefaultRequest':
          return PostBaremetalInstanceIdIpv4ReverseDefaultRequest.fromJson(value);
        case 'PostFirewallsFirewallGroupIdRules201Response':
          return PostFirewallsFirewallGroupIdRules201Response.fromJson(value);
        case 'PostFirewallsFirewallGroupIdRulesRequest':
          return PostFirewallsFirewallGroupIdRulesRequest.fromJson(value);
        case 'PrivateNetworks':
          return PrivateNetworks.fromJson(value);
        case 'Pullzone':
          return Pullzone.fromJson(value);
        case 'Pushzone':
          return Pushzone.fromJson(value);
        case 'Pushzonefile':
          return Pushzonefile.fromJson(value);
        case 'Pushzonefilemeta':
          return Pushzonefilemeta.fromJson(value);
        case 'PutSnapshotsSnapshotIdRequest':
          return PutSnapshotsSnapshotIdRequest.fromJson(value);
        case 'RebootInstancesRequest':
          return RebootInstancesRequest.fromJson(value);
        case 'RegenerateObjectStorageKeys201Response':
          return RegenerateObjectStorageKeys201Response.fromJson(value);
        case 'RegenerateObjectStorageKeys201ResponseS3Credentials':
          return RegenerateObjectStorageKeys201ResponseS3Credentials.fromJson(value);
        case 'Region':
          return Region.fromJson(value);
        case 'ReinstallBaremetalRequest':
          return ReinstallBaremetalRequest.fromJson(value);
        case 'ReinstallInstanceRequest':
          return ReinstallInstanceRequest.fromJson(value);
        case 'RemoveUserIpWhitelistRequest':
          return RemoveUserIpWhitelistRequest.fromJson(value);
        case 'ReservedIp':
          return ReservedIp.fromJson(value);
        case 'RestoreInstance202Response':
          return RestoreInstance202Response.fromJson(value);
        case 'RestoreInstance202ResponseStatus':
          return RestoreInstance202ResponseStatus.fromJson(value);
        case 'RestoreInstanceRequest':
          return RestoreInstanceRequest.fromJson(value);
        case 'Snapshot':
          return Snapshot.fromJson(value);
        case 'Ssh':
          return Ssh.fromJson(value);
        case 'StartInstancesRequest':
          return StartInstancesRequest.fromJson(value);
        case 'StartKubernetesClusterUpgradeRequest':
          return StartKubernetesClusterUpgradeRequest.fromJson(value);
        case 'Startup':
          return Startup.fromJson(value);
        case 'StorageGateway':
          return StorageGateway.fromJson(value);
        case 'StorageGatewayExport':
          return StorageGatewayExport.fromJson(value);
        case 'StorageGatewayNetwork':
          return StorageGatewayNetwork.fromJson(value);
        case 'StorageGatewayNetworkPrimary':
          return StorageGatewayNetworkPrimary.fromJson(value);
        case 'StorageGatewayNetworkPrimaryVpc':
          return StorageGatewayNetworkPrimaryVpc.fromJson(value);
        case 'Subaccount':
          return Subaccount.fromJson(value);
        case 'Tiers':
          return Tiers.fromJson(value);
        case 'TiersLocationsInner':
          return TiersLocationsInner.fromJson(value);
        case 'UpdateBaremetal202Response':
          return UpdateBaremetal202Response.fromJson(value);
        case 'UpdateBaremetalRequest':
          return UpdateBaremetalRequest.fromJson(value);
        case 'UpdateBlockRequest':
          return UpdateBlockRequest.fromJson(value);
        case 'UpdateDnsDomainRecordRequest':
          return UpdateDnsDomainRecordRequest.fromJson(value);
        case 'UpdateDnsDomainRequest':
          return UpdateDnsDomainRequest.fromJson(value);
        case 'UpdateDnsDomainSoaRequest':
          return UpdateDnsDomainSoaRequest.fromJson(value);
        case 'UpdateFirewallGroupRequest':
          return UpdateFirewallGroupRequest.fromJson(value);
        case 'UpdateInferenceRequest':
          return UpdateInferenceRequest.fromJson(value);
        case 'UpdateInstanceRequest':
          return UpdateInstanceRequest.fromJson(value);
        case 'UpdateKubernetesClusterRequest':
          return UpdateKubernetesClusterRequest.fromJson(value);
        case 'UpdateLoadBalancerRequest':
          return UpdateLoadBalancerRequest.fromJson(value);
        case 'UpdateLoadBalancerRequestHealthCheck':
          return UpdateLoadBalancerRequestHealthCheck.fromJson(value);
        case 'UpdateNetworkRequest':
          return UpdateNetworkRequest.fromJson(value);
        case 'UpdateNodepoolRequest':
          return UpdateNodepoolRequest.fromJson(value);
        case 'UpdateNodepoolRequest1':
          return UpdateNodepoolRequest1.fromJson(value);
        case 'UpdateObjectStorageRequest':
          return UpdateObjectStorageRequest.fromJson(value);
        case 'UpdatePullzoneRequest':
          return UpdatePullzoneRequest.fromJson(value);
        case 'UpdatePushzoneRequest':
          return UpdatePushzoneRequest.fromJson(value);
        case 'UpdateSshKeyRequest':
          return UpdateSshKeyRequest.fromJson(value);
        case 'UpdateStartupScriptRequest':
          return UpdateStartupScriptRequest.fromJson(value);
        case 'UpdateStorageGatewayRequest':
          return UpdateStorageGatewayRequest.fromJson(value);
        case 'UpdateUserRequest':
          return UpdateUserRequest.fromJson(value);
        case 'UpdateVFSRequest':
          return UpdateVFSRequest.fromJson(value);
        case 'UpdateVFSRequestStorageSize':
          return UpdateVFSRequestStorageSize.fromJson(value);
        case 'UpdateVpc2Request':
          return UpdateVpc2Request.fromJson(value);
        case 'UpdateVpcRequest':
          return UpdateVpcRequest.fromJson(value);
        case 'Uploadendpoint':
          return Uploadendpoint.fromJson(value);
        case 'UploadendpointInputs':
          return UploadendpointInputs.fromJson(value);
        case 'User':
          return User.fromJson(value);
        case 'UserUser':
          return UserUser.fromJson(value);
        case 'Vfs':
          return Vfs.fromJson(value);
        case 'VfsAttachment':
          return VfsAttachment.fromJson(value);
        case 'VfsBilling':
          return VfsBilling.fromJson(value);
        case 'VfsRegion':
          return VfsRegion.fromJson(value);
        case 'VfsRegionMinSizeGb':
          return VfsRegionMinSizeGb.fromJson(value);
        case 'VfsRegionPricePerGb':
          return VfsRegionPricePerGb.fromJson(value);
        case 'VfsStorageSize':
          return VfsStorageSize.fromJson(value);
        case 'VkeCluster':
          return VkeCluster.fromJson(value);
        case 'VkeClusterOidc':
          return VkeClusterOidc.fromJson(value);
        case 'Vpc':
          return Vpc.fromJson(value);
        case 'Vpc2':
          return Vpc2.fromJson(value);
        case 'Vpc2nodes':
          return Vpc2nodes.fromJson(value);
        case 'VpcAttachment':
          return VpcAttachment.fromJson(value);
        case 'VpcAttachmentIp':
          return VpcAttachmentIp.fromJson(value);
        case 'VpcAttachmentLinkedSubscription':
          return VpcAttachmentLinkedSubscription.fromJson(value);
        case 'VpcInternet':
          return VpcInternet.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
