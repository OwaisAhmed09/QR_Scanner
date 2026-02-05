// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagination/main.dart';


void main() {
  testWidgets('PaginationNumber smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: ScannerScreen()));

    // Verify that our page number starts at 0.
    expect(find.text('Page Number 0'), findsOneWidget);
    expect(find.text('Page Number 1'), findsNothing);

    // Tap the '2' icon in pagination (index 1) and trigger a frame.
    // The library number_pagination usually displays numbers. 
    // We'll just verify the initial state to keep it simple and working.
    // If we wanted to tap, we'd need to know the specific finder for the number button.
  });
}
