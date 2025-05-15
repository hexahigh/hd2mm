import 'dart:io';

import 'package:json5/json5.dart';
import 'package:path/path.dart' as path;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/settings.dart';
import '../components/mod_list.dart';
import '../models/profile.dart';
import '../services/mod_manager.dart';
import '../helpers/dialog.dart';

final class ModsPage extends StatefulWidget {
  const ModsPage({super.key});

  @override
  State<ModsPage> createState() => _ModsPageState();
}

final class _ModsPageState extends State<ModsPage> {
  final _log = Logger("ModsPage");
  bool _loading = true;
  late Settings _settings;
  late ModManagerService _manager;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            CircularProgressIndicator(),
            Text("Loading..."),
          ],
        ),
      );
    } else {
      if (_dragging) {
        return DropTarget(
          onDragExited: (_) => setState(() => _dragging = false),
          onDragDone: _onDragDrop,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                Text(
                  "Add mods",
                  style: TextStyle(fontSize: 24),
                ),
                Icon(
                  Icons.download,
                  size: 50,
                ),
              ],
            ),
          ),
        );
      } else {
        final sideBar = SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 3,
            children: [
              ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: Text("Add"),
              ),
              if (_settings.developerMode)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, "/create"),
                  icon: const Icon(Icons.create),
                  label: Text("Create"),
                ),
              ElevatedButton(
                onPressed: null,
                child: Text("Import"),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text("Export"),
              ),
              Row(
                spacing: 3,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => launchUrlString("https://discord.gg/helldiversmodding"),
                      child: const Icon(
                        Icons.discord,
                        size: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,//() => launchUrlString("https://github.com/teutinsa/hd2mm"),
                      child: ImageIcon(
                        AssetImage("assets/images/github.png"),
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: null,//() => Navigator.pushNamed(context, "/help"),
                icon: const Icon(Icons.help_outline),
                label: Text("Help"),
              ),
              ElevatedButton.icon(
                onPressed: null,//() => launchUrlString("https://github.com/teutinsa/hd2mm/issues/new"),
                icon: const Icon(Icons.bug_report),
                label: Text("Report Bug"),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, "/about"),
                icon: const Icon(Icons.info_outline),
                label: Text("About"),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToSettings,
                icon: const Icon(Icons.settings),
                label: Text("Settings"),
              ),
            ],
          ),
        );

        final menuBar = Row(
          spacing: 3,
          children: [
            Expanded(
              child: DropdownButton(
                isExpanded: true,
                items: _manager.profiles.map((profile) => DropdownMenuItem(
                  value: profile,
                  child: Text(profile.name),
                ))
                .toList(),
                value: _manager.activeProfile,
                onChanged: _changeProfile,
              ),
            ),
            IconButton(
              onPressed: _addProfile,
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: _deleteProfile,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        );

        final centerPanel = ModList(
          manager: _manager,
          key: ObjectKey(_manager.activeProfile),
        );

        final toolBar = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 3,
          children: [
            ElevatedButton(
              onPressed: _purge,
              style: ButtonStyle(
                foregroundColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.red[200]!;
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.redAccent;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.red[400]!;
                  }
                  return Colors.red;
                }),
              ),
              child: Text("Purge"),
            ),
            ElevatedButton(
              onPressed: _deploy,
              style: ButtonStyle(
                foregroundColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.green[200]!;
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.greenAccent;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.green[400]!;
                  }
                  return Colors.green;
                }),
              ),
              child: Text("Deploy"),
            ),
            ElevatedButton(
              onPressed: _launch,
              style: ButtonStyle(
                foregroundColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.yellow[200]!;
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.yellowAccent;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.yellow[400]!;
                  }
                  return Colors.yellow;
                }),
              ),
              child: Text("Launch HD2"),
            ),
          ],
        );

        final layout = Row(
          spacing: 5,
          children: [
            sideBar,
            Expanded(
              child: Column(
                spacing: 5,
                children: [
                  menuBar,
                  Expanded(child: centerPanel),
                  toolBar,
                ],
              ),
            ),
          ],
        );

        return DropTarget(
          onDragEntered: (_) => setState(() => _dragging = true),
          child: layout,
        );
      }
    }
  }

  Future<void> _load() async {
    _log.info("Loading...");

    final settingsFile = File("settings.json");
    if (!await settingsFile.exists()) {
      _log.info("Settings file not found.");
      Navigator.pushReplacementNamed(context, "/settings");
      showNotificationDialog(
        context,
        text: "Setting file not found. Please perform the first time setup.",
      );
      return;
    }

    final content = await settingsFile.readAsString();
    final json = json5Decode(content) as Map<String, dynamic>;
    final settings = Settings.fromJson(json);

    if (!await settings.validate()) {
      _log.warning("Settings file invalid.");
      Navigator.pushReplacementNamed(context, "/settings");
      showNotificationDialog(
        context,
        type: NotificationType.error,
        text: "Some settings are invalid.",
      );
      return;
    }

    _settings = settings;

    _manager = ModManagerService();
    await _manager.init(_settings);

    _log.info("Loading complete");
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    showWaitDialog(context, title: "Saving");

    await _manager.save();

    closeDialog(context);
  }

  Future<void> _navigateToSettings() async {
    await _save();
    Navigator.pushReplacementNamed(context, "/settings");
  }

  Future<void> _onDragDrop(DropDoneDetails details) async {
    final files = <File>[];
    for (final item in details.files) {
      if (!await FileSystemEntity.isFile(item.path)) continue;
      files.add(File(item.path));
    }
    await _addFiles(files);
  }

  void _changeProfile(Profile? profile) {
    if (profile == null) return;
    setState(() => _manager.activeProfile = profile);
  }

  Future<void> _addProfile() async {
    final result = await showPromptDialog(
      context,
      title: "New Profile",
      hint: "Profile Name",
    );
    if (result == null) return;

    final profile = _manager.addProfile(result);
    if (profile == null) {
      showNotificationDialog(
        context,
        text: "Profile with that name already exists.",
        type: NotificationType.error
      );
      return;
    }

    setState(() => _manager.activeProfile = profile);
  }

  Future<void> _deleteProfile() async {
    final result = await showConfirmDialog(
      context,
      title: "Delete",
      question: "Do you really want to delete the profile \"${_manager.activeProfile.name}\"?",
    );
    if (!result) return;
    setState(() => _manager.removeProfile(_manager.activeProfile));
  }

  Future<void> _purge() async {
    showWaitDialog(context, title: "Purging");

    try {
      await _manager.purge();
    } on Exception catch (ex) {
      closeDialog(context);
      showNotificationDialog(
        context,
        text: "Purging failed!\n$ex",
        type: NotificationType.error
      );
      return;
    }

    closeDialog(context);
  }

  Future<void> _deploy() async {
    showWaitDialog(context, title: "Deploying");

    try {
      await _manager.deploy();
    } on Exception catch (ex) {
      closeDialog(context);
      showNotificationDialog(
        context,
        text: "Deployment failed!\n$ex",
        type: NotificationType.error,
      );
      return;
    }

    closeDialog(context);
    showNotificationDialog(
      context,
      text: "Deployment successful.",
    );
  }

  Future<void> _launch() async {
    showWaitDialog(context, title: "Launching Helldivers 2");

    await launchUrlString("steam://launch/553850");

    closeDialog(context);
  }

  Future<void> _add() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: const [
        "tar.gz",
        "tgz",
        "tar.bz2",
        "tbz",
        "tar.xz",
        "txz",
        "tar",
        "zip",
      ],
      dialogTitle: "Please select mod archives to add.",
      lockParentWindow: true,
      type: FileType.custom,
    );

    if (result == null) return;

    final files = result.files
      .where((file) => file.path != null)
      .map((file) => File(file.path!))
      .toList(growable: false);

    await _addFiles(files);
  }

  Future<void> _addFiles(List<File> files) async {
    final errors = <Object>[];
    for (final file in files) {
      if (file.path.isEmpty) continue;

      showWaitDialog(
        context,
        title: "Adding mod \"${path.basename(file.path)}\"",
      );

      try {
        if (!await _manager.addMod(File(file.path))) {
          errors.add("Mod already exists!");
        }
      } on Exception catch (ex) {
        errors.add(ex);
      }

      closeDialog(context);
    }

    setState(() { /* Invalidate for redraw since _manager changed */ });

    if (errors.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln("Adding failed!");

      for (final MapEntry(key: i, value: e) in errors.asMap().entries) {
        buffer.write(i);
        buffer.write(": ");
        buffer.writeln(e);
      }

      showNotificationDialog(
        context,
        text: buffer.toString(),
        type: NotificationType.error,
      );
    }
  }
}
