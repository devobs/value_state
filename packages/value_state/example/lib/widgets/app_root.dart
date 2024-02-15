import 'package:flutter/material.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Value State Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Demo Home Page')),
        body: DefaultTextStyle(
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          child: child,
        ),
      ),
    );
  }
}
