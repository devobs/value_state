import 'package:flutter/material.dart';

class FormattedColumn extends StatelessWidget {
  const FormattedColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}
