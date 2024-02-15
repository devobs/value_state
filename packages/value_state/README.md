A dart package that helps to implement basic states initial, success and error.


[![pub package](https://img.shields.io/pub/v/value_state.svg)](https://pub.dev/packages/value_state)
[![Test](https://github.com/devobs/value_state/actions/workflows/test.yml/badge.svg)](https://github.com/devobs/value_state/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/devobs/value_state/branch/main/graph/badge.svg)](https://app.codecov.io/gh/devobs/value_state/tree/main/packages/value_state)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

This package helps you manage the different states your data can have in your app (like loading, success, or error). It makes your code cleaner and easier to understand, especially when dealing with things like network requests, storage loading or complex operations.

It provides a way to represent a value that can be in one of three states:

  * initial
  * success
  * failure


## Usage

### Value

Create a value:

```dart
// The value is in the initial state.
final valueInitial = Value<int>.initial();

// The value is in the success state with data.
final valueSuccess = Value.success(1);

print('Data of value : ${valueSuccess.data}'); // Data of value : 1

// Map a Value to `failure` with actual data if any.
// There is no `Value.failure` constructor to prevent developers from forgetting to retain the data from a previous state of the Value.
final valueError = value1.toFailure(Exception('error'));

print('Data of value : ${valueError.data}'); // Data of value : null
print('Error of value : "${valueError.error}"'); // Error of value : "Exception: error"

// The new value from call `toFailure` on `valueSuccess` keep previous `data`. It provides a simple way to display both error and previous data (for example a refresh failure).
final valueErrorWithPreviousData = valueSuccess.toFailure(Exception('error'));

print('Data of value : ${valueErrorWithPreviousData.data}'); // Data of value : 1
print('Error of value : "${valueErrorWithPreviousData.error}"'); // Error of value : "Exception: error"

```

Get the state of the value:

```dart
// Get the state of the value.
final state = valueInitial.state; // ValueState.initial

// Check if the value is in the initial state.
final isInitial = valueInitial.isInitial; // true

// Check if the value is in the success state.
final isSuccess = valueSuccess.isSuccess; // false

// Check if the value is in the failure state.
final isFailure = valueError.isFailure; // false
```

Map the value to a different type:

```dart
// Map the value to a different type.
final map = valueInitial.map(
  initial: () => 'initial',
  success: (data) => 'success: $data',
  failure: (error) => 'failure: $error',
  orElse: () => 'orElse',
);
```

When the value is in a specific state:

```dart
// When the value is in a specific state.
final when = value.when(
  initial: () => print('initial'),
  success: (data) => print('success: $data'),
  failure: (error) => print('failure: $error'),
  orElse: () => print('orElse'),
);
```

Merge two values with different types:

```dart
// Merge two values with different types.
final mergedValue = value1.merge<int>(value2, mapData: (value) => value.length);
```

### Fetch

Generate a stream of Value during a processing Future:

```dart
// Generate a stream of Value during a processing Future.
final stream = Future.value(1).toValues();
```

Handle states (isFetching, success, error...) while an action is processed:

```dart
// Handle states (isFetching, success, error...) while an action is processed.
final fetch = value.fetch(
  () async => 1,
);
```

## License

MIT License

See the [LICENSE](https://www.google.com/url?sa=E&source=gmail&q=https://www.google.com/url?sa=E%26source=gmail%26q=LICENSE) file for details.

## Feedback

Please file any issues, bugs or feature requests as an issue on the [Github page](https://github.com/devobs/value_state/issues).
