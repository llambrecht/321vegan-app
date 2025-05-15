import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vegan_app/helpers/time_counter/time_counter.dart';

void main() {
  testWidgets('TimeCounter displays correct difference',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final targetDate = DateTime(
      now.year - 1,
      now.month - 2,
      now.day - 3,
      now.hour - 4,
      now.minute - 5,
      now.second - 6,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimeCounter(targetDate: targetDate),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    final expected = ['01', '02', '03', '04', '05'];
    for (final value in expected) {
      expect(find.text(value), findsOneWidget);
    }
  });

  testWidgets('TimeCounter displays zeros if targetDate is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TimeCounter(targetDate: null),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00'), findsNWidgets(6));
  });
}
