import 'package:flutter_test/flutter_test.dart';
import 'package:hado/models/reminder.dart';

void main() {
  group('Reminder Model Tests', () {
    test('isDueToday and isOverdue calculated accurately', () {
      final now = DateTime.now();
      final todayReminder = Reminder(
        id: '1',
        title: 'Call Dentist',
        dueDateTime: DateTime(now.year, now.month, now.day, 18, 0),
      );

      expect(todayReminder.isDueToday, isTrue);

      final pastReminder = Reminder(
        id: '2',
        title: 'Old Task',
        dueDateTime: now.subtract(const Duration(hours: 3)),
      );

      expect(pastReminder.isOverdue, isTrue);

      final completedPastReminder = pastReminder.copyWith(isCompleted: true);
      expect(completedPastReminder.isOverdue, isFalse);
    });

    test('isDueTomorrow and isUpcoming calculated accurately', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowReminder = Reminder(
        id: '3',
        title: 'Meeting',
        dueDateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
      );

      expect(tomorrowReminder.isDueTomorrow, isTrue);
      expect(tomorrowReminder.isUpcoming, isTrue);
    });

    test('formattedDueTime formats properly', () {
      final now = DateTime.now();
      final todayReminder = Reminder(
        id: '4',
        title: 'Evening Run',
        dueDateTime: DateTime(now.year, now.month, now.day, 20, 0),
      );

      expect(todayReminder.formattedDueTime.startsWith('Today,'), isTrue);
    });

    test('Reminder serialization to and from JSON', () {
      final now = DateTime.now();
      final reminder = Reminder(
        id: 'rem_xyz',
        title: 'Submit Tax Forms',
        dueDateTime: now,
        isPinned: true,
        isCompleted: false,
        notificationId: 99,
      );

      final json = reminder.toJson();
      final restored = Reminder.fromJson(json);

      expect(restored.id, equals('rem_xyz'));
      expect(restored.title, equals('Submit Tax Forms'));
      expect(restored.isPinned, isTrue);
      expect(restored.isCompleted, isFalse);
      expect(restored.notificationId, equals(99));
    });
  });
}
