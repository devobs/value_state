// ignore_for_file: prefer_const_constructors

import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

import 'stream.dart';

void main() {
  late CounterStream counterStream;

  setUp(() {
    counterStream = CounterStream();
  });

  tearDown(() async {
    await counterStream.close();
  });

  test('test fetchOnValue with stream', () {
    TypeMatcher<Value<int>> isFailure({required isFetching}) =>
        isA<Value<int>>()
            .having((value) => value.isFailure, 'is failure', true)
            .having(
              (value) => value.isFetching,
              'is fetching $isFetching',
              isFetching,
            )
            .having(
              (value) => value.error,
              'failure content',
              isA<TestFailure>(),
            );

    expect(
        counterStream.stream,
        emitsInOrder([
          const Value<int>.initial(),
          const Value<int>.initial(isFetching: true),
          Value<int>.success(0),
          Value<int>.success(0, isFetching: true),
          Value<int>.success(1),
          Value<int>.success(1, isFetching: true),
          Value<int>.success(2),
          Value<int>.success(2, isFetching: true),
          isFailure(isFetching: false),
          isFailure(isFetching: true),
          isFailure(isFetching: false),
          isFailure(isFetching: true),
          Value<int>.success(5),
          Value<int>.success(5, isFetching: true),
          isFailure(isFetching: false)
              .having((value) => value.data, 'data has old value', 5),
          isFailure(isFetching: true)
              .having((value) => value.data, 'data has old value', 5),
          Value<int>.success(7),
          Value<int>.success(7, isFetching: true),
          Value<int>.success(8),
          const Value<int>.initial(isFetching: true),
        ]));

    streamStandardActions(counterStream);
  });
}
