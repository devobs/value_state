import 'dart:async';

import 'package:stream_transform/stream_transform.dart';
import 'package:value_state/value_state.dart';

class CounterBehaviorSubject {
  var _value = 0;
  Future<int> _getCounterValueFromRepository() async => _value++;

  Future<void> refresh() => performOnState<int, void>(
      state: () => state,
      emitter: _streamController.add,
      action: (state, emitter) async {
        final result = await _getCounterValueFromRepository();

        if (result == 2) {
          throw 'Error';
        } else if (result > 4) {
          emitter(const NoValueState());
        } else {
          emitter(ValueState(result));
        }
      });

  final BaseState<int> _state = const InitState();
  BaseState<int> get state => _state;

  final _streamController = StreamController<BaseState<int>>();
  late StreamSubscription<BaseState<int>> _streamSubscription;

  Stream<BaseState<int>> get stream =>
      Stream.value(state).followedBy(_streamController.stream);

  Future<void> close() async {
    await _streamSubscription.cancel();
    await _streamController.close();
  }
}

main() async {
  final counterCubit = CounterBehaviorSubject();

  final timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
    try {
      await counterCubit.refresh();
    } catch (error) {
      // Prevent stop execution for example
    }
  });

  await for (final state in counterCubit.stream) {
    if (state is ReadyState<int>) {
      print('State is refreshing: ${state.refreshing}');

      if (state.hasError) {
        print('Error');
      }

      if (state is WithValueState<int>) {
        print('Value : ${state.value}');
      }

      if (state is NoValueState<int>) {
        timer.cancel();
        print('No value');
      }
    } else {
      print('Waiting for value - $state');
    }
  }
}
