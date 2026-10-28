import 'package:flutter_test/flutter_test.dart';
import 'package:hado/services/notification_service.dart';

void main() {
  late NotificationService service;

  setUp(() {
    service = NotificationService();
  });

  test('isScheduleValid returns false for past dates', () {
    final pastDate = DateTime.now().subtract(const Duration(minutes: 5));
    expect(service.isScheduleValid(pastDate), isFalse);
  });

  test('isScheduleValid returns true for future dates', () {
    final futureDate = DateTime.now().add(const Duration(hours: 1));
    expect(service.isScheduleValid(futureDate), isTrue);
  });

  test('channel constants are properly defined', () {
    expect(NotificationService.channelId, equals('habit_reminder_channel'));
    expect(NotificationService.channelName, equals('Reminders'));
  });
}
