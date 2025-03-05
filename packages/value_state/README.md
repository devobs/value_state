## value_state

[![pub package](https://img.shields.io/pub/v/value_state.svg)](https://pub.dev/packages/value_state) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Test](https://github.com/devobs/value_state/actions/workflows/test.yml/badge.svg)](https://github.com/devobs/value_state/actions/workflows/test.yml) [![codecov](https://codecov.io/gh/devobs/value_state/branch/main/graph/badge.svg)](https://app.codecov.io/gh/devobs/value_state/tree/main/packages/value_state)

A dart package that helps to implement basic states such as initial, success and error.

### 🔥 Features

This package helps you manage the different states your data can have in your app (like loading, success, or error). It makes your code cleaner and easier to understand, especially when dealing with things like network requests, storage loading or complex operations.

It provides a way to represent a value that can be in one of three states:
  * initial
  * success
  * failure


### 🚀 Quick start

```dart
final valueInitial = Value<int>.initial();
final state = valueInitial.state; // ValueState.initial
final isInitial = valueInitial.isInitial; // true

final valueSuccess = Value.success(1);
final isSuccess = valueSuccess.isSuccess; // true
final isFailure = valueError.isFailure; // false
print('Data of value : ${valueSuccess.data}'); // Data of value : 1
```

#### When the value is in a specific state

```dart
value.when(
  initial: () => print('initial'),
  success: (data) => print('success: $data'),
  failure: (error) => print('failure: $error'),
  orElse: () => print('orElse'),
);
```

#### Map the value to a different type

```dart
valueInitial.map(
  initial: () => 'initial',
  success: (data) => 'success: $data',
  failure: (error) => 'failure: $error',
  orElse: () => 'orElse',
);
```

#### Map the value to a different type using pattern matching

```dart
final result = switch(valueInitial) {
  Value(isInitial: true) => 'initial',
  Value(:final dataOnSuccess?) => 'success: $dataOnSuccess',
  Value(:final error?) => 'failure: $error',
  _ => 'orElse',
};
```

#### Merge two values with different types

```dart
const valueInt = Value.success(0);
const valueStr = Value.success('toto');
final newValue = valueInt.merge(valueStr, mapData: (value) => value.length);
print('$newValue'); // Value<int>(state: ValueState.success, isFetching: false, data: 4)
```

#### Value error

Map a Value to `failure` with actual data if any. There is no `Value.failure` constructor to prevent developers from forgetting to retain the data from a previous state of the [Value].

```dart
final valueError = Value.initial().toFailure(Exception('error'));

print('Data of value : ${valueError.data}'); // Data of value : null
print('Error of value : "${valueError.error}"'); // Error of value : "Exception: error"
```

The new value from call `toFailure` on `valueSuccess` keep previous `data`. It provides a simple way to display both error and previous data (for example a refresh failure).
```dart
final valueErrorWithPreviousData = valueSuccess.toFailure(Exception('error'));

print('Data of value : ${valueErrorWithPreviousData.data}'); // Data of value : 1
print('Error of value : "${valueErrorWithPreviousData.error}"'); // Error of value : "Exception: error"
```

#### Handle states (isFetching, success, error...) while an action is processed

```dart
const value = Value<String>.initial();
print(value);
value.fetchFrom(() async => "result").forEach(print);
// Result :
// Value<String>(state: ValueState.initial, isFetching: false)
// Value<String>(state: ValueState.initial, isFetching: true)
// Value<String>(state: ValueState.success, isFetching: false, data: result)
```

### ⚙️ Migration

If you previously used [value_cubit](https://pub.dev/packages/value_cubit) or [flutter_value_state](https://pub.dev/packages/flutter_value_state), please refer to the [example with Cubit](https://github.com/devobs/value_state/blob/main/packages/value_state/example/lib/main_cubit.dart) or the [basic example](https://github.com/devobs/value_state/blob/main/packages/value_state/example/lib/main.dart) for guidance.

### License

MIT License

See the [LICENSE](https://www.google.com/url?sa=E&source=gmail&q=https://www.google.com/url?sa=E%26source=gmail%26q=LICENSE) file for details.

### Feedback

Please file any issues, bugs or feature requests as an issue on the [Github page](https://github.com/devobs/value_state/issues).