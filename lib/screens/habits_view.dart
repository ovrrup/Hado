import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_bottom_sheet.dart';
import '../widgets/glass_surface.dart';
import '../widgets/habit_glass_card.dart';

/// Habits mode workspace with minimal date header, animated glass progress bar,
/// active habits at the top, completed habits at the dimmed bottom section,
/// and responsive layout (single column under 600px, 2-3 column grid up to 1000px max width).
class HabitsView extends StatelessWidget {
  final AppState appState;

  const HabitsView({
    super.key,
    required this.appState,
  });

  void _openEditSheet(BuildContext context, Habit habit) {
    unawaited(
      GlassBottomSheet.show(
        context: context,
        isHabitsMode: true,
        initialHabit: habit,
        onSaveHabit: (title, days) {
          unawaited(
            appState.updateHabit(habit.copyWith(title: title, targetDays: days)),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Habit habit) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassSurface(
            borderRadius: 24,
            surfaceColor: Colors.black.withOpacity(0.8),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Delete Habit?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${habit.title}"?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          unawaited(appState.deleteHabit(habit.id));
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeHabits = appState.activeHabits;
    final completedHabits = appState.completedHabits;
    final totalHabits = appState.habits.length;
    final ratio = appState.todayCompletionRatio;
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final gridColumns = constraints.maxWidth >= 850 ? 3 : 2;

        Widget content = CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top spacing + Minimal Date Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Label
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Main Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Habits',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: Colors.white,
                          ),
                        ),
                        if (totalHabits > 0)
                          Text(
                            '${(ratio * 100).toInt()}% Done',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Animated Glass Progress Bar
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.progressTrack,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: ratio),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return FractionallySizedBox(
                              widthFactor: val.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.emerald, AppColors.teal],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.emerald.withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Empty State
            if (totalHabits == 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: GlassSurface(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 48,
                            color: AppColors.emerald.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No habits tracked yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button below to start your daily rituals.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Active Habits Section
            if (activeHabits.isNotEmpty) ...[
              if (!isWide)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = activeHabits[index];
                      return HabitGlassCard(
                        habit: habit,
                        onToggle: () => unawaited(appState.toggleHabitToday(habit.id)),
                        onEdit: () => _openEditSheet(context, habit),
                        onSkipToday: () => unawaited(appState.skipHabitToday(habit.id)),
                        onDelete: () => _confirmDelete(context, habit),
                      );
                    },
                    childCount: activeHabits.length,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridColumns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = activeHabits[index];
                        return HabitGlassCard(
                          habit: habit,
                          onToggle: () => unawaited(appState.toggleHabitToday(habit.id)),
                          onEdit: () => _openEditSheet(context, habit),
                          onSkipToday: () => unawaited(appState.skipHabitToday(habit.id)),
                          onDelete: () => _confirmDelete(context, habit),
                        );
                      },
                      childCount: activeHabits.length,
                    ),
                  ),
                ),
            ],

            // Completed Section Header
            if (completedHabits.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'COMPLETED (${completedHabits.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Completed Habits Grid / List (Dimmed)
              if (!isWide)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = completedHabits[index];
                      return Opacity(
                        opacity: 0.72,
                        child: HabitGlassCard(
                          habit: habit,
                          onToggle: () => unawaited(appState.toggleHabitToday(habit.id)),
                          onEdit: () => _openEditSheet(context, habit),
                          onSkipToday: () => unawaited(appState.skipHabitToday(habit.id)),
                          onDelete: () => _confirmDelete(context, habit),
                        ),
                      );
                    },
                    childCount: completedHabits.length,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridColumns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = completedHabits[index];
                        return Opacity(
                          opacity: 0.72,
                          child: HabitGlassCard(
                            habit: habit,
                            onToggle: () => unawaited(appState.toggleHabitToday(habit.id)),
                            onEdit: () => _openEditSheet(context, habit),
                            onSkipToday: () => unawaited(appState.skipHabitToday(habit.id)),
                            onDelete: () => _confirmDelete(context, habit),
                          ),
                        );
                      },
                      childCount: completedHabits.length,
                    ),
                  ),
                ),
            ],

            // Bottom padding so content is never covered by floating nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 108),
            ),
          ],
        );

        if (isWide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}
