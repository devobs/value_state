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
      accept(_ValueStateBuilderVisitor<T>(
        onDefault: onDefault,
        onError: onError,
        onWithValue: onValue,
        onNoValue: onNoValue,
        onWaiting: onWaiting,
        valueMixedWithError: valueMixedWithError,
        wrapped: wrapped,
        wrapper: wrapper,
      ));
}

class _ValueStateBuilderVisitor<T> extends StateVisitor<Widget, T> {
  const _ValueStateBuilderVisitor({
    required this.onWithValue,
    required this.onWaiting,
    required this.onNoValue,
    required this.onError,
    required this.onDefault,
    required this.wrapper,
    required this.wrapped,
    required this.valueMixedWithError,
  });

  final OnValueStateWithValue<T>? onWithValue;

  final OnValueStateWaiting<T>? onWaiting;

  final OnValueStateNoValue<T>? onNoValue;
  final OnValueStateError<T>? onError;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapper<T>? wrapper;

  final bool wrapped;
  final bool valueMixedWithError;

  static Widget _unwrapped<T>(
          BuildContext context, BaseState<T> state, Widget child) =>
      child;

  Widget _builder(
    BaseState<T> state,
    Widget Function(BuildContext context,
            ValueStateConfigurationData valueStateConfiguration)
        builder,
  ) =>
      _StateBuilder(
        state: state,
        builder: builder,
        onDefault: onDefault,
        wrapper: wrapper ?? _unwrapped<T>,
        wrapped: wrapped,
      );

  @override
  Widget visitInitState(InitState<T> state) => _visitWaitingState(state);

  @override
  Widget visitPendingState(PendingState<T> state) => _visitWaitingState(state);

  Widget _visitWaitingState(WaitingState<T> state) =>
      _builder(state, (context, valueStateConfiguration) {
        final onWaiting =
            this.onWaiting ?? valueStateConfiguration.builderWaiting;

        return onWaiting(context, state);
      });

  @override
  Widget visitNoValueState(NoValueState<T> state) =>
      _builder(state, (context, valueStateConfiguration) {
        final onNoValue =
            this.onNoValue ?? valueStateConfiguration.builderNoValue;

        return onNoValue(context, state);
      });

  @override
  Widget visitValueState(ValueState<T> state) => _visitWithValueState(state);

  @override
  Widget visitErrorState(ErrorState<T> state) {
    if (valueMixedWithError && state is ErrorWithPreviousValue<T>) {
      return _visitWithValueState(state);
    }

    return _builder(state, (context, valueStateConfiguration) {
      final onError = this.onError ?? valueStateConfiguration.builderError;

      return onError(context, state);
    });
  }

  Widget _visitWithValueState(WithValueState<T> state) =>
      _builder(state, (context, valueStateConfiguration) {
        final onError = this.onError ?? valueStateConfiguration.builderError;
        Widget? error;

        if (state is ErrorWithPreviousValue<T>) {
          error = onError(context, state);
        }

        return onWithValue?.call(context, state, error) ??
            valueStateConfiguration.builderDefault(context, state);
      });
}

class _StateBuilder<T> extends StatelessWidget {
  const _StateBuilder({
    required this.state,
    required this.builder,
    required this.onDefault,
    required this.wrapper,
    required this.wrapped,
  });

  final BaseState<T> state;
  final Widget Function(BuildContext context,
      ValueStateConfigurationData valueStateConfiguration) builder;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapper<T> wrapper;

  final bool wrapped;

  @override
  Widget build(BuildContext context) {
    final valueStateConfiguration = context.stateConfiguration;
    Widget child = builder(context, valueStateConfiguration);

    child = wrapper(context, state, child);

    return wrapped
        ? valueStateConfiguration.wrapper(context, state, child)
        : child;
  }
}
