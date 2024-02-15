import 'package:meta/meta.dart';

/// A class that represents a value that can be in one of three states:
/// * [ValueState.initial] - the initial state of the value.
/// * [ValueState.success] - the state when the value is successfully fetched.
/// * [ValueState.failure] - the state when the value has failed to fetch.
enum ValueState {
  initial,
  success,
  failure,
}

/// A convenient class to handle different states of a value.
/// The three states are enumerated in [ValueState].
///
/// [T] cannot be `null` or `void` :
/// * if you need a nullable data, use an `Optional` class pattern as type.
/// * if you want to follow excution flow with `void`, create or use a `Unit`
///   class.
final class Value<T extends Object> {
  /// Create a value in the initial state.
  const Value.initial({bool isFetching = false})
      : this._(
          data: null,
          failure: null,
          isFetching: isFetching,
        );

  /// Create a value in the success state with [data].
  const Value.success(T data, {bool isFetching = false})
      : this._(
          data: data,
          failure: null,
          isFetching: isFetching,
        );

  /// Map a [Value] to `failure` with actual [data] if any.
  ///
  /// There is no [Value.failure] constructor to prevent developers from
  /// forgetting to retain the [data] from a previous [Value].
  Value<T> toFailure(
    Object error, {
    StackTrace? stackTrace,
    bool isFetching = false,
  }) =>
      Value._(
        data: data,
        failure: _Failure(error, stackTrace: stackTrace),
        isFetching: isFetching,
      );

  /// Create a [Value] in the [ValueState.failure] state.
  /// This is only for tests purpose.
  @visibleForTesting
  Value.failure(
    Object error, {
    StackTrace? stackTrace,
    bool isFetching = false,
  }) : this._(
          data: null,
          failure: _Failure(error, stackTrace: stackTrace),
          isFetching: isFetching,
        );

  const Value._({
    required this.isFetching,
    required this.data,
    required _Failure? failure,
  }) : _failure = failure;

  /// A new value state will be available. It can start from
  /// [ValueState.initial] or a previous [ValueState.success] or
  /// [ValueState.failure].
  final bool isFetching;

  /// Get data if available, otherwise return `null`.
  /// [Value] can have [data] in this [state] :
  /// * [ValueState.success] - when the value is successfully fetched,
  /// * [ValueState.failure] - when the value has failed to `fetch` and the
  ///                          previous [Value] has [data].
  final T? data;

  final _Failure? _failure;

  /// Get error if available, otherwise return `null`.
  Object? get error => _failure?.error;

  /// Get stackTrace if available, otherwise return `null`.
  StackTrace? get stackTrace => _failure?.stackTrace;

  /// Get state of the value.
  ValueState get state => switch (this) {
        Value<T>(hasError: true) => ValueState.failure,
        Value<T>(hasData: true) => ValueState.success,
        _ => ValueState.initial,
      };

  /// Check if the value is in the initial state.
  bool get isInitial => state == ValueState.initial;

  /// Check if the value is in the success state.
  /// If the generic type T is nullable, [isSuccess] will return true if the
  /// data is `null`.
  bool get isSuccess => state == ValueState.success;

  /// Check if the value is in the failure state.
  bool get isFailure => state == ValueState.failure;

  /// Get data if the value is in the [ValueState.success] state, otherwise
  /// return `null`.
  T? get dataOnSuccess => isSuccess ? data : null;

  /// Get data if the value is in the [ValueState.failure] state, otherwise
  /// return `null`. A [Value] in the [ValueState.failure] state can have [data]
  /// if previous value before `fetch` has [data].
  T? get previousDataOnFailure => isFailure ? data : null;

  /// Check if the value has data. It is a bit different of [isSuccess] because
  /// [ValueState.failure] can have data (from previous state).
  bool get hasData => data != null;

  /// Check if the value has error (available only in
  /// [ValueState.failure]).
  bool get hasError => _failure != null;

  /// Check if the value has stack trace (available only in
  /// [ValueState.failure]).
  bool get hasStackTrace => _failure?.stackTrace != null;

  /// Check if the value is fecthing again : the current state is fetching with
  /// a previous fetched state ([ValueState.success] or [ValueState.failure]).
  bool get isRefetching => !isInitial && isFetching;

  /// Copy the actual object with fetching as [isFetching].
  Value<T> copyWithFetching(bool isFetching) => this.isFetching != isFetching
      ? Value._(
          data: data,
          failure: _failure,
          isFetching: isFetching,
        )
      : this;

  /// Merge two values with different type. It is intendend to facilitate
  /// data mapping from a value to another without handling [Value.isFetching]
  /// and [Value.error]/[Value.stackTrace] attributes.
  Value<T> merge<F extends Object>(
    Value<F> from, {
    Value<T> Function(F from)? mapData,
  }) =>
      mapData != null && from.data != null
          ? mapData(from.data!).copyWithFetching(from.isFetching)
          : Value<T>._(
              data: this.data,
              failure: from._failure,
              isFetching: from.isFetching,
            );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is Value<T> &&
          isFetching == other.isFetching &&
          data == other.data &&
          _failure == other._failure;

  @override
  int get hashCode => Object.hash(data, _failure, isFetching);

  @override
  String toString() {
    final prettyPrint = _attributes.entries
        .where((entry) => entry.value?.toString().isNotEmpty ?? false)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');

    return '$runtimeType($prettyPrint)';
  }

  Map<String, dynamic> get _attributes => {
        'state': state,
        'isFetching': isFetching,
        if (!isInitial) 'data': data,
        ...?_failure?._attributes,
      };
}

final class _Failure {
  const _Failure(this.error, {this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _Failure &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hash(error, stackTrace);

  Map<String, dynamic> get _attributes => {
        'error': error,
        'stackTrace': stackTrace,
      };
}
