//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:vultr_api/api.dart';
import 'package:test/test.dart';


/// tests for DnsApi
void main() {
  // final instance = DnsApi();

  group('tests for DnsApi', () {
    // Create DNS Domain
    //
    // Create a DNS Domain for `domain`. If no `ip` address is supplied a domain with no records will be created.
    //
    //Future<CreateDnsDomain200Response> createDnsDomain({ CreateDnsDomainRequest createDnsDomainRequest }) async
    test('test createDnsDomain', () async {
      // TODO
    });

    // Create Record
    //
    // Create a DNS record.
    //
    //Future<CreateDnsDomainRecord201Response> createDnsDomainRecord(String dnsDomain, { CreateDnsDomainRecordRequest createDnsDomainRecordRequest }) async
    test('test createDnsDomainRecord', () async {
      // TODO
    });

    // Delete Domain
    //
    // Delete the DNS Domain.
    //
    //Future deleteDnsDomain(String dnsDomain) async
    test('test deleteDnsDomain', () async {
      // TODO
    });

    // Delete Record
    //
    // Delete the DNS record.
    //
    //Future deleteDnsDomainRecord(String dnsDomain, String recordId) async
    test('test deleteDnsDomainRecord', () async {
      // TODO
    });

    // Get DNS Domain
    //
    // Get information for the DNS Domain.
    //
    //Future<CreateDnsDomain200Response> getDnsDomain(String dnsDomain) async
    test('test getDnsDomain', () async {
      // TODO
    });

    // Get DNSSec Info
    //
    // Get the DNSSEC information for the DNS Domain.
    //
    //Future<GetDnsDomainDnssec200Response> getDnsDomainDnssec(String dnsDomain) async
    test('test getDnsDomainDnssec', () async {
      // TODO
    });

    // Get Record
    //
    // Get information for a DNS Record.
    //
    //Future<CreateDnsDomainRecord201Response> getDnsDomainRecord(String dnsDomain, String recordId) async
    test('test getDnsDomainRecord', () async {
      // TODO
    });

    // Get SOA information
    //
    // Get SOA information for the DNS Domain.
    //
    //Future<GetDnsDomainSoa200Response> getDnsDomainSoa(String dnsDomain) async
    test('test getDnsDomainSoa', () async {
      // TODO
    });

    // List Records
    //
    // Get the DNS records for the Domain.
    //
    //Future<ListDnsDomainRecords200Response> listDnsDomainRecords(String dnsDomain, { int perPage, String cursor }) async
    test('test listDnsDomainRecords', () async {
      // TODO
    });

    // List DNS Domains
    //
    // List all DNS Domains in your account.
    //
    //Future<ListDnsDomains200Response> listDnsDomains({ int perPage, String cursor }) async
    test('test listDnsDomains', () async {
      // TODO
    });

    // Update a DNS Domain
    //
    // Update the DNS Domain. 
    //
    //Future updateDnsDomain(String dnsDomain, { UpdateDnsDomainRequest updateDnsDomainRequest }) async
    test('test updateDnsDomain', () async {
      // TODO
    });

    // Update Record
    //
    // Update the information for a DNS record. All attributes are optional. If not set, the attributes will retain their original values.
    //
    //Future updateDnsDomainRecord(String dnsDomain, String recordId, { UpdateDnsDomainRecordRequest updateDnsDomainRecordRequest }) async
    test('test updateDnsDomainRecord', () async {
      // TODO
    });

    // Update SOA information
    //
    // Update the SOA information for the DNS Domain. All attributes are optional. If not set, the attributes will retain their original values.
    //
    //Future updateDnsDomainSoa(String dnsDomain, { UpdateDnsDomainSoaRequest updateDnsDomainSoaRequest }) async
    test('test updateDnsDomainSoa', () async {
      // TODO
    });

  });
}
