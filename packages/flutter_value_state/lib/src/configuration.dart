import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

Widget _defaultBuilder<T>(BuildContext context, BaseState<T> state) =>
    const SizedBox.shrink();

Widget _defaultWrapper<T>(
        BuildContext context, BaseState<T> state, Widget child) =>
    child;

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
    OnValueStateWrapper? wrapper,
    OnValueStateWaiting? builderWaiting,
    OnValueStateNoValue? builderNoValue,
    OnValueStateError? builderError,
    OnValueStateDefault? builderDefault,
  })  : _wrapper = wrapper,
        _builderWaiting = builderWaiting,
        _builderNoValue = builderNoValue,
        _builderError = builderError,
        _builderDefault = builderDefault;

  /// Builder for all states that will be wrapped by this builder.
  OnValueStateWrapper get wrapper => _wrapper ?? _defaultWrapper;
  final OnValueStateWrapper? _wrapper;

  /// Builder for [WaitingState].
  OnValueStateWaiting get builderWaiting => _builderWaiting ?? builderDefault;
  final OnValueStateWaiting? _builderWaiting;

  /// Builder for [NoValueState].
  OnValueStateNoValue get builderNoValue => _builderNoValue ?? builderDefault;
  final OnValueStateNoValue? _builderNoValue;

  /// Builder for [ErrorState].
  OnValueStateError get builderError => _builderError ?? builderDefault;
  final OnValueStateError? _builderError;

  /// Fallback builder when one of the state builder is empty.
  OnValueStateDefault get builderDefault => _builderDefault ?? _defaultBuilder;
  final OnValueStateDefault? _builderDefault;

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
      wrapper: _wrapper,
      builderWaiting: _builderWaiting,
      builderNoValue: _builderNoValue,
      builderError: _builderError,
      builderDefault: _builderDefault,
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
