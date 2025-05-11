import 'package:flutter/material.dart';

int _dialogsOpen = 0;

void closeDialog<T>(BuildContext context, [T? result]) {
  if (_dialogsOpen > 0) {
    Navigator.pop(context, result);
    _dialogsOpen--;
  }
}

enum NotificationType {
  info,
  warning,
  error,
}

void showNotificationDialog(BuildContext context, {
  required String text,
  NotificationType type = NotificationType.info,
}) {
  _showBaseDialog(
    context: context,
    title: switch (type) {
      NotificationType.info => "Info",
      NotificationType.warning => "Warning",
      NotificationType.error => "Error",
    },
    titleColor: switch (type) {
      NotificationType.info => Colors.blue,
      NotificationType.warning => Colors.orange,
      NotificationType.error => Colors.red,
    },
    dismissible: true,
    widget: Text(
      text,
      softWrap: true,
      textAlign: TextAlign.start,
    ),
  );
}

void showWaitDialog(BuildContext context, {
  required String title,
}) {
  _showBaseDialog(
    context: context,
    title: title,
    widget: Column(
      spacing: 5,
      children: [
        const CircularProgressIndicator(),
        Text("Please wait..."),
      ],
    ),
  );
}

Future<bool> showConfirmDialog(BuildContext context, {
  required String title,
  required String question,
}) async {
  return await _showBaseDialog<bool>(
    context: context,
    title: title,
    widget: Column(
      spacing: 5,
      children: [
        Text(question),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 3,
          children: [
            ElevatedButton(
              onPressed: () => closeDialog(context, true),
              child: Text("Yes"),
            ),
            ElevatedButton(
              onPressed: () => closeDialog(context, false),
              child: Text("No"),
            ),
          ],
        ),
      ],
    ),
  ) ?? false;
}

Future<T?> _showBaseDialog<T>({
  required BuildContext context,
  required String title,
  required Widget widget,
  bool dismissible = false,
  Color? titleColor,
}) async {
  _dialogsOpen++;
  return await showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    useRootNavigator: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: ContinuousRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 3
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: "Blockletter",
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              widget,
            ],
          ),
        ),
      );
    },
  );
}