import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class GlassSwitch extends StatelessWidget {
  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabChanged;

  const GlassSwitch({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHabits = selectedTab == AppTab.habits;
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isHabits
        ? HadoPalettes.habitTerracotta
        : HadoPalettes.reminderCoral;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.2 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSegment(
                context: context,
                title: 'Habits',
                icon: Icons.repeat_rounded,
                isSelected: isHabits,
                activeColor: activeColor,
                onTap: () {
                  if (!isHabits) {
                    HapticFeedback.lightImpact();
                    onTabChanged(AppTab.habits);
                  }
                },
              ),
              const SizedBox(width: 4),
              _buildSegment(
                context: context,
                title: 'Reminders',
                icon: Icons.notifications_active_outlined,
                isSelected: !isHabits,
                activeColor: activeColor,
                onTap: () {
                  if (isHabits) {
                    HapticFeedback.lightImpact();
                    onTabChanged(AppTab.reminders);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
