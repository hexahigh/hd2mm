import 'dart:io';

import 'package:path/path.dart' as path;

import 'mod_manifest.dart';

final class Mod {
  final Directory directory;
  final ModManifest manifest;

  const Mod(this.directory, this.manifest);

  Future<File?> getFile(String filePath) async {
    final file = File(path.join(directory.path, filePath));
    if (!await file.exists()) return null;
    return file;
  }
  
  File? getFileSync(String filePath) {
    final file = File(path.join(directory.path, filePath));
    if (!file.existsSync()) return null;
    return file;
  }
}