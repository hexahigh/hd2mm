import 'dart:io';

import 'package:path/path.dart' as path;

extension DirectoryExtensions on Directory {
  Future<bool> containsDirectory(String name) async {
    await for (final entry in list()) {
      if (entry is! Directory) continue;
      if (path.basename(entry.path) == name) return true;
    }
    return false;
  }

  Future<bool> containsFile(String name) async {
    await for (final entry in list()) {
      if (entry is! File) continue;
      if (path.basename(entry.path) == name) return true;
    }
    return false;
  }

  Future<Directory?> tryGetDirectory(String name) async {
    await for (final entry in list()) {
      if (entry is! Directory) continue;
      if (path.basename(entry.path) == name) return entry;
    }
    return null;
  }

  Future<File?> tryGetFile(String name) async {
    await for (final entry in list()) {
      if (entry is! File) continue;
      if (path.basename(entry.path) == name) return entry;
    }
    return null;
  }
}