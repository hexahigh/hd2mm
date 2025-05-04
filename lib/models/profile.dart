import 'package:json_annotation/json_annotation.dart';

import 'mod_data.dart';

part 'profile.g.dart';

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
)
final class Profile {
  final String name;
  final List<ModData> mods;

  Profile(this.name) : mods = [];

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
)
final class ProfileData {
  int active;
  final List<Profile> profiles;

  ProfileData(this.active, this.profiles);

  factory ProfileData.fromJson(Map<String, dynamic> json) => _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}