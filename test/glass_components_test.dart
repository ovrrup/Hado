import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hado/core/theme.dart';
import 'package:hado/presentation/widgets/glass_container.dart';
import 'package:hado/presentation/widgets/glass_switch.dart';

void main() {
  testWidgets('GlassContainer renders child content and responds to tap',
      (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            onTap: () => tapped = true,
            child: const Text('Inside Glass'),
          ),
        ),
      ),
    );

    expect(find.text('Inside Glass'), findsOneWidget);
    await tester.tap(find.text('Inside Glass'));
    expect(tapped, isTrue);
  });

  testWidgets('GlassSwitch triggers callback when segment tapped',
      (tester) async {
    AppTab selected = AppTab.habits;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GlassSwitch(
                selectedTab: selected,
                onTabChanged: (tab) {
                  setState(() {
                    selected = tab;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);

    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();

    expect(selected, equals(AppTab.reminders));
  });
}
