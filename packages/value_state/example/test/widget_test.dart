// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:value_state_example/main.dart';
import 'package:value_state_example/main_cubit.dart';
import 'package:value_state_example/main_riverpod.dart';

void main() {
  testScenario(
    'Counter increments standard test',
    const MyApp(),
  );
  testScenario(
    'Counter increments cubit test',
    const MyCubitApp(),
  );
  testScenario(
    'Counter increments riverpod test',
    const ProviderScope(child: MyRiverpodApp()),
  );
}

@isTest
void testScenario(String name, Widget widget) {
  const incrementTextButton = 'Increment';
  const expectedError = 'Expected error.';
  Finder findCounter(int count) => find.text('Counter value : $count');

  testWidgets(
    name,
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      runZonedGuarded<void>(
        () async {
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          // Verify that our counter starts at 0.
          expect(findCounter(0), findsOneWidget);
          expect(findCounter(1), findsNothing);
          expect(find.byType(LinearProgressIndicator), findsNothing);

          // Tap the refresh icon.
          await tester.tap(find.text(incrementTextButton));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(findCounter(0), findsNothing);
          expect(findCounter(1), findsOneWidget);
          expect(find.text(expectedError), findsNothing);

          // Tap the refresh icon.
          await tester.tap(find.text(incrementTextButton));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text(expectedError), findsOneWidget);
          expect(findCounter(1), findsOneWidget);

          // Tap the refresh icon.
          await tester.tap(find.text(incrementTextButton));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text(expectedError), findsNothing);
          expect(findCounter(3), findsOneWidget);

          await tester.tap(find.text(incrementTextButton));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text(expectedError), findsNothing);
          expect(findCounter(4), findsOneWidget);

          await tester.tap(find.text(incrementTextButton));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text(expectedError), findsNothing);
          expect(findCounter(5), findsOneWidget);
        },
        (error, stack) {
          if (error != 'Error') {
            // 'Error' expected
            throw error;
          }
        },
      );
    },
  );
}
