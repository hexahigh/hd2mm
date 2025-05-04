import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import '../helpers/directory_converter.dart';
import '../helpers/directory_extensions.dart';

part 'settings.g.dart';

@JsonSerializable(
  checked: true,
  fieldRename: FieldRename.pascal,
)
final class Settings {
  @DirectoryConverter()
  Directory tempPath;
  @DirectoryConverter()
  Directory? gamePath;
  @DirectoryConverter()
  Directory storagePath;
  bool caseSensitiveSearch;
  bool developerMode;
  @JsonKey(
    fromJson: _levelFromJson,
    toJson: _levelToJson,
  )
  Level logLevel;
  List<String> skipList;

  Settings({
    required this.tempPath,
    required this.gamePath,
    required this.storagePath,
    required this.caseSensitiveSearch,
    required this.developerMode,
    required this.logLevel,
    required this.skipList,
  });

  factory Settings.defaultWith({
    Directory? tempPath,
    Directory? gamePath,
    Directory? storagePath,
    bool? caseSensitiveSearch,
    bool? developerMode,
    Level? logLevel,
    List<String>? skipList,
  }) {
    final settings = Settings.$default();
    if (tempPath != null) settings.tempPath = tempPath;
    if (gamePath != null) settings.gamePath = gamePath;
    if (storagePath != null) settings.storagePath = storagePath;
    if (caseSensitiveSearch != null) settings.caseSensitiveSearch = caseSensitiveSearch;
    if (developerMode != null) settings.developerMode = developerMode;
    if (logLevel != null) settings.logLevel = logLevel;
    if (skipList != null) settings.skipList = skipList;
    return settings;
  }
  
  factory Settings.$default() {
    final tempPath = Directory(
      Platform.isWindows
      ? path.join(Platform.environment["TEMP"]!, "hd2mm")
      : "/tmp/hd2mm"
    );
    final storagePath = Directory(
      Platform.isWindows
      ? path.join(Platform.environment["LOCALAPPDATA"]!, "hd2mm")
      : "~/.local/share/hd2mm"
    );
    return Settings(
      tempPath: tempPath,
      gamePath: null,
      storagePath: storagePath,
      caseSensitiveSearch: false,
      developerMode: false,
      logLevel: Level.WARNING,
      skipList: [],
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  Future<bool> validate() async {
    try {
      if (gamePath == null) return false;
      if (!await gamePath!.exists()) return false;
      
      final binDir = await gamePath!.tryGetDirectory("bin");
      if (binDir == null) return false;
      
      final exeName = Platform.isWindows ? "helldivers2.exe" : "helldivers";
      if (!await binDir.containsFile(exeName)) return false;

      if (!await gamePath!.containsDirectory("data")) return false;

      if (!await gamePath!.containsDirectory("tools")) return false;
      
      return true;
    } catch (e, s) {
      Logger.root.severe("Settings validation failed!", e, s);
      return false;
    }
  }

  static Level _levelFromJson(String value) {
    final i = Level.LEVELS.indexWhere((lvl) => lvl.name == value);
    if (i == -1) return Level.ALL;
    return Level.LEVELS[i];
  }

  static String _levelToJson(Level value) {
    return value.name;
  }
}