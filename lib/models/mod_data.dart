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
  bool enabled;
  final List<bool> toggled;
  final List<int> selected;

  ModData._({
    required this.guid,
    required this.enabled,
    required this.toggled,
    required this.selected,
  });

  ModData.legacy({
    required this.guid,
    required int index,
  })
    : enabled = true,
    toggled = const [],
    selected = [ index ];

  ModData.v1({
    required this.guid,
    required this.toggled,
    required this.selected,
  }) : enabled = true;

  factory ModData.fromJson(Map<String, dynamic> json) => _$ModDataFromJson(json);

  Map<String, dynamic> toJson() => _$ModDataToJson(this);
}