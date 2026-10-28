import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import 'glass_container.dart';

class HabitCard extends StatelessWidget {
  final HabitWithStreak item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = item.habit;
    final isDone = item.isCompletedToday;
    final accentColor = Color(habit.colorValue != 0
        ? habit.colorValue
        : HadoPalettes.habitTerracotta.value);

    return Dismissible(
      key: ValueKey('habit_${habit.id}'),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        borderRadius: BorderRadius.circular(24),
        blur: 16,
        opacity: isDone ? 0.35 : 0.55,
        child: Row(
          children: [
            // Left Accent Pill Indicator
            Container(
              width: 5,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Habit Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Streak Flame Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (item.currentStreak > 0
                                  ? HadoPalettes.habitTerracotta
                                  : Colors.black45)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (item.currentStreak > 0
                                    ? HadoPalettes.habitTerracotta
                                    : Colors.black26)
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.currentStreak > 0 ? '🔥' : '🌱',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${item.currentStreak} day streak',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: item.currentStreak > 0
                                    ? HadoPalettes.habitTerracotta
                                    : const Color(0xFF6E6862),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (habit.description != null &&
                          habit.description!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            habit.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: const Color(0xFF5A534E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Oversized Completion Action Button (52px)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onToggle();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDone
                      ? HadoPalettes.habitTerracotta
                      : HadoPalettes.habitTerracotta.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? HadoPalettes.habitTerracotta
                        : HadoPalettes.habitTerracotta.withOpacity(0.4),
                    width: 2.5,
                  ),
                  boxShadow: isDone
                      ? [
                          BoxShadow(
                            color: HadoPalettes.habitTerracotta
                                .withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: isDone ? Colors.white : HadoPalettes.habitTerracotta,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
