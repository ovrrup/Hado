import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';
import 'glass_toast.dart';

/// Glass card for a single reminder.
///
/// Supports:
/// - Title with strikethrough when completed
/// - Due time pill highlighted Amber if due today or overdue
/// - Pin icon
/// - Tap-to-complete with strikethrough and haptic feedback
/// - Swipe-right to complete (Dismissible)
/// - Swipe-left to snooze +1 hour with glass toast (Dismissible)
/// - Long-press for Pin/Unpin, Edit, Delete glass menu
class ReminderGlassCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggleComplete;
  final VoidCallback onSnooze;
  final VoidCallback onTogglePin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderGlassCard({
    super.key,
    required this.reminder,
    required this.onToggleComplete,
    required this.onSnooze,
    required this.onTogglePin,
    required this.onEdit,
    required this.onDelete,
  });

  void _showGlassActionMenu(BuildContext context) {
    unawaited(HapticFeedback.mediumImpact());
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReminderActionMenu(
        reminder: reminder,
        onTogglePin: () {
          Navigator.pop(ctx);
          onTogglePin();
        },
        onEdit: () {
          Navigator.pop(ctx);
          onEdit();
        },
        onDelete: () {
          Navigator.pop(ctx);
          onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = reminder.isCompleted;
    final isAmberHighlighted = !isDone && (reminder.isDueToday || reminder.isOverdue);

    return Dismissible(
      key: ValueKey('reminder_${reminder.id}_${reminder.dueDateTime.millisecondsSinceEpoch}_${reminder.isCompleted}'),
      direction: isDone
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Complete
          unawaited(HapticFeedback.lightImpact());
          onToggleComplete();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left: Snooze +1 hour
          unawaited(HapticFeedback.lightImpact());
          onSnooze();
          GlassToast.show(
            context,
            'Snoozed for 1 hour',
            icon: Icons.snooze_rounded,
            glowColor: AppColors.warmAmber,
          );
          return false;
        }
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.emerald.withOpacity(0.25),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(
            color: AppColors.emerald.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 24),
            SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.warmAmber.withOpacity(0.25),
          borderRadius: BorderRadius.circular(AppColors.glassBorderRadius),
          border: Border.all(
            color: AppColors.warmAmber.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Snooze +1h',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.snooze_rounded, color: AppColors.warmAmber, size: 24),
          ],
        ),
      ),
      child: GlassSurface(
        borderRadius: AppColors.glassBorderRadius,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(18),
        onTap: () {
          unawaited(HapticFeedback.lightImpact());
          onToggleComplete();
        },
        onLongPress: () => _showGlassActionMenu(context),
        surfaceColor: isDone
            ? Colors.white.withOpacity(0.03)
            : (isAmberHighlighted
                ? AppColors.warmAmber.withOpacity(0.08)
                : AppColors.glassSurface),
        customBorder: isAmberHighlighted
            ? Border.all(
                color: AppColors.warmAmber.withOpacity(0.40),
                width: 1.0,
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox icon
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                onToggleComplete();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDone
                      ? AppColors.warmAmber
                      : Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: isDone
                        ? AppColors.warmAmber
                        : Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Title and due time pill
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDone
                                ? AppColors.textDimmed
                                : Colors.white,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors.white.withOpacity(0.4),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (reminder.isPinned) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: AppColors.warmAmber,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Due time pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: isAmberHighlighted
                          ? AppColors.warmAmber.withOpacity(0.22)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isAmberHighlighted
                            ? AppColors.warmAmber.withOpacity(0.55)
                            : Colors.white.withOpacity(0.12),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: isAmberHighlighted
                              ? AppColors.warmAmber
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          reminder.formattedDueTime,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: isAmberHighlighted
                                ? AppColors.warmAmber
                                : AppColors.textSecondary,
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

class _ReminderActionMenu extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTogglePin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderActionMenu({
    required this.reminder,
    required this.onTogglePin,
    required this.onEdit,
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
                  reminder.title,
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
                leading: Icon(
                  reminder.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                  color: AppColors.warmAmber,
                ),
                title: Text(
                  reminder.isPinned ? 'Unpin Reminder' : 'Pin Reminder',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: onTogglePin,
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: const Text('Edit Reminder', style: TextStyle(color: Colors.white)),
                onTap: onEdit,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                title: const Text('Delete Reminder', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
