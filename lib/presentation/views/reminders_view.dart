import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../services/notification_service.dart';
import '../widgets/glass_container.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GlassContainer(
                blur: 16,
                opacity: 0.5,
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: HadoPalettes.reminderCoral.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.alarm_on_rounded,
                          size: 40,
                          color: HadoPalettes.reminderCoral,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Reminders Yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C241E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Schedule tasks and time-sensitive alerts to stay effortlessly on top of your day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6E6862),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
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
          padding: const EdgeInsets.only(top: 6, bottom: 100),
          children: [
            if (overdueAndToday.isNotEmpty) ...[
              _buildSectionHeader('Today & Overdue', overdueAndToday.length,
                  HadoPalettes.reminderCoral),
              ...overdueAndToday.map((r) => _buildCard(context, r)),
            ],
            if (upcoming.isNotEmpty) ...[
              _buildSectionHeader(
                  'Upcoming', upcoming.length, const Color(0xFF944F1A)),
              ...upcoming.map((r) => _buildCard(context, r)),
            ],
            if (completed.isNotEmpty) ...[
              _buildSectionHeader(
                  'Completed', completed.length, const Color(0xFF756F68)),
              ...completed.map((r) => _buildCard(context, r)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${reminder.title}"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
