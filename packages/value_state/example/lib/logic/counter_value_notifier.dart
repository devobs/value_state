import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

import 'repository.dart';

class CounterValueNotifier extends ValueNotifier<Value<int>> {
  CounterValueNotifier() : super(const Value.initial());

  final _myRepository = MyRepository();

  Future<void> increment() =>
      value.fetchFrom(_myRepository.getValue).forEach(setNotifierValue);
}

/// Add this extension on your Flutter project to make it easier to use.
extension ValueNotifierExtensions<T extends Object> on ValueNotifier {
  @protected
  void setNotifierValue(Value<T> newValue) {
    value = newValue;
  }
}
