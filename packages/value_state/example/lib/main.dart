import 'package:flutter/material.dart';
import 'package:value_state/value_state.dart';

import 'widgets/action_button.dart';
import 'widgets/app_root.dart';
import 'widgets/counter_notifier.dart';
import 'widgets/default_error.dart';
import 'widgets/formatted_column.dart';
import 'widgets/loader.dart';

// coverage:ignore-start
void main() {
  runApp(const MyApp());
}
// coverage:ignore-end

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) =>
      CounterNotifier(child: const AppRoot(child: MyHomePage()));
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) =>
      // This example, show how to handle different states with refetching
      // problematic. In this case, when an error is raised after a value has
      // been successfully fetched, we can see the error and the last value
      // fetched both displayed.
      ValueListenableBuilder(
        valueListenable: CounterNotifier.of(context),
        builder: (context, state, _) {
          if (state.isInitial) return const Loader();

          return FormattedColumn(children: [
            RefreshLoader(isLoading: state.isRefetching),
            if (state case Value(:final error?)) DefaultError(error: error),
            if (state case Value(:final data?)) Text('Counter value : $data'),
            ActionButton(
              onPressed: state.isRefetching
                  ? null
                  : CounterNotifier.of(context).increment,
            ),
          ]);
        },
      );
}
