import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/habits.dart';
import 'tables/habit_logs.dart';
import 'tables/reminders.dart';

part 'database.g.dart';

class HabitStreak {
  final int current;
  final int longest;
  HabitStreak({required this.current, required this.longest});
}

class HabitWithStreak {
  final Habit habit;
  final bool isCompletedToday;
  final int currentStreak;
  final int longestStreak;

  HabitWithStreak({
    required this.habit,
    required this.isCompletedToday,
    required this.currentStreak,
    required this.longestStreak,
  });
}

@DriftDatabase(tables: [Habits, HabitLogs, Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'hado_db'));

  @override
  int get schemaVersion => 1;

  static String formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // --- Habits Operations ---
  Future<int> insertHabit(HabitsCompanion habit) => into(habits).insert(habit);

  Future<bool> updateHabit(HabitsCompanion habit) => update(habits).replace(habit);

  Future<int> deleteHabit(int id) => (delete(habits)..where((h) => h.id.equals(id))).go();

  Future<void> logHabit(int habitId, DateTime date, {String? notes}) async {
    final dateStr = formatDate(date);
    await into(habitLogs).insertOnConflictUpdate(
      HabitLogsCompanion.insert(
        habitId: habitId,
        completedDate: dateStr,
        notes: Value(notes),
      ),
    );
  }

  Future<void> undoHabit(int habitId, DateTime date) async {
    final dateStr = formatDate(date);
    await (delete(habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.completedDate.equals(dateStr)))
        .go();
  }

  Future<List<String>> getCompletedDates(int habitId) async {
    final rows = await (select(habitLogs)
          ..where((l) => l.habitId.equals(habitId))
          ..orderBy([(l) => OrderingTerm.desc(l.completedDate)]))
        .get();
    return rows.map((r) => r.completedDate).toList();
  }

  Future<HabitStreak> calculateStreak(int habitId) async {
    final completedDates = await getCompletedDates(habitId);
    if (completedDates.isEmpty) {
      return HabitStreak(current: 0, longest: 0);
    }

    final dateSet = completedDates.toSet();
    final now = DateTime.now();
    final todayStr = formatDate(now);
    final yesterdayStr = formatDate(now.subtract(const Duration(days: 1)));

    // Current streak calculation
    int current = 0;
    DateTime checkDate = dateSet.contains(todayStr)
        ? now
        : (dateSet.contains(yesterdayStr) ? now.subtract(const Duration(days: 1)) : now);

    if (dateSet.contains(formatDate(checkDate))) {
      while (dateSet.contains(formatDate(checkDate))) {
        current++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // Longest streak calculation
    int longest = 0;
    final parsedDates = dateSet.map((d) => DateTime.parse(d)).toList()
      ..sort((a, b) => a.compareTo(b));

    int tempStreak = 0;
    DateTime? prev;
    for (final d in parsedDates) {
      if (prev == null) {
        tempStreak = 1;
      } else {
        final diff = d.difference(prev).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          tempStreak = 1;
        }
      }
      if (tempStreak > longest) {
        longest = tempStreak;
      }
      prev = d;
    }

    return HabitStreak(current: current, longest: longest);
  }

  Stream<List<HabitWithStreak>> watchHabitsWithTodayStatus() {
    return select(habits).watch().asyncMap((habitList) async {
      final todayStr = formatDate(DateTime.now());
      final result = <HabitWithStreak>[];

      for (final habit in habitList) {
        final logs = await (select(habitLogs)
              ..where((l) =>
                  l.habitId.equals(habit.id) & l.completedDate.equals(todayStr)))
            .get();
        final streak = await calculateStreak(habit.id);
        result.add(HabitWithStreak(
          habit: habit,
          isCompletedToday: logs.isNotEmpty,
          currentStreak: streak.current,
          longestStreak: streak.longest,
        ));
      }
      return result;
    });
  }

  // --- Reminders Operations ---
  Future<int> insertReminder(RemindersCompanion reminder) => into(reminders).insert(reminder);

  Future<bool> updateReminder(RemindersCompanion reminder) => update(reminders).replace(reminder);

  Future<void> updateReminderCompletion(int id, bool completed) async {
    await (update(reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        isCompleted: Value(completed),
        completedAt: Value(completed ? DateTime.now() : null),
      ),
    );
  }

  Future<int> deleteReminder(int id) => (delete(reminders)..where((r) => r.id.equals(id))).go();

  Stream<List<Reminder>> watchReminders({bool includeCompleted = true}) {
    final query = select(reminders);
    if (!includeCompleted) {
      query.where((r) => r.isCompleted.equals(false));
    }
    query.orderBy([
      (r) => OrderingTerm.asc(r.isCompleted),
      (r) => OrderingTerm.asc(r.dueDateTime),
    ]);
    return query.watch();
  }
}
