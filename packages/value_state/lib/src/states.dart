/// Base class for handling value states.
abstract class BaseState<T> {
  const BaseState();

  /// The action is processing to get a new value or refresh it.
  bool get fetching;

  /// Copy the actual object and according to the state can enable refreshing
  BaseState<T> mayRefreshing();

  /// Copy the actual object and according to the state can disable refreshing
  BaseState<T> mayNotRefreshing();

  /// Visitor pattern to safely enhance class capabilities
  R accept<R>(StateVisitor<R, T> visitor);

  Map<String, dynamic> get _diagnosticableAttributes => {'fetching': fetching};

  @override
  String toString() {
    return '$runtimeType${_prettyPrint(_diagnosticableAttributes)}';
  }

  static String _prettyPrint(Map<String, dynamic> attributes) =>
      '(${attributes.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')})';
}

/// State for waiting value and there was no [ReadyState] before.
/// Useful to handle waiting page before first value is displayed or when
/// a user is disconnected.
abstract class WaitingState<T> extends BaseState<T> {
  const WaitingState();

  @override
  WaitingState<T> mayRefreshing();

  @override
  WaitingState<T> mayNotRefreshing();

  @override
  bool get fetching => true;
}

/// Initial state before any processing. If all has been intialized and
/// the action to get the value is started, then emit a [WaitingState]
class InitState<T> extends WaitingState<T> {
  const InitState();

  @override
  WaitingState<T> mayRefreshing() => PendingState<T>();

  @override
  WaitingState<T> mayNotRefreshing() => PendingState<T>();

  @override
  R accept<R>(StateVisitor<R, T> visitor) => visitor.visitInitState(this);

  @override
  bool operator ==(other) =>
      identical(this, other) || runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Initial state before any processing. If all has been intialized and
/// the action to get the value is started, then emit a [WaitingState]
class PendingState<T> extends WaitingState<T> {
  const PendingState();

  @override
  WaitingState<T> mayRefreshing() => this;

  @override
  WaitingState<T> mayNotRefreshing() => this;

  @override
  R accept<R>(StateVisitor<R, T> visitor) => visitor.visitPendingState(this);

  @override
  bool operator ==(other) =>
      identical(this, other) || runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
}

/// Abstract class for all states that a value, no value or error has been
/// received.
abstract class ReadyState<T> extends BaseState<T> {
  const ReadyState();

  /// This property indicate an action is processing from a [ReadyState] to get a new state.
  /// [ValueState], [NoValueState] or [ErrorState] will be emitted.
  bool get refreshing;

  @override
  bool get fetching => refreshing;

  /// Current state carry a value ?
  bool get hasValue;

  /// Current state is an error ?
  bool get hasError;

  @override
  ReadyState<T> mayRefreshing();

  @override
  ReadyState<T> mayNotRefreshing();
}

/// State with no value (support null safety).
class NoValueState<T> extends ReadyState<T> {
  const NoValueState({this.refreshing = false});

  @override
  final hasValue = false;

  @override
  final hasError = false;

  @override
  final bool refreshing;

  @override
  ReadyState<T> mayRefreshing() => NoValueState<T>(refreshing: true);

  @override
  ReadyState<T> mayNotRefreshing() => NoValueState<T>(refreshing: false);

  @override
  R accept<R>(StateVisitor<R, T> visitor) => visitor.visitNoValueState(this);

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is NoValueState<T> &&
          refreshing == other.refreshing;
  @override
  int get hashCode => refreshing.hashCode;
}

/// Abstraction of a state with a value [ValueState] or [ErrorState]
abstract class WithValueState<T> extends ReadyState<T> {
  /// Value associated with state
  T get value;
}

/// State that provide the value.
class ValueState<T> extends ReadyState<T> implements WithValueState<T> {
  const ValueState(this.value, {this.refreshing = false});

  @override
  final T value;

  @override
  final hasValue = true;

  @override
  final hasError = false;

  @override
  final bool refreshing;

  @override
  ReadyState<T> mayRefreshing() => ValueState<T>(value, refreshing: true);

  @override
  ReadyState<T> mayNotRefreshing() => ValueState<T>(value, refreshing: false);

  @override
  R accept<R>(StateVisitor<R, T> visitor) => visitor.visitValueState(this);

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ValueState<T> &&
          refreshing == other.refreshing &&
          value == other.value;
  @override
  int get hashCode => Object.hash(refreshing, value);

  @override
  Map<String, dynamic> get _diagnosticableAttributes => {
        ...super._diagnosticableAttributes,
        'value': value,
      };
}

/// State for error (may be linked with a [ValueState] or not)
abstract class ErrorState<T> extends ReadyState<T> {
  factory ErrorState({
    required BaseState<T> previousState,
    required Object error,
    StackTrace? stackTrace,
    bool refreshing = false,
  }) {
    final stateBeforeError = _consumePreviousErrors<T>(previousState);

    if (stateBeforeError is ValueState<T>) {
      return ErrorWithPreviousValue<T>._(
          stateBeforeError: stateBeforeError,
          error: error,
          stackTrace: stackTrace,
          refreshing: refreshing);
    }

    return ErrorWithoutPreviousValue<T>._(
        stateBeforeError: stateBeforeError,
        error: error,
        stackTrace: stackTrace,
        refreshing: refreshing);
  }

  const ErrorState._({
    required this.error,
    required this.stackTrace,
    required this.stateBeforeError,
    required this.refreshing,
  });

  /// Previous state that is not [ErrorState]. If several errors are
  /// triggered, they are also ignored.
  final BaseState<T> stateBeforeError;

  /// The error object.
  final Object error;

  @override
  final hasError = true;

  /// The error stack trace.
  final StackTrace? stackTrace;

  /// Current error has previous value
  @override
  bool get hasValue => stateBeforeError is ValueState<T>;

  static BaseState<T> _consumePreviousErrors<T>(BaseState<T> state) =>
      state is ErrorState<T>
          ? _consumePreviousErrors<T>(state.stateBeforeError)
          : state.mayNotRefreshing();

  @override
  final bool refreshing;

  @override
  ReadyState<T> mayRefreshing() => ErrorState<T>(
        previousState: stateBeforeError,
        refreshing: true,
        error: error,
        stackTrace: stackTrace,
      );

  @override
  ReadyState<T> mayNotRefreshing() => ErrorState<T>(
        previousState: stateBeforeError,
        refreshing: false,
        error: error,
        stackTrace: stackTrace,
      );

  @override
  R accept<R>(StateVisitor<R, T> visitor) => visitor.visitErrorState(this);

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ErrorState<T> &&
          refreshing == other.refreshing &&
          error == other.error &&
          stackTrace == other.stackTrace &&
          stateBeforeError == other.stateBeforeError;
  @override
  int get hashCode =>
      Object.hash(refreshing, error, stackTrace, stateBeforeError);

  @override
  Map<String, dynamic> get _diagnosticableAttributes => {
        ...super._diagnosticableAttributes,
        'error': error,
        if (stackTrace != null) 'stackTrace': stackTrace,
        'stateBeforeError': stateBeforeError,
      };
}

/// An error with a [ValueState] as previous state
class ErrorWithoutPreviousValue<T> extends ErrorState<T> {
  const ErrorWithoutPreviousValue._({
    required Object error,
    required StackTrace? stackTrace,
    required BaseState<T> stateBeforeError,
    required bool refreshing,
  }) : super._(
            error: error,
            stackTrace: stackTrace,
            stateBeforeError: stateBeforeError,
            refreshing: refreshing);
}

/// An error with a [ValueState] as previous state
class ErrorWithPreviousValue<T> extends ErrorState<T>
    implements WithValueState<T> {
  const ErrorWithPreviousValue._({
    required Object error,
    required StackTrace? stackTrace,
    required ValueState<T> stateBeforeError,
    required bool refreshing,
  }) : super._(
            error: error,
            stackTrace: stackTrace,
            stateBeforeError: stateBeforeError,
            refreshing: refreshing);

  @override
  ValueState<T> get stateBeforeError => super.stateBeforeError as ValueState<T>;

  @override
  T get value => stateBeforeError.value;
}

/// Visitor base class to enhance states capabilities
abstract class StateVisitor<R, T> {
  const StateVisitor();

  R visitInitState(InitState<T> state);
  R visitPendingState(PendingState<T> state);

  R visitValueState(ValueState<T> state);
  R visitNoValueState(NoValueState<T> state);

  R visitErrorState(ErrorState<T> state);
}
