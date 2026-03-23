# openapi.api.KubernetesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createKubernetesCluster**](KubernetesApi.md#createkubernetescluster) | **POST** /kubernetes/clusters | Create Kubernetes Cluster
[**createNodepoolLabel**](KubernetesApi.md#createnodepoollabel) | **POST** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels | Create NodePool Label
[**createNodepoolTaint**](KubernetesApi.md#createnodepooltaint) | **POST** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints | Create NodePool Taint
[**createNodepools**](KubernetesApi.md#createnodepools) | **POST** /kubernetes/clusters/{vke-id}/node-pools | Create NodePool
[**deleteKubernetesCluster**](KubernetesApi.md#deletekubernetescluster) | **DELETE** /kubernetes/clusters/{vke-id} | Delete Kubernetes Cluster
[**deleteKubernetesClusterVkeIdDeleteWithLinkedResources**](KubernetesApi.md#deletekubernetesclustervkeiddeletewithlinkedresources) | **DELETE** /kubernetes/clusters/{vke-id}/delete-with-linked-resources | Delete VKE Cluster and All Related Resources
[**deleteNodepool**](KubernetesApi.md#deletenodepool) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id} | Delete Nodepool
[**deleteNodepoolInstance**](KubernetesApi.md#deletenodepoolinstance) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/nodes/{node-id} | Delete NodePool Instance
[**deleteNodepoolLabel**](KubernetesApi.md#deletenodepoollabel) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels/{label-id} | Delete NodePool Label
[**deleteNodepoolTaint**](KubernetesApi.md#deletenodepooltaint) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints/{taint-id} | Delete NodePool Taint
[**getKubernetesAvailableUpgrades**](KubernetesApi.md#getkubernetesavailableupgrades) | **GET** /kubernetes/clusters/{vke-id}/available-upgrades | Get Kubernetes Available Upgrades
[**getKubernetesClusters**](KubernetesApi.md#getkubernetesclusters) | **GET** /kubernetes/clusters/{vke-id} | Get Kubernetes Cluster
[**getKubernetesClustersConfig**](KubernetesApi.md#getkubernetesclustersconfig) | **GET** /kubernetes/clusters/{vke-id}/config | Get Kubernetes Cluster Kubeconfig
[**getKubernetesResources**](KubernetesApi.md#getkubernetesresources) | **GET** /kubernetes/clusters/{vke-id}/resources | Get Kubernetes Resources
[**getKubernetesVersions**](KubernetesApi.md#getkubernetesversions) | **GET** /kubernetes/versions | Get Kubernetes Versions
[**getNodepool**](KubernetesApi.md#getnodepool) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id} | Get NodePool
[**getNodepools**](KubernetesApi.md#getnodepools) | **GET** /kubernetes/clusters/{vke-id}/node-pools | List NodePools
[**listKubernetesClusters**](KubernetesApi.md#listkubernetesclusters) | **GET** /kubernetes/clusters | List all Kubernetes Clusters
[**listNodepoolLabels**](KubernetesApi.md#listnodepoollabels) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels | List NodePool Labels
[**listNodepoolTaints**](KubernetesApi.md#listnodepooltaints) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints | List NodePool Taints
[**readNodepoolLabel**](KubernetesApi.md#readnodepoollabel) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels/{label-id} | Read NodePool Label
[**readNodepoolTaint**](KubernetesApi.md#readnodepooltaint) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints/{taint-id} | Read NodePool Taint
[**recycleNodepoolInstance**](KubernetesApi.md#recyclenodepoolinstance) | **POST** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/nodes/{node-id}/recycle | Recycle a NodePool Instance
[**startKubernetesClusterUpgrade**](KubernetesApi.md#startkubernetesclusterupgrade) | **POST** /kubernetes/clusters/{vke-id}/upgrades | Start Kubernetes Cluster Upgrade
[**updateKubernetesCluster**](KubernetesApi.md#updatekubernetescluster) | **PUT** /kubernetes/clusters/{vke-id} | Update Kubernetes Cluster
[**updateNodepool**](KubernetesApi.md#updatenodepool) | **PATCH** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id} | Update Nodepool


# **createKubernetesCluster**
> CreateKubernetesCluster201Response createKubernetesCluster(createKubernetesClusterRequest)

Create Kubernetes Cluster

Create Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final createKubernetesClusterRequest = CreateKubernetesClusterRequest(); // CreateKubernetesClusterRequest | Request Body

try {
    final result = api_instance.createKubernetesCluster(createKubernetesClusterRequest);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->createKubernetesCluster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createKubernetesClusterRequest** | [**CreateKubernetesClusterRequest**](CreateKubernetesClusterRequest.md)| Request Body | [optional] 

### Return type

[**CreateKubernetesCluster201Response**](CreateKubernetesCluster201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createNodepoolLabel**
> CreateNodepoolLabel201Response createNodepoolLabel(vkeId, nodepoolId, nodepoolLabelReq)

Create NodePool Label

Add NodePool Label to Existing Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final nodepoolLabelReq = NodepoolLabelReq(); // NodepoolLabelReq | 

try {
    final result = api_instance.createNodepoolLabel(vkeId, nodepoolId, nodepoolLabelReq);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->createNodepoolLabel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **nodepoolLabelReq** | [**NodepoolLabelReq**](NodepoolLabelReq.md)|  | [optional] 

### Return type

[**CreateNodepoolLabel201Response**](CreateNodepoolLabel201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createNodepoolTaint**
> CreateNodepoolTaint201Response createNodepoolTaint(vkeId, nodepoolId, nodepoolTaintReq)

Create NodePool Taint

Add NodePool Taint to Existing Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final nodepoolTaintReq = NodepoolTaintReq(); // NodepoolTaintReq | 

try {
    final result = api_instance.createNodepoolTaint(vkeId, nodepoolId, nodepoolTaintReq);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->createNodepoolTaint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **nodepoolTaintReq** | [**NodepoolTaintReq**](NodepoolTaintReq.md)|  | [optional] 

### Return type

[**CreateNodepoolTaint201Response**](CreateNodepoolTaint201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createNodepools**
> CreateNodepools201Response createNodepools(vkeId, createNodepoolsRequest)

Create NodePool

Create NodePool for a Existing Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final createNodepoolsRequest = CreateNodepoolsRequest(); // CreateNodepoolsRequest | Request Body

try {
    final result = api_instance.createNodepools(vkeId, createNodepoolsRequest);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->createNodepools: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **createNodepoolsRequest** | [**CreateNodepoolsRequest**](CreateNodepoolsRequest.md)| Request Body | [optional] 

### Return type

[**CreateNodepools201Response**](CreateNodepools201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteKubernetesCluster**
> deleteKubernetesCluster(vkeId)

Delete Kubernetes Cluster

Delete Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).

try {
    api_instance.deleteKubernetesCluster(vkeId);
} catch (e) {
    print('Exception when calling KubernetesApi->deleteKubernetesCluster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteKubernetesClusterVkeIdDeleteWithLinkedResources**
> deleteKubernetesClusterVkeIdDeleteWithLinkedResources(vkeId)

Delete VKE Cluster and All Related Resources

Delete Kubernetes Cluster and all related resources. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | 

try {
    api_instance.deleteKubernetesClusterVkeIdDeleteWithLinkedResources(vkeId);
} catch (e) {
    print('Exception when calling KubernetesApi->deleteKubernetesClusterVkeIdDeleteWithLinkedResources: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNodepool**
> deleteNodepool(vkeId, nodepoolId)

Delete Nodepool

Delete a NodePool from a Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).

try {
    api_instance.deleteNodepool(vkeId, nodepoolId);
} catch (e) {
    print('Exception when calling KubernetesApi->deleteNodepool: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNodepoolInstance**
> deleteNodepoolInstance(vkeId, nodepoolId, nodeId)

Delete NodePool Instance

Delete a single nodepool instance from a given Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final nodeId = nodeId_example; // String | The [Instance ID](#operation/list-instances).

try {
    api_instance.deleteNodepoolInstance(vkeId, nodepoolId, nodeId);
} catch (e) {
    print('Exception when calling KubernetesApi->deleteNodepoolInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **nodeId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNodepoolLabel**
> deleteNodepoolLabel(vkeId, nodepoolId, labelId)

Delete NodePool Label

Delete NodePool Label on Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final labelId = labelId_example; // String | The [NodePool Label ID](#operation/list-labels).

try {
    api_instance.deleteNodepoolLabel(vkeId, nodepoolId, labelId);
} catch (e) {
    print('Exception when calling KubernetesApi->deleteNodepoolLabel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **labelId** | **String**| The [NodePool Label ID](#operation/list-labels). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNodepoolTaint**
> deleteNodepoolTaint(vkeId, nodepoolId, taintId)

Delete NodePool Taint

Delete NodePool Taint on Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final taintId = taintId_example; // String | The [NodePool Taint ID](#operation/list-taints).

try {
    api_instance.deleteNodepoolTaint(vkeId, nodepoolId, taintId);
} catch (e) {
    print('Exception when calling KubernetesApi->deleteNodepoolTaint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **taintId** | **String**| The [NodePool Taint ID](#operation/list-taints). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKubernetesAvailableUpgrades**
> GetKubernetesAvailableUpgrades200Response getKubernetesAvailableUpgrades(vkeId)

Get Kubernetes Available Upgrades

Get the available upgrades for the specified Kubernetes cluster.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).

try {
    final result = api_instance.getKubernetesAvailableUpgrades(vkeId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getKubernetesAvailableUpgrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 

### Return type

[**GetKubernetesAvailableUpgrades200Response**](GetKubernetesAvailableUpgrades200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKubernetesClusters**
> CreateKubernetesCluster201Response getKubernetesClusters(vkeId)

Get Kubernetes Cluster

Get Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).

try {
    final result = api_instance.getKubernetesClusters(vkeId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getKubernetesClusters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 

### Return type

[**CreateKubernetesCluster201Response**](CreateKubernetesCluster201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKubernetesClustersConfig**
> GetKubernetesClustersConfig200Response getKubernetesClustersConfig(vkeId)

Get Kubernetes Cluster Kubeconfig

Get Kubernetes Cluster Kubeconfig

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).

try {
    final result = api_instance.getKubernetesClustersConfig(vkeId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getKubernetesClustersConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 

### Return type

[**GetKubernetesClustersConfig200Response**](GetKubernetesClustersConfig200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKubernetesResources**
> GetKubernetesResources200Response getKubernetesResources(vkeId)

Get Kubernetes Resources

Get the block storage volumes and load balancers deployed by the specified Kubernetes cluster.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).

try {
    final result = api_instance.getKubernetesResources(vkeId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getKubernetesResources: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 

### Return type

[**GetKubernetesResources200Response**](GetKubernetesResources200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKubernetesVersions**
> GetKubernetesVersions200Response getKubernetesVersions()

Get Kubernetes Versions

Get a list of supported Kubernetes versions

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = KubernetesApi();

try {
    final result = api_instance.getKubernetesVersions();
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getKubernetesVersions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetKubernetesVersions200Response**](GetKubernetesVersions200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNodepool**
> CreateNodepools201Response getNodepool(vkeId, nodepoolId)

Get NodePool

Get Nodepool from a Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).

try {
    final result = api_instance.getNodepool(vkeId, nodepoolId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getNodepool: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 

### Return type

[**CreateNodepools201Response**](CreateNodepools201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNodepools**
> GetNodepools200Response getNodepools(vkeId)

List NodePools

List all available NodePools on a Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).

try {
    final result = api_instance.getNodepools(vkeId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->getNodepools: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 

### Return type

[**GetNodepools200Response**](GetNodepools200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listKubernetesClusters**
> ListKubernetesClusters200Response listKubernetesClusters()

List all Kubernetes Clusters

List all Kubernetes clusters currently deployed

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();

try {
    final result = api_instance.listKubernetesClusters();
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->listKubernetesClusters: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListKubernetesClusters200Response**](ListKubernetesClusters200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNodepoolLabels**
> ListNodepoolLabels200Response listNodepoolLabels(vkeId, nodepoolId)

List NodePool Labels

List NodePool Labels on Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).

try {
    final result = api_instance.listNodepoolLabels(vkeId, nodepoolId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->listNodepoolLabels: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 

### Return type

[**ListNodepoolLabels200Response**](ListNodepoolLabels200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNodepoolTaints**
> ListNodepoolTaints200Response listNodepoolTaints(vkeId, nodepoolId)

List NodePool Taints

List NodePool Taints on Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).

try {
    final result = api_instance.listNodepoolTaints(vkeId, nodepoolId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->listNodepoolTaints: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 

### Return type

[**ListNodepoolTaints200Response**](ListNodepoolTaints200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readNodepoolLabel**
> CreateNodepoolLabel201Response readNodepoolLabel(vkeId, nodepoolId, labelId)

Read NodePool Label

Read NodePool Label on Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final labelId = labelId_example; // String | The [NodePool Label ID](#operation/list-labels).

try {
    final result = api_instance.readNodepoolLabel(vkeId, nodepoolId, labelId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->readNodepoolLabel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **labelId** | **String**| The [NodePool Label ID](#operation/list-labels). | 

### Return type

[**CreateNodepoolLabel201Response**](CreateNodepoolLabel201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readNodepoolTaint**
> CreateNodepoolTaint201Response readNodepoolTaint(vkeId, nodepoolId, taintId)

Read NodePool Taint

Read NodePool Taint on Kubernetes Nodepool

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final taintId = taintId_example; // String | The [NodePool Taint ID](#operation/list-taints).

try {
    final result = api_instance.readNodepoolTaint(vkeId, nodepoolId, taintId);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->readNodepoolTaint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **taintId** | **String**| The [NodePool Taint ID](#operation/list-taints). | 

### Return type

[**CreateNodepoolTaint201Response**](CreateNodepoolTaint201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recycleNodepoolInstance**
> recycleNodepoolInstance(vkeId, nodepoolId, nodeId)

Recycle a NodePool Instance

Recycle a specific NodePool Instance

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final nodeId = nodeId_example; // String | Node ID

try {
    api_instance.recycleNodepoolInstance(vkeId, nodepoolId, nodeId);
} catch (e) {
    print('Exception when calling KubernetesApi->recycleNodepoolInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **nodeId** | **String**| Node ID | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startKubernetesClusterUpgrade**
> startKubernetesClusterUpgrade(vkeId, startKubernetesClusterUpgradeRequest)

Start Kubernetes Cluster Upgrade

Start a Kubernetes cluster upgrade.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final startKubernetesClusterUpgradeRequest = StartKubernetesClusterUpgradeRequest(); // StartKubernetesClusterUpgradeRequest | Request Body

try {
    api_instance.startKubernetesClusterUpgrade(vkeId, startKubernetesClusterUpgradeRequest);
} catch (e) {
    print('Exception when calling KubernetesApi->startKubernetesClusterUpgrade: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **startKubernetesClusterUpgradeRequest** | [**StartKubernetesClusterUpgradeRequest**](StartKubernetesClusterUpgradeRequest.md)| Request Body | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateKubernetesCluster**
> updateKubernetesCluster(vkeId, updateKubernetesClusterRequest)

Update Kubernetes Cluster

Update Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final updateKubernetesClusterRequest = UpdateKubernetesClusterRequest(); // UpdateKubernetesClusterRequest | Request Body

try {
    api_instance.updateKubernetesCluster(vkeId, updateKubernetesClusterRequest);
} catch (e) {
    print('Exception when calling KubernetesApi->updateKubernetesCluster: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **updateKubernetesClusterRequest** | [**UpdateKubernetesClusterRequest**](UpdateKubernetesClusterRequest.md)| Request Body | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateNodepool**
> CreateNodepools201Response updateNodepool(vkeId, nodepoolId, updateNodepoolRequest)

Update Nodepool

Update a Nodepool on a Kubernetes Cluster

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KubernetesApi();
final vkeId = vkeId_example; // String | The [VKE ID](#operation/list-kubernetes-clusters).
final nodepoolId = nodepoolId_example; // String | The [NodePool ID](#operation/get-nodepools).
final updateNodepoolRequest = UpdateNodepoolRequest(); // UpdateNodepoolRequest | Request Body

try {
    final result = api_instance.updateNodepool(vkeId, nodepoolId, updateNodepoolRequest);
    print(result);
} catch (e) {
    print('Exception when calling KubernetesApi->updateNodepool: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **vkeId** | **String**| The [VKE ID](#operation/list-kubernetes-clusters). | 
 **nodepoolId** | **String**| The [NodePool ID](#operation/get-nodepools). | 
 **updateNodepoolRequest** | [**UpdateNodepoolRequest**](UpdateNodepoolRequest.md)| Request Body | [optional] 

### Return type

[**CreateNodepools201Response**](CreateNodepools201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json, application/xml
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

