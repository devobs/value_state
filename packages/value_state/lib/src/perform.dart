import 'dart:async';

import '../value_state.dart';

typedef PerfomOnStateEmitter<T> = FutureOr<void> Function(BaseState<T> state);
typedef PerfomOnStateAction<T, R> = FutureOr<R> Function(
    BaseState<T> state, PerfomOnStateEmitter<T> emitter);

/// Handle states (waiting, refreshing, error...) while an [action] is
/// processed.
/// [state] must return the state updated.
/// If [errorAsState] is `true` and [action] raise an exception then an
/// [ErrorState] is emitted. if `false`, nothing is emitted. The exception
/// is always rethrown by [perform] to be handled by the caller.
Future<R> performOnState<T, R>(
    {required BaseState<T> Function() state,
    required PerfomOnStateEmitter<T> emitter,
    required PerfomOnStateAction<T, R> action,
    bool errorAsState = true}) async {
  try {
    final currentState = state();
    final stateRefreshing = currentState.mayRefreshing();

    if (currentState != stateRefreshing) await emitter(stateRefreshing);

    return await action(state(), emitter);
  } catch (error, stackTrace) {
    if (errorAsState) {
      await emitter(ErrorState<T>(
          previousState: state().mayNotRefreshing(),
          error: error,
          stackTrace: stackTrace));
    }
    rethrow;
  } finally {
    final currentState = state();
    final stateRefreshingEnd = currentState.mayNotRefreshing();

    if (currentState != stateRefreshingEnd) await emitter(stateRefreshingEnd);
  }
}

extension ValueStatePerformExtensions<T> on BaseState<T> {
  Stream<BaseState<T>> perform(
      Future<BaseState<T>> Function(BaseState<T> state) action,
      {bool errorAsState = true}) {
    final controller = StreamController<BaseState<T>>();
    var lastState = this;

    performOnState<T, void>(
      state: () => lastState,
      emitter: (state) {
        lastState = state;
        controller.add(state);
      },
      action: (state, emit) async {
        return emit(await action(state));
      },
      errorAsState: errorAsState,
    ).then((_) {
      controller.close();
    });

    return controller.stream;
  }

  Stream<BaseState<T>> performStream(
      Stream<BaseState<T>> Function(BaseState<T> state) action,
      {bool errorAsState = true}) {
    final controller = StreamController<BaseState<T>>();
    var lastState = this;

    performOnState<T, void>(
      state: () => lastState,
      emitter: (state) {
        lastState = state;
        controller.add(state);
      },
      action: (state, emit) {
        final stream = action(this);
        final subscription = stream.listen(emit);

        return subscription.asFuture();
      },
      errorAsState: errorAsState,
    ).then((_) {
      controller.close();
    });

    return controller.stream;
  }
}
