import 'states.dart';

extension ObjectWithValueExtensions<T> on BaseState<T> {
  /// Shortcut on [BaseState] to handle easily [WithValueState] state. It can be used in different case :
  /// * To return a value
  /// ```dart
  /// print('Phone number : ${personState.whenValue((person) => person.phone) ?? 'unknown'}');
  /// ```
  /// * To perform some action
  /// ```dart
  /// personState.whenValue((person) => print('Phone number : ${person.phone}'));
  /// ```
  ///
  /// If [onlyValueState] is true, then [withValue] is trigerred only on [ValueState] state.
  R? withValue<R>(R Function(T value) onValue, {bool onlyValueState = false}) {
    final state = this;

    if (state is WithValueState<T>) {
      if (!onlyValueState || !state.hasError) {
        return onValue(state.value);
      }
    }

    return null;
  }

  /// Shorcut to [withValue] with its parameter `onlyValueState` set to `true`. It is equivalent to handle only
  /// [ValueState] state.
  R? whenValue<R>(R Function(T value) onValue) =>
      withValue<R>(onValue, onlyValueState: true);
}

extension OrExtensions<R> on R? {
  /// Helpers to execute/return non null result on a null object.
  ///
  /// Example :
  /// ```dart
  /// personState.whenValue((person) {
  ///   print('Phone number : ${person.phone}');
  /// }).orElse(() {
  ///   print('Phone number unknown');
  /// });
  /// ```
  R orElse(R Function() elseAction) => this ?? elseAction();
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
