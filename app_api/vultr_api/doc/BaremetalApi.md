# openapi.api.BaremetalApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**attachBaremetalsVpc2**](BaremetalApi.md#attachbaremetalsvpc2) | **POST** /bare-metals/{baremetal-id}/vpc2/attach | Attach VPC 2.0 Network to Bare Metal Instance
[**attachBaremetalsVpcs**](BaremetalApi.md#attachbaremetalsvpcs) | **POST** /bare-metals/{baremetal-id}/vpcs/attach | Attach VPC Network to Bare Metal Instance
[**createBaremetal**](BaremetalApi.md#createbaremetal) | **POST** /bare-metals | Create Bare Metal Instance
[**createBaremetalReverseIpv4**](BaremetalApi.md#createbaremetalreverseipv4) | **POST** /bare-metals/{baremetal-id}/ipv4/reverse | Create Baremetal Reverse IPv4
[**createBaremetalReverseIpv6**](BaremetalApi.md#createbaremetalreverseipv6) | **POST** /bare-metals/{baremetal-id}/ipv6/reverse | Create Baremetal Reverse IPv6
[**deleteBaremetal**](BaremetalApi.md#deletebaremetal) | **DELETE** /bare-metals/{baremetal-id} | Delete Bare Metal
[**deleteBaremetalReverseIpv6**](BaremetalApi.md#deletebaremetalreverseipv6) | **DELETE** /bare-metals/{baremetal-id}/ipv6/reverse/{ipv6} | Delete BareMetal Reverse IPv6
[**detachBaremetalVpc2**](BaremetalApi.md#detachbaremetalvpc2) | **POST** /bare-metals/{baremetal-id}/vpc2/detach | Detach VPC 2.0 Network from Bare Metal Instance
[**detachBaremetalVpcs**](BaremetalApi.md#detachbaremetalvpcs) | **POST** /bare-metals/{baremetal-id}/vpcs/detach | Detach VPC Network from Bare Metal Instance
[**getBandwidthBaremetal**](BaremetalApi.md#getbandwidthbaremetal) | **GET** /bare-metals/{baremetal-id}/bandwidth | Bare Metal Bandwidth
[**getBareMetalUserdata**](BaremetalApi.md#getbaremetaluserdata) | **GET** /bare-metals/{baremetal-id}/user-data | Get Bare Metal User Data
[**getBareMetalVnc**](BaremetalApi.md#getbaremetalvnc) | **GET** /bare-metals/{baremetal-id}/vnc | Get VNC URL for a Bare Metal
[**getBareMetalsUpgrades**](BaremetalApi.md#getbaremetalsupgrades) | **GET** /bare-metals/{baremetal-id}/upgrades | Get Available Bare Metal Upgrades
[**getBaremetal**](BaremetalApi.md#getbaremetal) | **GET** /bare-metals/{baremetal-id} | Get Bare Metal
[**getIpv4Baremetal**](BaremetalApi.md#getipv4baremetal) | **GET** /bare-metals/{baremetal-id}/ipv4 | Bare Metal IPv4 Addresses
[**getIpv6Baremetal**](BaremetalApi.md#getipv6baremetal) | **GET** /bare-metals/{baremetal-id}/ipv6 | Bare Metal IPv6 Addresses
[**haltBaremetal**](BaremetalApi.md#haltbaremetal) | **POST** /bare-metals/{baremetal-id}/halt | Halt Bare Metal
[**haltBaremetals**](BaremetalApi.md#haltbaremetals) | **POST** /bare-metals/halt | Halt Bare Metals
[**listBaremetalVpc2**](BaremetalApi.md#listbaremetalvpc2) | **GET** /bare-metals/{baremetal-id}/vpc2 | List Bare Metal Instance VPC 2.0 Networks
[**listBaremetalVpcs**](BaremetalApi.md#listbaremetalvpcs) | **GET** /bare-metals/{baremetal-id}/vpcs | List Bare Metal Instance VPC Networks
[**listBaremetals**](BaremetalApi.md#listbaremetals) | **GET** /bare-metals | List Bare Metal Instances
[**postBaremetalInstanceIdIpv4ReverseDefault**](BaremetalApi.md#postbaremetalinstanceidipv4reversedefault) | **POST** /bare-metals/{baremetal-id}/ipv4/reverse/default | Set Default Reverse DNS Entry
[**rebootBareMetals**](BaremetalApi.md#rebootbaremetals) | **POST** /bare-metals/reboot | Reboot Bare Metals
[**rebootBaremetal**](BaremetalApi.md#rebootbaremetal) | **POST** /bare-metals/{baremetal-id}/reboot | Reboot Bare Metal
[**reinstallBaremetal**](BaremetalApi.md#reinstallbaremetal) | **POST** /bare-metals/{baremetal-id}/reinstall | Reinstall Bare Metal
[**startBareMetals**](BaremetalApi.md#startbaremetals) | **POST** /bare-metals/start | Start Bare Metals
[**startBaremetal**](BaremetalApi.md#startbaremetal) | **POST** /bare-metals/{baremetal-id}/start | Start Bare Metal
[**updateBaremetal**](BaremetalApi.md#updatebaremetal) | **PATCH** /bare-metals/{baremetal-id} | Update Bare Metal


# **attachBaremetalsVpc2**
> attachBaremetalsVpc2(baremetalId, attachBaremetalsVpc2Request)

Attach VPC 2.0 Network to Bare Metal Instance

Attach a VPC 2.0 Network to a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Attach VPC Network to Bare Metal Instance](#operation/attach-baremetals-vpcs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal ID](#operation/list-baremetals).
final attachBaremetalsVpc2Request = AttachBaremetalsVpc2Request(); // AttachBaremetalsVpc2Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachBaremetalsVpc2(baremetalId, attachBaremetalsVpc2Request);
} catch (e) {
    print('Exception when calling BaremetalApi->attachBaremetalsVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal ID](#operation/list-baremetals). | 
 **attachBaremetalsVpc2Request** | [**AttachBaremetalsVpc2Request**](AttachBaremetalsVpc2Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attachBaremetalsVpcs**
> attachBaremetalsVpcs(baremetalId, attachBaremetalsVpcsRequest)

Attach VPC Network to Bare Metal Instance

Attach a VPC Network to a Bare Metal Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal ID](#operation/list-baremetals).
final attachBaremetalsVpcsRequest = AttachBaremetalsVpcsRequest(); // AttachBaremetalsVpcsRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.attachBaremetalsVpcs(baremetalId, attachBaremetalsVpcsRequest);
} catch (e) {
    print('Exception when calling BaremetalApi->attachBaremetalsVpcs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal ID](#operation/list-baremetals). | 
 **attachBaremetalsVpcsRequest** | [**AttachBaremetalsVpcsRequest**](AttachBaremetalsVpcsRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBaremetal**
> CreateBaremetal202Response createBaremetal(createBaremetalRequest)

Create Bare Metal Instance

Create a new Bare Metal instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:  * `os_id` * `snapshot_id` * `app_id` * `image_id`  Supply other attributes as desired.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final createBaremetalRequest = CreateBaremetalRequest(); // CreateBaremetalRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createBaremetal(createBaremetalRequest);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->createBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBaremetalRequest** | [**CreateBaremetalRequest**](CreateBaremetalRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateBaremetal202Response**](CreateBaremetal202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBaremetalReverseIpv4**
> createBaremetalReverseIpv4(baremetalId, createBaremetalReverseIpv4Request)

Create Baremetal Reverse IPv4

Create a reverse IPv4 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal ID](#operation/baremetals).
final createBaremetalReverseIpv4Request = CreateBaremetalReverseIpv4Request(); // CreateBaremetalReverseIpv4Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createBaremetalReverseIpv4(baremetalId, createBaremetalReverseIpv4Request);
} catch (e) {
    print('Exception when calling BaremetalApi->createBaremetalReverseIpv4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal ID](#operation/baremetals). | 
 **createBaremetalReverseIpv4Request** | [**CreateBaremetalReverseIpv4Request**](CreateBaremetalReverseIpv4Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBaremetalReverseIpv6**
> createBaremetalReverseIpv6(baremetalId, createBaremetalReverseIpv6Request)

Create Baremetal Reverse IPv6

Create a reverse IPv6 entry for a Bare Metal Instance. The `ip` and `reverse` attributes are required. IP address must be in full, expanded format.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare metal ID](#operation/baremetals).
final createBaremetalReverseIpv6Request = CreateBaremetalReverseIpv6Request(); // CreateBaremetalReverseIpv6Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.createBaremetalReverseIpv6(baremetalId, createBaremetalReverseIpv6Request);
} catch (e) {
    print('Exception when calling BaremetalApi->createBaremetalReverseIpv6: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare metal ID](#operation/baremetals). | 
 **createBaremetalReverseIpv6Request** | [**CreateBaremetalReverseIpv6Request**](CreateBaremetalReverseIpv6Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteBaremetal**
> deleteBaremetal(baremetalId)

Delete Bare Metal

Delete a Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    api_instance.deleteBaremetal(baremetalId);
} catch (e) {
    print('Exception when calling BaremetalApi->deleteBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteBaremetalReverseIpv6**
> deleteBaremetalReverseIpv6(baremetalId, ipv6)

Delete BareMetal Reverse IPv6

Delete the reverse IPv6 for a Bare metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).
final ipv6 = ipv6_example; // String | The IPv6 address.

try {
    api_instance.deleteBaremetalReverseIpv6(baremetalId, ipv6);
} catch (e) {
    print('Exception when calling BaremetalApi->deleteBaremetalReverseIpv6: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 
 **ipv6** | **String**| The IPv6 address. | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachBaremetalVpc2**
> detachBaremetalVpc2(baremetalId, detachBaremetalVpc2Request)

Detach VPC 2.0 Network from Bare Metal Instance

Detach a VPC 2.0 Network from an Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [Detach VPC Network from Bare Metal Instance](#operation/detach-baremetal-vpcs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [bare-metal ID](#operation/list-baremetals).
final detachBaremetalVpc2Request = DetachBaremetalVpc2Request(); // DetachBaremetalVpc2Request | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachBaremetalVpc2(baremetalId, detachBaremetalVpc2Request);
} catch (e) {
    print('Exception when calling BaremetalApi->detachBaremetalVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [bare-metal ID](#operation/list-baremetals). | 
 **detachBaremetalVpc2Request** | [**DetachBaremetalVpc2Request**](DetachBaremetalVpc2Request.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detachBaremetalVpcs**
> detachBaremetalVpcs(baremetalId, detachBaremetalVpcsRequest)

Detach VPC Network from Bare Metal Instance

Detach a VPC Network from an Bare Metal Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [bare-metal ID](#operation/list-baremetals).
final detachBaremetalVpcsRequest = DetachBaremetalVpcsRequest(); // DetachBaremetalVpcsRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.detachBaremetalVpcs(baremetalId, detachBaremetalVpcsRequest);
} catch (e) {
    print('Exception when calling BaremetalApi->detachBaremetalVpcs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [bare-metal ID](#operation/list-baremetals). | 
 **detachBaremetalVpcsRequest** | [**DetachBaremetalVpcsRequest**](DetachBaremetalVpcsRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBandwidthBaremetal**
> GetBandwidthBaremetal200Response getBandwidthBaremetal(baremetalId)

Bare Metal Bandwidth

Get bandwidth information for the Bare Metal instance.<br><br>The `bandwidth` object in a successful response contains objects representing a day in the month. The date is denoted by the nested object keys. Days begin and end in the UTC timezone. Bandwidth utilization data contained within the date object is refreshed periodically. We do not recommend using this endpoint to gather real-time metrics.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    final result = api_instance.getBandwidthBaremetal(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getBandwidthBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

[**GetBandwidthBaremetal200Response**](GetBandwidthBaremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBareMetalUserdata**
> GetBareMetalUserdata200Response getBareMetalUserdata(baremetalId)

Get Bare Metal User Data

Get the user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for a Bare Metal.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    final result = api_instance.getBareMetalUserdata(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getBareMetalUserdata: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

[**GetBareMetalUserdata200Response**](GetBareMetalUserdata200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBareMetalVnc**
> GetBareMetalVnc200Response getBareMetalVnc(baremetalId)

Get VNC URL for a Bare Metal

Get the VNC URL for a Bare Metal

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    final result = api_instance.getBareMetalVnc(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getBareMetalVnc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

[**GetBareMetalVnc200Response**](GetBareMetalVnc200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBareMetalsUpgrades**
> GetBareMetalsUpgrades200Response getBareMetalsUpgrades(baremetalId, type)

Get Available Bare Metal Upgrades

Get available upgrades for a Bare Metal

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).
final type = type_example; // String | Filter upgrade by type:  - all (applications, plans) - applications - os

try {
    final result = api_instance.getBareMetalsUpgrades(baremetalId, type);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getBareMetalsUpgrades: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 
 **type** | **String**| Filter upgrade by type:  - all (applications, plans) - applications - os | [optional] 

### Return type

[**GetBareMetalsUpgrades200Response**](GetBareMetalsUpgrades200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBaremetal**
> GetBaremetal200Response getBaremetal(baremetalId)

Get Bare Metal

Get information for a Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    final result = api_instance.getBaremetal(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

[**GetBaremetal200Response**](GetBaremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getIpv4Baremetal**
> GetIpv4Baremetal200Response getIpv4Baremetal(baremetalId)

Bare Metal IPv4 Addresses

Get the IPv4 information for the Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    final result = api_instance.getIpv4Baremetal(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getIpv4Baremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

[**GetIpv4Baremetal200Response**](GetIpv4Baremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getIpv6Baremetal**
> GetIpv6Baremetal200Response getIpv6Baremetal(baremetalId)

Bare Metal IPv6 Addresses

Get the IPv6 information for the Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    final result = api_instance.getIpv6Baremetal(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->getIpv6Baremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

[**GetIpv6Baremetal200Response**](GetIpv6Baremetal200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **haltBaremetal**
> haltBaremetal(baremetalId)

Halt Bare Metal

Halt the Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    api_instance.haltBaremetal(baremetalId);
} catch (e) {
    print('Exception when calling BaremetalApi->haltBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **haltBaremetals**
> haltBaremetals(haltBaremetalsRequest)

Halt Bare Metals

Halt Bare Metals.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final haltBaremetalsRequest = HaltBaremetalsRequest(); // HaltBaremetalsRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.haltBaremetals(haltBaremetalsRequest);
} catch (e) {
    print('Exception when calling BaremetalApi->haltBaremetals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **haltBaremetalsRequest** | [**HaltBaremetalsRequest**](HaltBaremetalsRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBaremetalVpc2**
> ListBaremetalVpc2200Response listBaremetalVpc2(baremetalId)

List Bare Metal Instance VPC 2.0 Networks

List the VPC 2.0 networks for a Bare Metal Instance.<br><br>**Deprecated**: Migrate to VPC Networks and use [List Bare Metal Instance VPC Networks](#operation/list-baremetal-vpcs) instead.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal ID](#operation/list-baremetals).

try {
    final result = api_instance.listBaremetalVpc2(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->listBaremetalVpc2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal ID](#operation/list-baremetals). | 

### Return type

[**ListBaremetalVpc2200Response**](ListBaremetalVpc2200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBaremetalVpcs**
> ListBaremetalVpcs200Response listBaremetalVpcs(baremetalId)

List Bare Metal Instance VPC Networks

List the VPC networks for a Bare Metal Instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal ID](#operation/list-baremetals).

try {
    final result = api_instance.listBaremetalVpcs(baremetalId);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->listBaremetalVpcs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal ID](#operation/list-baremetals). | 

### Return type

[**ListBaremetalVpcs200Response**](ListBaremetalVpcs200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBaremetals**
> ListBaremetals200Response listBaremetals(perPage, cursor)

List Bare Metal Instances

List all Bare Metal instances in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500. 
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listBaremetals(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->listBaremetals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500.  | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListBaremetals200Response**](ListBaremetals200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postBaremetalInstanceIdIpv4ReverseDefault**
> postBaremetalInstanceIdIpv4ReverseDefault(baremetalId, postBaremetalInstanceIdIpv4ReverseDefaultRequest)

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

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal ID](#operation/list-baremetals).
final postBaremetalInstanceIdIpv4ReverseDefaultRequest = PostBaremetalInstanceIdIpv4ReverseDefaultRequest(); // PostBaremetalInstanceIdIpv4ReverseDefaultRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.postBaremetalInstanceIdIpv4ReverseDefault(baremetalId, postBaremetalInstanceIdIpv4ReverseDefaultRequest);
} catch (e) {
    print('Exception when calling BaremetalApi->postBaremetalInstanceIdIpv4ReverseDefault: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal ID](#operation/list-baremetals). | 
 **postBaremetalInstanceIdIpv4ReverseDefaultRequest** | [**PostBaremetalInstanceIdIpv4ReverseDefaultRequest**](PostBaremetalInstanceIdIpv4ReverseDefaultRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebootBareMetals**
> rebootBareMetals(haltBaremetalsRequest)

Reboot Bare Metals

Reboot Bare Metals.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final haltBaremetalsRequest = HaltBaremetalsRequest(); // HaltBaremetalsRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.rebootBareMetals(haltBaremetalsRequest);
} catch (e) {
    print('Exception when calling BaremetalApi->rebootBareMetals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **haltBaremetalsRequest** | [**HaltBaremetalsRequest**](HaltBaremetalsRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebootBaremetal**
> rebootBaremetal(baremetalId)

Reboot Bare Metal

Reboot the Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    api_instance.rebootBaremetal(baremetalId);
} catch (e) {
    print('Exception when calling BaremetalApi->rebootBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reinstallBaremetal**
> UpdateBaremetal202Response reinstallBaremetal(baremetalId, reinstallBaremetalRequest)

Reinstall Bare Metal

Reinstall the Bare Metal instance using an optional `hostname`.   **Note:** This action may take some time to complete.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).
final reinstallBaremetalRequest = ReinstallBaremetalRequest(); // ReinstallBaremetalRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.reinstallBaremetal(baremetalId, reinstallBaremetalRequest);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->reinstallBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 
 **reinstallBaremetalRequest** | [**ReinstallBaremetalRequest**](ReinstallBaremetalRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**UpdateBaremetal202Response**](UpdateBaremetal202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startBareMetals**
> startBareMetals(haltBaremetalsRequest)

Start Bare Metals

Start Bare Metals.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final haltBaremetalsRequest = HaltBaremetalsRequest(); // HaltBaremetalsRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.startBareMetals(haltBaremetalsRequest);
} catch (e) {
    print('Exception when calling BaremetalApi->startBareMetals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **haltBaremetalsRequest** | [**HaltBaremetalsRequest**](HaltBaremetalsRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startBaremetal**
> startBaremetal(baremetalId)

Start Bare Metal

Start the Bare Metal instance.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).

try {
    api_instance.startBaremetal(baremetalId);
} catch (e) {
    print('Exception when calling BaremetalApi->startBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateBaremetal**
> UpdateBaremetal202Response updateBaremetal(baremetalId, updateBaremetalRequest)

Update Bare Metal

Update a Bare Metal instance. All attributes are optional. If not set, the attributes will retain their original values.  **Note:** Changing `os_id`, `app_id` or `image_id` may take a few extra seconds to complete.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BaremetalApi();
final baremetalId = baremetalId_example; // String | The [Bare Metal id](#operation/list-baremetals).
final updateBaremetalRequest = UpdateBaremetalRequest(); // UpdateBaremetalRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.updateBaremetal(baremetalId, updateBaremetalRequest);
    print(result);
} catch (e) {
    print('Exception when calling BaremetalApi->updateBaremetal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **baremetalId** | **String**| The [Bare Metal id](#operation/list-baremetals). | 
 **updateBaremetalRequest** | [**UpdateBaremetalRequest**](UpdateBaremetalRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**UpdateBaremetal202Response**](UpdateBaremetal202Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

