import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:hado/data/database.dart';
import 'package:hado/services/notification_service.dart';
import 'package:hado/presentation/views/reminders_view.dart';
import 'package:hado/presentation/widgets/reminder_card.dart';

void main() {
  testWidgets('RemindersView displays empty state when no reminders exist',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final notifications = NotificationService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RemindersView(
            database: db,
            notificationService: notifications,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No Reminders Yet'), findsOneWidget);

    await db.close();
  });

  testWidgets('ReminderCard renders title and toggles status', (tester) async {
    bool toggled = false;
    final reminder = Reminder(
      id: 1,
      title: 'Doctor Appointment',
      notes: 'Bring records',
      dueDateTime: DateTime.now().add(const Duration(hours: 2)),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderCard(
            reminder: reminder,
            onToggle: (val) {
              toggled = val;
            },
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Doctor Appointment'), findsOneWidget);
    expect(find.text('Bring records'), findsOneWidget);

    // Tap checkbox circle
    await tester.tap(find.byType(GestureDetector).first);
    expect(toggled, isTrue);
  });
}
