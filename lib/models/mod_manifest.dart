import 'dart:io';

import 'package:json5/json5.dart';
import 'package:path/path.dart' as path;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../helpers/directory_extensions.dart';
import '../errors/serialization_exception.dart';
import '../helpers/uuid_converter.dart';
import 'mod_data.dart';

part 'mod_manifest.g.dart';

sealed class ModManifest {
  bool get canUpgrade;

  static Future<ModManifest> fromDirectory(Directory dir) async {
    final file = await dir.tryGetFile("manifest.json");
    if (file != null) return await fromFile(file);
    return inferFromDirectory(dir);
  }

  static Future<ModManifest> inferFromDirectory(Directory dir) async {
    const imageExtensions = { ".png", ".jpg", ".jpeg", ".bmp" };

    String? iconPath;
    List<String>? options;

    if (await dir.list().any((entry) => entry is File && imageExtensions.contains(path.extension(entry.path)))) {
      final entries = await dir.list()
        .where((entry) => entry is File && imageExtensions.contains(path.extension(entry.path)))
        .cast<File>()
        .toList();
      entries.sort((a, b) => path.basenameWithoutExtension(a.path) == "icon" ? -1 : 0);
      if (entries.isNotEmpty) {
        iconPath = path.relative(entries.first.path, from: dir.path);
      }
    }

    final directories = await dir.list()
      .where((entry) => entry is Directory)
      .cast<Directory>()
      .toList();
    if (directories.isNotEmpty) options = directories.map((dir) => path.basename(dir.path)).toList();

    return ModManifestLegacy(
      guid: Uuid().v4obj(),
      name: path.basename(dir.path),
      description: "A locally imported mod.",
      iconPath: iconPath,
      options: options,
      generated: true,
    );
  }

  static Future<ModManifest> fromFile(File file) async {
    final content = await file.readAsString();
    final json = json5Decode(content) as Map<String, dynamic>;
    return fromJson(json);
  }

  static ModManifest fromJson(Map<String, dynamic> json) {
    final version = json["Version"];
    return switch (version) {
      null => ModManifestLegacy.fromJson(json),
      1 => ModManifestV1.fromJson(json),
      _ => throw SerializationException("Unknown manifest version \"$version\"!"),
    };
  }

  ModData createModData() {
    return switch (this) {
      ModManifestLegacy _ => ModData.legacy(
        guid: getIdentifier(),
        index: 0,
      ),
      ModManifestV1 _ => ModData.v1(
        guid: getIdentifier(),
        toggled: List.filled((this as ModManifestV1).options?.length ?? 0, true),
        selected: List.filled((this as ModManifestV1).options?.length ?? 0, 0),
      ),
    };
  }

  Map<String, dynamic> toJson();

  UuidValue getIdentifier();
  
  String getName();

  String getDescription();

  NexusData? getNexusData();

  ModManifest upgrade();
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
  disallowUnrecognizedKeys: true,
)
final class NexusData {
  @JsonKey(
    name: "_generated",
    required: false,
    defaultValue: false,
  )
  final bool generated;
  @JsonKey(required: true)
  final int id;
  @JsonKey(required: false)
  final String? version;
  @JsonKey(
    name: "_fileId",
    required: false,
  )
  final int? fileId;

  NexusData({
    this.generated = false,
    required this.id,
    this.version,
    this.fileId,
  });
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
)
final class ModManifestLegacy extends ModManifest {
  @override
  bool get canUpgrade => true;

  @UuidValueConverter()
  @JsonKey(required: true)
  final UuidValue guid;
  @JsonKey(required: true)
  final String name;
  @JsonKey(required: true)
  final String description;
  @JsonKey(required: false)
  final String? iconPath;
  @JsonKey(required: false)
  final List<String>? options;
  @JsonKey(required: false)
  final NexusData? nexusData;
  @JsonKey(
    name: "_generated",
    required: false,
    defaultValue: false,
  )
  final bool generated;

  ModManifestLegacy({
    required this.guid,
    required this.name,
    required this.description,
    this.iconPath,
    this.options,
    this.nexusData,
    this.generated = false,
  }) {
    if (guid.isNil) throw FormatException("`Guid` can not be Nil!");
  }

  factory ModManifestLegacy.fromJson(Map<String, dynamic> json) => _$ModManifestLegacyFromJson(json);

  ModManifestLegacy copyWith({
    UuidValue? newGuid,
    String? newName,
    String? newDescription,
    String? newIconPath,
    List<String>? newOptions,
    NexusData? newNexusData,
  }) {
    return ModManifestLegacy(
      guid: newGuid ?? guid,
      name: newName ?? name,
      description: newDescription ?? description,
      iconPath: newIconPath ?? iconPath,
      options: newOptions ?? options,
      nexusData: newNexusData ?? nexusData,
      generated: generated,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$ModManifestLegacyToJson(this);

  @override
  UuidValue getIdentifier() => guid;

  @override
  String getName() => name;

  @override
  String getDescription()  => description;

  @override
  NexusData? getNexusData() => nexusData;

  @override
  ModManifest upgrade() {
    return ModManifestV1(
      guid: guid,
      name: name,
      description: description,
      iconPath: iconPath,
      options: options != null ? [
        ModOption(
          name: "Default",
          description: "",
          subOptions: options!.map((str) => ModSubOption(
            name: str,
            description: "",
            include: [str],
          )).toList()
        ),
      ] : null,
    );
  }
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
  disallowUnrecognizedKeys: true,
)
final class ModSubOption {
  @JsonKey(required: true)
  final String name;
  @JsonKey(required: true)
  final String description;
  @JsonKey(required: false)
  final String? image;
  @JsonKey(required: true)
  final List<String> include;

  ModSubOption({
    required this.name,
    required this.description,
    this.image,
    required this.include,
  });

  factory ModSubOption.fromJson(Map<String, dynamic> json) => _$ModSubOptionFromJson(json);

  Map<String, dynamic> toJson() => _$ModSubOptionToJson(this);
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
  disallowUnrecognizedKeys: true,
)
final class ModOption {
  @JsonKey(required: true)
  final String name;
  @JsonKey(required: true)
  final String description;
  @JsonKey(required: false)
  final String? image;
  @JsonKey(required: false)
  final List<String>? include;
  @JsonKey(required: false)
  final List<ModSubOption>? subOptions;

  ModOption({
    required this.name,
    required this.description,
    this.image,
    this.include,
    this.subOptions,
  });

  factory ModOption.fromJson(Map<String, dynamic> json) => _$ModOptionFromJson(json);

  Map<String, dynamic> toJson() => _$ModOptionToJson(this);
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
)
final class ModManifestV1 extends ModManifest {
  @override
  bool get canUpgrade => false;

  @JsonKey(required: true)
  final int version;
  @UuidValueConverter()
  @JsonKey(required: true)
  final UuidValue guid;
  @JsonKey(required: true)
  final String name;
  @JsonKey(required: true)
  final String description;
  @JsonKey(required: false)
  final String? iconPath;
  @JsonKey(required: false)
  final List<ModOption>? options;
  @JsonKey(required: false)
  final NexusData? nexusData;

  ModManifestV1({
    this.version = 1,
    required this.guid,
    required this.name,
    required this.description,
    this.iconPath,
    this.options,
    this.nexusData,
  }) : assert(version == 1) {
    if (guid.isNil) throw FormatException("`Guid` can not be Nil!");
  }

  factory ModManifestV1.fromJson(Map<String, dynamic> json) => _$ModManifestV1FromJson(json);

  ModManifestV1 copyWith({
    UuidValue? newGuid,
    String? newName,
    String? newDescription,
    String? newIconPath,
    List<ModOption>? newOptions,
    NexusData? newNexusData,
  }) {
    return ModManifestV1(
      guid: newGuid ?? guid,
      name: newName ?? name,
      description: newDescription ?? description,
      iconPath: newIconPath ?? iconPath,
      options: newOptions ?? options,
      nexusData: newNexusData ?? nexusData,
    );
  }

  @override
  Map<String, dynamic> toJson() => _$ModManifestV1ToJson(this);

  @override
  UuidValue getIdentifier() => guid;

  @override
  String getName() => name;

  @override
  String getDescription()  => description;

  @override
  NexusData? getNexusData() => nexusData;

  @override
  ModManifest upgrade() => throw UnsupportedError("Can't upgrade!");
}