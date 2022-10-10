import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:value_state/value_state.dart';

import 'cubit.dart';

/// Extensions for cubit to
extension StateAndStream<T> on Cubit<T> {
  /// Get a new stream with current state as first value and the following
  /// values
  Stream<T> get behaviorSubject => Stream.value(state).followedBy(stream);
}

/// This mixin help to listen a stream an then update the current cubit
mixin StreamInputCubitMixin<T, EVENT> on ValueCubit<T> {
  late StreamSubscription _refreshStreamSubscription;

  /// Listen the [stream] and call [emitValuesFromStream] for every event.
  @protected
  void listenRefreshStream(Stream<EVENT> stream,
      Future<void> Function(EVENT event) emitValuesFromStream) {
    _refreshStreamSubscription = stream.listen(emitValuesFromStream);
  }

  @override
  Future<void> close() async {
    await _refreshStreamSubscription.cancel();
    return super.close();
  }

  /// Helper to map from a state to other state. Useful to map "default" states
  /// from original stream.
  /// The [map] argument contains a function that map the origin event from the
  /// stream to the value.  If `null` is returned, then a [NoValueState] is
  /// emitted. Else a [ValueState] is emitted with the value returned inside.
  /// [fromState] is the origin state to map.
  /// If the optional parameter [refreshingWithCurrentState] is `true` (default
  /// value), then the cubit emit the current state refreshing if original
  /// stream emit a refreshing state. Else, the refreshing is mapped from
  /// original stream.
  /// [mapInit], [mapPending], [mapNoValue] and [mapError] override the default
  /// behavior of the mapper.
  void emitMappedState<F>(
    T? Function(F from) map,
    BaseState<F> fromState, {
    bool refreshingWithCurrentState = true,
    WaitingMapperType<T>? mapInit,
    WaitingMapperType<T>? mapPending,
    RefreshingyMapperType<T>? mapNoValue,
    ErrorMapperType<T, F>? mapError,
  }) {
    emit(mapState<T, F>(
      map,
      fromState,
      currentState: refreshingWithCurrentState ? state : null,
      mapInit: mapInit,
      mapPending: mapPending,
      mapNoValue: mapNoValue,
      mapError: mapError,
    ));
  }
}
