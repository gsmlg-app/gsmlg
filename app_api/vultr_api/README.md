# openapi
# Introduction

The Vultr API v2 is a set of HTTP endpoints that adhere to RESTful design principles and CRUD actions with predictable URIs. It uses standard HTTP response codes, authentication, and verbs. The API has consistent and well-formed JSON requests and responses with cursor-based pagination to simplify list handling. Error messages are descriptive and easy to understand. All functions of the Vultr customer portal are accessible via the API, enabling you to script complex unattended scenarios with any tool fluent in HTTP.

## Requests

Communicate with the API by making an HTTP request at the correct endpoint. The chosen method determines the action taken.

| Method | Usage |
| ------ | ------------- |
| DELETE | Use the DELETE method to destroy a resource in your account. If it is not found, the operation will return a 4xx error and an appropriate message. |
| GET | To retrieve information about a resource, use the GET method. The data is returned as a JSON object. GET methods are read-only and do not affect any resources. |
| PATCH | Some resources support partial modification with PATCH, which modifies specific attributes without updating the entire object representation. |
| POST | Issue a POST method to create a new object. Include all needed attributes in the request body encoded as JSON. |
| PUT | Use the PUT method to update information about a resource. PUT will set new values on the item without regard to their current values. |

**Rate Limit:** Vultr safeguards the API against bursts of incoming traffic based on the request's IP address to ensure stability for all users. If your application sends more than 30 requests per second, the API may return HTTP status code 429.

## Response Codes

We use standard HTTP response codes to show the success or failure of requests. Response codes in the 2xx range indicate success, while codes in the 4xx range indicate an error, such as an authorization failure or a malformed request. All 4xx errors will return a JSON response object with an `error` attribute explaining the error. Codes in the 5xx range indicate a server-side problem preventing Vultr from fulfilling your request.

| Response | Description |
| ------ | ------------- |
| 200 OK | The response contains your requested information. |
| 201 Created | Your request was accepted. The resource was created. |
| 202 Accepted | Your request was accepted. The resource was created or updated. |
| 204 No Content | Your request succeeded, there is no additional information returned. |
| 400 Bad Request | Your request was malformed. |
| 401 Unauthorized | You did not supply valid authentication credentials. |
| 403 Forbidden | You are not allowed to perform that action. |
| 404 Not Found | No results were found for your request. |
| 429 Too Many Requests | Your request exceeded the API rate limit. |
| 500 Internal Server Error | We were unable to perform the request due to server-side problems. |

## Meta and Pagination

Many API calls will return a `meta` object with paging information.

### Definitions

| Term | Description |
| ------ | ------------- |
| **List** | The items returned from the database for your request (not necessarily shown in a single response depending on the **cursor** size). |
| **Page** | A subset of the full **list** of items. Choose the size of a **page** with the `per_page` parameter. |
| **Total** | The `total` attribute indicates the number of items in the full **list**.|
| **Cursor** | Use the `cursor` query parameter to select a next or previous **page**. |
| **Next** & **Prev** | Use the `next` and `prev` attributes of the `links` meta object as `cursor` values. |

### How to use Paging

If your result **list** total exceeds the default **cursor** size (the default depends on the route, but is usually 100 records) or the value defined by the `per_page` query param (when present) the response will be returned to you paginated.

### Paging Example

> These examples have abbreviated attributes and sample values. Your actual `cursor` values will be encoded alphanumeric strings.

To return a **page** with the first two plans in the List:

    curl \"https://api.vultr.com/v2/plans?per_page=2\" \\
      -X GET \\
      -H \"Authorization: Bearer ${VULTR_API_KEY}\"

The API returns an object similar to this:

    {
        \"plans\": [
            {
                \"id\": \"vc2-1c-2gb\",
                \"vcpu_count\": 1,
                \"ram\": 2048,
                \"locations\": []
            },
            {
                \"id\": \"vc2-24c-97gb\",
                \"vcpu_count\": 24,
                \"ram\": 98304,
                \"locations\": []
            }
        ],
        \"meta\": {
            \"total\": 19,
            \"links\": {
                \"next\": \"WxYzExampleNext\",
                \"prev\": \"WxYzExamplePrev\"
            }
        }
    }

The object contains two plans. The `total` attribute indicates that 19 plans are available in the List. To navigate forward in the **list**, use the `next` value (`WxYzExampleNext` in this example) as your `cursor` query parameter.

    curl \"https://api.vultr.com/v2/plans?per_page=2&cursor=WxYzExampleNext\" \\
      -X GET
      -H \"Authorization: Bearer ${VULTR_API_KEY}\"

Likewise, you can use the example `prev` value `WxYzExamplePrev` to navigate backward.

## Parameters

You can pass information to the API with three different types of parameters.

### Path parameters

Some API calls require variable parameters as part of the endpoint path. For example, to retrieve information about a user, supply the `user-id` in the endpoint.

    curl \"https://api.vultr.com/v2/users/{user-id}\" \\
      -X GET \\
      -H \"Authorization: Bearer ${VULTR_API_KEY}\"

### Query parameters

Some API calls allow filtering with query parameters. For example, the `/v2/plans` endpoint supports a `type` query parameter. Setting `type=vhf` instructs the API only to return High Frequency Compute plans in the list. You'll find more specifics about valid filters in the endpoint documentation below.

    curl \"https://api.vultr.com/v2/plans?type=vhf\" \\
      -X GET \\
      -H \"Authorization: Bearer ${VULTR_API_KEY}\"

You can also combine filtering with paging. Use the `per_page` parameter to retreive a subset of vhf plans.

    curl \"https://api.vultr.com/v2/plans?type=vhf&per_page=2\" \\
      -X GET \\
      -H \"Authorization: Bearer ${VULTR_API_KEY}\"

### Request Body

PUT, POST, and PATCH methods may include an object in the request body with a content type of **application/json**. The documentation for each endpoint below has more information about the expected object.

## API Example Conventions

The examples in this documentation use `curl`, a command-line HTTP client, to demonstrate useage. Linux and macOS computers usually have curl installed by default, and it's [available for download](https://curl.se/download.html) on all popular platforms including Windows.

Each example is split across multiple lines with the `\\` character, which is compatible with a `bash` terminal. A typical example looks like this:

    curl \"https://api.vultr.com/v2/domains\" \\
      -X POST \\
      -H \"Authorization: Bearer ${VULTR_API_KEY}\" \\
      -H \"Content-Type: application/json\" \\
      --data '{
        \"domain\" : \"example.com\",
        \"ip\" : \"192.0.2.123\"
      }'

* The `-X` parameter sets the request method. For consistency, we show the method on all examples, even though it's not explicitly required for GET methods.
* The `-H` lines set required HTTP headers. These examples are formatted to expand the VULTR\\_API\\_KEY environment variable for your convenience.
* Examples that require a JSON object in the request body pass the required data via the `--data` parameter.

All values in this guide are examples. Do not rely on the OS or Plan IDs listed in this guide; use the appropriate endpoint to retreive values before creating resources.


This Dart package is automatically generated by the [OpenAPI Generator](https://openapi-generator.tech) project:

- API version: 2.0
- Generator version: 7.18.0
- Build package: org.openapitools.codegen.languages.DartClientCodegen
For more information, please visit [https://www.vultr.com](https://www.vultr.com)

## Requirements

Dart 2.12 or later

## Installation & Usage

### Github
If this Dart package is published to Github, add the following dependency to your pubspec.yaml
```
dependencies:
  openapi:
    git: https://github.com/GIT_USER_ID/GIT_REPO_ID.git
```

### Local
To use the package in your local drive, add the following dependency to your pubspec.yaml
```
dependencies:
  openapi:
    path: /path/to/openapi
```

## Tests

TODO

## Getting Started

Please follow the [installation procedure](#installation--usage) and then run the following:

```dart
import 'package:openapi/api.dart';

// TODO Configure HTTP Bearer authorization: API Key
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('API Key').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AccountApi();

try {
    final result = api_instance.getAccount();
    print(result);
} catch (e) {
    print('Exception when calling AccountApi->getAccount: $e\n');
}

```

## Documentation for API Endpoints

All URIs are relative to *https://api.vultr.com/v2*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*AccountApi* | [**getAccount**](doc//AccountApi.md#getaccount) | **GET** /account | Get Account Info
*AccountApi* | [**getAccountBandwidth**](doc//AccountApi.md#getaccountbandwidth) | **GET** /account/bandwidth | Get Account Bandwidth Info
*AccountApi* | [**getAccountBgp**](doc//AccountApi.md#getaccountbgp) | **GET** /account/bgp | Get Account BGP Info
*ApiKeysApi* | [**createApiKey**](doc//ApiKeysApi.md#createapikey) | **POST** /apikeys | Create API Key
*ApiKeysApi* | [**deleteApiKey**](doc//ApiKeysApi.md#deleteapikey) | **DELETE** /apikeys/{apikey-id} | Delete API Key
*ApiKeysApi* | [**getApiKey**](doc//ApiKeysApi.md#getapikey) | **GET** /apikeys/{apikey-id} | Get API Key
*ApiKeysApi* | [**listApiKeys**](doc//ApiKeysApi.md#listapikeys) | **GET** /apikeys | List API Keys
*ApplicationApi* | [**listApplications**](doc//ApplicationApi.md#listapplications) | **GET** /applications | List Applications
*BackupApi* | [**getBackup**](doc//BackupApi.md#getbackup) | **GET** /backups/{backup-id} | Get a Backup
*BackupApi* | [**listBackups**](doc//BackupApi.md#listbackups) | **GET** /backups | List Backups
*BaremetalApi* | [**attachBaremetalsVpc2**](doc//BaremetalApi.md#attachbaremetalsvpc2) | **POST** /bare-metals/{baremetal-id}/vpc2/attach | Attach VPC 2.0 Network to Bare Metal Instance
*BaremetalApi* | [**attachBaremetalsVpcs**](doc//BaremetalApi.md#attachbaremetalsvpcs) | **POST** /bare-metals/{baremetal-id}/vpcs/attach | Attach VPC Network to Bare Metal Instance
*BaremetalApi* | [**createBaremetal**](doc//BaremetalApi.md#createbaremetal) | **POST** /bare-metals | Create Bare Metal Instance
*BaremetalApi* | [**createBaremetalReverseIpv4**](doc//BaremetalApi.md#createbaremetalreverseipv4) | **POST** /bare-metals/{baremetal-id}/ipv4/reverse | Create Baremetal Reverse IPv4
*BaremetalApi* | [**createBaremetalReverseIpv6**](doc//BaremetalApi.md#createbaremetalreverseipv6) | **POST** /bare-metals/{baremetal-id}/ipv6/reverse | Create Baremetal Reverse IPv6
*BaremetalApi* | [**deleteBaremetal**](doc//BaremetalApi.md#deletebaremetal) | **DELETE** /bare-metals/{baremetal-id} | Delete Bare Metal
*BaremetalApi* | [**deleteBaremetalReverseIpv6**](doc//BaremetalApi.md#deletebaremetalreverseipv6) | **DELETE** /bare-metals/{baremetal-id}/ipv6/reverse/{ipv6} | Delete BareMetal Reverse IPv6
*BaremetalApi* | [**detachBaremetalVpc2**](doc//BaremetalApi.md#detachbaremetalvpc2) | **POST** /bare-metals/{baremetal-id}/vpc2/detach | Detach VPC 2.0 Network from Bare Metal Instance
*BaremetalApi* | [**detachBaremetalVpcs**](doc//BaremetalApi.md#detachbaremetalvpcs) | **POST** /bare-metals/{baremetal-id}/vpcs/detach | Detach VPC Network from Bare Metal Instance
*BaremetalApi* | [**getBandwidthBaremetal**](doc//BaremetalApi.md#getbandwidthbaremetal) | **GET** /bare-metals/{baremetal-id}/bandwidth | Bare Metal Bandwidth
*BaremetalApi* | [**getBareMetalUserdata**](doc//BaremetalApi.md#getbaremetaluserdata) | **GET** /bare-metals/{baremetal-id}/user-data | Get Bare Metal User Data
*BaremetalApi* | [**getBareMetalVnc**](doc//BaremetalApi.md#getbaremetalvnc) | **GET** /bare-metals/{baremetal-id}/vnc | Get VNC URL for a Bare Metal
*BaremetalApi* | [**getBareMetalsUpgrades**](doc//BaremetalApi.md#getbaremetalsupgrades) | **GET** /bare-metals/{baremetal-id}/upgrades | Get Available Bare Metal Upgrades
*BaremetalApi* | [**getBaremetal**](doc//BaremetalApi.md#getbaremetal) | **GET** /bare-metals/{baremetal-id} | Get Bare Metal
*BaremetalApi* | [**getIpv4Baremetal**](doc//BaremetalApi.md#getipv4baremetal) | **GET** /bare-metals/{baremetal-id}/ipv4 | Bare Metal IPv4 Addresses
*BaremetalApi* | [**getIpv6Baremetal**](doc//BaremetalApi.md#getipv6baremetal) | **GET** /bare-metals/{baremetal-id}/ipv6 | Bare Metal IPv6 Addresses
*BaremetalApi* | [**haltBaremetal**](doc//BaremetalApi.md#haltbaremetal) | **POST** /bare-metals/{baremetal-id}/halt | Halt Bare Metal
*BaremetalApi* | [**haltBaremetals**](doc//BaremetalApi.md#haltbaremetals) | **POST** /bare-metals/halt | Halt Bare Metals
*BaremetalApi* | [**listBaremetalVpc2**](doc//BaremetalApi.md#listbaremetalvpc2) | **GET** /bare-metals/{baremetal-id}/vpc2 | List Bare Metal Instance VPC 2.0 Networks
*BaremetalApi* | [**listBaremetalVpcs**](doc//BaremetalApi.md#listbaremetalvpcs) | **GET** /bare-metals/{baremetal-id}/vpcs | List Bare Metal Instance VPC Networks
*BaremetalApi* | [**listBaremetals**](doc//BaremetalApi.md#listbaremetals) | **GET** /bare-metals | List Bare Metal Instances
*BaremetalApi* | [**postBaremetalInstanceIdIpv4ReverseDefault**](doc//BaremetalApi.md#postbaremetalinstanceidipv4reversedefault) | **POST** /bare-metals/{baremetal-id}/ipv4/reverse/default | Set Default Reverse DNS Entry
*BaremetalApi* | [**rebootBareMetals**](doc//BaremetalApi.md#rebootbaremetals) | **POST** /bare-metals/reboot | Reboot Bare Metals
*BaremetalApi* | [**rebootBaremetal**](doc//BaremetalApi.md#rebootbaremetal) | **POST** /bare-metals/{baremetal-id}/reboot | Reboot Bare Metal
*BaremetalApi* | [**reinstallBaremetal**](doc//BaremetalApi.md#reinstallbaremetal) | **POST** /bare-metals/{baremetal-id}/reinstall | Reinstall Bare Metal
*BaremetalApi* | [**startBareMetals**](doc//BaremetalApi.md#startbaremetals) | **POST** /bare-metals/start | Start Bare Metals
*BaremetalApi* | [**startBaremetal**](doc//BaremetalApi.md#startbaremetal) | **POST** /bare-metals/{baremetal-id}/start | Start Bare Metal
*BaremetalApi* | [**updateBaremetal**](doc//BaremetalApi.md#updatebaremetal) | **PATCH** /bare-metals/{baremetal-id} | Update Bare Metal
*BillingApi* | [**getInvoice**](doc//BillingApi.md#getinvoice) | **GET** /billing/invoices/{invoice-id} | Get Invoice
*BillingApi* | [**getInvoiceItems**](doc//BillingApi.md#getinvoiceitems) | **GET** /billing/invoices/{invoice-id}/items | Get Invoice Items
*BillingApi* | [**listBillingHistory**](doc//BillingApi.md#listbillinghistory) | **GET** /billing/history | List Billing History
*BillingApi* | [**listInvoices**](doc//BillingApi.md#listinvoices) | **GET** /billing/invoices | List Invoices
*BillingApi* | [**pendingCharges**](doc//BillingApi.md#pendingcharges) | **GET** /billing/pending-charges | List Pending Charges
*BillingApi* | [**pendingChargesCsv**](doc//BillingApi.md#pendingchargescsv) | **GET** /billing/pending-charges/csv | Get Pending Charges CSV
*BlockApi* | [**attachBlock**](doc//BlockApi.md#attachblock) | **POST** /blocks/{block-id}/attach | Attach Block Storage
*BlockApi* | [**createBlock**](doc//BlockApi.md#createblock) | **POST** /blocks | Create Block Storage
*BlockApi* | [**deleteBlock**](doc//BlockApi.md#deleteblock) | **DELETE** /blocks/{block-id} | Delete Block Storage
*BlockApi* | [**detachBlock**](doc//BlockApi.md#detachblock) | **POST** /blocks/{block-id}/detach | Detach Block Storage
*BlockApi* | [**getBlock**](doc//BlockApi.md#getblock) | **GET** /blocks/{block-id} | Get Block Storage
*BlockApi* | [**listBlocks**](doc//BlockApi.md#listblocks) | **GET** /blocks | List Block storages
*BlockApi* | [**updateBlock**](doc//BlockApi.md#updateblock) | **PATCH** /blocks/{block-id} | Update Block Storage
*CDNsApi* | [**createPullzone**](doc//CDNsApi.md#createpullzone) | **POST** /cdns/pull-zones | Create CDN Pull Zones
*CDNsApi* | [**createPushzone**](doc//CDNsApi.md#createpushzone) | **POST** /cdns/push-zones | Create CDN Push Zones
*CDNsApi* | [**createPushzoneUpload**](doc//CDNsApi.md#createpushzoneupload) | **POST** /cdns/push-zones/{pushzone-id}/files | Create CDN Push Zone File Upload Endpoint
*CDNsApi* | [**deletePullzone**](doc//CDNsApi.md#deletepullzone) | **DELETE** /cdns/pull-zones/{pullzone-id} | Delete CDN Pullzone
*CDNsApi* | [**deletePushzone**](doc//CDNsApi.md#deletepushzone) | **DELETE** /cdns/push-zones/{pushzone-id} | Delete CDN Pushzone
*CDNsApi* | [**deletePushzoneFile**](doc//CDNsApi.md#deletepushzonefile) | **DELETE** /cdns/push-zones/{pushzone-id}/files/{file-name} | Delete CDN Pushzone File
*CDNsApi* | [**getPullzone**](doc//CDNsApi.md#getpullzone) | **GET** /cdns/pull-zones/{pullzone-id} | Get CDN Pull Zone
*CDNsApi* | [**getPushzone**](doc//CDNsApi.md#getpushzone) | **GET** /cdns/push-zones/{pushzone-id} | Get CDN Push Zone
*CDNsApi* | [**getPushzoneFiles**](doc//CDNsApi.md#getpushzonefiles) | **GET** /cdns/push-zones/{pushzone-id}/files | List CDN Push Zone Files
*CDNsApi* | [**getPushzone_0**](doc//CDNsApi.md#getpushzone_0) | **GET** /cdns/push-zones/{pushzone-id}/files/{file-name} | Get CDN Push Zone File
*CDNsApi* | [**listPullzones**](doc//CDNsApi.md#listpullzones) | **GET** /cdns/pull-zones | List CDN Pull Zones
*CDNsApi* | [**listPushzones**](doc//CDNsApi.md#listpushzones) | **GET** /cdns/push-zones | List CDN Push Zones
*CDNsApi* | [**purgePullzone**](doc//CDNsApi.md#purgepullzone) | **GET** /cdns/pull-zones/{pullzone-id}/purge | Purge CDN Pull Zone
*CDNsApi* | [**updatePullzone**](doc//CDNsApi.md#updatepullzone) | **PUT** /cdns/pull-zones/{pullzone-id} | Update CDN Pull Zone
*CDNsApi* | [**updatePushzone**](doc//CDNsApi.md#updatepushzone) | **PUT** /cdns/push-zones/{pushzone-id} | Update CDN Push Zone
*DnsApi* | [**createDnsDomain**](doc//DnsApi.md#creatednsdomain) | **POST** /domains | Create DNS Domain
*DnsApi* | [**createDnsDomainRecord**](doc//DnsApi.md#creatednsdomainrecord) | **POST** /domains/{dns-domain}/records | Create Record
*DnsApi* | [**deleteDnsDomain**](doc//DnsApi.md#deletednsdomain) | **DELETE** /domains/{dns-domain} | Delete Domain
*DnsApi* | [**deleteDnsDomainRecord**](doc//DnsApi.md#deletednsdomainrecord) | **DELETE** /domains/{dns-domain}/records/{record-id} | Delete Record
*DnsApi* | [**getDnsDomain**](doc//DnsApi.md#getdnsdomain) | **GET** /domains/{dns-domain} | Get DNS Domain
*DnsApi* | [**getDnsDomainDnssec**](doc//DnsApi.md#getdnsdomaindnssec) | **GET** /domains/{dns-domain}/dnssec | Get DNSSec Info
*DnsApi* | [**getDnsDomainRecord**](doc//DnsApi.md#getdnsdomainrecord) | **GET** /domains/{dns-domain}/records/{record-id} | Get Record
*DnsApi* | [**getDnsDomainSoa**](doc//DnsApi.md#getdnsdomainsoa) | **GET** /domains/{dns-domain}/soa | Get SOA information
*DnsApi* | [**listDnsDomainRecords**](doc//DnsApi.md#listdnsdomainrecords) | **GET** /domains/{dns-domain}/records | List Records
*DnsApi* | [**listDnsDomains**](doc//DnsApi.md#listdnsdomains) | **GET** /domains | List DNS Domains
*DnsApi* | [**updateDnsDomain**](doc//DnsApi.md#updatednsdomain) | **PUT** /domains/{dns-domain} | Update a DNS Domain
*DnsApi* | [**updateDnsDomainRecord**](doc//DnsApi.md#updatednsdomainrecord) | **PATCH** /domains/{dns-domain}/records/{record-id} | Update Record
*DnsApi* | [**updateDnsDomainSoa**](doc//DnsApi.md#updatednsdomainsoa) | **PATCH** /domains/{dns-domain}/soa | Update SOA information
*FirewallApi* | [**createFirewallGroup**](doc//FirewallApi.md#createfirewallgroup) | **POST** /firewalls | Create Firewall Group
*FirewallApi* | [**deleteFirewallGroup**](doc//FirewallApi.md#deletefirewallgroup) | **DELETE** /firewalls/{firewall-group-id} | Delete Firewall Group
*FirewallApi* | [**deleteFirewallGroupRule**](doc//FirewallApi.md#deletefirewallgrouprule) | **DELETE** /firewalls/{firewall-group-id}/rules/{firewall-rule-id} | Delete Firewall Rule
*FirewallApi* | [**getFirewallGroup**](doc//FirewallApi.md#getfirewallgroup) | **GET** /firewalls/{firewall-group-id} | Get Firewall Group
*FirewallApi* | [**getFirewallGroupRule**](doc//FirewallApi.md#getfirewallgrouprule) | **GET** /firewalls/{firewall-group-id}/rules/{firewall-rule-id} | Get Firewall Rule
*FirewallApi* | [**listFirewallGroupRules**](doc//FirewallApi.md#listfirewallgrouprules) | **GET** /firewalls/{firewall-group-id}/rules | List Firewall Rules
*FirewallApi* | [**listFirewallGroups**](doc//FirewallApi.md#listfirewallgroups) | **GET** /firewalls | List Firewall Groups
*FirewallApi* | [**postFirewallsFirewallGroupIdRules**](doc//FirewallApi.md#postfirewallsfirewallgroupidrules) | **POST** /firewalls/{firewall-group-id}/rules | Create Firewall Rules
*FirewallApi* | [**updateFirewallGroup**](doc//FirewallApi.md#updatefirewallgroup) | **PUT** /firewalls/{firewall-group-id} | Update Firewall Group
*InstancesApi* | [**attachInstanceIso**](doc//InstancesApi.md#attachinstanceiso) | **POST** /instances/{instance-id}/iso/attach | Attach ISO to Instance
*InstancesApi* | [**attachInstanceNetwork**](doc//InstancesApi.md#attachinstancenetwork) | **POST** /instances/{instance-id}/private-networks/attach | Attach Private Network to Instance
*InstancesApi* | [**attachInstanceVpc**](doc//InstancesApi.md#attachinstancevpc) | **POST** /instances/{instance-id}/vpcs/attach | Attach VPC to Instance
*InstancesApi* | [**attachInstanceVpc2**](doc//InstancesApi.md#attachinstancevpc2) | **POST** /instances/{instance-id}/vpc2/attach | Attach VPC 2.0 Network to Instance
*InstancesApi* | [**createInstance**](doc//InstancesApi.md#createinstance) | **POST** /instances | Create Instance
*InstancesApi* | [**createInstanceBackupSchedule**](doc//InstancesApi.md#createinstancebackupschedule) | **POST** /instances/{instance-id}/backup-schedule | Set Instance Backup Schedule
*InstancesApi* | [**createInstanceIpv4**](doc//InstancesApi.md#createinstanceipv4) | **POST** /instances/{instance-id}/ipv4 | Create IPv4
*InstancesApi* | [**createInstanceReverseIpv4**](doc//InstancesApi.md#createinstancereverseipv4) | **POST** /instances/{instance-id}/ipv4/reverse | Create Instance Reverse IPv4
*InstancesApi* | [**createInstanceReverseIpv6**](doc//InstancesApi.md#createinstancereverseipv6) | **POST** /instances/{instance-id}/ipv6/reverse | Create Instance Reverse IPv6
*InstancesApi* | [**deleteInstance**](doc//InstancesApi.md#deleteinstance) | **DELETE** /instances/{instance-id} | Delete Instance
*InstancesApi* | [**deleteInstanceIpv4**](doc//InstancesApi.md#deleteinstanceipv4) | **DELETE** /instances/{instance-id}/ipv4/{ipv4} | Delete IPv4 Address
*InstancesApi* | [**deleteInstanceReverseIpv6**](doc//InstancesApi.md#deleteinstancereverseipv6) | **DELETE** /instances/{instance-id}/ipv6/reverse/{ipv6} | Delete Instance Reverse IPv6
*InstancesApi* | [**detachInstanceIso**](doc//InstancesApi.md#detachinstanceiso) | **POST** /instances/{instance-id}/iso/detach | Detach ISO from instance
*InstancesApi* | [**detachInstanceNetwork**](doc//InstancesApi.md#detachinstancenetwork) | **POST** /instances/{instance-id}/private-networks/detach | Detach Private Network from Instance.
*InstancesApi* | [**detachInstanceVpc**](doc//InstancesApi.md#detachinstancevpc) | **POST** /instances/{instance-id}/vpcs/detach | Detach VPC from Instance
*InstancesApi* | [**detachInstanceVpc2**](doc//InstancesApi.md#detachinstancevpc2) | **POST** /instances/{instance-id}/vpc2/detach | Detach VPC 2.0 Network from Instance
*InstancesApi* | [**getInstance**](doc//InstancesApi.md#getinstance) | **GET** /instances/{instance-id} | Get Instance
*InstancesApi* | [**getInstanceBackupSchedule**](doc//InstancesApi.md#getinstancebackupschedule) | **GET** /instances/{instance-id}/backup-schedule | Get Instance Backup Schedule
*InstancesApi* | [**getInstanceBandwidth**](doc//InstancesApi.md#getinstancebandwidth) | **GET** /instances/{instance-id}/bandwidth | Instance Bandwidth
*InstancesApi* | [**getInstanceIpv4**](doc//InstancesApi.md#getinstanceipv4) | **GET** /instances/{instance-id}/ipv4 | List Instance IPv4 Information
*InstancesApi* | [**getInstanceIpv6**](doc//InstancesApi.md#getinstanceipv6) | **GET** /instances/{instance-id}/ipv6 | Get Instance IPv6 Information
*InstancesApi* | [**getInstanceIsoStatus**](doc//InstancesApi.md#getinstanceisostatus) | **GET** /instances/{instance-id}/iso | Get Instance ISO Status
*InstancesApi* | [**getInstanceJob**](doc//InstancesApi.md#getinstancejob) | **GET** /instances/jobs/{job-id} | Get Instance Job
*InstancesApi* | [**getInstanceNeighbors**](doc//InstancesApi.md#getinstanceneighbors) | **GET** /instances/{instance-id}/neighbors | Get Instance neighbors
*InstancesApi* | [**getInstanceUpgrades**](doc//InstancesApi.md#getinstanceupgrades) | **GET** /instances/{instance-id}/upgrades | Get Available Instance Upgrades
*InstancesApi* | [**getInstanceUserdata**](doc//InstancesApi.md#getinstanceuserdata) | **GET** /instances/{instance-id}/user-data | Get Instance User Data
*InstancesApi* | [**haltInstance**](doc//InstancesApi.md#haltinstance) | **POST** /instances/{instance-id}/halt | Halt Instance
*InstancesApi* | [**haltInstances**](doc//InstancesApi.md#haltinstances) | **POST** /instances/halt | Halt Instances
*InstancesApi* | [**listInstanceIpv6Reverse**](doc//InstancesApi.md#listinstanceipv6reverse) | **GET** /instances/{instance-id}/ipv6/reverse | List Instance IPv6 Reverse
*InstancesApi* | [**listInstancePrivateNetworks**](doc//InstancesApi.md#listinstanceprivatenetworks) | **GET** /instances/{instance-id}/private-networks | List instance Private Networks
*InstancesApi* | [**listInstanceVpc2**](doc//InstancesApi.md#listinstancevpc2) | **GET** /instances/{instance-id}/vpc2 | List Instance VPC 2.0 Networks
*InstancesApi* | [**listInstanceVpcs**](doc//InstancesApi.md#listinstancevpcs) | **GET** /instances/{instance-id}/vpcs | List instance VPCs
*InstancesApi* | [**listInstances**](doc//InstancesApi.md#listinstances) | **GET** /instances | List Instances
*InstancesApi* | [**postInstancesInstanceIdIpv4ReverseDefault**](doc//InstancesApi.md#postinstancesinstanceidipv4reversedefault) | **POST** /instances/{instance-id}/ipv4/reverse/default | Set Default Reverse DNS Entry
*InstancesApi* | [**rebootInstance**](doc//InstancesApi.md#rebootinstance) | **POST** /instances/{instance-id}/reboot | Reboot Instance
*InstancesApi* | [**rebootInstances**](doc//InstancesApi.md#rebootinstances) | **POST** /instances/reboot | Reboot instances
*InstancesApi* | [**reinstallInstance**](doc//InstancesApi.md#reinstallinstance) | **POST** /instances/{instance-id}/reinstall | Reinstall Instance
*InstancesApi* | [**restoreInstance**](doc//InstancesApi.md#restoreinstance) | **POST** /instances/{instance-id}/restore | Restore Instance
*InstancesApi* | [**startInstance**](doc//InstancesApi.md#startinstance) | **POST** /instances/{instance-id}/start | Start instance
*InstancesApi* | [**startInstances**](doc//InstancesApi.md#startinstances) | **POST** /instances/start | Start instances
*InstancesApi* | [**updateInstance**](doc//InstancesApi.md#updateinstance) | **PATCH** /instances/{instance-id} | Update Instance
*IsoApi* | [**createIso**](doc//IsoApi.md#createiso) | **POST** /iso | Create ISO
*IsoApi* | [**deleteIso**](doc//IsoApi.md#deleteiso) | **DELETE** /iso/{iso-id} | Delete ISO
*IsoApi* | [**isoGet**](doc//IsoApi.md#isoget) | **GET** /iso/{iso-id} | Get ISO
*IsoApi* | [**listIsos**](doc//IsoApi.md#listisos) | **GET** /iso | List ISOs
*IsoApi* | [**listPublicIsos**](doc//IsoApi.md#listpublicisos) | **GET** /iso-public | List Public ISOs
*KubernetesApi* | [**createKubernetesCluster**](doc//KubernetesApi.md#createkubernetescluster) | **POST** /kubernetes/clusters | Create Kubernetes Cluster
*KubernetesApi* | [**createNodepoolLabel**](doc//KubernetesApi.md#createnodepoollabel) | **POST** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels | Create NodePool Label
*KubernetesApi* | [**createNodepoolTaint**](doc//KubernetesApi.md#createnodepooltaint) | **POST** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints | Create NodePool Taint
*KubernetesApi* | [**createNodepools**](doc//KubernetesApi.md#createnodepools) | **POST** /kubernetes/clusters/{vke-id}/node-pools | Create NodePool
*KubernetesApi* | [**deleteKubernetesCluster**](doc//KubernetesApi.md#deletekubernetescluster) | **DELETE** /kubernetes/clusters/{vke-id} | Delete Kubernetes Cluster
*KubernetesApi* | [**deleteKubernetesClusterVkeIdDeleteWithLinkedResources**](doc//KubernetesApi.md#deletekubernetesclustervkeiddeletewithlinkedresources) | **DELETE** /kubernetes/clusters/{vke-id}/delete-with-linked-resources | Delete VKE Cluster and All Related Resources
*KubernetesApi* | [**deleteNodepool**](doc//KubernetesApi.md#deletenodepool) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id} | Delete Nodepool
*KubernetesApi* | [**deleteNodepoolInstance**](doc//KubernetesApi.md#deletenodepoolinstance) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/nodes/{node-id} | Delete NodePool Instance
*KubernetesApi* | [**deleteNodepoolLabel**](doc//KubernetesApi.md#deletenodepoollabel) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels/{label-id} | Delete NodePool Label
*KubernetesApi* | [**deleteNodepoolTaint**](doc//KubernetesApi.md#deletenodepooltaint) | **DELETE** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints/{taint-id} | Delete NodePool Taint
*KubernetesApi* | [**getKubernetesAvailableUpgrades**](doc//KubernetesApi.md#getkubernetesavailableupgrades) | **GET** /kubernetes/clusters/{vke-id}/available-upgrades | Get Kubernetes Available Upgrades
*KubernetesApi* | [**getKubernetesClusters**](doc//KubernetesApi.md#getkubernetesclusters) | **GET** /kubernetes/clusters/{vke-id} | Get Kubernetes Cluster
*KubernetesApi* | [**getKubernetesClustersConfig**](doc//KubernetesApi.md#getkubernetesclustersconfig) | **GET** /kubernetes/clusters/{vke-id}/config | Get Kubernetes Cluster Kubeconfig
*KubernetesApi* | [**getKubernetesResources**](doc//KubernetesApi.md#getkubernetesresources) | **GET** /kubernetes/clusters/{vke-id}/resources | Get Kubernetes Resources
*KubernetesApi* | [**getKubernetesVersions**](doc//KubernetesApi.md#getkubernetesversions) | **GET** /kubernetes/versions | Get Kubernetes Versions
*KubernetesApi* | [**getNodepool**](doc//KubernetesApi.md#getnodepool) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id} | Get NodePool
*KubernetesApi* | [**getNodepools**](doc//KubernetesApi.md#getnodepools) | **GET** /kubernetes/clusters/{vke-id}/node-pools | List NodePools
*KubernetesApi* | [**listKubernetesClusters**](doc//KubernetesApi.md#listkubernetesclusters) | **GET** /kubernetes/clusters | List all Kubernetes Clusters
*KubernetesApi* | [**listNodepoolLabels**](doc//KubernetesApi.md#listnodepoollabels) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels | List NodePool Labels
*KubernetesApi* | [**listNodepoolTaints**](doc//KubernetesApi.md#listnodepooltaints) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints | List NodePool Taints
*KubernetesApi* | [**readNodepoolLabel**](doc//KubernetesApi.md#readnodepoollabel) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/labels/{label-id} | Read NodePool Label
*KubernetesApi* | [**readNodepoolTaint**](doc//KubernetesApi.md#readnodepooltaint) | **GET** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/taints/{taint-id} | Read NodePool Taint
*KubernetesApi* | [**recycleNodepoolInstance**](doc//KubernetesApi.md#recyclenodepoolinstance) | **POST** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id}/nodes/{node-id}/recycle | Recycle a NodePool Instance
*KubernetesApi* | [**startKubernetesClusterUpgrade**](doc//KubernetesApi.md#startkubernetesclusterupgrade) | **POST** /kubernetes/clusters/{vke-id}/upgrades | Start Kubernetes Cluster Upgrade
*KubernetesApi* | [**updateKubernetesCluster**](doc//KubernetesApi.md#updatekubernetescluster) | **PUT** /kubernetes/clusters/{vke-id} | Update Kubernetes Cluster
*KubernetesApi* | [**updateNodepool**](doc//KubernetesApi.md#updatenodepool) | **PATCH** /kubernetes/clusters/{vke-id}/node-pools/{nodepool-id} | Update Nodepool
*LoadBalancerApi* | [**createLoadBalancer**](doc//LoadBalancerApi.md#createloadbalancer) | **POST** /load-balancers | Create Load Balancer
*LoadBalancerApi* | [**createLoadBalancerForwardingRules**](doc//LoadBalancerApi.md#createloadbalancerforwardingrules) | **POST** /load-balancers/{load-balancer-id}/forwarding-rules | Create Forwarding Rule
*LoadBalancerApi* | [**createLoadBalancerReverseDnsIpv4**](doc//LoadBalancerApi.md#createloadbalancerreversednsipv4) | **PUT** /load-balancers/{load-balancer-id}/reverse-dns | Update Reverse DNS IPV4
*LoadBalancerApi* | [**createLoadBalancerReverseDnsIpv6**](doc//LoadBalancerApi.md#createloadbalancerreversednsipv6) | **POST** /load-balancers/{load-balancer-id}/reverse-dns | Create Reverse DNS IPV6
*LoadBalancerApi* | [**deleteLoadBalancer**](doc//LoadBalancerApi.md#deleteloadbalancer) | **DELETE** /load-balancers/{load-balancer-id} | Delete Load Balancer
*LoadBalancerApi* | [**deleteLoadBalancerAutoSsl**](doc//LoadBalancerApi.md#deleteloadbalancerautossl) | **DELETE** /load-balancers/{load-balancer-id}/auto_ssl | Disable Load Balancer Auto SSL
*LoadBalancerApi* | [**deleteLoadBalancerForwardingRule**](doc//LoadBalancerApi.md#deleteloadbalancerforwardingrule) | **DELETE** /load-balancers/{load-balancer-id}/forwarding-rules/{forwarding-rule-id} | Delete Forwarding Rule
*LoadBalancerApi* | [**deleteLoadBalancerReverseDns**](doc//LoadBalancerApi.md#deleteloadbalancerreversedns) | **DELETE** /load-balancers/{load-balancer-id}/reverse-dns | Delete Reverse DNS
*LoadBalancerApi* | [**deleteLoadBalancerSsl**](doc//LoadBalancerApi.md#deleteloadbalancerssl) | **DELETE** /load-balancers/{load-balancer-id}/ssl | Delete Load Balancer SSL
*LoadBalancerApi* | [**getLoadBalancer**](doc//LoadBalancerApi.md#getloadbalancer) | **GET** /load-balancers/{load-balancer-id} | Get Load Balancer
*LoadBalancerApi* | [**getLoadBalancerForwardingRule**](doc//LoadBalancerApi.md#getloadbalancerforwardingrule) | **GET** /load-balancers/{load-balancer-id}/forwarding-rules/{forwarding-rule-id} | Get Forwarding Rule
*LoadBalancerApi* | [**getLoadBalancerReverseDns**](doc//LoadBalancerApi.md#getloadbalancerreversedns) | **GET** /load-balancers/{load-balancer-id}/reverse-dns | Get Reverse DNS
*LoadBalancerApi* | [**getLoadbalancerFirewallRule**](doc//LoadBalancerApi.md#getloadbalancerfirewallrule) | **GET** /load-balancers/{loadbalancer-id}/firewall-rules/{firewall-rule-id} | Get Firewall Rule
*LoadBalancerApi* | [**listLoadBalancerForwardingRules**](doc//LoadBalancerApi.md#listloadbalancerforwardingrules) | **GET** /load-balancers/{load-balancer-id}/forwarding-rules | List Forwarding Rules
*LoadBalancerApi* | [**listLoadBalancers**](doc//LoadBalancerApi.md#listloadbalancers) | **GET** /load-balancers | List Load Balancers
*LoadBalancerApi* | [**listLoadbalancerFirewallRules**](doc//LoadBalancerApi.md#listloadbalancerfirewallrules) | **GET** /load-balancers/{loadbalancer-id}/firewall-rules | List Firewall Rules
*LoadBalancerApi* | [**updateLoadBalancer**](doc//LoadBalancerApi.md#updateloadbalancer) | **PATCH** /load-balancers/{load-balancer-id} | Update Load Balancer
*LogsApi* | [**listLogs**](doc//LogsApi.md#listlogs) | **GET** /logs | List Logs
*MarketplaceApi* | [**listMarketplaceAppVariables**](doc//MarketplaceApi.md#listmarketplaceappvariables) | **GET** /marketplace/apps/{image-id}/variables | List Marketplace App Variables
*OsApi* | [**listOs**](doc//OsApi.md#listos) | **GET** /os | List OS
*PlansApi* | [**listMetalPlans**](doc//PlansApi.md#listmetalplans) | **GET** /plans-metal | List Bare Metal Plans
*PlansApi* | [**listPlans**](doc//PlansApi.md#listplans) | **GET** /plans | List Plans
*PrivateNetworksApi* | [**createNetwork**](doc//PrivateNetworksApi.md#createnetwork) | **POST** /private-networks | Create a Private Network
*PrivateNetworksApi* | [**deleteNetwork**](doc//PrivateNetworksApi.md#deletenetwork) | **DELETE** /private-networks/{network-id} | Delete a private network
*PrivateNetworksApi* | [**getNetwork**](doc//PrivateNetworksApi.md#getnetwork) | **GET** /private-networks/{network-id} | Get a private network
*PrivateNetworksApi* | [**listNetworks**](doc//PrivateNetworksApi.md#listnetworks) | **GET** /private-networks | List Private Networks
*PrivateNetworksApi* | [**updateNetwork**](doc//PrivateNetworksApi.md#updatenetwork) | **PUT** /private-networks/{network-id} | Update a Private Network
*RegionApi* | [**listAvailablePlansRegion**](doc//RegionApi.md#listavailableplansregion) | **GET** /regions/{region-id}/availability | List available plans in region
*RegionApi* | [**listRegions**](doc//RegionApi.md#listregions) | **GET** /regions | List Regions
*ReservedIpApi* | [**attachReservedIp**](doc//ReservedIpApi.md#attachreservedip) | **POST** /reserved-ips/{reserved-ip}/attach | Attach Reserved IP
*ReservedIpApi* | [**convertReservedIp**](doc//ReservedIpApi.md#convertreservedip) | **POST** /reserved-ips/convert | Convert Instance IP to Reserved IP
*ReservedIpApi* | [**createReservedIp**](doc//ReservedIpApi.md#createreservedip) | **POST** /reserved-ips | Create Reserved IP
*ReservedIpApi* | [**deleteReservedIp**](doc//ReservedIpApi.md#deletereservedip) | **DELETE** /reserved-ips/{reserved-ip} | Delete Reserved IP
*ReservedIpApi* | [**detachReservedIp**](doc//ReservedIpApi.md#detachreservedip) | **POST** /reserved-ips/{reserved-ip}/detach | Detach Reserved IP
*ReservedIpApi* | [**getReservedIp**](doc//ReservedIpApi.md#getreservedip) | **GET** /reserved-ips/{reserved-ip} | Get Reserved IP
*ReservedIpApi* | [**listReservedIps**](doc//ReservedIpApi.md#listreservedips) | **GET** /reserved-ips | List Reserved IPs
*ReservedIpApi* | [**patchReservedIpsReservedIp**](doc//ReservedIpApi.md#patchreservedipsreservedip) | **PATCH** /reserved-ips/{reserved-ip} | Update Reserved IP
*S3Api* | [**createObjectStorage**](doc//S3Api.md#createobjectstorage) | **POST** /object-storage | Create Object Storage
*S3Api* | [**deleteObjectStorage**](doc//S3Api.md#deleteobjectstorage) | **DELETE** /object-storage/{object-storage-id} | Delete Object Storage
*S3Api* | [**getObjectStorage**](doc//S3Api.md#getobjectstorage) | **GET** /object-storage/{object-storage-id} | Get Object Storage
*S3Api* | [**listObjectStorageClusterTiers**](doc//S3Api.md#listobjectstorageclustertiers) | **GET** /object-storage/clusters/{cluster-id}/tiers | Get All Cluster Tiers
*S3Api* | [**listObjectStorageClusters**](doc//S3Api.md#listobjectstorageclusters) | **GET** /object-storage/clusters | Get All Clusters
*S3Api* | [**listObjectStorageTiers**](doc//S3Api.md#listobjectstoragetiers) | **GET** /object-storage/tiers | Get All Tiers
*S3Api* | [**listObjectStorages**](doc//S3Api.md#listobjectstorages) | **GET** /object-storage | List Object Storages
*S3Api* | [**regenerateObjectStorageKeys**](doc//S3Api.md#regenerateobjectstoragekeys) | **POST** /object-storage/{object-storage-id}/regenerate-keys | Regenerate Object Storage Keys
*S3Api* | [**updateObjectStorage**](doc//S3Api.md#updateobjectstorage) | **PUT** /object-storage/{object-storage-id} | Update Object Storage
*ServerlessInferenceApi* | [**createInference**](doc//ServerlessInferenceApi.md#createinference) | **POST** /inference | Create Serverless Inference
*ServerlessInferenceApi* | [**deleteInference**](doc//ServerlessInferenceApi.md#deleteinference) | **DELETE** /inference/{inference-id} | Delete Serverless Inference
*ServerlessInferenceApi* | [**getInference**](doc//ServerlessInferenceApi.md#getinference) | **GET** /inference/{inference-id} | Get Serverless Inference
*ServerlessInferenceApi* | [**getInferenceUsage**](doc//ServerlessInferenceApi.md#getinferenceusage) | **GET** /inference/{inference-id}/usage | Get Serverless Inference Usage Information
*ServerlessInferenceApi* | [**listInference**](doc//ServerlessInferenceApi.md#listinference) | **GET** /inference | List Serverless Inference
*ServerlessInferenceApi* | [**updateInference**](doc//ServerlessInferenceApi.md#updateinference) | **PATCH** /inference/{inference-id} | Update Serverless Inference
*SnapshotApi* | [**createSnapshot**](doc//SnapshotApi.md#createsnapshot) | **POST** /snapshots | Create Snapshot
*SnapshotApi* | [**createSnapshotCreateFromUrl**](doc//SnapshotApi.md#createsnapshotcreatefromurl) | **POST** /snapshots/create-from-url | Create Snapshot from URL
*SnapshotApi* | [**deleteSnapshot**](doc//SnapshotApi.md#deletesnapshot) | **DELETE** /snapshots/{snapshot-id} | Delete Snapshot
*SnapshotApi* | [**getSnapshot**](doc//SnapshotApi.md#getsnapshot) | **GET** /snapshots/{snapshot-id} | Get Snapshot
*SnapshotApi* | [**listSnapshots**](doc//SnapshotApi.md#listsnapshots) | **GET** /snapshots | List Snapshots
*SnapshotApi* | [**putSnapshotsSnapshotId**](doc//SnapshotApi.md#putsnapshotssnapshotid) | **PUT** /snapshots/{snapshot-id} | Update Snapshot
*SshApi* | [**createSshKey**](doc//SshApi.md#createsshkey) | **POST** /ssh-keys | Create SSH key
*SshApi* | [**deleteSshKey**](doc//SshApi.md#deletesshkey) | **DELETE** /ssh-keys/{ssh-key-id} | Delete SSH Key
*SshApi* | [**getSshKey**](doc//SshApi.md#getsshkey) | **GET** /ssh-keys/{ssh-key-id} | Get SSH Key
*SshApi* | [**listSshKeys**](doc//SshApi.md#listsshkeys) | **GET** /ssh-keys | List SSH Keys
*SshApi* | [**updateSshKey**](doc//SshApi.md#updatesshkey) | **PATCH** /ssh-keys/{ssh-key-id} | Update SSH Key
*StartupApi* | [**createStartupScript**](doc//StartupApi.md#createstartupscript) | **POST** /startup-scripts | Create Startup Script
*StartupApi* | [**deleteStartupScript**](doc//StartupApi.md#deletestartupscript) | **DELETE** /startup-scripts/{startup-id} | Delete Startup Script
*StartupApi* | [**getStartupScript**](doc//StartupApi.md#getstartupscript) | **GET** /startup-scripts/{startup-id} | Get Startup Script
*StartupApi* | [**listStartupScripts**](doc//StartupApi.md#liststartupscripts) | **GET** /startup-scripts | List Startup Scripts
*StartupApi* | [**updateStartupScript**](doc//StartupApi.md#updatestartupscript) | **PATCH** /startup-scripts/{startup-id} | Update Startup Script
*StorageGatewaysApi* | [**addStorageGatewayExport**](doc//StorageGatewaysApi.md#addstoragegatewayexport) | **POST** /storage-gateways/{storage-gateway-id}/exports | Add a new export to this storage gateway
*StorageGatewaysApi* | [**createStorageGateway**](doc//StorageGatewaysApi.md#createstoragegateway) | **POST** /storage-gateways | Create Storage Gateway
*StorageGatewaysApi* | [**deleteStorageGateway**](doc//StorageGatewaysApi.md#deletestoragegateway) | **DELETE** /storage-gateways/{storage-gateway-id} | Delete Storage Gateway
*StorageGatewaysApi* | [**deleteStorageGatewayExport**](doc//StorageGatewaysApi.md#deletestoragegatewayexport) | **DELETE** /storage-gateways/{storage-gateway-id}/exports/{export-id} | Delete Storage Gateway Export
*StorageGatewaysApi* | [**getStorageGateway**](doc//StorageGatewaysApi.md#getstoragegateway) | **GET** /storage-gateways/{storage-gateway-id} | Get Storage Gateway
*StorageGatewaysApi* | [**listStorageGateways**](doc//StorageGatewaysApi.md#liststoragegateways) | **GET** /storage-gateways | List storage gateways
*StorageGatewaysApi* | [**updateStorageGateway**](doc//StorageGatewaysApi.md#updatestoragegateway) | **PUT** /storage-gateways/{storage-gateway-id} | Update Storage Gateway
*SubaccountApi* | [**createSubaccount**](doc//SubaccountApi.md#createsubaccount) | **POST** /subaccounts | Create Sub-Account
*SubaccountApi* | [**listSubaccounts**](doc//SubaccountApi.md#listsubaccounts) | **GET** /subaccounts | List Sub-Accounts
*UsersApi* | [**addUserIpWhitelist**](doc//UsersApi.md#adduseripwhitelist) | **POST** /users/{user-id}/ip-whitelist | Add IP to User Whitelist
*UsersApi* | [**createUser**](doc//UsersApi.md#createuser) | **POST** /users | Create User
*UsersApi* | [**createUserApiKey**](doc//UsersApi.md#createuserapikey) | **POST** /users/{user-id}/apikeys | Create User API Key
*UsersApi* | [**deleteUser**](doc//UsersApi.md#deleteuser) | **DELETE** /users/{user-id} | Delete User
*UsersApi* | [**deleteUserApiKey**](doc//UsersApi.md#deleteuserapikey) | **DELETE** /users/{user-id}/apikeys/{apikey-id} | Delete User API Key
*UsersApi* | [**getUser**](doc//UsersApi.md#getuser) | **GET** /users/{user-id} | Get User
*UsersApi* | [**getUserApiKey**](doc//UsersApi.md#getuserapikey) | **GET** /users/{user-id}/apikeys/{apikey-id} | Get User API Key
*UsersApi* | [**getUserIpWhitelistEntry**](doc//UsersApi.md#getuseripwhitelistentry) | **GET** /users/{user-id}/ip-whitelist/entry | Get User IP Whitelist Entry
*UsersApi* | [**listUserApiKeys**](doc//UsersApi.md#listuserapikeys) | **GET** /users/{user-id}/apikeys | List User API Keys
*UsersApi* | [**listUserIpWhitelist**](doc//UsersApi.md#listuseripwhitelist) | **GET** /users/{user-id}/ip-whitelist | List User IP Whitelist
*UsersApi* | [**listUsers**](doc//UsersApi.md#listusers) | **GET** /users | Get Users
*UsersApi* | [**removeUserIpWhitelist**](doc//UsersApi.md#removeuseripwhitelist) | **DELETE** /users/{user-id}/ip-whitelist | Remove IP from User Whitelist
*UsersApi* | [**updateUser**](doc//UsersApi.md#updateuser) | **PATCH** /users/{user-id} | Update User
*VFSApi* | [**createVFS**](doc//VFSApi.md#createvfs) | **POST** /vfs | Create VFS
*VFSApi* | [**createVFSAttachment**](doc//VFSApi.md#createvfsattachment) | **PUT** /vfs/{vfs_id}/attachments/{vps_id} | Attach VPS Instance to VFS
*VFSApi* | [**deleteVFS**](doc//VFSApi.md#deletevfs) | **DELETE** /vfs/{vfs_id} | Delete VFS
*VFSApi* | [**deleteVFSAttachment**](doc//VFSApi.md#deletevfsattachment) | **DELETE** /vfs/{vfs_id}/attachments/{vps_id} | Delete VFS Attachment
*VFSApi* | [**getVFS**](doc//VFSApi.md#getvfs) | **GET** /vfs/{vfs_id} | Get VFS
*VFSApi* | [**getVFSAttachment**](doc//VFSApi.md#getvfsattachment) | **GET** /vfs/{vfs_id}/attachments/{vps_id} | Get VFS Attachment
*VFSApi* | [**listRegions**](doc//VFSApi.md#listregions) | **GET** /vfs/regions | List VFS Regions
*VFSApi* | [**listVFS**](doc//VFSApi.md#listvfs) | **GET** /vfs | List VFSs
*VFSApi* | [**listVFSAttachments**](doc//VFSApi.md#listvfsattachments) | **GET** /vfs/{vfs_id}/attachments | List VFS Attachments
*VFSApi* | [**updateVFS**](doc//VFSApi.md#updatevfs) | **PUT** /vfs/{vfs_id} | Update VFS
*VPC2Api* | [**attachVpc2Nodes**](doc//VPC2Api.md#attachvpc2nodes) | **POST** /vpc2/{vpc-id}/nodes/attach | Attach nodes to a VPC 2.0 network
*VPC2Api* | [**createVpc2**](doc//VPC2Api.md#createvpc2) | **POST** /vpc2 | Create a VPC 2.0 network
*VPC2Api* | [**deleteVpc2**](doc//VPC2Api.md#deletevpc2) | **DELETE** /vpc2/{vpc-id} | Delete a VPC 2.0 network
*VPC2Api* | [**detachVpc2Nodes**](doc//VPC2Api.md#detachvpc2nodes) | **POST** /vpc2/{vpc-id}/nodes/detach | Remove nodes from a VPC 2.0 network
*VPC2Api* | [**getVpc2**](doc//VPC2Api.md#getvpc2) | **GET** /vpc2/{vpc-id} | Get a VPC 2.0 network
*VPC2Api* | [**listVpc2**](doc//VPC2Api.md#listvpc2) | **GET** /vpc2 | List VPC 2.0 networks
*VPC2Api* | [**listVpc2Nodes**](doc//VPC2Api.md#listvpc2nodes) | **GET** /vpc2/{vpc-id}/nodes | Get a list of nodes attached to a VPC 2.0 network
*VPC2Api* | [**updateVpc2**](doc//VPC2Api.md#updatevpc2) | **PUT** /vpc2/{vpc-id} | Update a VPC 2.0 network
*VPCsApi* | [**createVpc**](doc//VPCsApi.md#createvpc) | **POST** /vpcs | Create a VPC
*VPCsApi* | [**deleteVpc**](doc//VPCsApi.md#deletevpc) | **DELETE** /vpcs/{vpc-id} | Delete a VPC
*VPCsApi* | [**getVpc**](doc//VPCsApi.md#getvpc) | **GET** /vpcs/{vpc-id} | Get a VPC
*VPCsApi* | [**listVpcAttachments**](doc//VPCsApi.md#listvpcattachments) | **GET** /vpcs/{vpc-id}/attachments | List VPC Attachments
*VPCsApi* | [**listVpcs**](doc//VPCsApi.md#listvpcs) | **GET** /vpcs | List VPCs
*VPCsApi* | [**updateVpc**](doc//VPCsApi.md#updatevpc) | **PUT** /vpcs/{vpc-id} | Update a VPC


## Documentation For Models

 - [Account](doc//Account.md)
 - [AccountBandwidth](doc//AccountBandwidth.md)
 - [AccountBandwidthCurrentMonthProjected](doc//AccountBandwidthCurrentMonthProjected.md)
 - [AccountBandwidthCurrentMonthToDate](doc//AccountBandwidthCurrentMonthToDate.md)
 - [AccountBandwidthPreviousMonth](doc//AccountBandwidthPreviousMonth.md)
 - [AccountBgp](doc//AccountBgp.md)
 - [AddStorageGatewayExport200Response](doc//AddStorageGatewayExport200Response.md)
 - [AddUserIpWhitelistRequest](doc//AddUserIpWhitelistRequest.md)
 - [Apikey](doc//Apikey.md)
 - [AppVariable](doc//AppVariable.md)
 - [Application](doc//Application.md)
 - [AttachBaremetalsVpc2Request](doc//AttachBaremetalsVpc2Request.md)
 - [AttachBaremetalsVpcsRequest](doc//AttachBaremetalsVpcsRequest.md)
 - [AttachBlockRequest](doc//AttachBlockRequest.md)
 - [AttachInstanceIso202Response](doc//AttachInstanceIso202Response.md)
 - [AttachInstanceIso202ResponseIsoStatus](doc//AttachInstanceIso202ResponseIsoStatus.md)
 - [AttachInstanceIsoRequest](doc//AttachInstanceIsoRequest.md)
 - [AttachInstanceNetworkRequest](doc//AttachInstanceNetworkRequest.md)
 - [AttachInstanceVpc2Request](doc//AttachInstanceVpc2Request.md)
 - [AttachInstanceVpcRequest](doc//AttachInstanceVpcRequest.md)
 - [AttachReservedIpRequest](doc//AttachReservedIpRequest.md)
 - [AttachVpc2NodesRequest](doc//AttachVpc2NodesRequest.md)
 - [AttachedVpcs](doc//AttachedVpcs.md)
 - [Backup](doc//Backup.md)
 - [BackupSchedule](doc//BackupSchedule.md)
 - [Bandwidth](doc//Bandwidth.md)
 - [Baremetal](doc//Baremetal.md)
 - [BaremetalGet](doc//BaremetalGet.md)
 - [BaremetalIpv4](doc//BaremetalIpv4.md)
 - [BaremetalIpv6](doc//BaremetalIpv6.md)
 - [Billing](doc//Billing.md)
 - [Blockstorage](doc//Blockstorage.md)
 - [ClusterTiers](doc//ClusterTiers.md)
 - [Clusters](doc//Clusters.md)
 - [ConvertReservedIpRequest](doc//ConvertReservedIpRequest.md)
 - [CreateBaremetal202Response](doc//CreateBaremetal202Response.md)
 - [CreateBaremetalRequest](doc//CreateBaremetalRequest.md)
 - [CreateBaremetalReverseIpv4Request](doc//CreateBaremetalReverseIpv4Request.md)
 - [CreateBaremetalReverseIpv6Request](doc//CreateBaremetalReverseIpv6Request.md)
 - [CreateBlock202Response](doc//CreateBlock202Response.md)
 - [CreateBlockRequest](doc//CreateBlockRequest.md)
 - [CreateDnsDomain200Response](doc//CreateDnsDomain200Response.md)
 - [CreateDnsDomainRecord201Response](doc//CreateDnsDomainRecord201Response.md)
 - [CreateDnsDomainRecordRequest](doc//CreateDnsDomainRecordRequest.md)
 - [CreateDnsDomainRequest](doc//CreateDnsDomainRequest.md)
 - [CreateFirewallGroup201Response](doc//CreateFirewallGroup201Response.md)
 - [CreateFirewallGroupRequest](doc//CreateFirewallGroupRequest.md)
 - [CreateInference201Response](doc//CreateInference201Response.md)
 - [CreateInferenceRequest](doc//CreateInferenceRequest.md)
 - [CreateInstance202Response](doc//CreateInstance202Response.md)
 - [CreateInstanceBackupScheduleRequest](doc//CreateInstanceBackupScheduleRequest.md)
 - [CreateInstanceIpv4Request](doc//CreateInstanceIpv4Request.md)
 - [CreateInstanceRequest](doc//CreateInstanceRequest.md)
 - [CreateIso201Response](doc//CreateIso201Response.md)
 - [CreateIsoRequest](doc//CreateIsoRequest.md)
 - [CreateKubernetesCluster201Response](doc//CreateKubernetesCluster201Response.md)
 - [CreateKubernetesClusterRequest](doc//CreateKubernetesClusterRequest.md)
 - [CreateKubernetesClusterRequestNodePoolsInner](doc//CreateKubernetesClusterRequestNodePoolsInner.md)
 - [CreateKubernetesClusterRequestOidc](doc//CreateKubernetesClusterRequestOidc.md)
 - [CreateLoadBalancer202Response](doc//CreateLoadBalancer202Response.md)
 - [CreateLoadBalancerForwardingRulesRequest](doc//CreateLoadBalancerForwardingRulesRequest.md)
 - [CreateLoadBalancerRequest](doc//CreateLoadBalancerRequest.md)
 - [CreateLoadBalancerRequestAutoSsl](doc//CreateLoadBalancerRequestAutoSsl.md)
 - [CreateLoadBalancerRequestFirewallRulesInner](doc//CreateLoadBalancerRequestFirewallRulesInner.md)
 - [CreateLoadBalancerRequestForwardingRulesInner](doc//CreateLoadBalancerRequestForwardingRulesInner.md)
 - [CreateLoadBalancerRequestGlobalRegionsInner](doc//CreateLoadBalancerRequestGlobalRegionsInner.md)
 - [CreateLoadBalancerRequestHealthCheck](doc//CreateLoadBalancerRequestHealthCheck.md)
 - [CreateLoadBalancerRequestSsl](doc//CreateLoadBalancerRequestSsl.md)
 - [CreateLoadBalancerRequestStickySession](doc//CreateLoadBalancerRequestStickySession.md)
 - [CreateLoadBalancerReverseDnsIpv4Request](doc//CreateLoadBalancerReverseDnsIpv4Request.md)
 - [CreateLoadBalancerReverseDnsIpv6Request](doc//CreateLoadBalancerReverseDnsIpv6Request.md)
 - [CreateLoadBalancerReverseDnsIpv6RequestV6Inner](doc//CreateLoadBalancerReverseDnsIpv6RequestV6Inner.md)
 - [CreateNetworkRequest](doc//CreateNetworkRequest.md)
 - [CreateNodepoolLabel201Response](doc//CreateNodepoolLabel201Response.md)
 - [CreateNodepoolTaint201Response](doc//CreateNodepoolTaint201Response.md)
 - [CreateNodepools201Response](doc//CreateNodepools201Response.md)
 - [CreateNodepoolsRequest](doc//CreateNodepoolsRequest.md)
 - [CreateObjectStorage202Response](doc//CreateObjectStorage202Response.md)
 - [CreateObjectStorageRequest](doc//CreateObjectStorageRequest.md)
 - [CreatePullzone201Response](doc//CreatePullzone201Response.md)
 - [CreatePullzoneRequest](doc//CreatePullzoneRequest.md)
 - [CreatePushzone201Response](doc//CreatePushzone201Response.md)
 - [CreatePushzoneRequest](doc//CreatePushzoneRequest.md)
 - [CreatePushzoneUpload201Response](doc//CreatePushzoneUpload201Response.md)
 - [CreatePushzoneUploadRequest](doc//CreatePushzoneUploadRequest.md)
 - [CreateReservedIpRequest](doc//CreateReservedIpRequest.md)
 - [CreateSnapshotCreateFromUrlRequest](doc//CreateSnapshotCreateFromUrlRequest.md)
 - [CreateSnapshotRequest](doc//CreateSnapshotRequest.md)
 - [CreateSshKeyRequest](doc//CreateSshKeyRequest.md)
 - [CreateStartupScriptRequest](doc//CreateStartupScriptRequest.md)
 - [CreateStorageGateway202Response](doc//CreateStorageGateway202Response.md)
 - [CreateStorageGatewayRequest](doc//CreateStorageGatewayRequest.md)
 - [CreateSubaccount201Response](doc//CreateSubaccount201Response.md)
 - [CreateSubaccountRequest](doc//CreateSubaccountRequest.md)
 - [CreateUserApiKeyRequest](doc//CreateUserApiKeyRequest.md)
 - [CreateUserRequest](doc//CreateUserRequest.md)
 - [CreateVFSRequest](doc//CreateVFSRequest.md)
 - [CreateVFSRequestStorageSize](doc//CreateVFSRequestStorageSize.md)
 - [CreateVpc2Request](doc//CreateVpc2Request.md)
 - [CreateVpcRequest](doc//CreateVpcRequest.md)
 - [DbaasMeta](doc//DbaasMeta.md)
 - [DetachBaremetalVpc2Request](doc//DetachBaremetalVpc2Request.md)
 - [DetachBaremetalVpcsRequest](doc//DetachBaremetalVpcsRequest.md)
 - [DetachBlockRequest](doc//DetachBlockRequest.md)
 - [DetachInstanceIso202Response](doc//DetachInstanceIso202Response.md)
 - [DetachInstanceIso202ResponseIsoStatus](doc//DetachInstanceIso202ResponseIsoStatus.md)
 - [DetachInstanceNetworkRequest](doc//DetachInstanceNetworkRequest.md)
 - [DetachInstanceVpc2Request](doc//DetachInstanceVpc2Request.md)
 - [DetachInstanceVpcRequest](doc//DetachInstanceVpcRequest.md)
 - [DetachVpc2NodesRequest](doc//DetachVpc2NodesRequest.md)
 - [DnsRecord](doc//DnsRecord.md)
 - [DnsSoa](doc//DnsSoa.md)
 - [Domain](doc//Domain.md)
 - [FirewallGroup](doc//FirewallGroup.md)
 - [FirewallRule](doc//FirewallRule.md)
 - [ForwardingRule](doc//ForwardingRule.md)
 - [GetAccount200Response](doc//GetAccount200Response.md)
 - [GetAccountBandwidth200Response](doc//GetAccountBandwidth200Response.md)
 - [GetBackup200Response](doc//GetBackup200Response.md)
 - [GetBandwidthBaremetal200Response](doc//GetBandwidthBaremetal200Response.md)
 - [GetBareMetalUserdata200Response](doc//GetBareMetalUserdata200Response.md)
 - [GetBareMetalUserdata200ResponseUserData](doc//GetBareMetalUserdata200ResponseUserData.md)
 - [GetBareMetalVnc200Response](doc//GetBareMetalVnc200Response.md)
 - [GetBareMetalVnc200ResponseVnc](doc//GetBareMetalVnc200ResponseVnc.md)
 - [GetBareMetalsUpgrades200Response](doc//GetBareMetalsUpgrades200Response.md)
 - [GetBareMetalsUpgrades200ResponseUpgrades](doc//GetBareMetalsUpgrades200ResponseUpgrades.md)
 - [GetBaremetal200Response](doc//GetBaremetal200Response.md)
 - [GetDnsDomainDnssec200Response](doc//GetDnsDomainDnssec200Response.md)
 - [GetDnsDomainSoa200Response](doc//GetDnsDomainSoa200Response.md)
 - [GetInferenceUsage200Response](doc//GetInferenceUsage200Response.md)
 - [GetInstance200Response](doc//GetInstance200Response.md)
 - [GetInstanceBackupSchedule200Response](doc//GetInstanceBackupSchedule200Response.md)
 - [GetInstanceIsoStatus200Response](doc//GetInstanceIsoStatus200Response.md)
 - [GetInstanceIsoStatus200ResponseIsoStatus](doc//GetInstanceIsoStatus200ResponseIsoStatus.md)
 - [GetInstanceJob200Response](doc//GetInstanceJob200Response.md)
 - [GetInstanceJob200ResponseJob](doc//GetInstanceJob200ResponseJob.md)
 - [GetInstanceNeighbors200Response](doc//GetInstanceNeighbors200Response.md)
 - [GetInstanceUpgrades200Response](doc//GetInstanceUpgrades200Response.md)
 - [GetInstanceUpgrades200ResponseUpgrades](doc//GetInstanceUpgrades200ResponseUpgrades.md)
 - [GetInstanceUserdata200Response](doc//GetInstanceUserdata200Response.md)
 - [GetInstanceUserdata200ResponseUserData](doc//GetInstanceUserdata200ResponseUserData.md)
 - [GetInvoice200Response](doc//GetInvoice200Response.md)
 - [GetInvoiceItems200Response](doc//GetInvoiceItems200Response.md)
 - [GetInvoiceItems200ResponseInvoiceItemsInner](doc//GetInvoiceItems200ResponseInvoiceItemsInner.md)
 - [GetInvoiceItems200ResponseMeta](doc//GetInvoiceItems200ResponseMeta.md)
 - [GetInvoiceItems200ResponseMetaLinks](doc//GetInvoiceItems200ResponseMetaLinks.md)
 - [GetIpv4Baremetal200Response](doc//GetIpv4Baremetal200Response.md)
 - [GetIpv6Baremetal200Response](doc//GetIpv6Baremetal200Response.md)
 - [GetKubernetesAvailableUpgrades200Response](doc//GetKubernetesAvailableUpgrades200Response.md)
 - [GetKubernetesClustersConfig200Response](doc//GetKubernetesClustersConfig200Response.md)
 - [GetKubernetesResources200Response](doc//GetKubernetesResources200Response.md)
 - [GetKubernetesResources200ResponseResources](doc//GetKubernetesResources200ResponseResources.md)
 - [GetKubernetesResources200ResponseResourcesBlockStorageInner](doc//GetKubernetesResources200ResponseResourcesBlockStorageInner.md)
 - [GetKubernetesResources200ResponseResourcesLoadBalancerInner](doc//GetKubernetesResources200ResponseResourcesLoadBalancerInner.md)
 - [GetKubernetesVersions200Response](doc//GetKubernetesVersions200Response.md)
 - [GetLoadBalancerForwardingRule200Response](doc//GetLoadBalancerForwardingRule200Response.md)
 - [GetLoadBalancerReverseDns200Response](doc//GetLoadBalancerReverseDns200Response.md)
 - [GetNetwork200Response](doc//GetNetwork200Response.md)
 - [GetNodepools200Response](doc//GetNodepools200Response.md)
 - [GetPushzone200Response](doc//GetPushzone200Response.md)
 - [GetPushzoneFiles200Response](doc//GetPushzoneFiles200Response.md)
 - [GetReservedIp200Response](doc//GetReservedIp200Response.md)
 - [GetSnapshot200Response](doc//GetSnapshot200Response.md)
 - [GetSshKey200Response](doc//GetSshKey200Response.md)
 - [GetStartupScript200Response](doc//GetStartupScript200Response.md)
 - [GetUserApiKey200Response](doc//GetUserApiKey200Response.md)
 - [GetUserIpWhitelistEntry200Response](doc//GetUserIpWhitelistEntry200Response.md)
 - [GetVpc200Response](doc//GetVpc200Response.md)
 - [GetVpc2200Response](doc//GetVpc2200Response.md)
 - [HaltBaremetalsRequest](doc//HaltBaremetalsRequest.md)
 - [HaltInstancesRequest](doc//HaltInstancesRequest.md)
 - [InferenceSubscription](doc//InferenceSubscription.md)
 - [InferenceUsage](doc//InferenceUsage.md)
 - [InferenceUsageAudio](doc//InferenceUsageAudio.md)
 - [InferenceUsageChat](doc//InferenceUsageChat.md)
 - [Instance](doc//Instance.md)
 - [InstanceGet](doc//InstanceGet.md)
 - [InstanceV6NetworksInner](doc//InstanceV6NetworksInner.md)
 - [InstanceVpc](doc//InstanceVpc.md)
 - [InstanceVpc2](doc//InstanceVpc2.md)
 - [Invoice](doc//Invoice.md)
 - [IpWhitelistEntry](doc//IpWhitelistEntry.md)
 - [Iso](doc//Iso.md)
 - [IsoPublic](doc//IsoPublic.md)
 - [ListApplications200Response](doc//ListApplications200Response.md)
 - [ListAvailablePlansRegion200Response](doc//ListAvailablePlansRegion200Response.md)
 - [ListBackups200Response](doc//ListBackups200Response.md)
 - [ListBaremetalVpc2200Response](doc//ListBaremetalVpc2200Response.md)
 - [ListBaremetalVpcs200Response](doc//ListBaremetalVpcs200Response.md)
 - [ListBaremetals200Response](doc//ListBaremetals200Response.md)
 - [ListBillingHistory200Response](doc//ListBillingHistory200Response.md)
 - [ListBlocks200Response](doc//ListBlocks200Response.md)
 - [ListDnsDomainRecords200Response](doc//ListDnsDomainRecords200Response.md)
 - [ListDnsDomains200Response](doc//ListDnsDomains200Response.md)
 - [ListFirewallGroupRules200Response](doc//ListFirewallGroupRules200Response.md)
 - [ListFirewallGroups200Response](doc//ListFirewallGroups200Response.md)
 - [ListInference200Response](doc//ListInference200Response.md)
 - [ListInstanceIpv6Reverse200Response](doc//ListInstanceIpv6Reverse200Response.md)
 - [ListInstanceIpv6Reverse200ResponseReverseIpv6sInner](doc//ListInstanceIpv6Reverse200ResponseReverseIpv6sInner.md)
 - [ListInstancePrivateNetworks200Response](doc//ListInstancePrivateNetworks200Response.md)
 - [ListInstanceVpc2200Response](doc//ListInstanceVpc2200Response.md)
 - [ListInstanceVpcs200Response](doc//ListInstanceVpcs200Response.md)
 - [ListInstances200Response](doc//ListInstances200Response.md)
 - [ListInvoices200Response](doc//ListInvoices200Response.md)
 - [ListIsos200Response](doc//ListIsos200Response.md)
 - [ListKubernetesClusters200Response](doc//ListKubernetesClusters200Response.md)
 - [ListLoadBalancerForwardingRules200Response](doc//ListLoadBalancerForwardingRules200Response.md)
 - [ListLoadBalancers200Response](doc//ListLoadBalancers200Response.md)
 - [ListLogs200Response](doc//ListLogs200Response.md)
 - [ListMarketplaceAppVariables200Response](doc//ListMarketplaceAppVariables200Response.md)
 - [ListMetalPlans200Response](doc//ListMetalPlans200Response.md)
 - [ListNetworks200Response](doc//ListNetworks200Response.md)
 - [ListNodepoolLabels200Response](doc//ListNodepoolLabels200Response.md)
 - [ListNodepoolTaints200Response](doc//ListNodepoolTaints200Response.md)
 - [ListObjectStorageClusterTiers200Response](doc//ListObjectStorageClusterTiers200Response.md)
 - [ListObjectStorageClusters200Response](doc//ListObjectStorageClusters200Response.md)
 - [ListObjectStorageTiers200Response](doc//ListObjectStorageTiers200Response.md)
 - [ListObjectStorages200Response](doc//ListObjectStorages200Response.md)
 - [ListOs200Response](doc//ListOs200Response.md)
 - [ListPlans200Response](doc//ListPlans200Response.md)
 - [ListPublicIsos200Response](doc//ListPublicIsos200Response.md)
 - [ListPullzones200Response](doc//ListPullzones200Response.md)
 - [ListPushzones200Response](doc//ListPushzones200Response.md)
 - [ListRegions200Response](doc//ListRegions200Response.md)
 - [ListReservedIps200Response](doc//ListReservedIps200Response.md)
 - [ListSnapshots200Response](doc//ListSnapshots200Response.md)
 - [ListSshKeys200Response](doc//ListSshKeys200Response.md)
 - [ListStartupScripts200Response](doc//ListStartupScripts200Response.md)
 - [ListStorageGateways200Response](doc//ListStorageGateways200Response.md)
 - [ListSubaccounts200Response](doc//ListSubaccounts200Response.md)
 - [ListUserApiKeys200Response](doc//ListUserApiKeys200Response.md)
 - [ListUserIpWhitelist200Response](doc//ListUserIpWhitelist200Response.md)
 - [ListUsers200Response](doc//ListUsers200Response.md)
 - [ListVFS200Response](doc//ListVFS200Response.md)
 - [ListVFSAttachments200Response](doc//ListVFSAttachments200Response.md)
 - [ListVpc2200Response](doc//ListVpc2200Response.md)
 - [ListVpc2Nodes200Response](doc//ListVpc2Nodes200Response.md)
 - [ListVpcAttachments200Response](doc//ListVpcAttachments200Response.md)
 - [ListVpcs200Response](doc//ListVpcs200Response.md)
 - [Loadbalancer](doc//Loadbalancer.md)
 - [LoadbalancerAutoSsl](doc//LoadbalancerAutoSsl.md)
 - [LoadbalancerFirewallRule](doc//LoadbalancerFirewallRule.md)
 - [LoadbalancerFirewallRulesInner](doc//LoadbalancerFirewallRulesInner.md)
 - [LoadbalancerForwardRulesInner](doc//LoadbalancerForwardRulesInner.md)
 - [LoadbalancerGenericInfo](doc//LoadbalancerGenericInfo.md)
 - [LoadbalancerGenericInfoStickySessions](doc//LoadbalancerGenericInfoStickySessions.md)
 - [LoadbalancerHealthCheck](doc//LoadbalancerHealthCheck.md)
 - [LoadbalancerNodeIps](doc//LoadbalancerNodeIps.md)
 - [Log](doc//Log.md)
 - [LogMeta](doc//LogMeta.md)
 - [LogMetadata](doc//LogMetadata.md)
 - [Meta](doc//Meta.md)
 - [MetaLinks](doc//MetaLinks.md)
 - [Network](doc//Network.md)
 - [NodepoolInstances](doc//NodepoolInstances.md)
 - [NodepoolLabel](doc//NodepoolLabel.md)
 - [NodepoolLabelReq](doc//NodepoolLabelReq.md)
 - [NodepoolTaint](doc//NodepoolTaint.md)
 - [NodepoolTaintReq](doc//NodepoolTaintReq.md)
 - [Nodepools](doc//Nodepools.md)
 - [ObjectStorage](doc//ObjectStorage.md)
 - [ObjectStorages](doc//ObjectStorages.md)
 - [ObjectStoragesTier](doc//ObjectStoragesTier.md)
 - [Os](doc//Os.md)
 - [PatchReservedIpsReservedIpRequest](doc//PatchReservedIpsReservedIpRequest.md)
 - [PendingCharges200Response](doc//PendingCharges200Response.md)
 - [Plans](doc//Plans.md)
 - [PlansLocationCostValue](doc//PlansLocationCostValue.md)
 - [PlansMetal](doc//PlansMetal.md)
 - [PostBaremetalInstanceIdIpv4ReverseDefaultRequest](doc//PostBaremetalInstanceIdIpv4ReverseDefaultRequest.md)
 - [PostFirewallsFirewallGroupIdRules201Response](doc//PostFirewallsFirewallGroupIdRules201Response.md)
 - [PostFirewallsFirewallGroupIdRulesRequest](doc//PostFirewallsFirewallGroupIdRulesRequest.md)
 - [PrivateNetworks](doc//PrivateNetworks.md)
 - [Pullzone](doc//Pullzone.md)
 - [Pushzone](doc//Pushzone.md)
 - [Pushzonefile](doc//Pushzonefile.md)
 - [Pushzonefilemeta](doc//Pushzonefilemeta.md)
 - [PutSnapshotsSnapshotIdRequest](doc//PutSnapshotsSnapshotIdRequest.md)
 - [RebootInstancesRequest](doc//RebootInstancesRequest.md)
 - [RegenerateObjectStorageKeys201Response](doc//RegenerateObjectStorageKeys201Response.md)
 - [RegenerateObjectStorageKeys201ResponseS3Credentials](doc//RegenerateObjectStorageKeys201ResponseS3Credentials.md)
 - [Region](doc//Region.md)
 - [ReinstallBaremetalRequest](doc//ReinstallBaremetalRequest.md)
 - [ReinstallInstanceRequest](doc//ReinstallInstanceRequest.md)
 - [RemoveUserIpWhitelistRequest](doc//RemoveUserIpWhitelistRequest.md)
 - [ReservedIp](doc//ReservedIp.md)
 - [RestoreInstance202Response](doc//RestoreInstance202Response.md)
 - [RestoreInstance202ResponseStatus](doc//RestoreInstance202ResponseStatus.md)
 - [RestoreInstanceRequest](doc//RestoreInstanceRequest.md)
 - [Snapshot](doc//Snapshot.md)
 - [Ssh](doc//Ssh.md)
 - [StartInstancesRequest](doc//StartInstancesRequest.md)
 - [StartKubernetesClusterUpgradeRequest](doc//StartKubernetesClusterUpgradeRequest.md)
 - [Startup](doc//Startup.md)
 - [StorageGateway](doc//StorageGateway.md)
 - [StorageGatewayExport](doc//StorageGatewayExport.md)
 - [StorageGatewayNetwork](doc//StorageGatewayNetwork.md)
 - [StorageGatewayNetworkPrimary](doc//StorageGatewayNetworkPrimary.md)
 - [StorageGatewayNetworkPrimaryVpc](doc//StorageGatewayNetworkPrimaryVpc.md)
 - [Subaccount](doc//Subaccount.md)
 - [Tiers](doc//Tiers.md)
 - [TiersLocationsInner](doc//TiersLocationsInner.md)
 - [UpdateBaremetal202Response](doc//UpdateBaremetal202Response.md)
 - [UpdateBaremetalRequest](doc//UpdateBaremetalRequest.md)
 - [UpdateBlockRequest](doc//UpdateBlockRequest.md)
 - [UpdateDnsDomainRecordRequest](doc//UpdateDnsDomainRecordRequest.md)
 - [UpdateDnsDomainRequest](doc//UpdateDnsDomainRequest.md)
 - [UpdateDnsDomainSoaRequest](doc//UpdateDnsDomainSoaRequest.md)
 - [UpdateFirewallGroupRequest](doc//UpdateFirewallGroupRequest.md)
 - [UpdateInferenceRequest](doc//UpdateInferenceRequest.md)
 - [UpdateInstanceRequest](doc//UpdateInstanceRequest.md)
 - [UpdateKubernetesClusterRequest](doc//UpdateKubernetesClusterRequest.md)
 - [UpdateLoadBalancerRequest](doc//UpdateLoadBalancerRequest.md)
 - [UpdateLoadBalancerRequestHealthCheck](doc//UpdateLoadBalancerRequestHealthCheck.md)
 - [UpdateNetworkRequest](doc//UpdateNetworkRequest.md)
 - [UpdateNodepoolRequest](doc//UpdateNodepoolRequest.md)
 - [UpdateNodepoolRequest1](doc//UpdateNodepoolRequest1.md)
 - [UpdateObjectStorageRequest](doc//UpdateObjectStorageRequest.md)
 - [UpdatePullzoneRequest](doc//UpdatePullzoneRequest.md)
 - [UpdatePushzoneRequest](doc//UpdatePushzoneRequest.md)
 - [UpdateSshKeyRequest](doc//UpdateSshKeyRequest.md)
 - [UpdateStartupScriptRequest](doc//UpdateStartupScriptRequest.md)
 - [UpdateStorageGatewayRequest](doc//UpdateStorageGatewayRequest.md)
 - [UpdateUserRequest](doc//UpdateUserRequest.md)
 - [UpdateVFSRequest](doc//UpdateVFSRequest.md)
 - [UpdateVFSRequestStorageSize](doc//UpdateVFSRequestStorageSize.md)
 - [UpdateVpc2Request](doc//UpdateVpc2Request.md)
 - [UpdateVpcRequest](doc//UpdateVpcRequest.md)
 - [Uploadendpoint](doc//Uploadendpoint.md)
 - [UploadendpointInputs](doc//UploadendpointInputs.md)
 - [User](doc//User.md)
 - [UserUser](doc//UserUser.md)
 - [Vfs](doc//Vfs.md)
 - [VfsAttachment](doc//VfsAttachment.md)
 - [VfsBilling](doc//VfsBilling.md)
 - [VfsRegion](doc//VfsRegion.md)
 - [VfsRegionMinSizeGb](doc//VfsRegionMinSizeGb.md)
 - [VfsRegionPricePerGb](doc//VfsRegionPricePerGb.md)
 - [VfsStorageSize](doc//VfsStorageSize.md)
 - [VkeCluster](doc//VkeCluster.md)
 - [VkeClusterOidc](doc//VkeClusterOidc.md)
 - [Vpc](doc//Vpc.md)
 - [Vpc2](doc//Vpc2.md)
 - [Vpc2nodes](doc//Vpc2nodes.md)
 - [VpcAttachment](doc//VpcAttachment.md)
 - [VpcAttachmentIp](doc//VpcAttachmentIp.md)
 - [VpcAttachmentLinkedSubscription](doc//VpcAttachmentLinkedSubscription.md)
 - [VpcInternet](doc//VpcInternet.md)


## Documentation For Authorization


Authentication schemes defined for the API:
### API Key

- **Type**: HTTP Bearer authentication


## Author

support@vultr.com

