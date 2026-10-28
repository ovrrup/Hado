import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../widgets/habit_card.dart';

class HabitsView extends StatelessWidget {
  final AppDatabase database;

  const HabitsView({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<HabitWithStreak>>(
      stream: database.watchHabitsWithTodayStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 72,
                    color: theme.colorScheme.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Habits Yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "+ New Habit" below to start tracking your daily routines and build streaks.',
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

        // Sort: Incomplete habits first, then completed habits
        final sortedItems = List<HabitWithStreak>.from(items)
          ..sort((a, b) {
            if (a.isCompletedToday == b.isCompletedToday) return 0;
            return a.isCompletedToday ? 1 : -1;
          });

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: sortedItems.length,
          itemBuilder: (context, index) {
            final item = sortedItems[index];
            return HabitCard(
              item: item,
              onToggle: () {
                if (item.isCompletedToday) {
                  database.undoHabit(item.habit.id, DateTime.now());
                } else {
                  database.logHabit(item.habit.id, DateTime.now());
                }
              },
              onDelete: () {
                database.deleteHabit(item.habit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${item.habit.title}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
