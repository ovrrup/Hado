import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hado/presentation/widgets/grain_shader_background.dart';

void main() {
  testWidgets('GrainShaderBackground renders child cleanly in test environment',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GrainShaderBackground(
          isHabitMode: true,
          enableAnimation: false,
          child: Scaffold(
            body: Center(
              child: Text('Test Content'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Content'), findsOneWidget);
  });
}
