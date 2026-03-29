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

// tests for RetentionRule
void main() {
  // final instance = RetentionRule();

  group('test RetentionRule', () {
    // The Retention rule's ID
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // Indicates whether the Retention rule is currently disabled
    // bool disabled
    test('to test the property `disabled`', () async {
      // TODO
    });

    // Specifies the action to be taken on the selected artifacts
    // String action
    test('to test the property `action`', () async {
      // TODO
    });

    // RetentionRuleParams params
    test('to test the property `params`', () async {
      // TODO
    });

    // RetentionRuleScopeSelectors scopeSelectors
    test('to test the property `scopeSelectors`', () async {
      // TODO
    });

    // A list of tag selector rules that determine which tags or untagged artifacts the retention rule should apply to
    // List<RetentionRuleTagSelectorsInner> tagSelectors (default value: const [])
    test('to test the property `tagSelectors`', () async {
      // TODO
    });

    // Specifies the rule logic template to use.  Possible templates:  * latestPushedK * latestPulledN * nDaysSinceLastPull * nDaysSinceLastPush * always
    // String template
    test('to test the property `template`', () async {
      // TODO
    });
  });
}
