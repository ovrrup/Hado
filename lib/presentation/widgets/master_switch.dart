import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class MasterSwitch extends StatelessWidget {
  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabChanged;

  const MasterSwitch({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHabits = selectedTab == AppTab.habits;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPill(
            context: context,
            title: 'Habits',
            icon: Icons.check_circle_outline,
            isSelected: isHabits,
            onTap: () {
              if (!isHabits) {
                HapticFeedback.lightImpact();
                onTabChanged(AppTab.habits);
              }
            },
          ),
          _buildPill(
            context: context,
            title: 'Reminders',
            icon: Icons.alarm,
            isSelected: !isHabits,
            onTap: () {
              if (isHabits) {
                HapticFeedback.lightImpact();
                onTabChanged(AppTab.reminders);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
