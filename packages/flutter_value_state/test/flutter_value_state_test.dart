import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_state/flutter_value_state.dart';

const _buildWidgetKey = ValueKey('buildWidget');
const _defaultWidgetKey = ValueKey('defaultWidget');
const _errorWidgetKey = ValueKey('errorWidget');
const _noValueWidgetKey = ValueKey('noValueWidget');
const _waitingWidgetKey = ValueKey('waitingWidget');
const _wrapperWidgetKey = ValueKey('wrapperWidget');
const _defaultWidgetType = SizedBox;

late ValueStateConfigurationData _valueStateConfigurationData;

class _TestWidget<T extends BaseState<int>> extends StatelessWidget {
  const _TestWidget({
    required this.state,
    this.valueMixedWithError = false,
    this.child,
    this.onWaiting,
    this.onNoValue,
    this.onError,
    this.onDefault,
    this.wrapper,
    this.wrapped = true,
  });

  final T state;
  final bool valueMixedWithError;

  final Widget? child;

  final OnValueStateWaiting<dynamic>? onWaiting;
  final OnValueStateNoValue<dynamic>? onNoValue;
  final OnValueStateError<dynamic>? onError;
  final OnValueStateDefault<dynamic>? onDefault;
  final OnValueStateWrapper<dynamic>? wrapper;

  final bool wrapped;

  @override
  Widget build(BuildContext context) {
    return state.buildWidget(
      onValue: (context, state, error) {
        return Column(
          children: [
            if (error != null) error,
            child ?? const SizedBox.shrink(key: _buildWidgetKey),
          ],
        );
      },
      valueMixedWithError: valueMixedWithError,
      onDefault: onDefault,
      onError: onError,
      onNoValue: onNoValue,
      onWaiting: onWaiting,
      wrapper: wrapper,
      wrapped: wrapped,
    );
  }
}

class _TestConfigurationWidget<T extends BaseState<int>>
    extends StatefulWidget {
  const _TestConfigurationWidget({
    super.key,
    required this.state,
    this.valueMixedWithError = false,
    this.child,
    this.onWaiting,
    this.onNoValue,
    this.onError,
    this.onDefault,
    this.wrapper,
    this.wrapped = true,
  });

  final T state;
  final bool valueMixedWithError;

  final Widget? child;

  final OnValueStateWaiting<dynamic>? onWaiting;
  final OnValueStateNoValue<dynamic>? onNoValue;
  final OnValueStateError<dynamic>? onError;
  final OnValueStateDefault<dynamic>? onDefault;
  final OnValueStateWrapper<dynamic>? wrapper;

  final bool wrapped;

  @override
  State<_TestConfigurationWidget<T>> createState() =>
      _TestConfigurationWidgetState<T>();
}

class _TestConfigurationWidgetState<T extends BaseState<int>>
    extends State<_TestConfigurationWidget<T>> {
  OnValueStateError _onError =
      (context, state) => const SizedBox.shrink(key: _errorWidgetKey);

  void updateOnError(OnValueStateError onError) {
    setState(() {
      _onError = onError;
    });
  }

  @override
  Widget build(BuildContext context) {
    _valueStateConfigurationData = ValueStateConfigurationData(
      builderDefault: (context, state) =>
          const SizedBox.shrink(key: _defaultWidgetKey),
      builderError: _onError,
      builderNoValue: (context, state) =>
          const SizedBox.shrink(key: _noValueWidgetKey),
      builderWaiting: (context, state) =>
          const SizedBox.shrink(key: _waitingWidgetKey),
      wrapper: (context, state, child) =>
          KeyedSubtree(key: _wrapperWidgetKey, child: child),
    );

    return ValueStateConfiguration(
        configuration: _valueStateConfigurationData,
        child: _TestWidget<T>(
          state: widget.state,
          valueMixedWithError: widget.valueMixedWithError,
          child: widget.child,
          onDefault: widget.onDefault,
          onError: widget.onError,
          onNoValue: widget.onNoValue,
          onWaiting: widget.onWaiting,
          wrapper: widget.wrapper,
          wrapped: widget.wrapped,
        ));
  }
}

void main() {
  test('$ValueStateConfiguration.copyWith without parameter', () {
    const configuration = ValueStateConfigurationData();

    expect(configuration.copyWith(), configuration);
  });

  group('without configuration', () {
    testWidgets('buildWidget with ${ValueState<int>}', (tester) async {
      await tester.pumpWidget(const _TestWidget(state: ValueState(1)));

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    testWidgets('buildWidget without parameter with ${ValueState<int>}',
        (tester) async {
      await tester.pumpWidget(const ValueState(1).buildWidget());

      expect(find.byKey(_buildWidgetKey), findsNothing);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    for (final state in <BaseState<int>>[
      const InitState(),
      const PendingState(),
      // const ValueState(1),
      const NoValueState(),
      ErrorState<int>(
          previousState: const InitState<int>(),
          error: 'Error',
          refreshing: false)
    ]) {
      testWidgets('defaultBuilder with ${state.runtimeType}', (tester) async {
        await tester.pumpWidget(_TestWidget(state: state));

        expect(find.byKey(_buildWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });

      testWidgets(
          'defaultBuilder with empty configuration ${state.runtimeType}',
          (tester) async {
        await tester.pumpWidget(
          ValueStateConfiguration(
              configuration: const ValueStateConfigurationData(),
              child: _TestWidget(state: state)),
        );

        expect(find.byKey(_buildWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });
    }

    for (final state in <BaseState<int>>[
      const InitState(),
      const PendingState(),
      // const ValueState(1),
      const NoValueState(),
      ErrorState<int>(
          previousState: const InitState<int>(),
          error: 'Error',
          refreshing: false)
    ]) {
      testWidgets('defaultBuilder with ${state.runtimeType}', (tester) async {
        await tester.pumpWidget(_TestWidget(state: state));

        expect(find.byKey(_buildWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });
    }
  });

  group('with configuration', () {
    testWidgets('should get ValueStateConfigurationData', (tester) async {
      late ValueStateConfigurationData valueStateConfigurationData;
      await tester.pumpWidget(_TestConfigurationWidget(
          state: const ValueState(1),
          child: Builder(builder: (context) {
            valueStateConfigurationData = ValueStateConfiguration.of(context);
            return const SizedBox.shrink();
          })));

      expect(valueStateConfigurationData, _valueStateConfigurationData);
      expect(valueStateConfigurationData.hashCode,
          _valueStateConfigurationData.hashCode);
    });

    testWidgets('buildWidget with ${ValueState<int>}', (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: const ValueState(1),
      ));

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);

      testKey.currentState!.updateOnError((context, state) {
        return Container(key: _errorWidgetKey);
      });

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    for (final state in <BaseState<int>, Key>{
      const InitState(): _waitingWidgetKey,
      const PendingState(): _waitingWidgetKey,
      const NoValueState(): _noValueWidgetKey,
      ErrorState<int>(
          previousState: const InitState<int>(),
          error: 'Error',
          refreshing: false): _errorWidgetKey,
    }.entries) {
      testWidgets('build with ${state.key.runtimeType}', (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(state: state.key));

        expect(find.byKey(state.value), findsOneWidget);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });
    }

    for (final state in <BaseState<int>, Key>{
      const InitState(): _waitingWidgetKey,
      const PendingState(): _waitingWidgetKey,
      const NoValueState(): _noValueWidgetKey,
      ErrorState<int>(
          previousState: const InitState<int>(),
          error: 'Error',
          refreshing: false): _errorWidgetKey,
    }.entries) {
      const wrapperKey = Key('innerWrapperWidget');
      testWidgets(
          'build with ${state.key.runtimeType} and callbacks and wrapper',
          (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(
          state: state.key,
          onDefault: (context, state) => Container(key: _defaultWidgetKey),
          onError: (context, state) => Container(key: _errorWidgetKey),
          onNoValue: (context, state) => Container(key: _noValueWidgetKey),
          onWaiting: (context, state) => Container(key: _waitingWidgetKey),
          wrapper: (context, state, child) =>
              Center(key: wrapperKey, child: child),
        ));

        expect(find.byKey(state.value), findsOneWidget);
        expect(find.byKey(wrapperKey), findsOneWidget);
        expect(find.byType(_defaultWidgetType), findsNothing);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets(
          'build with ${state.key.runtimeType} and callbacks and wrapper disabled',
          (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(
          state: state.key,
          onDefault: (context, state) => Container(key: _defaultWidgetKey),
          onError: (context, state) => Container(key: _errorWidgetKey),
          onNoValue: (context, state) => Container(key: _noValueWidgetKey),
          onWaiting: (context, state) => Container(key: _waitingWidgetKey),
          wrapper: (context, state, child) =>
              Center(key: wrapperKey, child: child),
          wrapped: false,
        ));

        expect(find.byKey(state.value), findsOneWidget);
        expect(find.byKey(wrapperKey), findsOneWidget);
        expect(find.byType(_defaultWidgetType), findsNothing);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
      });
    }

    testWidgets(
        'build with ${ErrorWithoutPreviousValue<int>} with and valueMixedWithError',
        (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: ErrorState<int>(
          previousState: const InitState(),
          error: 'Error',
          refreshing: false,
        ),
        valueMixedWithError: true,
      ));

      expect(find.byKey(_buildWidgetKey), findsNothing);
      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    testWidgets('build with ${ErrorWithPreviousValue<int>}', (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: ErrorState<int>(
          previousState: const ValueState(1),
          error: 'Error',
          refreshing: false,
        ),
      ));

      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);

      testKey.currentState!.updateOnError((context, state) {
        return Container(key: _errorWidgetKey);
      });

      await tester.pumpAndSettle();

      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsNothing);
    });

    testWidgets(
        'build with ${ErrorWithPreviousValue<int>} with and valueMixedWithError',
        (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: ErrorState<int>(
          previousState: const ValueState(1),
          error: 'Error',
          refreshing: false,
        ),
        valueMixedWithError: true,
      ));

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsNWidgets(2));
    });
  });
}
