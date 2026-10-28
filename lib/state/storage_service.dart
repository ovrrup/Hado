import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/reminder.dart';

class StorageService {
  static const String _habitsKey = 'hado_habits_v2';
  static const String _remindersKey = 'hado_reminders_v2';

  final SharedPreferences? _prefs;

  StorageService({SharedPreferences? prefs}) : _prefs = prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs: prefs);
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs;
    return await SharedPreferences.getInstance();
  }

  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_habitsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((item) => Habit.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Seed starter habits for fresh workspace
    final starterHabits = _getStarterHabits();
    await saveHabits(starterHabits);
    return starterHabits;
  }

  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await _getPrefs();
      final encoded = jsonEncode(habits.map((h) => h.toJson()).toList());
      await prefs.setString(_habitsKey, encoded);
    } catch (_) {}
  }

  Future<List<Reminder>> loadReminders() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_remindersKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Seed starter reminders for fresh workspace
    final starterReminders = _getStarterReminders();
    await saveReminders(starterReminders);
    return starterReminders;
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    try {
      final prefs = await _getPrefs();
      final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
      await prefs.setString(_remindersKey, encoded);
    } catch (_) {}
  }

  List<Habit> _getStarterHabits() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final fourDaysAgo = today.subtract(const Duration(days: 4));

    return [
      Habit(
        id: 'habit_1',
        title: 'Morning Sunlight & Hydration',
        targetDays: [1, 2, 3, 4, 5, 6, 7],
        completedDates: {
          Habit.formatDate(today),
          Habit.formatDate(yesterday),
          Habit.formatDate(twoDaysAgo),
          Habit.formatDate(fourDaysAgo),
        },
      ),
      Habit(
        id: 'habit_2',
        title: 'Deep Work Session (90m)',
        targetDays: [1, 2, 3, 4, 5],
        completedDates: {
          Habit.formatDate(yesterday),
          Habit.formatDate(twoDaysAgo),
        },
      ),
      Habit(
        id: 'habit_3',
        title: 'Read 20 Pages',
        targetDays: [1, 2, 3, 4, 5, 6, 7],
        completedDates: {
          Habit.formatDate(yesterday),
        },
      ),
      Habit(
        id: 'habit_4',
        title: 'Evening Screen Detox',
        targetDays: [1, 2, 3, 4, 5, 6, 7],
        completedDates: {},
      ),
    ];
  }

  List<Reminder> _getStarterReminders() {
    final now = DateTime.now();
    return [
      Reminder(
        id: 'rem_1',
        title: 'Review System Architecture PR',
        dueDateTime: DateTime(now.year, now.month, now.day, 16, 0),
        isPinned: true,
      ),
      Reminder(
        id: 'rem_2',
        title: 'Team Standup & Daily Sync',
        dueDateTime: DateTime(now.year, now.month, now.day, 14, 30),
      ),
      Reminder(
        id: 'rem_3',
        title: 'Submit Expense Reports',
        dueDateTime: now.add(const Duration(days: 1, hours: 2)),
      ),
      Reminder(
        id: 'rem_4',
        title: 'Plan Weekend Reading List',
        dueDateTime: now.add(const Duration(days: 3)),
      ),
    ];
  }
}
