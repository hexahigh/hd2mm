// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NexusData _$NexusDataFromJson(Map<String, dynamic> json) => $checkedCreate(
  'NexusData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const ['_generated', 'Id', 'Version', '_fileId'],
      requiredKeys: const ['Id'],
    );
    final val = NexusData(
      generated: $checkedConvert('_generated', (v) => v as bool? ?? false),
      id: $checkedConvert('Id', (v) => (v as num).toInt()),
      version: $checkedConvert('Version', (v) => v as String?),
      fileId: $checkedConvert('_fileId', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'generated': '_generated',
    'id': 'Id',
    'version': 'Version',
    'fileId': '_fileId',
  },
);

Map<String, dynamic> _$NexusDataToJson(NexusData instance) => <String, dynamic>{
  '_generated': instance.generated,
  'Id': instance.id,
  'Version': instance.version,
  '_fileId': instance.fileId,
};

ModManifestLegacy _$ModManifestLegacyFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ModManifestLegacy',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['Guid', 'Name', 'Description']);
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
      nexusData: $checkedConvert(
        'NexusData',
        (v) => v == null ? null : NexusData.fromJson(v as Map<String, dynamic>),
      ),
      generated: $checkedConvert('_generated', (v) => v as bool? ?? false),
    );
    return val;
  },
  fieldKeyMap: const {
    'guid': 'Guid',
    'name': 'Name',
    'description': 'Description',
    'iconPath': 'IconPath',
    'options': 'Options',
    'nexusData': 'NexusData',
    'generated': '_generated',
  },
);

Map<String, dynamic> _$ModManifestLegacyToJson(ModManifestLegacy instance) =>
    <String, dynamic>{
      'Guid': const UuidValueConverter().toJson(instance.guid),
      'Name': instance.name,
      'Description': instance.description,
      'IconPath': instance.iconPath,
      'Options': instance.options,
      'NexusData': instance.nexusData,
      '_generated': instance.generated,
    };

ModSubOption _$ModSubOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ModSubOption',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['Name', 'Description', 'Image', 'Include'],
          requiredKeys: const ['Name', 'Description', 'Include'],
        );
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
      requiredKeys: const ['Name', 'Description'],
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

ModManifestV1 _$ModManifestV1FromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ModManifestV1',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['Version', 'Guid', 'Name', 'Description'],
    );
    final val = ModManifestV1(
      version: $checkedConvert('Version', (v) => (v as num?)?.toInt() ?? 1),
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
      nexusData: $checkedConvert(
        'NexusData',
        (v) => v == null ? null : NexusData.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'version': 'Version',
    'guid': 'Guid',
    'name': 'Name',
    'description': 'Description',
    'iconPath': 'IconPath',
    'options': 'Options',
    'nexusData': 'NexusData',
  },
);

Map<String, dynamic> _$ModManifestV1ToJson(ModManifestV1 instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Guid': const UuidValueConverter().toJson(instance.guid),
      'Name': instance.name,
      'Description': instance.description,
      'IconPath': instance.iconPath,
      'Options': instance.options,
      'NexusData': instance.nexusData,
    };
