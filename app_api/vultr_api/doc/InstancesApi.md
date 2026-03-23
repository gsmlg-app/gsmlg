# openapi.api.InstancesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**attachInstanceIso**](InstancesApi.md#attachinstanceiso) | **POST** /instances/{instance-id}/iso/attach | Attach ISO to Instance
[**attachInstanceNetwork**](InstancesApi.md#attachinstancenetwork) | **POST** /instances/{instance-id}/private-networks/attach | Attach Private Network to Instance
[**attachInstanceVpc**](InstancesApi.md#attachinstancevpc) | **POST** /instances/{instance-id}/vpcs/attach | Attach VPC to Instance
[**attachInstanceVpc2**](InstancesApi.md#attachinstancevpc2) | **POST** /instances/{instance-id}/vpc2/attach | Attach VPC 2.0 Network to Instance
[**createInstance**](InstancesApi.md#createinstance) | **POST** /instances | Create Instance
[**createInstanceBackupSchedule**](InstancesApi.md#createinstancebackupschedule) | **POST** /instances/{instance-id}/backup-schedule | Set Instance Backup Schedule
[**createInstanceIpv4**](InstancesApi.md#createinstanceipv4) | **POST** /instances/{instance-id}/ipv4 | Create IPv4
[**createInstanceReverseIpv4**](InstancesApi.md#createinstancereverseipv4) | **POST** /instances/{instance-id}/ipv4/reverse | Create Instance Reverse IPv4
[**createInstanceReverseIpv6**](InstancesApi.md#createinstancereverseipv6) | **POST** /instances/{instance-id}/ipv6/reverse | Create Instance Reverse IPv6
[**deleteInstance**](InstancesApi.md#deleteinstance) | **DELETE** /instances/{instance-id} | Delete Instance
[**deleteInstanceIpv4**](InstancesApi.md#deleteinstanceipv4) | **DELETE** /instances/{instance-id}/ipv4/{ipv4} | Delete IPv4 Address
[**deleteInstanceReverseIpv6**](InstancesApi.md#deleteinstancereverseipv6) | **DELETE** /instances/{instance-id}/ipv6/reverse/{ipv6} | Delete Instance Reverse IPv6
[**detachInstanceIso**](InstancesApi.md#detachinstanceiso) | **POST** /instances/{instance-id}/iso/detach | Detach ISO from instance
[**detachInstanceNetwork**](InstancesApi.md#detachinstancenetwork) | **POST** /instances/{instance-id}/private-networks/detach | Detach Private Network from Instance.
[**detachInstanceVpc**](InstancesApi.md#detachinstancevpc) | **POST** /instances/{instance-id}/vpcs/detach | Detach VPC from Instance
[**detachInstanceVpc2**](InstancesApi.md#detachinstancevpc2) | **POST** /instances/{instance-id}/vpc2/detach | Detach VPC 2.0 Network from Instance
[**getInstance**](InstancesApi.md#getinstance) | **GET** /instances/{instance-id} | Get Instance
[**getInstanceBackupSchedule**](InstancesApi.md#getinstancebackupschedule) | **GET** /instances/{instance-id}/backup-schedule | Get Instance Backup Schedule
[**getInstanceBandwidth**](InstancesApi.md#getinstancebandwidth) | **GET** /instances/{instance-id}/bandwidth | Instance Bandwidth
[**getInstanceIpv4**](InstancesApi.md#getinstanceipv4) | **GET** /instances/{instance-id}/ipv4 | List Instance IPv4 Information
[**getInstanceIpv6**](InstancesApi.md#getinstanceipv6) | **GET** /instances/{instance-id}/ipv6 | Get Instance IPv6 Information
[**getInstanceIsoStatus**](InstancesApi.md#getinstanceisostatus) | **GET** /instances/{instance-id}/iso | Get Instance ISO Status
[**getInstanceJob**](InstancesApi.md#getinstancejob) | **GET** /instances/jobs/{job-id} | Get Instance Job
[**getInstanceNeighbors**](InstancesApi.md#getinstanceneighbors) | **GET** /instances/{instance-id}/neighbors | Get Instance neighbors
[**getInstanceUpgrades**](InstancesApi.md#getinstanceupgrades) | **GET** /instances/{instance-id}/upgrades | Get Available Instance Upgrades
[**getInstanceUserdata**](InstancesApi.md#getinstanceuserdata) | **GET** /instances/{instance-id}/user-data | Get Instance User Data
[**haltInstance**](InstancesApi.md#haltinstance) | **POST** /instances/{instance-id}/halt | Halt Instance
[**haltInstances**](InstancesApi.md#haltinstances) | **POST** /instances/halt | Halt Instances
[**listInstanceIpv6Reverse**](InstancesApi.md#listinstanceipv6reverse) | **GET** /instances/{instance-id}/ipv6/reverse | List Instance IPv6 Reverse
[**listInstancePrivateNetworks**](InstancesApi.md#listinstanceprivatenetworks) | **GET** /instances/{instance-id}/private-networks | List instance Private Networks
[**listInstanceVpc2**](InstancesApi.md#listinstancevpc2) | **GET** /instances/{instance-id}/vpc2 | List Instance VPC 2.0 Networks
[**listInstanceVpcs**](InstancesApi.md#listinstancevpcs) | **GET** /instances/{instance-id}/vpcs | List instance VPCs
[**listInstances**](InstancesApi.md#listinstances) | **GET** /instances | List Instances
[**postInstancesInstanceIdIpv4ReverseDefault**](InstancesApi.md#postinstancesinstanceidipv4reversedefault) | **POST** /instances/{instance-id}/ipv4/reverse/default | Set Default Reverse DNS Entry
[**rebootInstance**](InstancesApi.md#rebootinstance) | **POST** /instances/{instance-id}/reboot | Reboot Instance
[**rebootInstances**](InstancesApi.md#rebootinstances) | **POST** /instances/reboot | Reboot instances
[**reinstallInstance**](InstancesApi.md#reinstallinstance) | **POST** /instances/{instance-id}/reinstall | Reinstall Instance
[**restoreInstance**](InstancesApi.md#restoreinstance) | **POST** /instances/{instance-id}/restore | Restore Instance
[**startInstance**](InstancesApi.md#startinstance) | **POST** /instances/{instance-id}/start | Start instance
[**startInstances**](InstancesApi.md#startinstances) | **POST** /instances/start | Start instances
[**updateInstance**](InstancesApi.md#updateinstance) | **PATCH** /instances/{instance-id} | Update Instance


# **attachInstanceIso**
> AttachInstanceIso202Response attachInstanceIso(instanceId, attachInstanceIsoRequest)

Attach ISO to Instance

Attach an ISO to an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | 
final attachInstanceIsoRequest = AttachInstanceIsoRequest(); // AttachInstanceIsoRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.attachInstanceIso(instanceId, attachInstanceIsoRequest);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->attachInstanceIso: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**|  | 
 **attachInstanceIsoRequest** | [**AttachInstanceIsoRequest**](AttachInstanceIsoRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**AttachInstanceIso202Response**](AttachInstanceIso202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attachInstanceNetwork**
> attachInstanceNetwork(instanceId, attachInstanceNetworkRequest)

Attach Private Network to Instance

Attach Private Network to an Instance.<br><br>**Deprecated**: use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final attachInstanceNetworkRequest = AttachInstanceNetworkRequest(); // AttachInstanceNetworkRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachInstanceNetwork(instanceId, attachInstanceNetworkRequest);
} catch (e) {
    print('Exception when calling InstancesApi->attachInstanceNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **attachInstanceNetworkRequest** | [**AttachInstanceNetworkRequest**](AttachInstanceNetworkRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attachInstanceVpc**
> attachInstanceVpc(instanceId, attachInstanceVpcRequest)

Attach VPC to Instance

Attach a VPC to an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final attachInstanceVpcRequest = AttachInstanceVpcRequest(); // AttachInstanceVpcRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachInstanceVpc(instanceId, attachInstanceVpcRequest);
} catch (e) {
    print('Exception when calling InstancesApi->attachInstanceVpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **attachInstanceVpcRequest** | [**AttachInstanceVpcRequest**](AttachInstanceVpcRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attachInstanceVpc2**
> attachInstanceVpc2(instanceId, attachInstanceVpc2Request)

Attach VPC 2.0 Network to Instance

Attach a VPC 2.0 Network to an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC to Instance](#operation/attach-instance-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final attachInstanceVpc2Request = AttachInstanceVpc2Request(); // AttachInstanceVpc2Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachInstanceVpc2(instanceId, attachInstanceVpc2Request);
} catch (e) {
    print('Exception when calling InstancesApi->attachInstanceVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **attachInstanceVpc2Request** | [**AttachInstanceVpc2Request**](AttachInstanceVpc2Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInstance**
> CreateInstance202Response createInstance(createInstanceRequest)

Create Instance

Create a new VPS Instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `iso_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final createInstanceRequest = CreateInstanceRequest(); // CreateInstanceRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createInstance(createInstanceRequest);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->createInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createInstanceRequest** | [**CreateInstanceRequest**](CreateInstanceRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateInstance202Response**](CreateInstance202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInstanceBackupSchedule**
> createInstanceBackupSchedule(instanceId, createInstanceBackupScheduleRequest)

Set Instance Backup Schedule

Set the backup schedule for an Instance in UTC. The `type` is required.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final createInstanceBackupScheduleRequest = CreateInstanceBackupScheduleRequest(); // CreateInstanceBackupScheduleRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createInstanceBackupSchedule(instanceId, createInstanceBackupScheduleRequest);
} catch (e) {
    print('Exception when calling InstancesApi->createInstanceBackupSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **createInstanceBackupScheduleRequest** | [**CreateInstanceBackupScheduleRequest**](CreateInstanceBackupScheduleRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInstanceIpv4**
> Object createInstanceIpv4(instanceId, createInstanceIpv4Request)

Create IPv4

Create an IPv4 address for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final createInstanceIpv4Request = CreateInstanceIpv4Request(); // CreateInstanceIpv4Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createInstanceIpv4(instanceId, createInstanceIpv4Request);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->createInstanceIpv4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **createInstanceIpv4Request** | [**CreateInstanceIpv4Request**](CreateInstanceIpv4Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**Object**](Object.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInstanceReverseIpv4**
> createInstanceReverseIpv4(instanceId, createBaremetalReverseIpv4Request)

Create Instance Reverse IPv4

Create a reverse IPv4 entry for an Instance. The `ip` and `reverse` attributes are required. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final createBaremetalReverseIpv4Request = CreateBaremetalReverseIpv4Request(); // CreateBaremetalReverseIpv4Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createInstanceReverseIpv4(instanceId, createBaremetalReverseIpv4Request);
} catch (e) {
    print('Exception when calling InstancesApi->createInstanceReverseIpv4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **createBaremetalReverseIpv4Request** | [**CreateBaremetalReverseIpv4Request**](CreateBaremetalReverseIpv4Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInstanceReverseIpv6**
> createInstanceReverseIpv6(instanceId, createBaremetalReverseIpv6Request)

Create Instance Reverse IPv6

Create a reverse IPv6 entry for an Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final createBaremetalReverseIpv6Request = CreateBaremetalReverseIpv6Request(); // CreateBaremetalReverseIpv6Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createInstanceReverseIpv6(instanceId, createBaremetalReverseIpv6Request);
} catch (e) {
    print('Exception when calling InstancesApi->createInstanceReverseIpv6: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **createBaremetalReverseIpv6Request** | [**CreateBaremetalReverseIpv6Request**](CreateBaremetalReverseIpv6Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteInstance**
> deleteInstance(instanceId)

Delete Instance

Delete an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    api_instance.deleteInstance(instanceId);
} catch (e) {
    print('Exception when calling InstancesApi->deleteInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteInstanceIpv4**
> deleteInstanceIpv4(instanceId, ipv4)

Delete IPv4 Address

Delete an IPv4 address from an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final ipv4 = ipv4_example; // String | The IPv4 address.

try {
    api_instance.deleteInstanceIpv4(instanceId, ipv4);
} catch (e) {
    print('Exception when calling InstancesApi->deleteInstanceIpv4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **ipv4** | **String**| The IPv4 address. | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteInstanceReverseIpv6**
> deleteInstanceReverseIpv6(instanceId, ipv6)

Delete Instance Reverse IPv6

Delete the reverse IPv6 for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final ipv6 = ipv6_example; // String | The IPv6 address.

try {
    api_instance.deleteInstanceReverseIpv6(instanceId, ipv6);
} catch (e) {
    print('Exception when calling InstancesApi->deleteInstanceReverseIpv6: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **ipv6** | **String**| The IPv6 address. | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachInstanceIso**
> DetachInstanceIso202Response detachInstanceIso(instanceId)

Detach ISO from instance

Detach the ISO from an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.detachInstanceIso(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->detachInstanceIso: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**DetachInstanceIso202Response**](DetachInstanceIso202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachInstanceNetwork**
> detachInstanceNetwork(instanceId, detachInstanceNetworkRequest)

Detach Private Network from Instance.

Detach Private Network from an Instance.<br><br>**Deprecated**: use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final detachInstanceNetworkRequest = DetachInstanceNetworkRequest(); // DetachInstanceNetworkRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachInstanceNetwork(instanceId, detachInstanceNetworkRequest);
} catch (e) {
    print('Exception when calling InstancesApi->detachInstanceNetwork: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **detachInstanceNetworkRequest** | [**DetachInstanceNetworkRequest**](DetachInstanceNetworkRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachInstanceVpc**
> detachInstanceVpc(instanceId, detachInstanceVpcRequest)

Detach VPC from Instance

Detach a VPC from an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final detachInstanceVpcRequest = DetachInstanceVpcRequest(); // DetachInstanceVpcRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachInstanceVpc(instanceId, detachInstanceVpcRequest);
} catch (e) {
    print('Exception when calling InstancesApi->detachInstanceVpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **detachInstanceVpcRequest** | [**DetachInstanceVpcRequest**](DetachInstanceVpcRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachInstanceVpc2**
> detachInstanceVpc2(instanceId, detachInstanceVpc2Request)

Detach VPC 2.0 Network from Instance

Detach a VPC 2.0 Network from an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC from Instance](#operation/detach-instance-vpc) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final detachInstanceVpc2Request = DetachInstanceVpc2Request(); // DetachInstanceVpc2Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachInstanceVpc2(instanceId, detachInstanceVpc2Request);
} catch (e) {
    print('Exception when calling InstancesApi->detachInstanceVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **detachInstanceVpc2Request** | [**DetachInstanceVpc2Request**](DetachInstanceVpc2Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstance**
> GetInstance200Response getInstance(instanceId)

Get Instance

Get information about an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.getInstance(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**GetInstance200Response**](GetInstance200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceBackupSchedule**
> GetInstanceBackupSchedule200Response getInstanceBackupSchedule(instanceId)

Get Instance Backup Schedule

Get the backup schedule for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.getInstanceBackupSchedule(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceBackupSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**GetInstanceBackupSchedule200Response**](GetInstanceBackupSchedule200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceBandwidth**
> GetBandwidthBaremetal200Response getInstanceBandwidth(instanceId, dateRange)

Instance Bandwidth

Get bandwidth information about an Instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. The bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final dateRange = 56; // int | The range of days to include, represented as the number of days relative to the current date. Default 30, Minimum 1 and Max 180.

try {
    final result = api_instance.getInstanceBandwidth(instanceId, dateRange);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceBandwidth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **dateRange** | **int**| The range of days to include, represented as the number of days relative to the current date. Default 30, Minimum 1 and Max 180. | [optional] 

### Return type

[**GetBandwidthBaremetal200Response**](GetBandwidthBaremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceIpv4**
> GetIpv4Baremetal200Response getInstanceIpv4(instanceId, publicNetwork, perPage, cursor)

List Instance IPv4 Information

List the IPv4 information for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final publicNetwork = true; // bool | If `true`, includes information about the public network adapter (such as MAC address) with the `main_ip` entry.
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500. 
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.getInstanceIpv4(instanceId, publicNetwork, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceIpv4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **publicNetwork** | **bool**| If `true`, includes information about the public network adapter (such as MAC address) with the `main_ip` entry. | [optional] 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500.  | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**GetIpv4Baremetal200Response**](GetIpv4Baremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceIpv6**
> GetIpv6Baremetal200Response getInstanceIpv6(instanceId)

Get Instance IPv6 Information

Get the IPv6 information for an VPS Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.getInstanceIpv6(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceIpv6: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**GetIpv6Baremetal200Response**](GetIpv6Baremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceIsoStatus**
> GetInstanceIsoStatus200Response getInstanceIsoStatus(instanceId)

Get Instance ISO Status

Get the ISO status for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.getInstanceIsoStatus(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceIsoStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**GetInstanceIsoStatus200Response**](GetInstanceIsoStatus200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceJob**
> GetInstanceJob200Response getInstanceJob(jobId)

Get Instance Job

Get available information for an Instance job

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final jobId = jobId_example; // String | The [Job ID](#operation/update-instance).

try {
    final result = api_instance.getInstanceJob(jobId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**| The [Job ID](#operation/update-instance). | 

### Return type

[**GetInstanceJob200Response**](GetInstanceJob200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceNeighbors**
> GetInstanceNeighbors200Response getInstanceNeighbors(instanceId)

Get Instance neighbors

Get a list of other instances in the same location as this Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.getInstanceNeighbors(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceNeighbors: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**GetInstanceNeighbors200Response**](GetInstanceNeighbors200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceUpgrades**
> GetInstanceUpgrades200Response getInstanceUpgrades(instanceId, type)

Get Available Instance Upgrades

Get available upgrades for an Instance

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final type = type_example; // String | Filter upgrade by type:  - all (applications, os, plans) - applications - os - plans

try {
    final result = api_instance.getInstanceUpgrades(instanceId, type);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceUpgrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **type** | **String**| Filter upgrade by type:  - all (applications, os, plans) - applications - os - plans | [optional] 

### Return type

[**GetInstanceUpgrades200Response**](GetInstanceUpgrades200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInstanceUserdata**
> GetInstanceUserdata200Response getInstanceUserdata(instanceId)

Get Instance User Data

Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.getInstanceUserdata(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->getInstanceUserdata: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**GetInstanceUserdata200Response**](GetInstanceUserdata200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **haltInstance**
> haltInstance(instanceId)

Halt Instance

Halt an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    api_instance.haltInstance(instanceId);
} catch (e) {
    print('Exception when calling InstancesApi->haltInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **haltInstances**
> haltInstances(haltInstancesRequest)

Halt Instances

Halt Instances.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final haltInstancesRequest = HaltInstancesRequest(); // HaltInstancesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.haltInstances(haltInstancesRequest);
} catch (e) {
    print('Exception when calling InstancesApi->haltInstances: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **haltInstancesRequest** | [**HaltInstancesRequest**](HaltInstancesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInstanceIpv6Reverse**
> ListInstanceIpv6Reverse200Response listInstanceIpv6Reverse(instanceId)

List Instance IPv6 Reverse

List the reverse IPv6 information for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    final result = api_instance.listInstanceIpv6Reverse(instanceId);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->listInstanceIpv6Reverse: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

[**ListInstanceIpv6Reverse200Response**](ListInstanceIpv6Reverse200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInstancePrivateNetworks**
> ListInstancePrivateNetworks200Response listInstancePrivateNetworks(instanceId, perPage, cursor)

List instance Private Networks

**Deprecated**: use [List Instance VPCs](#operation/list-instance-vpcs) instead.<br><br>List the private networks for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listInstancePrivateNetworks(instanceId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->listInstancePrivateNetworks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListInstancePrivateNetworks200Response**](ListInstancePrivateNetworks200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInstanceVpc2**
> ListInstanceVpc2200Response listInstanceVpc2(instanceId, perPage, cursor)

List Instance VPC 2.0 Networks

List the VPC 2.0 networks for an Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Instance VPCs](#operation/list-instance-vpcs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listInstanceVpc2(instanceId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->listInstanceVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListInstanceVpc2200Response**](ListInstanceVpc2200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInstanceVpcs**
> ListInstanceVpcs200Response listInstanceVpcs(instanceId, perPage, cursor)

List instance VPCs

List the VPCs for an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listInstanceVpcs(instanceId, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->listInstanceVpcs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListInstanceVpcs200Response**](ListInstanceVpcs200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInstances**
> ListInstances200Response listInstances(perPage, cursor, tag, label, mainIp, region, firewallGroupId, hostname, showPendingCharges)

List Instances

List all VPS instances in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
final tag = tag_example; // String | Filter by specific tag.
final label = label_example; // String | Filter by label.
final mainIp = mainIp_example; // String | Filter by main ip address.
final region = region_example; // String | Filter by [Region id](#operation/list-regions).
final firewallGroupId = firewallGroupId_example; // String | Filter by [Firewall group id](#operation/list-firewall-groups).
final hostname = hostname_example; // String | Filter by hostname.
final showPendingCharges = true; // bool | Set to `true` to show pending charges.

try {
    final result = api_instance.listInstances(perPage, cursor, tag, label, mainIp, region, firewallGroupId, hostname, showPendingCharges);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->listInstances: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 
 **tag** | **String**| Filter by specific tag. | [optional] 
 **label** | **String**| Filter by label. | [optional] 
 **mainIp** | **String**| Filter by main ip address. | [optional] 
 **region** | **String**| Filter by [Region id](#operation/list-regions). | [optional] 
 **firewallGroupId** | **String**| Filter by [Firewall group id](#operation/list-firewall-groups). | [optional] 
 **hostname** | **String**| Filter by hostname. | [optional] 
 **showPendingCharges** | **bool**| Set to `true` to show pending charges. | [optional] 

### Return type

[**ListInstances200Response**](ListInstances200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postInstancesInstanceIdIpv4ReverseDefault**
> postInstancesInstanceIdIpv4ReverseDefault(instanceId, postBaremetalInstanceIdIpv4ReverseDefaultRequest)

Set Default Reverse DNS Entry

Set a reverse DNS entry for an IPv4 address

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final postBaremetalInstanceIdIpv4ReverseDefaultRequest = PostBaremetalInstanceIdIpv4ReverseDefaultRequest(); // PostBaremetalInstanceIdIpv4ReverseDefaultRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.postInstancesInstanceIdIpv4ReverseDefault(instanceId, postBaremetalInstanceIdIpv4ReverseDefaultRequest);
} catch (e) {
    print('Exception when calling InstancesApi->postInstancesInstanceIdIpv4ReverseDefault: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **postBaremetalInstanceIdIpv4ReverseDefaultRequest** | [**PostBaremetalInstanceIdIpv4ReverseDefaultRequest**](PostBaremetalInstanceIdIpv4ReverseDefaultRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebootInstance**
> rebootInstance(instanceId)

Reboot Instance

Reboot an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    api_instance.rebootInstance(instanceId);
} catch (e) {
    print('Exception when calling InstancesApi->rebootInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebootInstances**
> rebootInstances(rebootInstancesRequest)

Reboot instances

Reboot Instances.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final rebootInstancesRequest = RebootInstancesRequest(); // RebootInstancesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.rebootInstances(rebootInstancesRequest);
} catch (e) {
    print('Exception when calling InstancesApi->rebootInstances: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rebootInstancesRequest** | [**RebootInstancesRequest**](RebootInstancesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reinstallInstance**
> CreateInstance202Response reinstallInstance(instanceId, reinstallInstanceRequest)

Reinstall Instance

Reinstall an Instance using an optional `hostname`.  **Note:** This action may take a few extra seconds to complete.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final reinstallInstanceRequest = ReinstallInstanceRequest(); // ReinstallInstanceRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.reinstallInstance(instanceId, reinstallInstanceRequest);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->reinstallInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **reinstallInstanceRequest** | [**ReinstallInstanceRequest**](ReinstallInstanceRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateInstance202Response**](CreateInstance202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **restoreInstance**
> RestoreInstance202Response restoreInstance(instanceId, restoreInstanceRequest)

Restore Instance

Restore an Instance from either `backup_id` or `snapshot_id`.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final restoreInstanceRequest = RestoreInstanceRequest(); // RestoreInstanceRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.restoreInstance(instanceId, restoreInstanceRequest);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->restoreInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **restoreInstanceRequest** | [**RestoreInstanceRequest**](RestoreInstanceRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**RestoreInstance202Response**](RestoreInstance202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startInstance**
> startInstance(instanceId)

Start instance

Start an Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).

try {
    api_instance.startInstance(instanceId);
} catch (e) {
    print('Exception when calling InstancesApi->startInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startInstances**
> startInstances(startInstancesRequest)

Start instances

Start Instances.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final startInstancesRequest = StartInstancesRequest(); // StartInstancesRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.startInstances(startInstancesRequest);
} catch (e) {
    print('Exception when calling InstancesApi->startInstances: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startInstancesRequest** | [**StartInstancesRequest**](StartInstancesRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateInstance**
> CreateInstance202Response updateInstance(instanceId, updateInstanceRequest)

Update Instance

Update information for an Instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InstancesApi();
final instanceId = instanceId_example; // String | The [Instance ID](#operation/list-instances).
final updateInstanceRequest = UpdateInstanceRequest(); // UpdateInstanceRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.updateInstance(instanceId, updateInstanceRequest);
    print(result);
} catch (e) {
    print('Exception when calling InstancesApi->updateInstance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instanceId** | **String**| The [Instance ID](#operation/list-instances). | 
 **updateInstanceRequest** | [**UpdateInstanceRequest**](UpdateInstanceRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateInstance202Response**](CreateInstance202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

