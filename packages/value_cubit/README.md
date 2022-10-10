A dart package that helps to implement basic states for [BLoC library](https://pub.dev/packages/bloc) to perform, load and fetch data.


[![pub package](https://img.shields.io/pub/v/value_cubit.svg)](https://pub.dev/packages/value_cubit)
[![Test](https://github.com/devobs/value_state/actions/workflows/test.yml/badge.svg)](https://github.com/devobs/value_state/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/devobs/value_state/branch/main/graph/badge.svg)](https://app.codecov.io/gh/devobs/value_state/tree/main/packages/value_cubit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

* Provides all necessary states for data : init, waiting, value/no value and error states (from [value_state](https://pub.dev/packages/value_state)),
* A `ValueCubit` class to simplify `Cubit` subclassing,
* A `RefreshValueCubit` class like `ValueCubit` with refreshing capabilities,
* Some helpers `perform` (an extension on `Cubit`) to emit intermediate states while an action is intended to update state : the same state is reemitted with attribute `refreshing` at `true`.

## Usage

This example shows how different value states from this library help developpers to show load step data widgets.


```dart
class CounterCubit extends ValueCubit<int> {
  var _value = 0;

  // Put your WS call that can be refreshed
  Future<int> _getCounterValueFromWebService() async => _value++;

  Future<void> increment() => perform(() async {
        // [perform] generate intermediate or final states such as PendingState,
        // concrete subclass of ReadyState with right [ReadyState.refreshing] value
        // or ErrorState if an error is raised.
        final result = await _getCounterValueFromWebService();

        emit(ValueState(result));
      });

  void clear() {
    _value = 0;
    emit(const PendingState());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CounterCubit, BaseState<int>>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: DefaultTextStyle(
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          child: state is ReadyState<int>
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (state.refreshing) const LinearProgressIndicator(),
                    const Spacer(),
                    if (state.hasError)
                      Text('Expected error.',
                          style: TextStyle(color: theme.errorColor)),
                    if (state is WithValueState<int>) ...[
                      if (state.hasError)
                        const Text('Previous counter value :')
                      else
                        const Text('Actual counter value :'),
                      Text(
                        state.value.toString(),
                        style: theme.textTheme.headline4,
                      ),
                    ],
                    if (state is NoValueState<int>) const Text('No Value'),
                    const Spacer(),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        floatingActionButton: state is! ReadyState<int>
            ? null
            : FloatingActionButton(
                onPressed: state.refreshing
                    ? null
                    : context.read<CounterCubit>().increment,
                tooltip: 'Increment',
                child: state.refreshing
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary))
                    : const Icon(Icons.refresh)),
      );
    });
  }
}
```

The whole code of this example is available in [example](example).


If your cubit is only a getter with the need to refresh your cubit state, you can simplify the implementation `ValueCubit` with `RefreshValueCubit`.

```dart
class CounterCubit extends RefreshValueCubit<int> {
  var _value = 0;

  // Put your WS call that can be refreshed
  Future<int> _getCounterValueFromWebService() async => _value++;

  @override
  Future<void> emitValues() async {
    final result = await _getCounterValueFromWebService();

    emit(ValueState(result));
  }
}
```

Update your value (increment in our example) by calling `myCubit.refresh()`.

## Feedback

Please file any issues, bugs or feature requests as an issue on the [Github page](https://github.com/devobs/value_state/issues).
