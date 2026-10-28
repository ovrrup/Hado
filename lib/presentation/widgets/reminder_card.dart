import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('h:mm a').format(dt);

    if (reminderDay == today) {
      return 'Today at $timeStr';
    } else if (reminderDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow at $timeStr';
    } else if (reminderDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $timeStr';
    } else {
      return '${DateFormat('MMM d').format(dt)} at $timeStr';
    }
  }

  bool get isOverdue {
    if (reminder.isCompleted) return false;
    return reminder.dueDateTime.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = reminder.isCompleted;

    return Dismissible(
      key: ValueKey('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              Checkbox(
                value: isDone,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  onToggle(val ?? false);
                },
              ),
              const SizedBox(width: 8),
              // Reminder Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isDone
                            ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                            : null,
                      ),
                    ),
                    if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        reminder.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Date & Time Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.grey.withOpacity(0.1)
                            : (isOverdue
                                ? Colors.red.withOpacity(0.12)
                                : theme.colorScheme.primary.withOpacity(0.08)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue && !isDone
                                ? Icons.warning_amber_rounded
                                : Icons.access_time_rounded,
                            size: 13,
                            color: isDone
                                ? Colors.grey
                                : (isOverdue
                                    ? Colors.red.shade700
                                    : theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(reminder.dueDateTime),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isOverdue && !isDone
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isDone
                                  ? Colors.grey
                                  : (isOverdue
                                      ? Colors.red.shade700
                                      : theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
