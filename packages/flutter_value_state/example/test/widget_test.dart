// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_state_value_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Counter increments test',
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      runZonedGuarded<void>(
        () async {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle();

          // Verify that our counter starts at 0.
          expect(find.text('0'), findsOneWidget);
          expect(find.text('1'), findsNothing);
          expect(find.byType(LinearProgressIndicator), findsNothing);

          // Tap the refresh icon.
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text('0'), findsNothing);
          expect(find.text('1'), findsOneWidget);
          expect(find.text('Expected error.'), findsNothing);

          // Tap the refresh icon.
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text('Expected error.'), findsOneWidget);
          expect(find.text('1'), findsOneWidget);

          // Tap the refresh icon.
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text('Expected error.'), findsNothing);
          expect(find.text('3'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text('Expected error.'), findsNothing);
          expect(find.text('4'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();

          expect(find.byType(LinearProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          // Verify that our counter has incremented.
          expect(find.text('Expected error.'), findsNothing);
          expect(find.text('5'), findsNothing);
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
