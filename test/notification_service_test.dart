import 'package:flutter_test/flutter_test.dart';
import 'package:hado/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
    });

    test('isScheduleValid returns false for past dates and true for future', () {
      final pastDate = DateTime.now().subtract(const Duration(minutes: 10));
      expect(service.isScheduleValid(pastDate), isFalse);

      final futureDate = DateTime.now().add(const Duration(hours: 2));
      expect(service.isScheduleValid(futureDate), isTrue);
    });

    test('Notification constants are properly set', () {
      expect(NotificationService.channelId, equals('habit_reminder_channel'));
      expect(NotificationService.channelName, equals('Reminders'));
    });
  });
}
