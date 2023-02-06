import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';
import 'package:value_state/value_state.dart';

/// Shortbut to user [BaseState] with [Cubit]
abstract class ValueCubit<T> extends Cubit<BaseState<T>> with ValueCubitMixin {
  ValueCubit([BaseState<T>? initState]) : super(initState ?? InitState<T>());
}

/// Shared implementation to handle refresh capability on cubit
abstract class RefreshValueCubit<T> extends ValueCubit<T>
    with RefreshValueCubitMixin {
  RefreshValueCubit([BaseState<T>? initState])
      : super(initState ?? InitState<T>());
}

/// Shared implementation to handle refresh capability on cubit
mixin RefreshValueCubitMixin<T> on ValueCubitMixin<T> {
  /// Refresh the cubit state.
  Future<void> refresh() async {
    await perform(emitValues);
  }

  /// Init the state of cubit.
  void clear() {
    emit(PendingState<T>());
  }

  /// Get the value here and emit a [ValueState] if success.
  @protected
  Future<void> emitValues();
}

@Deprecated(
    'CubitValueStateMixin will be dropped in 2.0, use ValueCubitMixin instead.')
typedef CubitValueStateMixin<T> = ValueCubitMixin;

/// Shared implementation of [perform].
mixin ValueCubitMixin<T> on BlocBase<BaseState<T>> {
  /// Ensure that [perform] executions are sequential.
  final _performValueCubitLock = Lock(reentrant: true);

  /// Handle states (waiting, refreshing, error...) while an [action] is
  /// processed.
  /// If [errorAsState] is `true` and [action] raise an exception then an
  /// [ErrorState] is emitted. if `false`, nothing is emitted. The exception
  /// is always rethrown by [perform] to be handled by the caller.
  @protected
  Future<R> perform<R>(FutureOr<R> Function() action,
          {bool errorAsState = true}) =>
      _performValueCubitLock.synchronized<R>(
        () => performOnState<T, R>(
            state: () => state,
            emitter: emit,
            action: (state, emitter) => action()),
      );

  /// Return `true` when a [ReadyState] is emitted.
  /// Return `false` if this bloc is closed before a [ReadyState] is emitted.
  Future<bool> waitReady() async {
    if (state is! ReadyState<T>) {
      final result = await stream.firstWhere((state) => state is ReadyState<T>,
          orElse: () => PendingState<T>());

      return result is ReadyState<T>;
    }

    return true;
  }
}

/// Execute [CubitValueStateMixin.perform] on each cubit of a list.
/// Useful for cubits that are suscribed to others.
@Deprecated('This feature will be dropped in 2.0.')
Future<R> performOnIterable<R>(
    Iterable<ValueCubit> cubits, FutureOr<R> Function() action,
    {bool errorAsState = true}) async {
  if (cubits.isEmpty) {
    return await action();
  }

  return performOnIterable<R>(cubits.skip(1),
      () => cubits.first.perform<R>(action, errorAsState: errorAsState),
      errorAsState: errorAsState);
}
