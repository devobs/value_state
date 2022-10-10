import 'package:test/test.dart';
import 'package:value_cubit/value_cubit.dart';

import 'cubit.dart';

class CounterCubitListener extends ValueCubit<int>
    with StreamInputCubitMixin<int, BaseState<int>> {
  CounterCubitListener(
      {required CounterCubit counterCubit, required bool variant}) {
    var ignoreMapError = false;
    listenRefreshStream(counterCubit.behaviorSubject, (state) async {
      if (!ignoreMapError && state is WithValueState<int> && state.value > 4) {
        ignoreMapError = true;
      }

      emitMappedState<int>(
          (from) => variant && from == 1 ? null : from + 1, state,
          refreshingWithCurrentState: !variant,
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
    });
  }
}

void main() {
  late CounterCubit counterCubit;
  late CounterCubitListener counterCubitListener;
  late CounterCubitListener counterCubitListener2;

  setUp(() {
    counterCubit = CounterCubit();
    counterCubitListener =
        CounterCubitListener(counterCubit: counterCubit, variant: false);
    counterCubitListener2 =
        CounterCubitListener(counterCubit: counterCubit, variant: true);
  });

  tearDown(() async {
    await counterCubitListener2.close();
    await counterCubitListener.close();
    await counterCubit.close();
  });

  test('with values incremented', () {
    expect(counterCubitListener.state, isA<InitState<int>>());
    cubitStandardActions(counterCubit);

    expect(
        counterCubitListener.stream,
        emitsInOrder([
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
  });

  test('with values incremented and variant', () {
    expect(counterCubitListener2.state, isA<InitState<int>>());
    cubitStandardActions(counterCubit);

    expect(
        counterCubitListener2.stream,
        emitsInOrder([
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
  });

  test('performIterable', () {
    final counterCubit2 = CounterCubit();

    expect(counterCubit2.state, isA<InitState<int>>());

    expect(
      // ignore: deprecated_member_use_from_same_package
      performOnIterable<String>([counterCubit, counterCubit2], () async {
        await counterCubit.refresh();
        await counterCubit2.refresh();

        return 'Success';
      }).then((res) {
        // ignore: deprecated_member_use_from_same_package
        return performOnIterable([counterCubit, counterCubit2], () async {
          await counterCubit.refresh();

          return res;
        });
      }),
      completion('Success'),
    );

    expect(
        counterCubit.stream,
        emitsInOrder([
          const PendingState<int>(),
          isA<ValueState<int>>()
              .having((state) => state.refreshing, 'first value not refreshing',
                  false)
              .having((state) => state.value, 'first value', 0),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', true)
              .having((state) => state.value, 'second value', 0),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', false)
              .having((state) => state.value, 'second value', 1),
        ]));

    expect(
        counterCubit2.stream,
        emitsInOrder([
          isA<ValueState<int>>()
              .having((state) => state.refreshing, 'first value not refreshing',
                  false)
              .having((state) => state.value, 'first value', 0),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', true)
              .having((state) => state.value, 'second value', 0),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'second value not refreshing', false)
              .having((state) => state.value, 'second value not changed', 0),
        ]));
  });
}
