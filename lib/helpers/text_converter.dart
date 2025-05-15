import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

final class TextEditingControllerConverter extends JsonConverter<TextEditingController, String> {
  const TextEditingControllerConverter();

  @override
  TextEditingController fromJson(String json) => TextEditingController(text: json);

  @override
  String toJson(TextEditingController object) => object.text;
}