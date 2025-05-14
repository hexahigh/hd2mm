// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Settings',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const [
        'TempPath',
        'GamePath',
        'StoragePath',
        'CaseSensitiveSearch',
        'DeveloperMode',
        'LogLevel',
        'SkipList',
      ],
    );
    final val = Settings(
      tempPath: $checkedConvert(
        'TempPath',
        (v) => const DirectoryConverter().fromJson(v as String),
      ),
      gamePath: $checkedConvert(
        'GamePath',
        (v) => _$JsonConverterFromJson<String, Directory>(
          v,
          const DirectoryConverter().fromJson,
        ),
      ),
      storagePath: $checkedConvert(
        'StoragePath',
        (v) => const DirectoryConverter().fromJson(v as String),
      ),
      caseSensitiveSearch: $checkedConvert(
        'CaseSensitiveSearch',
        (v) => v as bool,
      ),
      developerMode: $checkedConvert('DeveloperMode', (v) => v as bool),
      logLevel: $checkedConvert(
        'LogLevel',
        (v) => Settings._levelFromJson(v as String),
      ),
      skipList: $checkedConvert(
        'SkipList',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'tempPath': 'TempPath',
    'gamePath': 'GamePath',
    'storagePath': 'StoragePath',
    'caseSensitiveSearch': 'CaseSensitiveSearch',
    'developerMode': 'DeveloperMode',
    'logLevel': 'LogLevel',
    'skipList': 'SkipList',
  },
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'TempPath': const DirectoryConverter().toJson(instance.tempPath),
  'GamePath': _$JsonConverterToJson<String, Directory>(
    instance.gamePath,
    const DirectoryConverter().toJson,
  ),
  'StoragePath': const DirectoryConverter().toJson(instance.storagePath),
  'CaseSensitiveSearch': instance.caseSensitiveSearch,
  'DeveloperMode': instance.developerMode,
  'LogLevel': Settings._levelToJson(instance.logLevel),
  'SkipList': instance.skipList,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
