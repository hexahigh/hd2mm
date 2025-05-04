import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hd2mm/models/settings.dart';
import 'package:logging/logging.dart';
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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
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
      final _sideBar = SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 3,
          children: [
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.add),
              label: Text("Add"),
            ),
            ElevatedButton.icon(
              onPressed: null,
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
            Spacer(),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, "/help"),
              icon: const Icon(Icons.help_outline),
              label: Text("Help"),
            ),
            ElevatedButton.icon(
              onPressed: null,
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

      final _menuBar = Placeholder(fallbackHeight: 50);

      final _centerPanel = Placeholder();

      final _toolBar = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 3,
        children: [
          ElevatedButton(
            onPressed: null,
            child: Text("Purge"),
          ),
          ElevatedButton(
            onPressed: null,
            child: Text("Deploy"),
          ),
          ElevatedButton(
            onPressed: null,
            child: Text("Launch HD2"),
          ),
        ],
      );

      return Row(
        spacing: 5,
        children: [
          _sideBar,
          Expanded(
            child: Column(
              spacing: 5,
              children: [
                _menuBar,
                Expanded(child: _centerPanel),
                _toolBar,
              ],
            ),
          ),
        ],
      );
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
    final json = jsonDecode(content);
    final settings = Settings.fromJson(json);

    if (!await settings.validate()) {
      _log.warning("Settings file invalid.");
      Navigator.pushReplacementNamed(context, "/settings");
      showNotificationDialog(
        context,
        type: NotificationType.warning,
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
    showWaitDialog(
      context,
      title: "Saving",
    );

    //TODO: save

    closeDialog(context);
  }

  Future<void> _navigateToSettings() async {
    await _save();
    Navigator.pushReplacementNamed(context, "/settings");
  }
}