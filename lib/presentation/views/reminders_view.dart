import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../services/notification_service.dart';

class RemindersView extends StatelessWidget {
  final AppDatabase database;
  final NotificationService notificationService;

  const RemindersView({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reminders View Placeholder'),
    );
  }
}
