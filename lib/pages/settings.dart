import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json5/json5.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import '../helpers/dialog.dart';
import '../helpers/directory_extensions.dart';
import '../models/settings.dart';
import '../interop/interop.dart';

final class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

final class _SettingsPageState extends State<SettingsPage> {
  static final File _settingsFile = File("settings.json");
  final _log = Logger("Settings");
  var _gamePathController = TextEditingController();
  var _storagePathController = TextEditingController();
  var _tempPathController = TextEditingController();
  bool _caseSensitive = true;
  bool _developerMode = false;
  Level _logLevel = Level.ALL;
  List<String> _skipList = [];
  String? _gamePathError;
  String? _storagePathError;
  String? _tempPathError;
  CancelableOperation<void>? _gamePathCheckOperation;
  CancelableOperation<void>? _storagePathCheckOperation;
  CancelableOperation<void>? _tempPathCheckOperation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(5),
            children: [
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: Tooltip(
                      message: "The path to your Helldivers 2 installation.",
                      margin: const EdgeInsets.all(3),
                      child: TextField(
                        controller: _gamePathController,
                        onChanged: (value) {
                          _gamePathCheckOperation?.cancel();
                          _gamePathCheckOperation = CancelableOperation.fromFuture(_checkGamePath(value));
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Game Path",
                          hintText: Platform.isWindows ? "eg. \"C:\\Program Files (x86)\\Steam\\steamapps\\common\\Helldivers 2\\\"" : "eg. \"~/.local/share/Steam/steamapps/common/Helldivers 2/\"",
                          errorText: _gamePathError,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _browseGame,
                    tooltip: "Browse game path",
                    icon: const Icon(Icons.folder_open),
                  ),
                  Tooltip(
                    message: "Try to detect the games installation location automatically.",
                    margin: const EdgeInsets.all(3),
                    child: TextButton(
                      onPressed: _tryDetectGame,
                      child: Text("Detect"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ExpansionTile(
                initiallyExpanded: _storagePathError != null || _tempPathError != null,
                title: Text("Advanced"),
                childrenPadding: const EdgeInsets.all(5),
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: "A path to a folder where the Manager can store it's data.",
                          margin: const EdgeInsets.all(3),
                          child: TextField(
                            controller: _storagePathController,
                            onChanged: (value) {
                              _storagePathCheckOperation?.cancel();
                              _storagePathCheckOperation = CancelableOperation.fromFuture(_checkStoragePath(value));
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Storage Path",
                              hintText: Platform.isWindows ? "Default: \"\"" : "Default: \"\"",
                              errorText: _storagePathError,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _browseStorage,
                        tooltip: "Browse storage path",
                        icon: const Icon(Icons.folder_open),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: "A path to a folder that the Manager will use for temporary storage. (SSD advised)",
                          margin: const EdgeInsets.all(3),
                          child: TextField(
                            controller: _tempPathController,
                            onChanged: (value) {
                              _tempPathCheckOperation?.cancel();
                              _tempPathCheckOperation = CancelableOperation.fromFuture(_checkTempPath(value));
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Temporary Path",
                              hintText: Platform.isWindows ? "Default: \"\"" : "Default: \"\"",
                              errorText: _tempPathError,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _browseTemp,
                        tooltip: "Browse temporary path",
                        icon: const Icon(Icons.folder_open),
                      ),
                    ],
                  ),
                ],
              ),
              SwitchListTile(
                title: Text("Case sensitive search"),
                value: _caseSensitive,
                onChanged: (value) => setState(() => _caseSensitive = value),
              ),
              const Divider(),
              ListTile(
                title: Text("Actions"),
                subtitle: Column(
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        ElevatedButton(
                          onPressed: null,//_importV1Stuff,
                          child: Text("Import V1 Manager content"),
                        ),
                        Expanded(
                          child: Text(
                            "Imports all mods and previous mod settings from MM version 1 as their own profile.",
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: Text("Developer mode"),
                subtitle: _developerMode ? null : Text("This option enables features intended to help mod developers."),
                value: _developerMode,
                onChanged: (value) => setState(() => _developerMode = value),
              ),
              if (_developerMode)
                ...[
                  ListTile(
                    title: Text("Log level"),
                    subtitle: DropdownButton(
                      items: Level.LEVELS.map((lvl) {
                        return DropdownMenuItem(
                          value: lvl,
                          child: Text(lvl.name),
                        );
                      }).toList(growable: false),
                      isExpanded: true,
                      value: _logLevel,
                      onChanged: (value) => setState(() => _logLevel = value ?? Level.ALL),
                    ),
                  ),
                  ListTile(
                    title: Text("Skip list"),
                    subtitle: Column(
                      spacing: 3,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 3,
                            ),
                          ),
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              itemCount: _skipList.length,
                              itemBuilder: (context, index) => Text(_skipList[index]),
                            ),
                          ),
                        ),
                        Row(
                          spacing: 5,
                          children: [
                            IconButton(
                              onPressed: null,
                              icon: const Icon(Icons.add),
                            ),
                            IconButton(
                              onPressed: null,
                              icon: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
            ],
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: _reset,
              style: ButtonStyle(
                foregroundColor: WidgetStateColor.resolveWith((state) {
                  if (state.contains(WidgetState.disabled)) {
                    return Colors.red[300]!;
                  }
                  return Colors.red;
                })
              ),
              child: Text("Reset"),
            ),
            Spacer(),
            TextButton(
              onPressed: _save,
              style: ButtonStyle(
                foregroundColor: WidgetStateColor.resolveWith((state) {
                  if (state.contains(WidgetState.disabled)) {
                    return Colors.green[300]!;
                  }
                  return Colors.green;
                })
              ),
              child: Text("OK"),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _load() async {
    showWaitDialog(
      context,
      title: "Loading",
    );

    if (await _settingsFile.exists()) {
      final content = await _settingsFile.readAsString();
      final json = json5Decode(content) as Map<String, dynamic>;
      final settings = Settings.fromJson(json);
      _apply(settings);
    } else {
      _reset();
    }

    closeDialog(context);
  }

  Future<void> _browseGame() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select your Helldivers 2 install path",
      lockParentWindow: true,
    );
    if (result != null) {
      setState(() => _gamePathController = TextEditingController(text: result));
      _gamePathCheckOperation?.cancel();
      _gamePathCheckOperation = CancelableOperation.fromFuture(_checkGamePath(result));
    }
  }

  Future<void> _browseStorage() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select the storage directory for the Manager",
      lockParentWindow: true,
    );
    if (result != null) {
      setState(() => _storagePathController = TextEditingController(text: result));
      _storagePathCheckOperation?.cancel();
      _storagePathCheckOperation = CancelableOperation.fromFuture(_checkStoragePath(result));
    }
  }

  Future<void> _browseTemp() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select the temporary directory for the Manager",
      lockParentWindow: true,
    );
    if (result != null) {
      setState(() => _tempPathController = TextEditingController(text: result));
      _tempPathCheckOperation?.cancel();
      _tempPathCheckOperation = CancelableOperation.fromFuture(_checkTempPath(result));
    }
  }

  Future<bool> _validateGameDir(Directory dir) async {
    final binDir = await dir.tryGetDirectory("bin");
    if (binDir == null) return false;
    if (!await binDir.containsFile("helldivers2.exe")) return false;
    if (!await dir.containsDirectory("data")) return false;
    if (!await dir.containsDirectory("tools")) return false;
    return true;
  }

  Future<void> _tryDetectGame() async {
    showWaitDialog(
      context,
      title: "Looking for game",
    );

    final stopwatch = Stopwatch();
    stopwatch.start();

    String? gamePath;
    if (Platform.isWindows) {
      final drives = Interop.instance.getDrives();
      for (var drive in drives) {
        final dirPath = drive.name == "C:\\"
          ? path.join(drive.name, "Program Files (x86)", "Steam", "steamapps", "common", "Helldivers 2")
          : path.join(drive.name, "SteamLibrary", "steamapps", "common", "Helldivers 2");
        final dir = Directory(dirPath);
        if (!await dir.exists()) continue;
        if (!await _validateGameDir(dir)) continue;
        gamePath = dirPath;
        break;
      }
    } else {
      final paths = const <String>[
        "~/.steam/steam/steamapps/common/Helldivers 2",
        "~/.local/share/Steam/steamapps/common/Helldivers 2",
      ];
      for (final dirPath in paths) {
        final dir = Directory(dirPath);
        if (!await dir.exists()) continue;
        if (!await _validateGameDir(dir)) continue;
        gamePath = dirPath;
        break;
      }
    }

    stopwatch.stop();
    final delay = 200 - stopwatch.elapsedMilliseconds;
    if (delay > 0) {
      await Future.delayed(Duration(milliseconds: delay));
    }

    closeDialog(context);

    if (gamePath == null) {
      showNotificationDialog(
        context,
        text: "Could not automatically detect game!\nPlease select your install location manually.",
        type: NotificationType.error,
      );
    } else {
      setState(() {
        _gamePathController = TextEditingController(text: gamePath);
        _gamePathError = null;
      });
    }
  }

  void _reset() {
    _apply(Settings.$default());
    setState(() {
      _gamePathError = "Path can not be empty!";
      _storagePathError = null;
      _tempPathError = null;
    });
  }

  void _apply(Settings settings) {
    setState(() {
      _gamePathController = settings.gamePath != null
      ? TextEditingController(text: settings.gamePath!.path)
      : TextEditingController();
      _storagePathController = TextEditingController(text: settings.storagePath.path);
      _tempPathController = TextEditingController(text: settings.tempPath.path);
      _caseSensitive = settings.caseSensitiveSearch;
      _developerMode = settings.developerMode;
      _logLevel = settings.logLevel;
      _skipList = settings.skipList;
    });
  }

  Future<void> _save() async {
    _log.info("Saving settings...");

    showWaitDialog(
      context,
      title: "Saving",
    );

    if (_gamePathError != null) {
      closeDialog(context);
      showNotificationDialog(
        context,
        text: _gamePathError!,
        type: NotificationType.error,
      );
      return;
    }

    if (_storagePathError != null) {
      closeDialog(context);
      showNotificationDialog(
        context,
        text: _storagePathError!,
        type: NotificationType.error,
      );
      return;
    }

    if (_tempPathError != null) {
      closeDialog(context);
      showNotificationDialog(
        context,
        text: _tempPathError!,
        type: NotificationType.error,
      );
      return;
    }

    final settings = Settings(
      tempPath: Directory(_tempPathController.text),
      gamePath: Directory(_gamePathController.text),
      storagePath: Directory(_storagePathController.text),
      caseSensitiveSearch: _caseSensitive,
      developerMode: _developerMode,
      logLevel: _developerMode ? _logLevel : Level.WARNING,
      skipList: _developerMode ? _skipList : const [],
    );
    final json = settings.toJson();
    final content = jsonEncode(json);

    await _settingsFile.writeAsString(content);

    closeDialog(context);
    _log.info("Settings saved.");
    Navigator.pushReplacementNamed(context, "/mods");
  }

  Future<void> _checkGamePath(String gamePath) async {
    if (gamePath.isEmpty) {
      setState(() => _gamePathError = "Path can not be empty!");
      return;
    }

    final dir = Directory(gamePath);
    if (!await dir.exists()) {
      setState(() => _gamePathError = "Game path does not exist!");
      return;
    }
    
    final binDir = await dir.tryGetDirectory("bin");
    if (binDir == null) {
      setState(() => _gamePathError = "Game path does not contain a directory called \"bin\"!");
      return;
    }

    if (!await binDir.containsFile("helldivers2.exe")) {
      setState(() => _gamePathError = "Directory \"bin\" in game path does not contain a file called \"helldivers2.exe\"!");
      return;
    }

    if (!await dir.containsDirectory("data")) {
      setState(() => _gamePathError = "Game path does not contain a directory called \"data\"!");
      return;
    }

    if (!await dir.containsDirectory("tools")) {
      setState(() => _gamePathError = "Game path does not contain a directory called \"tools\"!");
      return;
    }

    setState(() => _gamePathError = null);
  }

  Future<void> _checkStoragePath(String storagePath) async {
    if (storagePath.isEmpty) {
      setState(() => _storagePathError = "Path can not be empty!");
      return;
    }

    if (!await FileSystemEntity.isDirectory(storagePath)) {
      setState(() => _storagePathError = "Path is not a directory");
      return;
    }

    setState(() => _storagePathError = null);
  }

  Future<void> _checkTempPath(String tempPath) async {
    if (tempPath.isEmpty) {
      setState(() => _tempPathError = "Path can not be empty!");
      return;
    }

    if (!await FileSystemEntity.isDirectory(tempPath)) {
      setState(() => _tempPathError = "Path is not a directory");
      return;
    }

    setState(() => _tempPathError = null);
  }

  Future<void> _importV1Stuff() async {
    
  }
}