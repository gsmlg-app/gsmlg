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

/// tests for UsersApi
void main() {
  // final instance = UsersApi();

  group('tests for UsersApi', () {
    // Add IP to User Whitelist
    //
    // Add an IP address or subnet to a User's whitelist. Only root users or users with manage users permission can access this endpoint.
    //
    //Future addUserIpWhitelist(String userId, { AddUserIpWhitelistRequest addUserIpWhitelistRequest }) async
    test('test addUserIpWhitelist', () async {
      // TODO
    });

    // Create User
    //
    // Create a new User. The `email`, `first_name`, `last_name`, and `password` attributes are required.
    //
    //Future<User> createUser({ CreateUserRequest createUserRequest }) async
    test('test createUser', () async {
      // TODO
    });

    // Create User API Key
    //
    // Adds an API key to the target user's API key list. Only root users or users with manage users permission can access this endpoint.
    //
    //Future createUserApiKey(String userId, { CreateUserApiKeyRequest createUserApiKeyRequest }) async
    test('test createUserApiKey', () async {
      // TODO
    });

    // Delete User
    //
    // Delete a User.
    //
    //Future deleteUser(String userId) async
    test('test deleteUser', () async {
      // TODO
    });

    // Delete User API Key
    //
    // Delete an API key from the target user's API key list. Only root users or users with manage users permission can access this endpoint.
    //
    //Future deleteUserApiKey(String userId, String apikeyId) async
    test('test deleteUserApiKey', () async {
      // TODO
    });

    // Get User
    //
    // Get information about a User.
    //
    //Future<User> getUser(String userId) async
    test('test getUser', () async {
      // TODO
    });

    // Get User API Key
    //
    // Gets information about a user's API key. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.
    //
    //Future<GetUserApiKey200Response> getUserApiKey(String userId, String apikeyId) async
    test('test getUserApiKey', () async {
      // TODO
    });

    // Get User IP Whitelist Entry
    //
    // Get a specific IP whitelist entry for a User. Only root users or users with manage users permission can access this endpoint.
    //
    //Future<GetUserIpWhitelistEntry200Response> getUserIpWhitelistEntry(String userId, String subnet, int subnetSize) async
    test('test getUserIpWhitelistEntry', () async {
      // TODO
    });

    // List User API Keys
    //
    // Gets all API keys for the target user. API keys returned by this method are masked. Only root users or users with manage users permission can access this endpoint.
    //
    //Future<ListUserApiKeys200Response> listUserApiKeys(String userId) async
    test('test listUserApiKeys', () async {
      // TODO
    });

    // List User IP Whitelist
    //
    // Get the IP whitelist for a User. Only root users or users with manage users permission can access this endpoint.
    //
    //Future<ListUserIpWhitelist200Response> listUserIpWhitelist(String userId) async
    test('test listUserIpWhitelist', () async {
      // TODO
    });

    // Get Users
    //
    // Get a list of all Users in your account.
    //
    //Future<ListUsers200Response> listUsers({ num perPage, String cursor }) async
    test('test listUsers', () async {
      // TODO
    });

    // Remove IP from User Whitelist
    //
    // Remove an IP address or subnet from a User's whitelist. Only root users or users with manage users permission can access this endpoint.
    //
    //Future removeUserIpWhitelist(String userId, { RemoveUserIpWhitelistRequest removeUserIpWhitelistRequest }) async
    test('test removeUserIpWhitelist', () async {
      // TODO
    });

    // Update User
    //
    // Update information for a User. All attributes are optional. If not set, the attributes will retain their original values.
    //
    //Future updateUser(String userId, { UpdateUserRequest updateUserRequest }) async
    test('test updateUser', () async {
      // TODO
    });
  });
}
