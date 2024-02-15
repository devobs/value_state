import 'dart:async';

import 'package:value_state/value_state.dart';

typedef FetchOnValueEmitter<T extends Object> = FutureOr<void> Function(
    Value<T> value);
typedef FetchOnValueAction<T extends Object, R> = FutureOr<R> Function(
  Value<T> value,
  FetchOnValueEmitter<T> emitter,
);

Future<R> fetchOnValue<T extends Object, R>({
  required Value<T> Function() value,
  required FetchOnValueEmitter<T> emitter,
  required FetchOnValueAction<T, R> action,
  required bool lastValueOnError,
}) async {
  final valueBeforeFetch = value();

  try {
    final currentValue = valueBeforeFetch;
    final valueFetching = currentValue.copyWithFetching(true);

    if (currentValue != valueFetching) await emitter(valueFetching);

    return await action(value(), emitter);
  } catch (error, stackTrace) {
    final currentValue = lastValueOnError ? value() : valueBeforeFetch;

    await emitter(currentValue.toFailure(
      error,
      stackTrace: stackTrace,
      isFetching: false,
    ));

    rethrow;
  } finally {
    final currentValue = value();
    final valueFetchingEnd = currentValue.copyWithFetching(false);

    if (currentValue != valueFetchingEnd) await emitter(valueFetchingEnd);
  }
}
