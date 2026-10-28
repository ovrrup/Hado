import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/native.dart';
import 'package:hado/data/database.dart';
import 'package:hado/services/notification_service.dart';
import 'package:hado/presentation/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('HomeScreen renders minimal mode header and toggles between modes',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final notifications = NotificationService();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          database: db,
          notificationService: notifications,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Initial state: Habits header
    expect(find.text('Habits'), findsNWidgets(2)); // Header + Switch label
    expect(find.text('Reminders'), findsOneWidget); // Switch label

    // Tap Reminders on switch
    await tester.tap(find.text('Reminders'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Now header is Reminders
    expect(find.text('Reminders'), findsNWidgets(2)); // Header + Switch label
    expect(find.text('New Reminder'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await db.close();
  });
}
