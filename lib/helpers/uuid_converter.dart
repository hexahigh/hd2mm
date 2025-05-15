import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

final class UuidValueConverter extends JsonConverter<UuidValue, String> {
  const UuidValueConverter();

  @override
  UuidValue fromJson(String json) => UuidValue.withValidation(json, ValidationMode.nonStrict);

  @override
  String toJson(UuidValue object) => object.uuid;
}