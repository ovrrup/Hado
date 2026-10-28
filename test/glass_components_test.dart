import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hado/models/habit.dart';
import 'package:hado/models/reminder.dart';
import 'package:hado/theme/app_colors.dart';
import 'package:hado/widgets/ambient_glass_scaffold.dart';
import 'package:hado/widgets/glass_nav_bar.dart';
import 'package:hado/widgets/glass_surface.dart';
import 'package:hado/widgets/habit_glass_card.dart';
import 'package:hado/widgets/reminder_glass_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Glass Components Widget Tests', () {
    testWidgets('GlassSurface renders child content and triggers tap callback',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              onTap: () => tapped = true,
              child: const Text('Optical Frosted Glass'),
            ),
          ),
        ),
      );

      expect(find.text('Optical Frosted Glass'), findsOneWidget);
      await tester.tap(find.text('Optical Frosted Glass'));
      expect(tapped, isTrue);
    });

    testWidgets('AmbientGlassScaffold renders child cleanly with animation disabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AmbientGlassScaffold(
            enableAnimation: false,
            modeOffset: 0.0,
            child: Center(
              child: Text('Ambient Workspace'),
            ),
          ),
        ),
      );

      expect(find.text('Ambient Workspace'), findsOneWidget);
    });

    testWidgets('GlassNavBar renders Habits, Reminders, and FAB',
        (tester) async {
      int selectedIndex = -1;
      bool fabTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassNavBar(
              pageOffset: 0.0,
              onTabSelected: (idx) => selectedIndex = idx,
              onFabTap: () => fabTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.text('Reminders'));
      expect(selectedIndex, equals(1));

      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(fabTapped, isTrue);
    });

    testWidgets('HabitGlassCard displays title, schedule subtitle, and 7-day micro-history',
        (tester) async {
      final habit = Habit(
        id: 'test_1',
        title: 'Drink 2L Water',
        targetDays: [1, 2, 3, 4, 5, 6, 7],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitGlassCard(
              habit: habit,
              onToggle: () {},
              onEdit: () {},
              onSkipToday: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Drink 2L Water'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('7D'), findsOneWidget);
    });

    testWidgets('ReminderGlassCard displays title and due time pill',
        (tester) async {
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'test_rem',
        title: 'Submit Tax Documentation',
        dueDateTime: DateTime(now.year, now.month, now.day, 17, 30),
        isPinned: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderGlassCard(
              reminder: reminder,
              onToggleComplete: () {},
              onSnooze: () {},
              onTogglePin: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Submit Tax Documentation'), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
      expect(find.text(reminder.formattedDueTime), findsOneWidget);
    });

    test('AppColors contains exact design specifications', () {
      expect(AppColors.obsidianBase.value, equals(0xFF0B0F17));
      expect(AppColors.emerald.value, equals(0xFF10B981));
      expect(AppColors.teal.value, equals(0xFF059669));
      expect(AppColors.warmAmber.value, equals(0xFFF59E0B));
      expect(AppColors.coral.value, equals(0xFFEA580C));
      expect(AppColors.glassBlurSigma, equals(24.0));
      expect(AppColors.glassBorderRadius, equals(20.0));
      expect(AppColors.glassBorderWidth, equals(1.0));
    });
  });
}
