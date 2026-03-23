# openapi.api.BillingApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.vultr.com/v2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getInvoice**](BillingApi.md#getinvoice) | **GET** /billing/invoices/{invoice-id} | Get Invoice
[**getInvoiceItems**](BillingApi.md#getinvoiceitems) | **GET** /billing/invoices/{invoice-id}/items | Get Invoice Items
[**listBillingHistory**](BillingApi.md#listbillinghistory) | **GET** /billing/history | List Billing History
[**listInvoices**](BillingApi.md#listinvoices) | **GET** /billing/invoices | List Invoices
[**pendingCharges**](BillingApi.md#pendingcharges) | **GET** /billing/pending-charges | List Pending Charges
[**pendingChargesCsv**](BillingApi.md#pendingchargescsv) | **GET** /billing/pending-charges/csv | Get Pending Charges CSV


# **getInvoice**
> GetInvoice200Response getInvoice(invoiceId)

Get Invoice

Retrieve specified invoice

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BillingApi();
final invoiceId = invoiceId_example; // String | ID of invoice

try {
    final result = api_instance.getInvoice(invoiceId);
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->getInvoice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invoiceId** | **String**| ID of invoice | 

### Return type

[**GetInvoice200Response**](GetInvoice200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvoiceItems**
> GetInvoiceItems200Response getInvoiceItems(invoiceId)

Get Invoice Items

Retrieve full specified invoice

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BillingApi();
final invoiceId = invoiceId_example; // String | ID of invoice

try {
    final result = api_instance.getInvoiceItems(invoiceId);
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->getInvoiceItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invoiceId** | **String**| ID of invoice | 

### Return type

[**GetInvoiceItems200Response**](GetInvoiceItems200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBillingHistory**
> ListBillingHistory200Response listBillingHistory()

List Billing History

Retrieve list of billing history

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BillingApi();

try {
    final result = api_instance.listBillingHistory();
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->listBillingHistory: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListBillingHistory200Response**](ListBillingHistory200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInvoices**
> ListInvoices200Response listInvoices()

List Invoices

Retrieve a list of invoices

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BillingApi();

try {
    final result = api_instance.listInvoices();
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->listInvoices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListInvoices200Response**](ListInvoices200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pendingCharges**
> PendingCharges200Response pendingCharges()

List Pending Charges

Retrieve list of billing pending charges

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BillingApi();

try {
    final result = api_instance.pendingCharges();
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->pendingCharges: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PendingCharges200Response**](PendingCharges200Response.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pendingChargesCsv**
> MultipartFile pendingChargesCsv()

Get Pending Charges CSV

Get pending charges as CSV file. Returns all current month charges.

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BillingApi();

try {
    final result = api_instance.pendingChargesCsv();
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->pendingChargesCsv: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MultipartFile**](MultipartFile.md)

### Authorization

[API Key](../README.md#API Key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

