import 'package:flutter_test/flutter_test.dart';
import 'package:hado/models/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('scheduleSubtitle correctly formats standard schedules', () {
      final dailyHabit = Habit(
        id: '1',
        title: 'Water',
        targetDays: [1, 2, 3, 4, 5, 6, 7],
      );
      expect(dailyHabit.scheduleSubtitle, equals('Daily'));

      final weekdaysHabit = Habit(
        id: '2',
        title: 'Deep Work',
        targetDays: [1, 2, 3, 4, 5],
      );
      expect(weekdaysHabit.scheduleSubtitle, equals('Weekdays'));

      final weekendsHabit = Habit(
        id: '3',
        title: 'Hike',
        targetDays: [6, 7],
      );
      expect(weekendsHabit.scheduleSubtitle, equals('Weekends'));

      final specificHabit = Habit(
        id: '4',
        title: 'Gym',
        targetDays: [1, 3, 5],
      );
      expect(specificHabit.scheduleSubtitle, equals('Mon, Wed, Fri'));
    });

    test('isCompletedOn and isCompletedToday accurately track dates', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final habit = Habit(
        id: '1',
        title: 'Meditate',
        completedDates: {Habit.formatDate(today)},
      );

      expect(habit.isCompletedToday, isTrue);
      expect(habit.isCompletedOn(yesterday), isFalse);
    });

    test('last7DaysHistory returns exactly 7 items', () {
      final today = DateTime.now();
      final habit = Habit(
        id: '1',
        title: 'Reading',
        completedDates: {Habit.formatDate(today)},
      );

      final history = habit.last7DaysHistory;
      expect(history.length, equals(7));
      expect(history.last, isTrue); // Today's completion
    });

    test('Habit serialization to and from JSON', () {
      final habit = Habit(
        id: 'test_123',
        title: 'Journaling',
        targetDays: [1, 2, 3],
        completedDates: {'2026-10-28'},
        skippedDates: {'2026-10-27'},
      );

      final json = habit.toJson();
      final restored = Habit.fromJson(json);

      expect(restored.id, equals('test_123'));
      expect(restored.title, equals('Journaling'));
      expect(restored.targetDays, equals([1, 2, 3]));
      expect(restored.completedDates.contains('2026-10-28'), isTrue);
      expect(restored.skippedDates.contains('2026-10-27'), isTrue);
    });
  });
}
