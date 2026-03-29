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

/// tests for CDNsApi
void main() {
  // final instance = CDNsApi();

  group('tests for CDNsApi', () {
    // Create CDN Pull Zones
    //
    // Create a new CDN Pull Zone.
    //
    //Future<CreatePullzone201Response> createPullzone({ CreatePullzoneRequest createPullzoneRequest }) async
    test('test createPullzone', () async {
      // TODO
    });

    // Create CDN Push Zones
    //
    // Create a new CDN Push Zone.
    //
    //Future<CreatePushzone201Response> createPushzone({ CreatePushzoneRequest createPushzoneRequest }) async
    test('test createPushzone', () async {
      // TODO
    });

    // Create CDN Push Zone File Upload Endpoint
    //
    // Create a presigned post endpoint that can be used to upload a file to your Push Zone.  After sending this request you must send a second POST request to the returned URL. Include all of the returned inputs as form-data fields using the same key and value.  You must also include a field named \"file\" that holds the file to be uploaded.
    //
    //Future<CreatePushzoneUpload201Response> createPushzoneUpload(String pushzoneId, { CreatePushzoneUploadRequest createPushzoneUploadRequest }) async
    test('test createPushzoneUpload', () async {
      // TODO
    });

    // Delete CDN Pullzone
    //
    // Delete a CDN Pull Zone.
    //
    //Future deletePullzone(String pullzoneId) async
    test('test deletePullzone', () async {
      // TODO
    });

    // Delete CDN Pushzone
    //
    // Delete a CDN Push Zone.
    //
    //Future deletePushzone(String pushzoneId) async
    test('test deletePushzone', () async {
      // TODO
    });

    // Delete CDN Pushzone File
    //
    // Delete a CDN Push Zone file.
    //
    //Future deletePushzoneFile(String pushzoneId, String fileName) async
    test('test deletePushzoneFile', () async {
      // TODO
    });

    // Get CDN Pull Zone
    //
    // Get information about a CDN Pull Zones
    //
    //Future<CreatePullzone201Response> getPullzone(String pullzoneId) async
    test('test getPullzone', () async {
      // TODO
    });

    // Get CDN Push Zone
    //
    // Get information about a CDN Push Zone
    //
    //Future<CreatePushzone201Response> getPushzone(String pushzoneId) async
    test('test getPushzone', () async {
      // TODO
    });

    // List CDN Push Zone Files
    //
    // Get a list of files that have been uploaded to a specific CDN Push Zones
    //
    //Future<GetPushzoneFiles200Response> getPushzoneFiles(String pushzoneId) async
    test('test getPushzoneFiles', () async {
      // TODO
    });

    // Get CDN Push Zone File
    //
    // Get information about a CDN Push Zone file
    //
    //Future<GetPushzone200Response> getPushzone_0(String pushzoneId, String fileName) async
    test('test getPushzone_0', () async {
      // TODO
    });

    // List CDN Pull Zones
    //
    // List CDN Pull Zones
    //
    //Future<ListPullzones200Response> listPullzones() async
    test('test listPullzones', () async {
      // TODO
    });

    // List CDN Push Zones
    //
    // List CDN Push Zones
    //
    //Future<ListPushzones200Response> listPushzones() async
    test('test listPushzones', () async {
      // TODO
    });

    // Purge CDN Pull Zone
    //
    // Clears cached content on server proxies so that visitors can get the latest page versions.  **Note:** This action may only be performed once every six hours.  **Note:** This action may take a few extra seconds to complete.
    //
    //Future<List<String>> purgePullzone(String pullzoneId) async
    test('test purgePullzone', () async {
      // TODO
    });

    // Update CDN Pull Zone
    //
    // Update information for a CDN Pullzone. All attributes are optional. If not set, the attributes will retain their original values.
    //
    //Future<CreatePullzone201Response> updatePullzone(String pullzoneId, { UpdatePullzoneRequest updatePullzoneRequest }) async
    test('test updatePullzone', () async {
      // TODO
    });

    // Update CDN Push Zone
    //
    // Update information for a CDN Pushzone. All attributes are optional. If not set, the attributes will retain their original values.
    //
    //Future<CreatePushzone201Response> updatePushzone(String pushzoneId, { UpdatePushzoneRequest updatePushzoneRequest }) async
    test('test updatePushzone', () async {
      // TODO
    });
  });
}
