import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Ensure this path is correct based on your project name
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // FIXED: Changed MyApp() to FyndoApp() to match your main.dart
    await tester.pumpWidget(const FyndoApp());

    // Verify that our counter starts at 0.
    // Note: Since your app is a shopping app and not the default counter app,
    // these specific tests below might still fail, but the CODE will now compile.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
