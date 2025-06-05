import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../providers/logs.dart';

class LogsPage extends StatelessWidget {
  final _controller = ScrollController();

  LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<LogsProvider>();
    final records = logs.records
      .where((r) => r.level >= logs.level)
      .toList(growable: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.jumpTo(_controller.position.maxScrollExtent));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          "Logs",
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemCount: records.length,
            itemBuilder: (context, index) {
              final item = records[index];
              final color = switch (item.level) {
                <= Level.FINE => Colors.grey,
                Level.CONFIG => Colors.blueGrey,
                Level.INFO => Colors.blue,
                Level.WARNING => Colors.yellow,
                Level.SEVERE => Colors.red,
                Level.SHOUT => Colors.red[900],
                _ => null,
              };
              if (item.stackTrace != null || item.error != null || item.object != null) {
                return ExpansionTile(
                  leading: Text(item.time.toString()),
                  title: Text(
                    item.level.toString(),
                    style: TextStyle(color: color),
                  ),
                  subtitle: Text(
                    item.message,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                );
              } else {
                return ListTile(
                  leading: Text(item.time.toString()),
                  title: Text(
                    item.level.toString(),
                    style: TextStyle(color: color),
                  ),
                  subtitle: Text(
                    item.message,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                );
              }
            },
          ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: Text("Back"),
        ),
      ],
    );
  }
}