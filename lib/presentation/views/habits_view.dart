import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../widgets/glass_container.dart';
import '../widgets/habit_card.dart';

class HabitsView extends StatelessWidget {
  final AppDatabase database;

  const HabitsView({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
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
                        color: HadoPalettes.habitTerracotta.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.spa_rounded,
                          size: 40,
                          color: HadoPalettes.habitTerracotta,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Habits Yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C241E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Start small by creating your first daily routine and build your streak.',
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

        // Sort: Incomplete first, then completed
        final sortedItems = List<HabitWithStreak>.from(items)
          ..sort((a, b) {
            if (a.isCompletedToday == b.isCompletedToday) return 0;
            return a.isCompletedToday ? 1 : -1;
          });

        return ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 100),
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
                    backgroundColor: const Color(0xFF2C241E),
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
