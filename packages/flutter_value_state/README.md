A dart package that helps to implement basic states for [BLoC library](https://pub.dev/packages/bloc) to perform, load and fetch data.


[![pub package](https://img.shields.io/pub/v/flutter_value_state.svg)](https://pub.dev/packages/flutter_value_state)
[![Test](https://github.com/devobs/value_state/actions/workflows/test.yml/badge.svg)](https://github.com/devobs/value_state/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/devobs/value_state/branch/main/graph/badge.svg)](https://app.codecov.io/gh/devobs/value_state/tree/main/packages/flutter_value_state)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

* Provides all necessary states for data : init, waiting, value/no value and error states (from [value_state](https://pub.dev/packages/value_state)),
* Provides `BaseState.buildWidget` that build a widget depending on its state. The `WithValueState` case is mandatory (first ordered parameter). Other states that are not passed as parameter are handled by `ValueStateConfiguration`. If no `ValueStateConfiguration` is in ascendant tree, a `SizedBox`is returned,
* `ValueStateConfiguration` provides a default behavior for null parameters in `BaseState.buildWidget`.

## Usage

This example show in the Flutter app, how pattern matching is used to handles the different states.

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => CounterCubit(),
        child: MaterialApp(
          title: 'Value Cubit Demo',
          builder: (context, child) => child == null
              ? const SizedBox.shrink()
              : ValueStateConfiguration(
                  configuration: ValueStateConfigurationData(
                    builderWaiting: (context, state) =>
                        const Center(child: CircularProgressIndicator()),
                    builderError: (context, state) => Center(
                      child: Text('Expected error.',
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                    builderNoValue: (context, state) =>
                        const Center(child: Text('No value.')),
                    wrapper: (context, state, child) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: child),
                  ),
                  child: child,
                ),
          home: const MyHomePage(),
        ));
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
          child: state.buildWidget(
              (context, state, error) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.refreshing) const LinearProgressIndicator(),
                        const Spacer(),
                        if (error != null) error,
                        const Text('Counter value :'),
                        Text(
                          state.value.toString(),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const Spacer(),
                      ]),
              valueMixedWithError: true),
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

## Feedback

Please file any issues, bugs or feature requests as an issue on the [Github page](https://github.com/devobs/value_state/issues).
