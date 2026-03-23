# openapi.api.DnsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createDnsDomain**](DnsApi.md#creatednsdomain) | **POST** /domains | Create DNS Domain
[**createDnsDomainRecord**](DnsApi.md#creatednsdomainrecord) | **POST** /domains/{dns-domain}/records | Create Record
[**deleteDnsDomain**](DnsApi.md#deletednsdomain) | **DELETE** /domains/{dns-domain} | Delete Domain
[**deleteDnsDomainRecord**](DnsApi.md#deletednsdomainrecord) | **DELETE** /domains/{dns-domain}/records/{record-id} | Delete Record
[**getDnsDomain**](DnsApi.md#getdnsdomain) | **GET** /domains/{dns-domain} | Get DNS Domain
[**getDnsDomainDnssec**](DnsApi.md#getdnsdomaindnssec) | **GET** /domains/{dns-domain}/dnssec | Get DNSSec Info
[**getDnsDomainRecord**](DnsApi.md#getdnsdomainrecord) | **GET** /domains/{dns-domain}/records/{record-id} | Get Record
[**getDnsDomainSoa**](DnsApi.md#getdnsdomainsoa) | **GET** /domains/{dns-domain}/soa | Get SOA information
[**listDnsDomainRecords**](DnsApi.md#listdnsdomainrecords) | **GET** /domains/{dns-domain}/records | List Records
[**listDnsDomains**](DnsApi.md#listdnsdomains) | **GET** /domains | List DNS Domains
[**updateDnsDomain**](DnsApi.md#updatednsdomain) | **PUT** /domains/{dns-domain} | Update a DNS Domain
[**updateDnsDomainRecord**](DnsApi.md#updatednsdomainrecord) | **PATCH** /domains/{dns-domain}/records/{record-id} | Update Record
[**updateDnsDomainSoa**](DnsApi.md#updatednsdomainsoa) | **PATCH** /domains/{dns-domain}/soa | Update SOA information


# **createDnsDomain**
> CreateDnsDomain200Response createDnsDomain(createDnsDomainRequest)

Create DNS Domain

Create a DNS Domain for `domain`. If no `ip` address is supplied a domain with no records will be created.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final createDnsDomainRequest = CreateDnsDomainRequest(); // CreateDnsDomainRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createDnsDomain(createDnsDomainRequest);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->createDnsDomain: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createDnsDomainRequest** | [**CreateDnsDomainRequest**](CreateDnsDomainRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateDnsDomain200Response**](CreateDnsDomain200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDnsDomainRecord**
> CreateDnsDomainRecord201Response createDnsDomainRecord(dnsDomain, createDnsDomainRecordRequest)

Create Record

Create a DNS record.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final createDnsDomainRecordRequest = CreateDnsDomainRecordRequest(); // CreateDnsDomainRecordRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    final result = api_instance.createDnsDomainRecord(dnsDomain, createDnsDomainRecordRequest);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->createDnsDomainRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **createDnsDomainRecordRequest** | [**CreateDnsDomainRecordRequest**](CreateDnsDomainRecordRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

[**CreateDnsDomainRecord201Response**](CreateDnsDomainRecord201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteDnsDomain**
> deleteDnsDomain(dnsDomain)

Delete Domain

Delete the DNS Domain.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).

try {
    api_instance.deleteDnsDomain(dnsDomain);
} catch (e) {
    print('Exception when calling DnsApi->deleteDnsDomain: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteDnsDomainRecord**
> deleteDnsDomainRecord(dnsDomain, recordId)

Delete Record

Delete the DNS record.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final recordId = recordId_example; // String | The [DNS Record id](#operation/list-dns-domain-records).

try {
    api_instance.deleteDnsDomainRecord(dnsDomain, recordId);
} catch (e) {
    print('Exception when calling DnsApi->deleteDnsDomainRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **recordId** | **String**| The [DNS Record id](#operation/list-dns-domain-records). | 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDnsDomain**
> CreateDnsDomain200Response getDnsDomain(dnsDomain)

Get DNS Domain

Get information for the DNS Domain.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).

try {
    final result = api_instance.getDnsDomain(dnsDomain);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->getDnsDomain: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 

### Return type

[**CreateDnsDomain200Response**](CreateDnsDomain200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDnsDomainDnssec**
> GetDnsDomainDnssec200Response getDnsDomainDnssec(dnsDomain)

Get DNSSec Info

Get the DNSSEC information for the DNS Domain.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).

try {
    final result = api_instance.getDnsDomainDnssec(dnsDomain);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->getDnsDomainDnssec: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 

### Return type

[**GetDnsDomainDnssec200Response**](GetDnsDomainDnssec200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDnsDomainRecord**
> CreateDnsDomainRecord201Response getDnsDomainRecord(dnsDomain, recordId)

Get Record

Get information for a DNS Record.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final recordId = recordId_example; // String | The [DNS Record id](#operation/list-dns-domain-records).

try {
    final result = api_instance.getDnsDomainRecord(dnsDomain, recordId);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->getDnsDomainRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **recordId** | **String**| The [DNS Record id](#operation/list-dns-domain-records). | 

### Return type

[**CreateDnsDomainRecord201Response**](CreateDnsDomainRecord201Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDnsDomainSoa**
> GetDnsDomainSoa200Response getDnsDomainSoa(dnsDomain)

Get SOA information

Get SOA information for the DNS Domain.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).

try {
    final result = api_instance.getDnsDomainSoa(dnsDomain);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->getDnsDomainSoa: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 

### Return type

[**GetDnsDomainSoa200Response**](GetDnsDomainSoa200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDnsDomainRecords**
> ListDnsDomainRecords200Response listDnsDomainRecords(dnsDomain, perPage, cursor)

List Records

Get the DNS records for the Domain.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500.
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listDnsDomainRecords(dnsDomain, perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->listDnsDomainRecords: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500. | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListDnsDomainRecords200Response**](ListDnsDomainRecords200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDnsDomains**
> ListDnsDomains200Response listDnsDomains(perPage, cursor)

List DNS Domains

List all DNS Domains in your account.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final perPage = 56; // int | Number of items requested per page. Default is 100 and Max is 500. 
final cursor = cursor_example; // String | Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).

try {
    final result = api_instance.listDnsDomains(perPage, cursor);
    print(result);
} catch (e) {
    print('Exception when calling DnsApi->listDnsDomains: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **perPage** | **int**| Number of items requested per page. Default is 100 and Max is 500.  | [optional] 
 **cursor** | **String**| Cursor for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination). | [optional] 

### Return type

[**ListDnsDomains200Response**](ListDnsDomains200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDnsDomain**
> updateDnsDomain(dnsDomain, updateDnsDomainRequest)

Update a DNS Domain

Update the DNS Domain. 

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final updateDnsDomainRequest = UpdateDnsDomainRequest(); // UpdateDnsDomainRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateDnsDomain(dnsDomain, updateDnsDomainRequest);
} catch (e) {
    print('Exception when calling DnsApi->updateDnsDomain: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **updateDnsDomainRequest** | [**UpdateDnsDomainRequest**](UpdateDnsDomainRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDnsDomainRecord**
> updateDnsDomainRecord(dnsDomain, recordId, updateDnsDomainRecordRequest)

Update Record

Update the information for a DNS record. All attributes are optional. If not set, the attributes will retain their original values.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final recordId = recordId_example; // String | The [DNS Record id](#operation/list-dns-domain-records).
final updateDnsDomainRecordRequest = UpdateDnsDomainRecordRequest(); // UpdateDnsDomainRecordRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateDnsDomainRecord(dnsDomain, recordId, updateDnsDomainRecordRequest);
} catch (e) {
    print('Exception when calling DnsApi->updateDnsDomainRecord: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **recordId** | **String**| The [DNS Record id](#operation/list-dns-domain-records). | 
 **updateDnsDomainRecordRequest** | [**UpdateDnsDomainRecordRequest**](UpdateDnsDomainRecordRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDnsDomainSoa**
> updateDnsDomainSoa(dnsDomain, updateDnsDomainSoaRequest)

Update SOA information

Update the SOA information for the DNS Domain. All attributes are optional. If not set, the attributes will retain their original values.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DnsApi();
final dnsDomain = dnsDomain_example; // String | The [DNS Domain](#operation/list-dns-domains).
final updateDnsDomainSoaRequest = UpdateDnsDomainSoaRequest(); // UpdateDnsDomainSoaRequest | Include a JSON object in the request body with a content type of **application/json**.

try {
    api_instance.updateDnsDomainSoa(dnsDomain, updateDnsDomainSoaRequest);
} catch (e) {
    print('Exception when calling DnsApi->updateDnsDomainSoa: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dnsDomain** | **String**| The [DNS Domain](#operation/list-dns-domains). | 
 **updateDnsDomainSoaRequest** | [**UpdateDnsDomainSoaRequest**](UpdateDnsDomainSoaRequest.md)| Include a JSON object in the request body with a content type of **application/json**. | [optional] 

### Return type

void (empty response body)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

