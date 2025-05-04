import 'package:flutter/material.dart';

final class ErrorPage extends StatelessWidget {
  final Object? arguments;

  const ErrorPage({required this.arguments, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 5,
          children: [
            Text(
              "Error",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SingleChildScrollView(
              child: Text(
                arguments != null ? arguments.toString() : "An unknown error occurred!",
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}