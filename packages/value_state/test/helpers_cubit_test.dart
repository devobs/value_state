import 'dart:async';

import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

import 'stream.dart';

class CounterStreamListener {
  CounterStreamListener({required this.counterStream, required this.variant});

  final CounterStream counterStream;
  final bool variant;

  Stream<BaseState<int>> get stream {
    var ignoreMapError = false;

    return counterStream.stream.map((state) {
      if (!ignoreMapError && state is WithValueState<int> && state.value > 4) {
        ignoreMapError = true;
      }

      final result = mapState<int, int>(
          (from) => variant && from == 1 ? null : from + 1, state,
          currentState: variant ? _state : null,
          mapError: variant && !ignoreMapError
              ? (errorState) {
                  return NoValueState(refreshing: errorState.refreshing);
                }
              : null,
          mapNoValue: variant
              ? (refreshing) {
                  return ValueState(-1, refreshing: refreshing);
                }
              : null);

      _state = result;

      return result;
    });
  }

  BaseState<int>? _state;
}

void main() {
  late CounterStream counterStream;
  late CounterStreamListener counterStreamListener;

  setUp(() {
    counterStream = CounterStream();
  });

  tearDown(() async {
    await counterStream.close();
  });

  test('with values incremented', () {
    counterStreamListener =
        CounterStreamListener(counterStream: counterStream, variant: false);

    expect(
        counterStreamListener.stream,
        emitsInOrder([
          const InitState<int>(),
          const PendingState<int>(),
          isA<ValueState<int>>()
              .having((state) => state.refreshing, 'first value not refreshing',
                  false)
              .having((state) => state.value, 'first value', 1),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', true)
              .having((state) => state.value, 'second value', 1),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', false)
              .having((state) => state.value, 'second value', 2),
          // refresh with no value after value
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'second value  refreshing', true)
              .having((state) => state.value, 'second value', 2),
          isA<NoValueState<int>>()
              .having((state) => state.refreshing, 'no value', false),
          isA<NoValueState<int>>()
              .having((state) => state.refreshing, 'no value refreshing', true),
          isA<ErrorWithoutPreviousValue<int>>()
              .having((state) => state.refreshing,
                  'error for third value not refreshing', false)
              .having(
                (state) => state.stateBeforeError,
                'no value before erreur',
                isA<NoValueState<int>>()
                    .having((state) => state.refreshing, 'no value', false),
              )
              .having((state) => state.hasValue, 'second value before erreur',
                  false),
          // refresh with error after error
          isA<ErrorWithoutPreviousValue<int>>().having(
              (state) => state.refreshing,
              'error for third value refreshing',
              true),
          isA<ErrorWithoutPreviousValue<int>>()
              .having((state) => state.refreshing,
                  'error for fourth value not refreshing', false)
              .having(
                (state) => state.stateBeforeError,
                'no value before erreur',
                isA<NoValueState<int>>()
                    .having((state) => state.refreshing, 'no value', false),
              )
              .having((state) => state.hasValue, 'second value before erreur',
                  false),
          // refresh after arror
          isA<ErrorWithoutPreviousValue<int>>().having(
              (state) => state.refreshing,
              'error for fourth value refreshing',
              true),
          isA<ValueState<int>>()
              .having((state) => state.refreshing, 'fifth value not refreshing',
                  false)
              .having((state) => state.value, 'fifth value ', 6),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'fifth value refreshing', true)
              .having((state) => state.value, 'fifth value', 6),
          isA<ErrorWithPreviousValue<int>>()
              .having((state) => state.refreshing,
                  'error for sixth value refreshing', false)
              .having(
                  (state) => state.hasValue, 'error for sixth has value', true)
              .having((state) => state.value,
                  'error for sixth value refreshing', 6),
          isA<ErrorWithPreviousValue<int>>().having((state) => state.refreshing,
              'error for sixth value refreshing', true),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'seventh value not refreshing', false)
              .having((state) => state.value, 'seventh value', 8),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'seventh value refreshing', true)
              .having((state) => state.value, 'seventh value', 8),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'eighth value not refreshing', false)
              .having((state) => state.value, 'eighth value', 9),
          // after _myRefresh.clear() triggered
          isA<WaitingState<int>>(),
        ]));

    streamStandardActions(counterStream);
  });

  test('with values incremented and variant', () {
    counterStreamListener =
        CounterStreamListener(counterStream: counterStream, variant: true);

    expect(
        counterStreamListener.stream,
        emitsInOrder([
          const InitState<int>(),
          const PendingState<int>(),
          isA<ValueState<int>>()
              .having((state) => state.refreshing, 'first value not refreshing',
                  false)
              .having((state) => state.value, 'first value', 1),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', true)
              .having((state) => state.value, 'second value', 1),
          isA<NoValueState<int>>().having((state) => state.refreshing,
              'error for fourth value not refreshing', false),
          isA<NoValueState<int>>().having((state) => state.refreshing,
              'error for fourth value  refreshing', true),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', false)
              .having((state) => state.value, 'second value', -1),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'second value refreshing', true)
              .having((state) => state.value, 'second value', -1),
          // refresh with error after error
          isA<NoValueState<int>>().having((state) => state.refreshing,
              'error for fourth value not refreshing', false),
          isA<NoValueState<int>>().having((state) => state.refreshing,
              'error for fourth value  refreshing', true),
          isA<NoValueState<int>>().having((state) => state.refreshing,
              'error for fourth value not refreshing', false),
          isA<NoValueState<int>>().having((state) => state.refreshing,
              'error for fourth value  refreshing', true),
          // refresh after arror
          isA<ValueState<int>>()
              .having((state) => state.refreshing, 'fifth value not refreshing',
                  false)
              .having((state) => state.value, 'fifth value ', 6),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'fifth value refreshing', true)
              .having((state) => state.value, 'fifth value', 6),
          isA<ErrorWithPreviousValue<int>>()
              .having((state) => state.refreshing,
                  'error for sixth value refreshing', false)
              .having(
                  (state) => state.hasValue, 'error for sixth has value', true)
              .having((state) => state.value,
                  'error for sixth value refreshing', 6),
          isA<ErrorWithPreviousValue<int>>().having((state) => state.refreshing,
              'error for sixth value refreshing', true),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'seventh value not refreshing', false)
              .having((state) => state.value, 'seventh value', 8),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'seventh value refreshing', true)
              .having((state) => state.value, 'seventh value', 8),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'eighth value not refreshing', false)
              .having((state) => state.value, 'eighth value', 9),
          // after _myRefresh.clear() triggered
          isA<WaitingState<int>>(),
        ]));

    streamStandardActions(counterStream);
  });
}
