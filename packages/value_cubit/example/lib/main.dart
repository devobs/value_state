import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_state/value_state.dart';

import 'cubit.dart';

// coverage:ignore-start
void main() {
  runApp(const MyApp());
}
// coverage:ignore-end

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => CounterCubit(),
        child: const MaterialApp(
          title: 'Value Cubit Demo',
          home: MyHomePage(),
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
