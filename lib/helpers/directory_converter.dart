import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

final class DirectoryConverter extends JsonConverter<Directory, String> {
  const DirectoryConverter();

  @override
  Directory fromJson(String json) => Directory(json);

  @override
  String toJson(Directory object) => object.path;
}