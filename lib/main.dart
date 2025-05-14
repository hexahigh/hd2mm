import 'dart:convert';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'helpers/dialog.dart';
import 'models/settings.dart';
import 'pages/about.dart';
import 'pages/help.dart';
import 'pages/mods.dart';
import 'pages/settings.dart';
import 'pages/error.dart';
import 'package:http/http.dart' as http;

void main() {
  if (kDebugMode) {
    final logDir = Directory("logs");
    logDir.deleteSync(recursive: true);
  }

  final logFile = File("logs/${DateFormat("yyyy-MM-dd_HH-mm-ss").format(DateTime.now())}.log");
  logFile.createSync(recursive: true);
  final logWriter = logFile.openWrite();

  // initialize logging
  Logger.root.onRecord.listen((LogRecord event) {
    final buffer = StringBuffer();
    
    buffer
      ..write(event.time)
      ..write(" [")
      ..write(event.level)
      ..write("] ")
      ..write(event.loggerName)
      ..write(": ")
      ..write(event.message.replaceAll("\n", "\n| "));

    if (event.error != null) {
      buffer.writeln();
      buffer.write(event.error);
    }

    if (event.stackTrace != null) {
      buffer.writeln();
      buffer.write(event.stackTrace);
    }

    final line = buffer.toString();
    // ignore: avoid_print
    print(line);
    logWriter.writeln(line);
  });

  if (kDebugMode) {
    Logger.root.level = Level.ALL;
  } else {
    // acquire log level from settings if they exist
    final settingsFile = File("settings.json");
    if (settingsFile.existsSync()) {
      try {
        final content = settingsFile.readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final settings = Settings.fromJson(json);
        Logger.root.level = settings.logLevel;
      } catch (e, s) {
        Logger.root.severe("Failed to set log level!", e, s);
      }
    }
  }

  // ensure binding initialization
  WidgetsFlutterBinding.ensureInitialized();

  // hook into unhandled errors
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.root.severe("Flutter error!", details.exception, details.stack);
  };
  
  // run the app
  runApp(const Hd2mmApp());

  doWhenWindowReady(() {
    const initialSize = Size(900, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Helldivers 2 Mod Manager";
    appWindow.show();
  });
}

class Hd2mmApp extends StatelessWidget {
  const Hd2mmApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Helldivers 2 Mod Manager",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ThemeData.dark(useMaterial3: true).colorScheme,
        fontFamily: "FS Sinclair",
      ),
      home: Scaffold(
        body: WindowBorder(
          color: Theme.of(context).dividerColor,
          width: 4,
          child: Column(
            children: [
              _TitleBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 3,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Navigator(
                    initialRoute: "/mods",
                    onGenerateRoute: (RouteSettings settings) {
                      Widget page = switch (settings.name) {
                        "/mods" => const ModsPage(),
                        "/settings" => const SettingsPage(),
                        "/help" => HelpPage(),
                        "/about" => AboutPage(),
                        "/error" => ErrorPage(arguments: settings.arguments),
                        _ => const Placeholder(color: Colors.red),
                      };
                      return MaterialPageRoute(
                        builder: (_) => page,
                        settings: settings,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _TitleBar extends StatefulWidget {
  const _TitleBar();

  @override
  State<_TitleBar> createState() => _TitleBarState();
}

final class _TitleBarState extends State<_TitleBar> {
  static final _updateButtonColors = WindowButtonColors(
    iconNormal: Colors.green,
    iconMouseDown: Colors.green,
    iconMouseOver: Colors.green,
  );
  final _log = Logger("TitleBar");

  ({String name, String version, String description})? _updateInfo;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MoveWindow(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 3,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const Text(
                    "Mod Manager",
                    style: TextStyle(
                      fontSize: 44,
                      fontFamily: "Blockletter",
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("v2.0.0"),
                      Text("(Preview 1)"),
                      if (kDebugMode)
                        Text(
                          "(Debug)",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_updateInfo != null)
                    Tooltip(
                      message: "A new version is available. Do you want to update now?\n${_updateInfo?.name} ${_updateInfo?.version}\n\t${_updateInfo?.description.replaceAll("\n", "\n\t")}",
                      child: WindowButton(
                        padding: const EdgeInsets.all(3),
                        iconBuilder: (buttonContext) => Icon(
                          Icons.file_download_outlined,
                          color: buttonContext.iconColor,
                        ),
                        onPressed: _update,
                        colors: _updateButtonColors,
                      ),
                    ),
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    const token = String.fromEnvironment("GITHUB_TOKEN");
    if (token.isEmpty) {
      _log.severe("GitHub token not found!");
      return;
    }
    
    final response = await http.get(
      Uri.parse("https://api.github.com/repos/teutinsa/hd2mm/releases/latest"),
      headers: {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer $token",
        "X-GitHub-Api-Version": "2022-11-28",
      },
    );

    if (response.statusCode != 200) {
      _log.severe("GET request for latest release failed with code ${response.statusCode}!\nBody: ${response.body}");
      return;
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      _log.severe("JSON root was not of type `object`!");
      return;
    }
    
    final name = json["name"];
    if (name == null) {
      _log.severe("JSON root object did not contain field `name`!");
      return;
    }
    if (name is! String) {
      _log.severe("JSON field `name` was not of type `string`!");
      return;
    }

    final tag = json["tag_name"];
    if (tag == null) {
      _log.severe("JSON root object did not contain field `tag_name`!");
      return;
    }
    if (tag is! String) {
      _log.severe("JSON field `tag_name` was not of type `string`!");
      return;
    }

    final body = json["body"];
    if (body == null) {
      _log.severe("JSON root object did not contain field `body`!");
      return;
    }
    if (body is! String) {
      _log.severe("JSON field `body` was not of type `string`!");
      return;
    }

    final assets = json["assets"];
    if (assets == null) {
      _log.severe("JSON root object did not contain field `assets`!");
      return;
    }
    if (assets is! List<dynamic>) {
      _log.severe("JSON field `assets` was not of type `array`!");
      return;
    }
    
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) {
        _log.severe("JSON array element was not of type `object`!");
        return;
      }
    }
  }

  Future<void> _update() async {
    showWaitDialog(
      context,
      title: "Updating"
    );


  }
}