import 'dart:async';

import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  test('fetch on ${Value<int>}', () {
    final stream = const Value.success(1).fetchFrom(() async => 2);

    expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          emitsDone,
        ]));
  });

  group('fetchStream', () {
    test('success', () {
      final stream = const Value.success(1).fetchFromStream(
        () => Stream.fromIterable(const [Value.success(2), Value.success(3)]),
      );

      expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          const Value.success(3, isFetching: false),
          emitsDone,
        ]),
      );

      expect(ValueFetch.errors, emitsInOrder([]));
    });

    group('failure', () {
      const myExceptionStr = 'My exception';
      Never throwMyException() => fail(myExceptionStr);
      final isMyException = isA<TestFailure>().having(
        (tf) => tf.message,
        'message',
        myExceptionStr,
      );

      test('with keepLastOnError set to false', () {
        final stream = const Value.success(1).fetchFromStream(() async* {
          yield const Value.success(2);
          yield const Value.success(3);
          throwMyException();
        });

        expect(
          stream,
          emitsInOrder([
            const Value.success(1, isFetching: true),
            const Value.success(2, isFetching: false),
            const Value.success(3, isFetching: false),
            isA<Value>()
                .having((v) => v.error, 'error', isMyException)
                .having((v) => v.data, 'data', 1),
            emitsDone,
          ]),
        );

        expect(ValueFetch.errors, emits(isA<AsyncError>()));
      });

      test('with keepLastOnError set to true', () {
        final stream = const Value.success(1).fetchFromStream(
          () async* {
            yield const Value.success(2);
            yield const Value.success(3);
            throwMyException();
          },
          keepLastOnError: true,
        );

        expect(
          stream,
          emitsInOrder([
            const Value.success(1, isFetching: true),
            const Value.success(2, isFetching: false),
            const Value.success(3, isFetching: false),
            isA<Value>()
                .having((v) => v.error, 'error', isMyException)
                .having((v) => v.data, 'data', 3),
            emitsDone,
          ]),
        );

        expect(ValueFetch.errors, emits(isA<AsyncError>()));
      });
    });
  });
}
