import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hado/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('can insert habit and log completion', () async {
    final habitId = await db.insertHabit(
      HabitsCompanion.insert(
        title: 'Drink 2L Water',
        frequency: const Value('daily'),
      ),
    );

    expect(habitId, equals(1));

    final today = DateTime.now();
    await db.logHabit(habitId, today);

    final streak = await db.calculateStreak(habitId);
    expect(streak.current, equals(1));
    expect(streak.longest, equals(1));
  });

  test('streak increments when completed consecutive days', () async {
    final habitId = await db.insertHabit(
      HabitsCompanion.insert(
        title: 'Morning Yoga',
      ),
    );

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    await db.logHabit(habitId, yesterday);
    await db.logHabit(habitId, today);

    final streak = await db.calculateStreak(habitId);
    expect(streak.current, equals(2));
    expect(streak.longest, equals(2));
  });

  test('can insert, complete, and delete reminder', () async {
    final reminderId = await db.insertReminder(
      RemindersCompanion.insert(
        title: 'Call Doctor',
        dueDateTime: DateTime.now().add(const Duration(hours: 2)),
      ),
    );

    expect(reminderId, equals(1));

    await db.updateReminderCompletion(reminderId, true);
    final reminders = await db.select(db.reminders).get();
    expect(reminders.first.isCompleted, isTrue);

    await db.deleteReminder(reminderId);
    final emptyList = await db.select(db.reminders).get();
    expect(emptyList.isEmpty, isTrue);
  });
}
