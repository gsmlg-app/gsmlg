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

/// tests for StartupApi
void main() {
  // final instance = StartupApi();

  group('tests for StartupApi', () {
    // Create Startup Script
    //
    // Create a new Startup Script. The `name` and `script` attributes are required, and scripts are base-64 encoded.
    //
    //Future<GetStartupScript200Response> createStartupScript({ CreateStartupScriptRequest createStartupScriptRequest }) async
    test('test createStartupScript', () async {
      // TODO
    });

    // Delete Startup Script
    //
    // Delete a Startup Script.
    //
    //Future deleteStartupScript(String startupId) async
    test('test deleteStartupScript', () async {
      // TODO
    });

    // Get Startup Script
    //
    // Get information for a Startup Script.
    //
    //Future<GetStartupScript200Response> getStartupScript(String startupId) async
    test('test getStartupScript', () async {
      // TODO
    });

    // List Startup Scripts
    //
    // Get a list of all Startup Scripts.
    //
    //Future<ListStartupScripts200Response> listStartupScripts({ int perPage, String cursor }) async
    test('test listStartupScripts', () async {
      // TODO
    });

    // Update Startup Script
    //
    // Update a Startup Script. The attributes `name` and `script` are optional. If not set, the attributes will retain their original values. The `script` attribute is base-64 encoded. New deployments will use the updated script, but this action does not update previously deployed instances.
    //
    //Future updateStartupScript(String startupId, { UpdateStartupScriptRequest updateStartupScriptRequest }) async
    test('test updateStartupScript', () async {
      // TODO
    });
  });
}
