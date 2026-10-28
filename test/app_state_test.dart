import 'package:flutter_test/flutter_test.dart';
import 'package:hado/services/notification_service.dart';
import 'package:hado/state/app_state.dart';
import 'package:hado/state/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState Business Logic Tests', () {
    late StorageService storageService;
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.create();
      appState = AppState(
        storageService: storageService,
        notificationService: NotificationService(),
      );
      await appState.init();
    });

    test('Initializes with default starter habits and reminders', () {
      expect(appState.isInitialized, isTrue);
      expect(appState.habits.isNotEmpty, isTrue);
      expect(appState.reminders.isNotEmpty, isTrue);
    });

    test('toggleHabitToday toggles completion state and updates ratio', () async {
      final habit = appState.habits.first;
      final wasCompleted = habit.isCompletedToday;

      await appState.toggleHabitToday(habit.id);

      final updated = appState.habits.firstWhere((h) => h.id == habit.id);
      expect(updated.isCompletedToday, equals(!wasCompleted));
    });

    test('skipHabitToday marks habit as skipped for today', () async {
      final habit = appState.habits.first;
      await appState.skipHabitToday(habit.id);

      final updated = appState.habits.firstWhere((h) => h.id == habit.id);
      expect(updated.isSkippedToday, isTrue);
    });

    test('addHabit inserts habit and persists', () async {
      final initialCount = appState.habits.length;
      await appState.addHabit(
        title: 'Learn Rust',
        targetDays: [1, 2, 3, 4, 5],
      );

      expect(appState.habits.length, equals(initialCount + 1));
      expect(appState.habits.first.title, equals('Learn Rust'));
    });

    test('deleteHabit removes habit from state', () async {
      final habit = appState.habits.first;
      await appState.deleteHabit(habit.id);

      expect(appState.habits.any((h) => h.id == habit.id), isFalse);
    });

    test('toggleReminderCompletion toggles isCompleted', () async {
      final reminder = appState.reminders.first;
      final wasCompleted = reminder.isCompleted;

      await appState.toggleReminderCompletion(reminder.id);

      final updated = appState.reminders.firstWhere((r) => r.id == reminder.id);
      expect(updated.isCompleted, equals(!wasCompleted));
    });

    test('snoozeReminder advances due time by duration', () async {
      final reminder = appState.reminders.first;
      final previousDue = reminder.dueDateTime;

      await appState.snoozeReminder(reminder.id, const Duration(hours: 1));

      final updated = appState.reminders.firstWhere((r) => r.id == reminder.id);
      expect(updated.dueDateTime.isAfter(previousDue), isTrue);
    });

    test('togglePinReminder toggles isPinned state', () async {
      final reminder = appState.reminders.first;
      final wasPinned = reminder.isPinned;

      await appState.togglePinReminder(reminder.id);

      final updated = appState.reminders.firstWhere((r) => r.id == reminder.id);
      expect(updated.isPinned, equals(!wasPinned));
    });

    test('addReminder and deleteReminder update list', () async {
      final initialCount = appState.reminders.length;
      await appState.addReminder(
        title: 'Call Accountant',
        dueDateTime: DateTime.now().add(const Duration(days: 2)),
        isPinned: true,
      );

      expect(appState.reminders.length, equals(initialCount + 1));
      final added = appState.reminders.first;
      expect(added.title, equals('Call Accountant'));
      expect(added.isPinned, isTrue);

      await appState.deleteReminder(added.id);
      expect(appState.reminders.length, equals(initialCount));
    });
  });
}
