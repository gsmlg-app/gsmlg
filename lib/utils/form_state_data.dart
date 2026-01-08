import 'package:flutter/material.dart';

class FormStateData {
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> fields;

  FormStateData({
    GlobalKey<FormState>? formKey,
    required List<String> fields,
  })  : formKey = formKey ?? GlobalKey<FormState>(debugLabel: 'FormStateData'),
        fields = {for (var field in fields) field: TextEditingController()};

  Map<String, String> get fieldsData {
    Map<String, String> data = {};
    for (var field in fields.keys) {
      data[field] = fields[field]!.text;
    }
    return data;
  }

  void setFieldValue(String name, String value) {
    final controller = fields[name];
    if (controller != null) {
      controller.text = value;
    }
  }

  void setFieldsValue(Map<String, String> data) {
    for (var name in data.keys) {
      final controller = fields[name];
      if (controller != null) {
        controller.text = data[name]!;
      }
    }
  }

  void dispose() {
    for (var controller in fields.values) {
      controller.dispose();
    }
  }
}
