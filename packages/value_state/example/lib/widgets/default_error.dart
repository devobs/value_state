import 'package:flutter/material.dart';

class DefaultError extends StatelessWidget {
  const DefaultError({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Expected error.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
