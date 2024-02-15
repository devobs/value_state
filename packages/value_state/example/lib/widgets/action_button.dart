import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: const Text('Increment'),
        ),
      );
}
