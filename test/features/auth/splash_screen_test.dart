import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/auth/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(onFinish: () {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('HABITIK'), findsOneWidget);
    expect(find.text('Hábitos que cuidan el planeta 🌎'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
