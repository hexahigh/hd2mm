// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubOptionState _$SubOptionStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SubOptionState', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'expanded',
          'nameController',
          'nameError',
          'descriptionController',
          'imagePathController',
          'includeError',
          'includeFiles',
        ],
      );
      final val = _SubOptionState(
        $checkedConvert('expanded', (v) => v as bool),
        $checkedConvert(
          'nameController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert('nameError', (v) => v as String?),
        $checkedConvert(
          'descriptionController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert(
          'imagePathController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert('includeError', (v) => v as String?),
        $checkedConvert(
          'includeFiles',
          (v) =>
              (v as List<dynamic>)
                  .map((e) => const FileConverter().fromJson(e as String))
                  .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SubOptionStateToJson(_SubOptionState instance) =>
    <String, dynamic>{
      'expanded': instance.expanded,
      'nameController': const TextEditingControllerConverter().toJson(
        instance.nameController,
      ),
      'nameError': instance.nameError,
      'descriptionController': const TextEditingControllerConverter().toJson(
        instance.descriptionController,
      ),
      'imagePathController': const TextEditingControllerConverter().toJson(
        instance.imagePathController,
      ),
      'includeError': instance.includeError,
      'includeFiles':
          instance.includeFiles.map(const FileConverter().toJson).toList(),
    };

_OptionState _$OptionStateFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_OptionState',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const [
        'expanded',
        'nameController',
        'nameError',
        'descriptionController',
        'imagePathController',
        'activeIncludes',
        'includeError',
        'includeFiles',
        'subOptions',
      ],
    );
    final val = _OptionState(
      $checkedConvert('expanded', (v) => v as bool),
      $checkedConvert(
        'nameController',
        (v) => const TextEditingControllerConverter().fromJson(v as String),
      ),
      $checkedConvert('nameError', (v) => v as String?),
      $checkedConvert(
        'descriptionController',
        (v) => const TextEditingControllerConverter().fromJson(v as String),
      ),
      $checkedConvert(
        'imagePathController',
        (v) => const TextEditingControllerConverter().fromJson(v as String),
      ),
      $checkedConvert('activeIncludes', (v) => v as bool),
      $checkedConvert('includeError', (v) => v as String?),
      $checkedConvert(
        'includeFiles',
        (v) =>
            (v as List<dynamic>)
                .map((e) => const FileConverter().fromJson(e as String))
                .toList(),
      ),
      $checkedConvert(
        'subOptions',
        (v) =>
            (v as List<dynamic>)
                .map((e) => _SubOptionState.fromJson(e as Map<String, dynamic>))
                .toList(),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$OptionStateToJson(_OptionState instance) =>
    <String, dynamic>{
      'expanded': instance.expanded,
      'nameController': const TextEditingControllerConverter().toJson(
        instance.nameController,
      ),
      'nameError': instance.nameError,
      'descriptionController': const TextEditingControllerConverter().toJson(
        instance.descriptionController,
      ),
      'imagePathController': const TextEditingControllerConverter().toJson(
        instance.imagePathController,
      ),
      'activeIncludes': instance.activeIncludes,
      'includeError': instance.includeError,
      'includeFiles':
          instance.includeFiles.map(const FileConverter().toJson).toList(),
      'subOptions': instance.subOptions,
    };

_ModProject _$ModProjectFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ModProject', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'guidController',
          'guidError',
          'nameController',
          'nameError',
          'descriptionController',
          'iconPathController',
          'options',
        ],
      );
      final val = _ModProject(
        $checkedConvert(
          'guidController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert('guidError', (v) => v as String?),
        $checkedConvert(
          'nameController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert('nameError', (v) => v as String?),
        $checkedConvert(
          'descriptionController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert(
          'iconPathController',
          (v) => const TextEditingControllerConverter().fromJson(v as String),
        ),
        $checkedConvert(
          'options',
          (v) =>
              (v as List<dynamic>)
                  .map((e) => _OptionState.fromJson(e as Map<String, dynamic>))
                  .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ModProjectToJson(_ModProject instance) =>
    <String, dynamic>{
      'guidController': const TextEditingControllerConverter().toJson(
        instance.guidController,
      ),
      'guidError': instance.guidError,
      'nameController': const TextEditingControllerConverter().toJson(
        instance.nameController,
      ),
      'nameError': instance.nameError,
      'descriptionController': const TextEditingControllerConverter().toJson(
        instance.descriptionController,
      ),
      'iconPathController': const TextEditingControllerConverter().toJson(
        instance.iconPathController,
      ),
      'options': instance.options,
    };
