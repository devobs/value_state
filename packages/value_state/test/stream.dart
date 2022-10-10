import 'dart:async';

import 'package:stream_transform/stream_transform.dart';
import 'package:test/expect.dart';
import 'package:value_state/value_state.dart';

class CounterStream {
  var _value = 0;
  Future<int?> _getMyValueFromRepository() async {
    final value = _value++;
    switch (value) {
      case 2:
        return null;

      case 3:
      case 4:
      case 6:
        fail('Error');
      default:
        return value;
    }
  }

  BaseState<int> state = const InitState();

  final _resultStreamController = StreamController<BaseState<int>>();
  Stream<BaseState<int>> get stream => Stream.value(state)
      .followedBy(_resultStreamController.stream)
      .handleError((_) {});

  var errorsRaisedCount = 0;

  Future<void> incrementValue() async {
    await performOnState<int, void>(
        state: () => state,
        emitter: (state) {
          this.state = state;
          _resultStreamController.add(this.state);
        },
        action: (state, emitter) async {
          final result = await _getMyValueFromRepository();

          emitter(result == null ? const NoValueState() : ValueState(result));
        }).onError((error, stackTrace) {
      errorsRaisedCount++;
    });
  }

  void clear() {
    _resultStreamController.add(const PendingState());
  }

  Future<void> close() async {
    await _resultStreamController.close();
  }
}

void streamStandardActions(CounterStream counterStream) async {
  for (var i = 0; i < 9; i++) {
    await counterStream.incrementValue();
  }
  counterStream.clear();
}
