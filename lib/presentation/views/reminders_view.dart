import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../services/notification_service.dart';
import '../widgets/reminder_card.dart';

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
    final theme = Theme.of(context);

    return StreamBuilder<List<Reminder>>(
      stream: database.watchReminders(includeCompleted: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 72,
                    color: theme.colorScheme.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Reminders Yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "+ New Reminder" to schedule tasks and time-sensitive alerts.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final now = DateTime.now();
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final overdueAndToday = <Reminder>[];
        final upcoming = <Reminder>[];
        final completed = <Reminder>[];

        for (final r in reminders) {
          if (r.isCompleted) {
            completed.add(r);
          } else if (r.dueDateTime.isBefore(endOfToday)) {
            overdueAndToday.add(r);
          } else {
            upcoming.add(r);
          }
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          children: [
            if (overdueAndToday.isNotEmpty) ...[
              _buildSectionHeader(context, 'Today & Overdue', overdueAndToday.length, Colors.red.shade700),
              ...overdueAndToday.map((r) => _buildCard(context, r)),
            ],
            if (upcoming.isNotEmpty) ...[
              _buildSectionHeader(context, 'Upcoming', upcoming.length, theme.colorScheme.primary),
              ...upcoming.map((r) => _buildCard(context, r)),
            ],
            if (completed.isNotEmpty) ...[
              _buildSectionHeader(context, 'Completed', completed.length, Colors.grey),
              ...completed.map((r) => _buildCard(context, r)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, int count, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Reminder reminder) {
    return ReminderCard(
      reminder: reminder,
      onToggle: (isDone) async {
        await database.updateReminderCompletion(reminder.id, isDone);
        if (isDone) {
          await notificationService.cancelReminder(reminder.id);
        } else if (reminder.dueDateTime.isAfter(DateTime.now())) {
          await notificationService.scheduleReminder(
            id: reminder.id,
            title: reminder.title,
            notes: reminder.notes,
            scheduledDate: reminder.dueDateTime,
          );
        }
      },
      onDelete: () async {
        await database.deleteReminder(reminder.id);
        await notificationService.cancelReminder(reminder.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${reminder.title}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
