import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../services/notification_service.dart';

class CreateReminderSheet extends StatelessWidget {
  final AppDatabase database;
  final NotificationService notificationService;

  const CreateReminderSheet({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('Create Reminder')),
    );
  }
}
