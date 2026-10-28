import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_bottom_sheet.dart';
import '../widgets/glass_surface.dart';
import '../widgets/reminder_glass_card.dart';

/// Reminders mode workspace grouped under clean headers:
/// PINNED, TODAY, UPCOMING, COMPLETED.
///
/// Fully responsive (single column under 600px, 2-3 column grid up to 1000px max width).
class RemindersView extends StatelessWidget {
  final AppState appState;

  const RemindersView({
    super.key,
    required this.appState,
  });

  void _openEditSheet(BuildContext context, Reminder reminder) {
    unawaited(
      GlassBottomSheet.show(
        context: context,
        isHabitsMode: false,
        initialReminder: reminder,
        onSaveReminder: (title, due, isPinned) {
          unawaited(
            appState.updateReminder(
              reminder.copyWith(
                title: title,
                dueDateTime: due,
                isPinned: isPinned,
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
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
                  'Delete Reminder?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${reminder.title}"?',
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
                          unawaited(appState.deleteReminder(reminder.id));
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

  Widget _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            Text(
              '$title ($count)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSectionGroup({
    required BuildContext context,
    required String title,
    required List<Reminder> items,
    required bool isWide,
    required int gridColumns,
  }) {
    if (items.isEmpty) return [];

    return [
      _buildSectionHeader(title, items.length),
      if (!isWide)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final rem = items[index];
              return ReminderGlassCard(
                reminder: rem,
                onToggleComplete: () => unawaited(appState.toggleReminderCompletion(rem.id)),
                onSnooze: () => unawaited(appState.snoozeReminder(rem.id, const Duration(hours: 1))),
                onTogglePin: () => unawaited(appState.togglePinReminder(rem.id)),
                onEdit: () => _openEditSheet(context, rem),
                onDelete: () => _confirmDelete(context, rem),
              );
            },
            childCount: items.length,
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
              childAspectRatio: 2.3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rem = items[index];
                return ReminderGlassCard(
                  reminder: rem,
                  onToggleComplete: () => unawaited(appState.toggleReminderCompletion(rem.id)),
                  onSnooze: () => unawaited(appState.snoozeReminder(rem.id, const Duration(hours: 1))),
                  onTogglePin: () => unawaited(appState.togglePinReminder(rem.id)),
                  onEdit: () => _openEditSheet(context, rem),
                  onDelete: () => _confirmDelete(context, rem),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pinned = appState.pinnedReminders;
    final today = appState.todayReminders;
    final upcoming = appState.upcomingReminders;
    final completed = appState.completedReminders;
    final total = appState.reminders.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final gridColumns = constraints.maxWidth >= 850 ? 3 : 2;

        Widget content = CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Workspace Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASK TIMELINE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Reminders',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: Colors.white,
                          ),
                        ),
                        if (total > 0)
                          Text(
                            '$total Active & Done',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warmAmber,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Empty State
            if (total == 0)
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
                            Icons.alarm_outlined,
                            size: 48,
                            color: AppColors.warmAmber.withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No reminders scheduled',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button below to create quick alerts and tasks.',
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

            // PINNED GROUP
            ..._buildSectionGroup(
              context: context,
              title: 'PINNED',
              items: pinned,
              isWide: isWide,
              gridColumns: gridColumns,
            ),

            // TODAY GROUP
            ..._buildSectionGroup(
              context: context,
              title: 'TODAY',
              items: today,
              isWide: isWide,
              gridColumns: gridColumns,
            ),

            // UPCOMING GROUP
            ..._buildSectionGroup(
              context: context,
              title: 'UPCOMING',
              items: upcoming,
              isWide: isWide,
              gridColumns: gridColumns,
            ),

            // COMPLETED GROUP
            ..._buildSectionGroup(
              context: context,
              title: 'COMPLETED',
              items: completed,
              isWide: isWide,
              gridColumns: gridColumns,
            ),

            // Bottom padding for floating nav bar
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
