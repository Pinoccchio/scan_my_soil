// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scan_my_soil/main.dart';

void main() {
  testWidgets('ScanMySoil app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScanMySoilApp());

    // Verify that our app title is displayed
    expect(find.text('ScanMySoil'), findsOneWidget);

    // Verify that we have the "Analyze Your Soil" text on the home screen
    expect(find.text('Analyze Your Soil'), findsOneWidget);

    // Verify that we have the "New Scan" button
    expect(find.text('New Scan'), findsOneWidget);

    // Tap the "New Scan" button and trigger a frame
    await tester.tap(find.text('New Scan'));
    await tester.pumpAndSettle(); // Wait for navigation animation to complete

    // Verify that we've navigated to the scan screen
    expect(find.text('Scan Soil Sample'), findsOneWidget);
    expect(find.text('Instructions:'), findsOneWidget);
  });
}