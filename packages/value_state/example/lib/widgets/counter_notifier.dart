import 'package:flutter/widgets.dart';

import '../logic/counter_value_notifier.dart';

class CounterNotifier extends InheritedNotifier<CounterValueNotifier> {
  CounterNotifier({super.key, required super.child})
      : super(notifier: CounterValueNotifier()..increment());

  static CounterValueNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CounterNotifier>()!.notifier!;
}
