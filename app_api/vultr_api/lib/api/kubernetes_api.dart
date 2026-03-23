//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class KubernetesApi {
  KubernetesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Kubernetes Cluster
  ///
  /// Create Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateKubernetesClusterRequest] createKubernetesClusterRequest:
  ///   Request Body
  Future<Response> createKubernetesClusterWithHttpInfo({ CreateKubernetesClusterRequest? createKubernetesClusterRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters';

    // ignore: prefer_final_locals
    Object? postBody = createKubernetesClusterRequest;

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

  /// Create Kubernetes Cluster
  ///
  /// Create Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [CreateKubernetesClusterRequest] createKubernetesClusterRequest:
  ///   Request Body
  Future<CreateKubernetesCluster201Response?> createKubernetesCluster({ CreateKubernetesClusterRequest? createKubernetesClusterRequest, }) async {
    final response = await createKubernetesClusterWithHttpInfo( createKubernetesClusterRequest: createKubernetesClusterRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateKubernetesCluster201Response',) as CreateKubernetesCluster201Response;
    
    }
    return null;
  }

  /// Create NodePool Label
  ///
  /// Add NodePool Label to Existing Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [NodepoolLabelReq] nodepoolLabelReq:
  Future<Response> createNodepoolLabelWithHttpInfo(String vkeId, String nodepoolId, { NodepoolLabelReq? nodepoolLabelReq, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

    // ignore: prefer_final_locals
    Object? postBody = nodepoolLabelReq;

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

  /// Create NodePool Label
  ///
  /// Add NodePool Label to Existing Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [NodepoolLabelReq] nodepoolLabelReq:
  Future<CreateNodepoolLabel201Response?> createNodepoolLabel(String vkeId, String nodepoolId, { NodepoolLabelReq? nodepoolLabelReq, }) async {
    final response = await createNodepoolLabelWithHttpInfo(vkeId, nodepoolId,  nodepoolLabelReq: nodepoolLabelReq, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepoolLabel201Response',) as CreateNodepoolLabel201Response;
    
    }
    return null;
  }

  /// Create NodePool Taint
  ///
  /// Add NodePool Taint to Existing Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [NodepoolTaintReq] nodepoolTaintReq:
  Future<Response> createNodepoolTaintWithHttpInfo(String vkeId, String nodepoolId, { NodepoolTaintReq? nodepoolTaintReq, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

    // ignore: prefer_final_locals
    Object? postBody = nodepoolTaintReq;

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

  /// Create NodePool Taint
  ///
  /// Add NodePool Taint to Existing Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [NodepoolTaintReq] nodepoolTaintReq:
  Future<CreateNodepoolTaint201Response?> createNodepoolTaint(String vkeId, String nodepoolId, { NodepoolTaintReq? nodepoolTaintReq, }) async {
    final response = await createNodepoolTaintWithHttpInfo(vkeId, nodepoolId,  nodepoolTaintReq: nodepoolTaintReq, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepoolTaint201Response',) as CreateNodepoolTaint201Response;
    
    }
    return null;
  }

  /// Create NodePool
  ///
  /// Create NodePool for a Existing Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [CreateNodepoolsRequest] createNodepoolsRequest:
  ///   Request Body
  Future<Response> createNodepoolsWithHttpInfo(String vkeId, { CreateNodepoolsRequest? createNodepoolsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools'
      .replaceAll('{vke-id}', vkeId);

    // ignore: prefer_final_locals
    Object? postBody = createNodepoolsRequest;

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

  /// Create NodePool
  ///
  /// Create NodePool for a Existing Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [CreateNodepoolsRequest] createNodepoolsRequest:
  ///   Request Body
  Future<CreateNodepools201Response?> createNodepools(String vkeId, { CreateNodepoolsRequest? createNodepoolsRequest, }) async {
    final response = await createNodepoolsWithHttpInfo(vkeId,  createNodepoolsRequest: createNodepoolsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepools201Response',) as CreateNodepools201Response;
    
    }
    return null;
  }

  /// Delete Kubernetes Cluster
  ///
  /// Delete Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<Response> deleteKubernetesClusterWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}'
      .replaceAll('{vke-id}', vkeId);

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

  /// Delete Kubernetes Cluster
  ///
  /// Delete Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<void> deleteKubernetesCluster(String vkeId,) async {
    final response = await deleteKubernetesClusterWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete VKE Cluster and All Related Resources
  ///
  /// Delete Kubernetes Cluster and all related resources. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  Future<Response> deleteKubernetesClusterVkeIdDeleteWithLinkedResourcesWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/delete-with-linked-resources'
      .replaceAll('{vke-id}', vkeId);

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

  /// Delete VKE Cluster and All Related Resources
  ///
  /// Delete Kubernetes Cluster and all related resources. 
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  Future<void> deleteKubernetesClusterVkeIdDeleteWithLinkedResources(String vkeId,) async {
    final response = await deleteKubernetesClusterVkeIdDeleteWithLinkedResourcesWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete Nodepool
  ///
  /// Delete a NodePool from a Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<Response> deleteNodepoolWithHttpInfo(String vkeId, String nodepoolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

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

  /// Delete Nodepool
  ///
  /// Delete a NodePool from a Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<void> deleteNodepool(String vkeId, String nodepoolId,) async {
    final response = await deleteNodepoolWithHttpInfo(vkeId, nodepoolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete NodePool Instance
  ///
  /// Delete a single nodepool instance from a given Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] nodeId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<Response> deleteNodepoolInstanceWithHttpInfo(String vkeId, String nodepoolId, String nodeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/nodes/{node-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId)
      .replaceAll('{node-id}', nodeId);

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

  /// Delete NodePool Instance
  ///
  /// Delete a single nodepool instance from a given Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] nodeId (required):
  ///   The [Instance ID](#operation/list-instances).
  Future<void> deleteNodepoolInstance(String vkeId, String nodepoolId, String nodeId,) async {
    final response = await deleteNodepoolInstanceWithHttpInfo(vkeId, nodepoolId, nodeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete NodePool Label
  ///
  /// Delete NodePool Label on Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] labelId (required):
  ///   The [NodePool Label ID](#operation/list-labels).
  Future<Response> deleteNodepoolLabelWithHttpInfo(String vkeId, String nodepoolId, String labelId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels/{label-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId)
      .replaceAll('{label-id}', labelId);

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

  /// Delete NodePool Label
  ///
  /// Delete NodePool Label on Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] labelId (required):
  ///   The [NodePool Label ID](#operation/list-labels).
  Future<void> deleteNodepoolLabel(String vkeId, String nodepoolId, String labelId,) async {
    final response = await deleteNodepoolLabelWithHttpInfo(vkeId, nodepoolId, labelId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Delete NodePool Taint
  ///
  /// Delete NodePool Taint on Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] taintId (required):
  ///   The [NodePool Taint ID](#operation/list-taints).
  Future<Response> deleteNodepoolTaintWithHttpInfo(String vkeId, String nodepoolId, String taintId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints/{taint-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId)
      .replaceAll('{taint-id}', taintId);

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

  /// Delete NodePool Taint
  ///
  /// Delete NodePool Taint on Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] taintId (required):
  ///   The [NodePool Taint ID](#operation/list-taints).
  Future<void> deleteNodepoolTaint(String vkeId, String nodepoolId, String taintId,) async {
    final response = await deleteNodepoolTaintWithHttpInfo(vkeId, nodepoolId, taintId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Kubernetes Available Upgrades
  ///
  /// Get the available upgrades for the specified Kubernetes cluster.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<Response> getKubernetesAvailableUpgradesWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/available-upgrades'
      .replaceAll('{vke-id}', vkeId);

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

  /// Get Kubernetes Available Upgrades
  ///
  /// Get the available upgrades for the specified Kubernetes cluster.
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<GetKubernetesAvailableUpgrades200Response?> getKubernetesAvailableUpgrades(String vkeId,) async {
    final response = await getKubernetesAvailableUpgradesWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetKubernetesAvailableUpgrades200Response',) as GetKubernetesAvailableUpgrades200Response;
    
    }
    return null;
  }

  /// Get Kubernetes Cluster
  ///
  /// Get Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<Response> getKubernetesClustersWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}'
      .replaceAll('{vke-id}', vkeId);

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

  /// Get Kubernetes Cluster
  ///
  /// Get Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<CreateKubernetesCluster201Response?> getKubernetesClusters(String vkeId,) async {
    final response = await getKubernetesClustersWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateKubernetesCluster201Response',) as CreateKubernetesCluster201Response;
    
    }
    return null;
  }

  /// Get Kubernetes Cluster Kubeconfig
  ///
  /// Get Kubernetes Cluster Kubeconfig
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<Response> getKubernetesClustersConfigWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/config'
      .replaceAll('{vke-id}', vkeId);

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

  /// Get Kubernetes Cluster Kubeconfig
  ///
  /// Get Kubernetes Cluster Kubeconfig
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<GetKubernetesClustersConfig200Response?> getKubernetesClustersConfig(String vkeId,) async {
    final response = await getKubernetesClustersConfigWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetKubernetesClustersConfig200Response',) as GetKubernetesClustersConfig200Response;
    
    }
    return null;
  }

  /// Get Kubernetes Resources
  ///
  /// Get the block storage volumes and load balancers deployed by the specified Kubernetes cluster.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<Response> getKubernetesResourcesWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/resources'
      .replaceAll('{vke-id}', vkeId);

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

  /// Get Kubernetes Resources
  ///
  /// Get the block storage volumes and load balancers deployed by the specified Kubernetes cluster.
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<GetKubernetesResources200Response?> getKubernetesResources(String vkeId,) async {
    final response = await getKubernetesResourcesWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetKubernetesResources200Response',) as GetKubernetesResources200Response;
    
    }
    return null;
  }

  /// Get Kubernetes Versions
  ///
  /// Get a list of supported Kubernetes versions
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getKubernetesVersionsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/versions';

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

  /// Get Kubernetes Versions
  ///
  /// Get a list of supported Kubernetes versions
  Future<GetKubernetesVersions200Response?> getKubernetesVersions() async {
    final response = await getKubernetesVersionsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetKubernetesVersions200Response',) as GetKubernetesVersions200Response;
    
    }
    return null;
  }

  /// Get NodePool
  ///
  /// Get Nodepool from a Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<Response> getNodepoolWithHttpInfo(String vkeId, String nodepoolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

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

  /// Get NodePool
  ///
  /// Get Nodepool from a Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<CreateNodepools201Response?> getNodepool(String vkeId, String nodepoolId,) async {
    final response = await getNodepoolWithHttpInfo(vkeId, nodepoolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepools201Response',) as CreateNodepools201Response;
    
    }
    return null;
  }

  /// List NodePools
  ///
  /// List all available NodePools on a Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<Response> getNodepoolsWithHttpInfo(String vkeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools'
      .replaceAll('{vke-id}', vkeId);

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

  /// List NodePools
  ///
  /// List all available NodePools on a Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  Future<GetNodepools200Response?> getNodepools(String vkeId,) async {
    final response = await getNodepoolsWithHttpInfo(vkeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetNodepools200Response',) as GetNodepools200Response;
    
    }
    return null;
  }

  /// List all Kubernetes Clusters
  ///
  /// List all Kubernetes clusters currently deployed
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listKubernetesClustersWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters';

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

  /// List all Kubernetes Clusters
  ///
  /// List all Kubernetes clusters currently deployed
  Future<ListKubernetesClusters200Response?> listKubernetesClusters() async {
    final response = await listKubernetesClustersWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListKubernetesClusters200Response',) as ListKubernetesClusters200Response;
    
    }
    return null;
  }

  /// List NodePool Labels
  ///
  /// List NodePool Labels on Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<Response> listNodepoolLabelsWithHttpInfo(String vkeId, String nodepoolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

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

  /// List NodePool Labels
  ///
  /// List NodePool Labels on Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<ListNodepoolLabels200Response?> listNodepoolLabels(String vkeId, String nodepoolId,) async {
    final response = await listNodepoolLabelsWithHttpInfo(vkeId, nodepoolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListNodepoolLabels200Response',) as ListNodepoolLabels200Response;
    
    }
    return null;
  }

  /// List NodePool Taints
  ///
  /// List NodePool Taints on Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<Response> listNodepoolTaintsWithHttpInfo(String vkeId, String nodepoolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

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

  /// List NodePool Taints
  ///
  /// List NodePool Taints on Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  Future<ListNodepoolTaints200Response?> listNodepoolTaints(String vkeId, String nodepoolId,) async {
    final response = await listNodepoolTaintsWithHttpInfo(vkeId, nodepoolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListNodepoolTaints200Response',) as ListNodepoolTaints200Response;
    
    }
    return null;
  }

  /// Read NodePool Label
  ///
  /// Read NodePool Label on Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] labelId (required):
  ///   The [NodePool Label ID](#operation/list-labels).
  Future<Response> readNodepoolLabelWithHttpInfo(String vkeId, String nodepoolId, String labelId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels/{label-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId)
      .replaceAll('{label-id}', labelId);

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

  /// Read NodePool Label
  ///
  /// Read NodePool Label on Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] labelId (required):
  ///   The [NodePool Label ID](#operation/list-labels).
  Future<CreateNodepoolLabel201Response?> readNodepoolLabel(String vkeId, String nodepoolId, String labelId,) async {
    final response = await readNodepoolLabelWithHttpInfo(vkeId, nodepoolId, labelId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepoolLabel201Response',) as CreateNodepoolLabel201Response;
    
    }
    return null;
  }

  /// Read NodePool Taint
  ///
  /// Read NodePool Taint on Kubernetes Nodepool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] taintId (required):
  ///   The [NodePool Taint ID](#operation/list-taints).
  Future<Response> readNodepoolTaintWithHttpInfo(String vkeId, String nodepoolId, String taintId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints/{taint-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId)
      .replaceAll('{taint-id}', taintId);

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

  /// Read NodePool Taint
  ///
  /// Read NodePool Taint on Kubernetes Nodepool
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] taintId (required):
  ///   The [NodePool Taint ID](#operation/list-taints).
  Future<CreateNodepoolTaint201Response?> readNodepoolTaint(String vkeId, String nodepoolId, String taintId,) async {
    final response = await readNodepoolTaintWithHttpInfo(vkeId, nodepoolId, taintId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepoolTaint201Response',) as CreateNodepoolTaint201Response;
    
    }
    return null;
  }

  /// Recycle a NodePool Instance
  ///
  /// Recycle a specific NodePool Instance
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] nodeId (required):
  ///   Node ID
  Future<Response> recycleNodepoolInstanceWithHttpInfo(String vkeId, String nodepoolId, String nodeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/nodes/{node-id}/recycle'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId)
      .replaceAll('{node-id}', nodeId);

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

  /// Recycle a NodePool Instance
  ///
  /// Recycle a specific NodePool Instance
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [String] nodeId (required):
  ///   Node ID
  Future<void> recycleNodepoolInstance(String vkeId, String nodepoolId, String nodeId,) async {
    final response = await recycleNodepoolInstanceWithHttpInfo(vkeId, nodepoolId, nodeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Start Kubernetes Cluster Upgrade
  ///
  /// Start a Kubernetes cluster upgrade.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [StartKubernetesClusterUpgradeRequest] startKubernetesClusterUpgradeRequest:
  ///   Request Body
  Future<Response> startKubernetesClusterUpgradeWithHttpInfo(String vkeId, { StartKubernetesClusterUpgradeRequest? startKubernetesClusterUpgradeRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/upgrades'
      .replaceAll('{vke-id}', vkeId);

    // ignore: prefer_final_locals
    Object? postBody = startKubernetesClusterUpgradeRequest;

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

  /// Start Kubernetes Cluster Upgrade
  ///
  /// Start a Kubernetes cluster upgrade.
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [StartKubernetesClusterUpgradeRequest] startKubernetesClusterUpgradeRequest:
  ///   Request Body
  Future<void> startKubernetesClusterUpgrade(String vkeId, { StartKubernetesClusterUpgradeRequest? startKubernetesClusterUpgradeRequest, }) async {
    final response = await startKubernetesClusterUpgradeWithHttpInfo(vkeId,  startKubernetesClusterUpgradeRequest: startKubernetesClusterUpgradeRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Kubernetes Cluster
  ///
  /// Update Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [UpdateKubernetesClusterRequest] updateKubernetesClusterRequest:
  ///   Request Body
  Future<Response> updateKubernetesClusterWithHttpInfo(String vkeId, { UpdateKubernetesClusterRequest? updateKubernetesClusterRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}'
      .replaceAll('{vke-id}', vkeId);

    // ignore: prefer_final_locals
    Object? postBody = updateKubernetesClusterRequest;

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

  /// Update Kubernetes Cluster
  ///
  /// Update Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [UpdateKubernetesClusterRequest] updateKubernetesClusterRequest:
  ///   Request Body
  Future<void> updateKubernetesCluster(String vkeId, { UpdateKubernetesClusterRequest? updateKubernetesClusterRequest, }) async {
    final response = await updateKubernetesClusterWithHttpInfo(vkeId,  updateKubernetesClusterRequest: updateKubernetesClusterRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Nodepool
  ///
  /// Update a Nodepool on a Kubernetes Cluster
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [UpdateNodepoolRequest] updateNodepoolRequest:
  ///   Request Body
  Future<Response> updateNodepoolWithHttpInfo(String vkeId, String nodepoolId, { UpdateNodepoolRequest? updateNodepoolRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}'
      .replaceAll('{vke-id}', vkeId)
      .replaceAll('{nodepool-id}', nodepoolId);

    // ignore: prefer_final_locals
    Object? postBody = updateNodepoolRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'application/xml'];


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

  /// Update Nodepool
  ///
  /// Update a Nodepool on a Kubernetes Cluster
  ///
  /// Parameters:
  ///
  /// * [String] vkeId (required):
  ///   The [VKE ID](#operation/list-kubernetes-clusters).
  ///
  /// * [String] nodepoolId (required):
  ///   The [NodePool ID](#operation/get-nodepools).
  ///
  /// * [UpdateNodepoolRequest] updateNodepoolRequest:
  ///   Request Body
  Future<CreateNodepools201Response?> updateNodepool(String vkeId, String nodepoolId, { UpdateNodepoolRequest? updateNodepoolRequest, }) async {
    final response = await updateNodepoolWithHttpInfo(vkeId, nodepoolId,  updateNodepoolRequest: updateNodepoolRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateNodepools201Response',) as CreateNodepools201Response;
    
    }
    return null;
  }
}
