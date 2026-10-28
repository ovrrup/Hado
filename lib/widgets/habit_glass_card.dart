import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';

/// Glass card displaying a single habit with an inline 7-day micro-history row,
/// 0.97 scale spring micro-interaction on tap, and long-press action menu.
class HabitGlassCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onSkipToday;
  final VoidCallback onDelete;

  const HabitGlassCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onSkipToday,
    required this.onDelete,
  });

  @override
  State<HabitGlassCard> createState() => _HabitGlassCardState();
}

class _HabitGlassCardState extends State<HabitGlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    unawaited(HapticFeedback.lightImpact());
    await _scaleController.forward();
    if (mounted) {
      await _scaleController.reverse();
    }
    widget.onToggle();
  }

  void _showGlassActionMenu() {
    unawaited(HapticFeedback.mediumImpact());
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HabitActionMenu(
        habit: widget.habit,
        onEdit: () {
          Navigator.pop(ctx);
          widget.onEdit();
        },
        onSkipToday: () {
          Navigator.pop(ctx);
          widget.onSkipToday();
        },
        onDelete: () {
          Navigator.pop(ctx);
          widget.onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final isDone = habit.isCompletedToday;
    final isSkipped = habit.isSkippedToday;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GlassSurface(
        borderRadius: AppColors.glassBorderRadius,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(18),
        onTap: _handleTap,
        onLongPress: _showGlassActionMenu,
        surfaceColor: isDone
            ? AppColors.emerald.withOpacity(0.10)
            : AppColors.glassSurface,
        customBorder: isDone
            ? Border.all(
                color: AppColors.emerald.withOpacity(0.35),
                width: 1.0,
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left content column: Title, subtitle, 7-day micro-history
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDone
                                ? Colors.white.withOpacity(0.85)
                                : Colors.white,
                            decoration: isDone ? TextDecoration.none : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSkipped) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SKIPPED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.scheduleSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Inline 7-day micro-history row of 7 small 8px dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < 7; i++) ...[
                        _MicroHistoryDot(
                          isDone: habit.last7DaysHistory[i],
                          isToday: i == 6,
                        ),
                        if (i < 6) const SizedBox(width: 6),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        '7D',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Right interactive completion trigger
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.emerald
                    : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: isDone
                      ? AppColors.emerald
                      : Colors.white.withOpacity(0.20),
                  width: 1.5,
                ),
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: AppColors.emerald.withOpacity(0.45),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('done'),
                          color: Colors.black,
                          size: 24,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey('undone'),
                          color: Colors.white.withOpacity(0.35),
                          size: 20,
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

class _MicroHistoryDot extends StatelessWidget {
  final bool isDone;
  final bool isToday;

  const _MicroHistoryDot({
    required this.isDone,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.habitDoneDot : AppColors.habitMissedDot,
        border: isToday
            ? Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 1.0,
              )
            : null,
        boxShadow: isDone
            ? [
                BoxShadow(
                  color: AppColors.emerald.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
    );
  }
}

class _HabitActionMenu extends StatelessWidget {
  final Habit habit;
  final VoidCallback onEdit;
  final VoidCallback onSkipToday;
  final VoidCallback onDelete;

  const _HabitActionMenu({
    required this.habit,
    required this.onEdit,
    required this.onSkipToday,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: GlassSurface(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 8),
          surfaceColor: Colors.black.withOpacity(0.65),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: const Text('Edit Habit', style: TextStyle(color: Colors.white)),
                onTap: onEdit,
              ),
              ListTile(
                leading: Icon(
                  habit.isSkippedToday ? Icons.undo_rounded : Icons.skip_next_rounded,
                  color: Colors.white,
                ),
                title: Text(
                  habit.isSkippedToday ? 'Unskip Today' : 'Skip Today',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: onSkipToday,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                title: const Text('Delete Habit', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
