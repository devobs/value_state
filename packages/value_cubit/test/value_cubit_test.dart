import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

import 'cubit.dart';

void main() {
  late CounterCubit counterCubit;

  setUp(() {
    counterCubit = CounterCubit();
  });

  tearDown(() async {
    await counterCubit.close();
  });

  test('with values incremented', () {
    expect(counterCubit.state, isA<InitState<int>>());

    cubitStandardActions(counterCubit);

    // Ensure the current state is [WaitingState] instead of [InitState]
    expect(counterCubit.state, isNot(isA<InitState<int>>()));
    expect(counterCubit.state, isA<PendingState<int>>());

    expect(
        counterCubit.stream,
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
              .having((state) => state.value, 'second value', 1),
          // refresh with no value after value
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'second value  refreshing', true)
              .having((state) => state.value, 'second value', 1),
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
              .having((state) => state.value, 'fifth value ', 5),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'fifth value refreshing', true)
              .having((state) => state.value, 'fifth value', 5),
          isA<ErrorWithPreviousValue<int>>()
              .having((state) => state.refreshing,
                  'error for sixth value refreshing', false)
              .having(
                  (state) => state.hasValue, 'error for sixth has value', true)
              .having((state) => state.value,
                  'error for sixth value refreshing', 5),
          isA<ErrorWithPreviousValue<int>>().having((state) => state.refreshing,
              'error for sixth value refreshing', true),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'seventh value not refreshing', false)
              .having((state) => state.value, 'seventh value', 7),
          isA<ValueState<int>>()
              .having(
                  (state) => state.refreshing, 'seventh value refreshing', true)
              .having((state) => state.value, 'seventh value', 7),
          isA<ValueState<int>>()
              .having((state) => state.refreshing,
                  'eighth value not refreshing', false)
              .having((state) => state.value, 'eighth value', 8),
          // after _myRefresh.clear() triggered
          isA<PendingState<int>>(),
        ]));
  });

  test('equalities and hash', () {
    // Dont create object with [const] to avoid [identical] return true
    const initState1 = InitState<int>(), initState2 = InitState<int>();

    expect(initState1, initState2);
    expect(initState1.hashCode, initState2.hashCode);

    const waitingState1 = PendingState<int>(),
        waitingState2 = PendingState<int>();

    expect(waitingState1, waitingState2);
    expect(waitingState1.hashCode, waitingState2.hashCode);

    expect(waitingState1.mayRefreshing(), waitingState1);
    expect(waitingState1.mayNotRefreshing(), waitingState2);

    const noValueState1 = NoValueState<int>(),
        noValueState2 = NoValueState<int>();

    expect(noValueState1, noValueState2);
    expect(noValueState1.hashCode, noValueState2.hashCode);

    const valueState1 = ValueState<int>(0), valueState2 = ValueState<int>(0);

    expect(valueState1, valueState2);
    expect(valueState1.hashCode, valueState2.hashCode);

    final errorState1 =
            ErrorState<int>(previousState: const InitState(), error: 'Error'),
        errorState2 =
            ErrorState<int>(previousState: const InitState(), error: 'Error');

    expect(errorState1, errorState2);
    expect(errorState1.hashCode, errorState2.hashCode);

    final errorStateWithValue1 =
            ErrorState<int>(previousState: const ValueState(1), error: 'Error'),
        errorStateWithValue2 =
            ErrorState<int>(previousState: const ValueState(1), error: 'Error');

    expect(errorStateWithValue1, errorStateWithValue2);
    expect(errorStateWithValue1.hashCode, errorStateWithValue2.hashCode);
  });

  test('waitReady', () async {
    expect(counterCubit.state, isA<InitState<int>>());

    counterCubit.refresh();

    final result = await counterCubit.waitReady();

    expect(result, isTrue);
    expect(counterCubit.state, isA<ReadyState<int>>());
  });

  test('waitReady', () async {
    expect(counterCubit.state, isA<InitState<int>>());

    counterCubit.close();

    final result = await counterCubit.waitReady();

    expect(result, isFalse);
    expect(counterCubit.state, isNot(isA<ReadyState<int>>()));
  });

  test('visitor', () {
    const visitor = _TestStateVisitor();

    expect(const InitState().accept(visitor), 1);
    expect(const PendingState().accept(visitor), 4);
    expect(const NoValueState().accept(visitor), 2);
    expect(const ValueState(0).accept(visitor), 3);
    expect(
        ErrorState(previousState: const InitState(), error: 'Error')
            .accept(visitor),
        0);
  });
}

class _TestStateVisitor extends StateVisitor<int, int> {
  const _TestStateVisitor();

  @override
  visitInitState(InitState state) => 1;
  @override
  visitPendingState(PendingState state) => 4;

  @override
  visitValueState(ValueState state) => 3;
  @override
  visitNoValueState(NoValueState state) => 2;

  @override
  visitErrorState(ErrorState state) => 0;
}
