import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

import 'configuration.dart';

extension StateConfigurationExtensions on BuildContext {
  ValueStateConfigurationData get stateConfiguration =>
      ValueStateConfiguration.maybeOf(this) ??
      const ValueStateConfigurationData();
}

extension ValueStateBuilderExtension<T> on BaseState<T> {
  Widget buildWidget({
    Key? key,
    OnValueStateWithValue<T>? onValue,
    OnValueStateWaiting<T>? onWaiting,
    OnValueStateNoValue<T>? onNoValue,
    OnValueStateError<T>? onError,
    OnValueStateDefault<T>? onDefault,
    OnValueStateWrapper<T>? wrapper,
    bool wrapped = true,
    bool valueMixedWithError = false,
  }) =>
      ValueStateWidget<T>(
        state: this,
        onDefault: onDefault,
        onError: onError,
        onWithValue: onValue,
        onNoValue: onNoValue,
        onWaiting: onWaiting,
        valueMixedWithError: valueMixedWithError,
        wrapped: wrapped,
        wrapper: wrapper,
      );
}

class ValueStateWidget<T> extends StatelessWidget {
  const ValueStateWidget({
    required this.state,
    this.onWithValue,
    this.onWaiting,
    this.onNoValue,
    this.onError,
    this.onDefault,
    this.wrapper,
    this.wrapped = true,
    this.valueMixedWithError = false,
  });

  final BaseState<T> state;

  final OnValueStateWithValue<T>? onWithValue;

  final OnValueStateWaiting<T>? onWaiting;

  final OnValueStateNoValue<T>? onNoValue;
  final OnValueStateError<T>? onError;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapper<T>? wrapper;

  final bool wrapped;
  final bool valueMixedWithError;

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    if (state is WaitingState<T>) {
      return _buildWaitingState(context, state);
    } else if (state is NoValueState<T>) {
      return _buildNoValueState(context, state);
    } else if (state is ValueState<T>) {
      return _buildWithValueState(context, state);
    } else if (state is ErrorState<T>) {
      return _buildErrorState(context, state);
    }

    // coverage:ignore-start
    throw UnimplementedError();
    // coverage:ignore-end
  }

  Widget _builder(
    BuildContext context,
    BaseState<T> state,
    Widget Function(
      BuildContext context,
      ValueStateConfigurationData valueStateConfiguration,
      OnValueStateDefault<T>? onDefault,
    ) builder,
  ) {
    final valueStateConfiguration = context.stateConfiguration;
    Widget child = builder(context, valueStateConfiguration, onDefault);

    if (wrapper != null) {
      child = wrapper!(context, state, child);
    }

    return wrapped
        ? valueStateConfiguration.wrapper(context, state, child)
        : child;
  }

  Widget _buildWaitingState(BuildContext context, WaitingState<T> state) =>
      _builder(context, state, (context, valueStateConfiguration, onDefault) {
        final onWaiting = this.onWaiting ??
            onDefault ??
            valueStateConfiguration.builderWaiting;

        return onWaiting(context, state);
      });

  Widget _buildNoValueState(BuildContext context, NoValueState<T> state) =>
      _builder(context, state, (context, valueStateConfiguration, onDefault) {
        final onNoValue = this.onNoValue ??
            onDefault ??
            valueStateConfiguration.builderNoValue;

        return onNoValue(context, state);
      });

  Widget _buildWithValueState(BuildContext context, WithValueState<T> state) =>
      _builder(context, state, (context, valueStateConfiguration, onDefault) {
        final onError =
            this.onError ?? onDefault ?? valueStateConfiguration.builderError;
        Widget? error;

        if (state is ErrorWithPreviousValue<T>) {
          error = onError(context, state);
        }

        return onWithValue?.call(context, state, error) ??
            onDefault?.call(context, state) ??
            valueStateConfiguration.builderDefault(context, state);
      });

  Widget _buildErrorState(BuildContext context, ErrorState<T> state) {
    if (valueMixedWithError && state is ErrorWithPreviousValue<T>) {
      return _buildWithValueState(context, state);
    }

    return _builder(context, state,
        (context, valueStateConfiguration, onDefault) {
      final onError =
          this.onError ?? onDefault ?? valueStateConfiguration.builderError;

      return onError(context, state);
    });
  }
}
