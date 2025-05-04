import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/settings.dart';

enum ManagerInitProgress {
  test
}

final class ModManagerService {
  bool _initialized = false;
  late Settings _settings;
  late Directory _modsDir;

  ModManagerService();

  Future<void> init(Settings settings, [void Function(ManagerInitProgress)? progressCallback]) async {
    _settings = settings;
    
    _modsDir = Directory(path.join(_settings.storagePath.path, "mods"));

    

    _initialized = true;
  }
}