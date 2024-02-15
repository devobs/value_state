import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:value_state/value_state.dart';

import 'repository.dart';

part 'counter_notifier.g.dart';

@riverpod
MyRepository myRepository(Ref ref) => MyRepository();

@riverpod
Future<int> counter(Ref ref) => ref.watch(myRepositoryProvider).getValue();

/// Simple extension to map [AsyncValue] to [Value] that you can include in
/// your project.
extension AsyncValueX<T extends Object> on AsyncValue<T> {
  Value<T> mapToValue() => map(
        data: (data) => Value<T>.success(data.value, isFetching: isLoading),
        error: (error) => switch (error) {
          AsyncError(:final value?) => Value<T>.success(value)
              .toFailure(error, stackTrace: stackTrace, isFetching: isLoading),
          _ => Value<T>.initial().toFailure(
              error,
              stackTrace: stackTrace,
              isFetching: isLoading,
            ),
        },
        loading: (loading) => Value<T>.initial(isFetching: isLoading),
      );
}
