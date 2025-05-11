// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModManifestLegacy _$ModManifestLegacyFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ModManifestLegacy',
      json,
      ($checkedConvert) {
        final val = ModManifestLegacy(
          guid: $checkedConvert(
            'Guid',
            (v) => const UuidValueConverter().fromJson(v as String),
          ),
          name: $checkedConvert('Name', (v) => v as String),
          description: $checkedConvert('Description', (v) => v as String),
          iconPath: $checkedConvert('IconPath', (v) => v as String?),
          options: $checkedConvert(
            'Options',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'guid': 'Guid',
        'name': 'Name',
        'description': 'Description',
        'iconPath': 'IconPath',
        'options': 'Options',
      },
    );

Map<String, dynamic> _$ModManifestLegacyToJson(ModManifestLegacy instance) =>
    <String, dynamic>{
      'Guid': const UuidValueConverter().toJson(instance.guid),
      'Name': instance.name,
      'Description': instance.description,
      'IconPath': instance.iconPath,
      'Options': instance.options,
    };

ModSubOption _$ModSubOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ModSubOption',
      json,
      ($checkedConvert) {
        final val = ModSubOption(
          name: $checkedConvert('Name', (v) => v as String),
          description: $checkedConvert('Description', (v) => v as String),
          image: $checkedConvert('Image', (v) => v as String?),
          include: $checkedConvert(
            'Include',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'name': 'Name',
        'description': 'Description',
        'image': 'Image',
        'include': 'Include',
      },
    );

Map<String, dynamic> _$ModSubOptionToJson(ModSubOption instance) =>
    <String, dynamic>{
      'Name': instance.name,
      'Description': instance.description,
      'Image': instance.image,
      'Include': instance.include,
    };

ModOption _$ModOptionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ModOption',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const [
        'Name',
        'Description',
        'Image',
        'Include',
        'SubOptions',
      ],
    );
    final val = ModOption(
      name: $checkedConvert('Name', (v) => v as String),
      description: $checkedConvert('Description', (v) => v as String),
      image: $checkedConvert('Image', (v) => v as String?),
      include: $checkedConvert(
        'Include',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      subOptions: $checkedConvert(
        'SubOptions',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => ModSubOption.fromJson(e as Map<String, dynamic>))
                .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'name': 'Name',
    'description': 'Description',
    'image': 'Image',
    'include': 'Include',
    'subOptions': 'SubOptions',
  },
);

Map<String, dynamic> _$ModOptionToJson(ModOption instance) => <String, dynamic>{
  'Name': instance.name,
  'Description': instance.description,
  'Image': instance.image,
  'Include': instance.include,
  'SubOptions': instance.subOptions,
};

ModManifestV1 _$ModManifestV1FromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ModManifestV1',
      json,
      ($checkedConvert) {
        final val = ModManifestV1(
          guid: $checkedConvert(
            'Guid',
            (v) => const UuidValueConverter().fromJson(v as String),
          ),
          name: $checkedConvert('Name', (v) => v as String),
          description: $checkedConvert('Description', (v) => v as String),
          iconPath: $checkedConvert('IconPath', (v) => v as String?),
          options: $checkedConvert(
            'Options',
            (v) =>
                (v as List<dynamic>?)
                    ?.map((e) => ModOption.fromJson(e as Map<String, dynamic>))
                    .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'guid': 'Guid',
        'name': 'Name',
        'description': 'Description',
        'iconPath': 'IconPath',
        'options': 'Options',
      },
    );

Map<String, dynamic> _$ModManifestV1ToJson(ModManifestV1 instance) =>
    <String, dynamic>{
      'Version': instance._version,
      'Guid': const UuidValueConverter().toJson(instance.guid),
      'Name': instance.name,
      'Description': instance.description,
      'IconPath': instance.iconPath,
      'Options': instance.options,
    };
