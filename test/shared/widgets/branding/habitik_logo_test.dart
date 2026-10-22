import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/shared/widgets/branding/habitik_logo.dart';

void main() {
  group('HabitikLogo Widget Tests', () {
    testWidgets('Renderiza correctamente el asset SVG del logo oficial', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HabitikLogo(size: 64))),
      );

      expect(find.byType(HabitikLogo), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('Aplica animación de pulso con pulseEffect: true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HabitikLogo(size: 80, pulseEffect: true)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HabitikLogo), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    test('Valida que el archivo SVG logo_habitik.svg se pueda parsear sin errores', () async {
      final file = File('assets/images/logo_habitik.svg');
      final content = await file.readAsString();
      expect(content.isNotEmpty, isTrue);
      final pictureInfo = await vg.loadPicture(SvgStringLoader(content), null);
      expect(pictureInfo, isNotNull);
    });
  });
}
