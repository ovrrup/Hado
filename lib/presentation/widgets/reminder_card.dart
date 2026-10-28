import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import 'glass_container.dart';

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
      return '${DateFormat('EEE, MMM d').format(dt)} at $timeStr';
    }
  }

  bool get isOverdue {
    if (reminder.isCompleted) return false;
    return reminder.dueDateTime.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isDone = reminder.isCompleted;

    return Dismissible(
      key: ValueKey('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        borderRadius: BorderRadius.circular(24),
        blur: 16,
        opacity: isDone ? 0.35 : 0.55,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Oversized Checkbox Circle
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle(!isDone);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDone
                      ? HadoPalettes.reminderCoral
                      : Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? HadoPalettes.reminderCoral
                        : HadoPalettes.reminderCoral.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isDone
                          ? const Color(0xFF6E6862)
                          : const Color(0xFF1E1A17),
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      reminder.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF5A534E),
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Time Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.black12
                          : (isOverdue
                              ? HadoPalettes.reminderCoral.withOpacity(0.18)
                              : HadoPalettes.reminderApricot.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDone
                            ? Colors.black12
                            : (isOverdue
                                ? HadoPalettes.reminderCoral.withOpacity(0.4)
                                : HadoPalettes.reminderApricot.withOpacity(0.5)),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOverdue && !isDone
                              ? Icons.alarm_on_rounded
                              : Icons.schedule_rounded,
                          size: 14,
                          color: isDone
                              ? const Color(0xFF6E6862)
                              : (isOverdue
                                  ? const Color(0xFFB52B20)
                                  : const Color(0xFF944F1A)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateTime(reminder.dueDateTime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue && !isDone
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isDone
                                ? const Color(0xFF6E6862)
                                : (isOverdue
                                    ? const Color(0xFFB52B20)
                                    : const Color(0xFF944F1A)),
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
    );
  }
}
