import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:hd2mm/helpers/directory_extensions.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../errors/not_initialized_error.dart';
import '../models/mod.dart';
import '../models/mod_manifest.dart';
import '../models/profile.dart';
import '../models/settings.dart';

enum ManagerInitProgress {
  loadingMods,
  loadingProfiles,
  checkingProfiles,
  complete,
}

final class ModManagerService {
  Profile get activeProfile => _profiles.profiles[_profiles.active];

  set activeProfile(Profile value) {
    final i = _profiles.profiles.indexOf(value);
    if (i == -1) return;
    _profiles.active = i;
  }

  UnmodifiableListView<Mod> get mods => UnmodifiableListView(_mods);

  UnmodifiableListView<Profile> get profiles => UnmodifiableListView(_profiles.profiles);

  final _log = Logger("ModManagerService");
  bool _initialized = false;
  late Settings _settings;
  late Directory _modsDir;
  final List<Mod> _mods = [];
  late File _profilesFile;
  late ProfileData _profiles;

  ModManagerService();

  Future<void> init(Settings settings, [void Function(ManagerInitProgress)? progressCallback]) async {
    _mods.clear();

    _log.info("Initializing manager service...");
    _settings = settings;
    
    _log.info("Loading mods...");
    progressCallback?.call(ManagerInitProgress.loadingMods);
    _modsDir = Directory(path.join(_settings.storagePath.path, "mods"));
    if (await _modsDir.exists()) {
      await for (final entry in _modsDir.list()) {
        if (entry is! Directory) continue;
        
        final manifestFile = await entry.tryGetFile("manifest.json");
        
        if (manifestFile == null) {
          _log.warning("Directory \"${path.basename(entry.path)}\" does not contain a manifest. Consider removing it.");
          continue;
        }

        try {
          final source = await manifestFile.readAsString();
          final json = jsonDecode(source);
          final manifest = ModManifest.fromJson(json);
          _mods.add(Mod(entry, manifest));
        } on Exception catch (e) {
          _log.severe("Error reading manifest in directory \"${path.basename(entry.path)}\"!", e);
        }
      }
    } else {
      await _modsDir.create(recursive: true);
    }

    _log.info("Loading profiles...");
    progressCallback?.call(ManagerInitProgress.loadingProfiles);
    _profilesFile = File(path.join(_settings.storagePath.path, "profiles.json"));
    if (await _profilesFile.exists()) {
      final source = await _profilesFile.readAsString();
      final json = jsonDecode(source);
      _profiles = ProfileData.fromJson(json);
    } else {
      _profiles = ProfileData(0, [ Profile("Default") ]);
    }

    //TODO: Check profiles

    _initialized = true;
    progressCallback?.call(ManagerInitProgress.complete);
    _log.info("Initialization complete.");
  }

  Mod? getModByGuid(UuidValue guid) {
    if (!_initialized) throw NotInitializedError("ModManagerService");

    for (final mod in _mods) {
      if (mod.manifest.getIdentifier() == guid) {
        return mod;
      }
    }
    return null;
  }

  Future<void> save() async {
    if (!_initialized) throw NotInitializedError("ModManagerService");

    final object = _profiles.toJson();
    final content = jsonEncode(object);
    await _profilesFile.writeAsString(content);
  }

  bool makeNewProfile(String name, [bool activate = false]) {
    if (!_initialized) throw NotInitializedError("ModManagerService");

    if (_profiles.profiles.any((p) => p.name == name)) return false;

    final profile = Profile(name);
    _profiles.profiles.add(profile);

    if (activate) {
      final index = _profiles.profiles.indexOf(profile);
      _profiles.active = index;
    }

    return true;
  }

  Future<void> addMod(File archiveFile) async {
    //TODO: Implement mod adding
    throw UnimplementedError();
  }

  Future<void> removeMod(Mod mod) async {
    await mod.directory.delete(recursive: true);
    _mods.remove(mod);
  }

  Future<void> purge() async {

  }

  Future<void> deploy() async {
    
  }
}