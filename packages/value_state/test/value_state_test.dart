// ignore_for_file: prefer_const_constructors

import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  const value = 0;
  final valueStr = value.toString();
  const error = 'Error';
  final stackTrace = StackTrace.fromString('My StackTrace');

  group('test getters', () {
    test('initial state', () {
      final state = Value<int>.initial();

      expect(state.isInitial, isTrue);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isFalse);
      expect(state.dataOnSuccess, isNull);
      expect(state.previousDataOnFailure, isNull);
      expect(state.hasData, isFalse);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, isNull);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('initial state fetching', () {
      final state = Value<int>.initial(isFetching: true);

      expect(state.isInitial, isTrue);
      expect(state.isFetching, isTrue);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isFalse);
      expect(state.dataOnSuccess, isNull);
      expect(state.previousDataOnFailure, isNull);
      expect(state.hasData, isFalse);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, isNull);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('success state', () {
      final state = Value.success(value);

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.hasData, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('success state', () {
      final state = Value.success(value);

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.dataOnSuccess, value);
      expect(state.previousDataOnFailure, isNull);
      expect(state.hasData, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, null);
      expect(state.stackTrace, null);
    });

    test('success state fetching', () {
      final state = Value.success(value, isFetching: true);

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isTrue);
      expect(state.isRefetching, isTrue);
      expect(state.isFetching, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.dataOnSuccess, value);
      expect(state.previousDataOnFailure, isNull);
      expect(state.hasData, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('failure state', () {
      final state = Value<int>.failure(error, stackTrace: stackTrace);

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isTrue);
      expect(state.hasData, isFalse);
      expect(state.hasError, isTrue);
      expect(state.hasStackTrace, isTrue);
      expect(state.data, isNull);
      expect(state.error, error);
      expect(state.stackTrace, stackTrace);
    });

    test('failure state fetching', () {
      final state = Value<int>.failure(
        error,
        stackTrace: stackTrace,
        isFetching: true,
      );

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isTrue);
      expect(state.isRefetching, isTrue);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isTrue);
      expect(state.dataOnSuccess, isNull);
      expect(state.previousDataOnFailure, isNull);
      expect(state.hasData, isFalse);
      expect(state.hasError, isTrue);
      expect(state.hasStackTrace, isTrue);
      expect(state.data, isNull);
      expect(state.error, error);
      expect(state.stackTrace, stackTrace);
    });

    test('success to failure state', () {
      final state = Value.success(value).toFailure(error);

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isTrue);
      expect(state.dataOnSuccess, isNull);
      expect(state.previousDataOnFailure, value);
      expect(state.hasData, isTrue);
      expect(state.hasError, isTrue);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, error);
      expect(state.stackTrace, isNull);
    });
  });

  group('merge', () {
    test('merge success in initial', () {
      final state = Value<int>.initial().merge(
        Value.success(valueStr),
        mapData: (from) => Value.success(int.parse(from)),
      );

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.hasData, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('merge success in success', () {
      final state = Value.success(value).merge(
        Value.success(valueStr),
        mapData: (from) => Value.success(int.parse(from)),
      );

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.hasData, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('merge success in failure', () {
      final state = Value<int>.failure(error).merge(
        Value.success(valueStr, isFetching: true),
        mapData: (from) => Value.success(int.parse(from)),
      );

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isTrue);
      expect(state.isRefetching, isTrue);
      expect(state.isSuccess, isTrue);
      expect(state.isFailure, isFalse);
      expect(state.hasData, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });

    test('merge failure in initial', () {
      final state = Value<int>.initial().merge(
        Value<String>.failure(error),
        mapData: (from) => Value.success(int.parse(from)),
      );

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isTrue);
      expect(state.hasData, isFalse);
      expect(state.hasError, isTrue);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, isNull);
      expect(state.error, error);
      expect(state.stackTrace, isNull);
    });

    test('merge failure in success', () {
      final state = Value.success(value).merge(
        Value<String>.failure(error),
        mapData: (from) => Value.success(int.parse(from)),
      );

      expect(state.isInitial, isFalse);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isTrue);
      expect(state.hasData, isTrue);
      expect(state.hasError, isTrue);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, value);
      expect(state.error, error);
      expect(state.stackTrace, isNull);
    });

    test('merge initial in failure', () {
      final state = Value<int>.failure(error).merge(
        Value<String>.initial(),
        mapData: (from) => Value.success(int.parse(from)),
      );

      expect(state.isInitial, isTrue);
      expect(state.isFetching, isFalse);
      expect(state.isRefetching, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isFailure, isFalse);
      expect(state.hasData, isFalse);
      expect(state.hasError, isFalse);
      expect(state.hasStackTrace, isFalse);
      expect(state.data, isNull);
      expect(state.error, isNull);
      expect(state.stackTrace, isNull);
    });
  });

  group('Value mappers', () {
    const myStr = 'My String';
    const myError = 'Test Error';
    const initial = Value<String>.initial();
    final success = Value<String>.success(myStr);

    final failure = Value<String>.failure(myError, stackTrace: stackTrace);
    final failureWithData = success.toFailure(myError, stackTrace: stackTrace);

    test('toFailure', () {
      expect(
        initial.toFailure(
          myError,
          stackTrace: stackTrace,
        ),
        Value<String>.failure(myError, stackTrace: stackTrace),
      );
      expect(
        initial.toFailure(
          myError,
          stackTrace: stackTrace,
          isFetching: true,
        ),
        Value<String>.failure(
          myError,
          stackTrace: stackTrace,
          isFetching: true,
        ),
      );

      expect(
        failure.toFailure(myError, stackTrace: stackTrace),
        Value<String>.failure(myError, stackTrace: stackTrace),
      );
      expect(
        failure.toFailure(myError, stackTrace: stackTrace, isFetching: true),
        Value<String>.failure(
          myError,
          stackTrace: stackTrace,
          isFetching: true,
        ),
      );

      expect(
        failureWithData,
        isA<Value<String>>()
            .having((value) => value.data, 'has data', failureWithData.data!)
            .having((value) => value.isFetching, 'is not fetching', false)
            .having((value) => value.isFailure, 'is failure', true)
            .having(
              (value) => value.error,
              'failure content',
              myError,
            ),
      );
      expect(
        success.toFailure(myError, isFetching: true),
        isA<Value<String>>()
            .having((value) => value.isFetching, 'is fetching', true)
            .having((value) => value.isFailure, 'is failure', true)
            .having(
              (value) => value.error,
              'failure content',
              myError,
            ),
      );
    });
  });

  test('test equalities and hash', () {
    // Dont create object with [const] to avoid [identical] return true
    final init1 = Value<int>.initial(), init2 = Value<int>.initial();

    expect(init1, init2);
    expect(init1.hashCode, init2.hashCode);

    final fetching1 = Value<int>.initial(isFetching: true),
        fetching2 = Value<int>.initial(isFetching: true);

    expect(fetching1, fetching2);
    expect(fetching1.hashCode, fetching2.hashCode);

    final success1 = Value.success(value), success2 = Value.success(value);

    expect(success1, success2);
    expect(success1.hashCode, success2.hashCode);

    final failure1 = Value<int>.failure(error),
        failure2 = Value<int>.failure(error);

    expect(failure1, failure2);
    expect(failure1.hashCode, failure2.hashCode);

    final failureWithData1 = success1.toFailure(error),
        failureWithData2 = success2.toFailure(error);

    expect(failureWithData1, failureWithData2);
    expect(failureWithData1.hashCode, failureWithData2.hashCode);
  });

  test('test toString', () {
    expect(const Value<String>.initial().toString(),
        'Value<String>(state: ValueState.initial, isFetching: false)');

    final value = Value.success('My value');

    expect(
        value.toString(),
        'Value<String>(state: ValueState.success, isFetching: false, '
        'data: My value)');
    expect(
        value.toFailure(ArgumentError()).toString(),
        'Value<String>(state: ValueState.failure, isFetching: false, '
        'data: My value, error: Invalid argument(s))');

    expect(
        Value<String>.failure(ArgumentError()).toString(),
        'Value<String>(state: ValueState.failure, isFetching: false, '
        'error: Invalid argument(s))');
  });
}
