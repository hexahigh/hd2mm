// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModData _$ModDataFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ModData',
  json,
  ($checkedConvert) {
    final val = ModData._(
      guid: $checkedConvert(
        'Guid',
        (v) => const UuidValueConverter().fromJson(v as String),
      ),
      enabled: $checkedConvert('Enabled', (v) => v as bool),
      toggled: $checkedConvert(
        'Toggled',
        (v) => (v as List<dynamic>).map((e) => e as bool).toList(),
      ),
      selected: $checkedConvert(
        'Selected',
        (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'guid': 'Guid',
    'enabled': 'Enabled',
    'toggled': 'Toggled',
    'selected': 'Selected',
  },
);

Map<String, dynamic> _$ModDataToJson(ModData instance) => <String, dynamic>{
  'Guid': const UuidValueConverter().toJson(instance.guid),
  'Enabled': instance.enabled,
  'Toggled': instance.toggled,
  'Selected': instance.selected,
};
