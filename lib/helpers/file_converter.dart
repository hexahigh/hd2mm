import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

final class FileConverter extends JsonConverter<File, String> {
  const FileConverter();

  @override
  File fromJson(String json) => File(json);

  @override
  String toJson(File object) => object.path;
}