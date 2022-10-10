import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

typedef OnValueStateWaiting<T> = Widget Function(
    BuildContext context, WaitingState<T> state);

typedef OnValueStateWithValue<T> = Widget Function(
    BuildContext context, WithValueState<T> state, Widget? error);
typedef OnValueStateNoValue<T> = Widget Function(
    BuildContext context, NoValueState<T> state);
typedef OnValueStateError<T> = Widget Function(
    BuildContext context, ErrorState<T> state);
typedef OnValueStateDefault<T> = Widget Function(
    BuildContext context, BaseState<T> state);
typedef OnValueStateWrapper<T> = Widget Function(
    BuildContext context, BaseState<T> state, Widget child);

/// Define default behavior for the states [WaitingState], [NoValueState], [ErrorState].
/// [builderDefault] can be used when none of this callback is mentionned.
class ValueStateConfigurationData {
  const ValueStateConfigurationData({
    this.wrapper,
    this.builderWaiting,
    this.builderNoValue,
    this.builderError,
    this.builderDefault,
  });

  /// Builder for all states that will be wrapped by this builder.
  final OnValueStateWrapper? wrapper;

  /// Builder for [WaitingState].
  final OnValueStateWaiting? builderWaiting;

  /// Builder for [NoValueState].
  final OnValueStateNoValue? builderNoValue;

  /// Builder for [ErrorState].
  final OnValueStateError? builderError;

  /// Fallback builder when one of the state builder is empty.
  final OnValueStateDefault? builderDefault;

  /// Creates a copy of this [ValueStateConfigurationData] but with the given
  /// fields replaced with the new values.
  ValueStateConfigurationData copyWith({
    OnValueStateWrapper? wrapper,
    OnValueStateWaiting? builderWaiting,
    OnValueStateNoValue? builderNoValue,
    OnValueStateError? builderError,
    OnValueStateDefault? builderDefault,
  }) =>
      ValueStateConfigurationData(
        wrapper: wrapper ?? this.wrapper,
        builderWaiting: builderWaiting ?? this.builderWaiting,
        builderNoValue: builderNoValue ?? this.builderNoValue,
        builderError: builderError ?? this.builderError,
        builderDefault: builderDefault ?? this.builderDefault,
      );

  /// Creates a new [ValueStateConfigurationData] where each parameter
  /// from this object has been merged with the matching attribute.
  ValueStateConfigurationData merge(
      ValueStateConfigurationData? configuration) {
    final baseConfiguration =
        configuration ?? const ValueStateConfigurationData();

    return baseConfiguration.copyWith(
      wrapper: wrapper,
      builderWaiting: builderWaiting,
      builderNoValue: builderNoValue,
      builderError: builderError,
      builderDefault: builderDefault,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ValueStateConfigurationData &&
          wrapper == other.wrapper &&
          builderWaiting == other.builderWaiting &&
          builderNoValue == other.builderNoValue &&
          builderError == other.builderError &&
          builderDefault == other.builderDefault;

  @override
  int get hashCode => Object.hash(
        wrapper,
        builderNoValue,
        builderWaiting,
        builderError,
        builderDefault,
      );
}

/// Provide a [ValueStateConfigurationData] for all inherited widget to define
/// default behavior for any state of [BaseState] except [ValueState].
///
/// If this configuration is in a subtree of another [ValueStateConfiguration],
/// the configuration will be merged with the parent one.
class ValueStateConfiguration extends StatelessWidget {
  const ValueStateConfiguration({
    super.key,
    required this.configuration,
    required this.child,
  });

  /// The default to configuration.
  final ValueStateConfigurationData configuration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inheritedConfiguration = maybeOf(context);

    return _ValueStateConfiguration(
        configuration: configuration.merge(inheritedConfiguration),
        child: child);
  }

  static ValueStateConfigurationData? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ValueStateConfiguration>()
      ?.configuration;

  static ValueStateConfigurationData of(BuildContext context) {
    final ValueStateConfigurationData? configuration = maybeOf(context);

    assert(
        configuration != null, 'No $ValueStateConfiguration found in context');

    return configuration!;
  }
}

class _ValueStateConfiguration extends InheritedWidget {
  const _ValueStateConfiguration(
      {required this.configuration, required super.child});

  final ValueStateConfigurationData configuration;

  @override
  bool updateShouldNotify(covariant _ValueStateConfiguration oldWidget) =>
      configuration != oldWidget.configuration;
}
