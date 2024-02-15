import 'dart:async';

import 'fetch_on_value.dart';
import 'value.dart';

extension ValueFetch<T extends Object> on Value<T> {
  /// Fetch a value from a [computation] function and return a stream of values.
  Stream<Value<T>> fetchFrom(Future<T> Function() computation) =>
      fetchFromStream(() => computation().asStream().map(Value.success));

  /// Handle values (isFetching, success, error...) before and after the
  /// [streamComputation] is processed :
  /// * Before the [streamComputation] is processed, the value is emitted with
  ///   [Value.isFetching] set to true.
  /// * After the [streamComputation] is processed, the last value is emitted
  ///   with [Value.isFetching] set to false.
  /// * If an exception is raised, an error is emitted based on the
  ///   [keepLastOnError] setting :
  ///    * If [keepLastOnError] is true, the most recent value emitted is used
  ///     to construct the error.
  ///    * If [keepLastOnError] is false, the value present before the stream
  ///     processing begins is used instead.
  Stream<Value<T>> fetchFromStream(
    Stream<Value<T>> Function() streamComputation, {
    bool keepLastOnError = false,
  }) {
    final controller = StreamController<Value<T>>();
    var lastValue = this;

    fetchOnValue<T, void>(
      value: () => lastValue,
      emitter: (value) {
        lastValue = value;
        controller.add(value);
      },
      action: (value, emit) => streamComputation().forEach(emit),
      lastValueOnError: keepLastOnError,
    ).onError((error, stackTrace) {
      if (error != null) {
        _errorsController.add(AsyncError(error, stackTrace));
      }
    }).whenComplete(() {
      controller.close();
    });

    return controller.stream;
  }

  /// Stream of errors emitted by [fetchFromStream] and [fetchFrom].
  static Stream<AsyncError> get errors => _errorsController.stream;

  static final StreamController<AsyncError> _errorsController =
      StreamController<AsyncError>.broadcast();
}
