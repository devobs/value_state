import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class RefreshLoader extends StatelessWidget {
  const RefreshLoader({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoading,
      child: const Align(
        heightFactor: 0,
        alignment: Alignment.topCenter,
        child: LinearProgressIndicator(),
      ),
    );
  }
}
