A dart package that helps to implement basic states for [BLoC library](https://pub.dev/packages/bloc) to perform, load and fetch data.


[![pub package](https://img.shields.io/pub/v/value_state.svg)](https://pub.dev/packages/value_state)
[![Test](https://github.com/devobs/value_state/actions/workflows/test.yml/badge.svg)](https://github.com/devobs/value_state/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/devobs/value_state/branch/main/graph/badge.svg)](https://app.codecov.io/gh/devobs/value_state/tree/main/packages/value_state)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

* Provides all necessary states for data : init, waiting, value/no value and error states,
* Some helpers `performOnState` to emit intermediate states while an action is intended to update state : the same state is reemitted with attribute `refreshing` at `true`.

## Usage

```dart
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
```

The whole code of this example is available in [example](example).

## Models

### State diagram

![State diagram](https://github.com/devobs/value_state/blob/main/packages/value_state/doc/state_diagram.png?raw=true)

### Class diagram

![Class diagram](https://github.com/devobs/value_state/blob/main/packages/value_state/doc/class_diagram.png?raw=true)

## Feedback

Please file any issues, bugs or feature requests as an issue on the [Github page](https://github.com/devobs/value_state/issues).
