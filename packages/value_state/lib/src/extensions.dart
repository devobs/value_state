import 'perform.dart';
import 'states.dart';

extension ObjectWithValueExtensions<T> on BaseState<T> {
  /// Destructuring pattern-matching
  ///
  /// Example :
  /// ```dart
  ///    const String? nullStr = null;
  ///    final result = nullStr.toState().when(
  ///       onValue: (state) => 'Value',
  ///       onError: (error) => 'Error',
  ///       orElse: () => 'Null value',
  ///    );
  /// ```
  R when<R>({
    R Function()? onWaiting,
    R Function()? onNoValue,
    R Function(T value)? onValue,
    R Function(Object error)? onError,
    required R Function() orElse,
  }) {
    final state = this;

    if (state is WaitingState<T>) {
      return onWaiting?.call() ?? orElse();
    } else if (state is NoValueState<T>) {
      return onNoValue?.call() ?? orElse();
    } else if (state is ValueState<T>) {
      return onValue?.call(state.value) ?? orElse();
    } else if (state is ErrorState<T>) {
      return onError?.call(state.error) ?? orElse();
    }

    return orElse();
  }

  /// Shortcut on [BaseState] to easily handle [WithValueState] state. It can be used in different case :
  /// * To return a value
  /// ```dart
  /// print('Phone number : ${personState.withValue((person) => person.phone) ?? 'unknown'}');
  /// ```
  /// * To perform some action
  /// ```dart
  /// personState.withValue((person) => print('Phone number : ${person.phone}'));
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
  R? whenValue<R>(R Function(T value) onValue) => withValue<R>(onValue, onlyValueState: true);

  /// Shorcut to [withValue] which return the value if avaible. [onlyValueState] is the same as [withValue].
  T? toValue({bool onlyValueState = false}) => withValue((value) => value, onlyValueState: onlyValueState);
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
    return state == null ? NoValueState<T>(refreshing: refreshing) : ValueState<T>(state, refreshing: refreshing);
  }
}

extension FutureValueStateExtension<T> on Future<T?> {
  /// Map a [Future] to [ReadyState] : [NoValueState] or [ValueState].
  Future<ReadyState<T>> toFutureState({bool refreshing = false}) async {
    final result = await this;

    if (result == null) return NoValueState(refreshing: refreshing);
    return ValueState(result, refreshing: refreshing);
  }

  /// Generate a stream of [BaseState] during a processing [Future].
  Stream<BaseState<T>> toStates() => InitState<T>().perform((_) => toFutureState());
}
