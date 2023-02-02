import 'states.dart';

extension ObjectWithValueExtensions<T> on BaseState<T> {
  /// Shortcut on [BaseState] to handle easily [WithValueState] state. It can be used in different case :
  /// * To return a value
  /// ```dart
  /// print('Phone number : ${personState.withValue((person) => person.phone) ?? 'unknown'}');
  /// ```
  /// * To perform some action
  /// ```dart
  /// personState.withValue((person) => print('Phone number : ${person.phone}'));
  /// ```
  R? withValue<R>(R Function(T value) onValue) {
    final state = this;
    if (state is WithValueState<T>) return onValue(state.value);

    return null;
  }
}

extension ToReadyStateExtensions<T extends Object> on T? {
  /// Shorcut to transform to a [ReadyState] with following rules :
  /// * if `this`is non null, it returns a [ValueState]
  /// * else it returns a [NoValueState]
  ReadyState<T> toState({bool refreshing = false}) {
    final state = this;
    return state == null
        ? NoValueState<T>(refreshing: refreshing)
        : ValueState<T>(state, refreshing: refreshing);
  }
}
