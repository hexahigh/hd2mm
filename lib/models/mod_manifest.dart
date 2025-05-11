import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../errors/serialization_exception.dart';
import '../helpers/uuid_converter.dart';
import 'mod_data.dart';

part 'mod_manifest.g.dart';

sealed class ModManifest {
  bool get canUpgrade;

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
        guid: getIdentifier() as UuidValue,
        index: 0,
      ),
      ModManifestV1 _ => ModData.v1(
        guid: getIdentifier() as UuidValue,
        toggled: List.filled((this as ModManifestV1).options?.length ?? 0, true),
        selected: List.filled((this as ModManifestV1).options?.length ?? 0, 0),
      ),
    };
  }

  Map<String, dynamic> toJson();

  Object getIdentifier();
  
  String getName();

  String getDescription();

  ModManifest upgrade();
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
)
final class ModManifestLegacy extends ModManifest {
  @override
  bool get canUpgrade => true;

  @UuidValueConverter()
  final UuidValue guid;
  final String name;
  final String description;
  final String? iconPath;
  final List<String>? options;

  ModManifestLegacy({
    required this.guid,
    required this.name,
    required this.description,
    this.iconPath,
    this.options,
  });

  factory ModManifestLegacy.fromJson(Map<String, dynamic> json) => _$ModManifestLegacyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ModManifestLegacyToJson(this);

  @override
  Object getIdentifier() => guid;

  @override
  String getName() => name;

  @override
  String getDescription()  => description;

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
)
final class ModSubOption {
  final String name;
  final String description;
  final String? image;
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
  final String name;
  final String description;
  final String? image;
  final List<String>? include;
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

  @JsonKey(
    name: "Version",
    includeToJson: true,
    includeFromJson: false, 
  )
  // ignore: unused_field
  final int _version;
  @UuidValueConverter()
  final UuidValue guid;
  final String name;
  final String description;
  final String? iconPath;
  final List<ModOption>? options;

  ModManifestV1({
    required this.guid,
    required this.name,
    required this.description,
    this.iconPath,
    this.options,
  }) : _version = 1;

  factory ModManifestV1.fromJson(Map<String, dynamic> json) => _$ModManifestV1FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ModManifestV1ToJson(this);

  @override
  Object getIdentifier() => guid;

  @override
  String getName() => name;

  @override
  String getDescription()  => description;

  @override
  ModManifest upgrade() => throw UnsupportedError("Can't upgrade!");
}