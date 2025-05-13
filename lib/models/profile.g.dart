// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Profile', json, ($checkedConvert) {
      final val = Profile(
        $checkedConvert('Name', (v) => v as String),
        $checkedConvert(
          'Mods',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => ModData.fromJson(e as Map<String, dynamic>))
                  .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'name': 'Name', 'mods': 'Mods'});

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'Name': instance.name,
  'Mods': instance.mods,
};

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProfileData', json, ($checkedConvert) {
      final val = ProfileData(
        $checkedConvert('Active', (v) => (v as num).toInt()),
        $checkedConvert(
          'Profiles',
          (v) =>
              (v as List<dynamic>)
                  .map((e) => Profile.fromJson(e as Map<String, dynamic>))
                  .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'active': 'Active', 'profiles': 'Profiles'});

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{'Active': instance.active, 'Profiles': instance.profiles};
