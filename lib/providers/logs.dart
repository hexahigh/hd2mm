import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LogsProvider extends ChangeNotifier {
  UnmodifiableListView<LogRecord> get records => UnmodifiableListView(_records);
  Level get level => Logger.root.level;

  final _records = <LogRecord>[];

  LogsProvider() {
    Logger.root.onRecord.listen((record) {
      _records.add(record);
      notifyListeners();
    });
    Logger.root.onLevelChanged.listen((level) => notifyListeners());
  }
}