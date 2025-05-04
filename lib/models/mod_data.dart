import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../helpers/uuid_converter.dart';

part 'mod_data.g.dart';

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
  constructor: "_",
)
final class ModData {
  @UuidValueConverter()
  final UuidValue guid;
  final List<bool> enabled;
  final List<int> selected;

  ModData._({
    required this.guid,
    required this.enabled,
    required this.selected,
  });

  ModData.legacy({
    required this.guid,
    required int index,
  })
    : enabled = const [],
    selected = [ index ];

  ModData.v1({
    required this.guid,
    required this.enabled,
    required this.selected,
  });

  factory ModData.fromJson(Map<String, dynamic> json) => _$ModDataFromJson(json);

  Map<String, dynamic> toJson() => _$ModDataToJson(this);
}