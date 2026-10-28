import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/reminder.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';

/// Unified glass bottom sheet for creating/editing habits and reminders.
///
/// Features:
/// - Transparent background with optical glass container
/// - Keyboard inset padding + scroll view to prevent RenderFlex overflows
/// - Habits Mode: Title input, M-T-W-T-F-S-S weekday circles, Emerald save button
/// - Reminders Mode: Title input, Pin toggle, Quick Time Chips (+1h, Tonight 8pm, Tomorrow 9am, Custom), Amber save button
class GlassBottomSheet extends StatefulWidget {
  final bool isHabitsMode;
  final Habit? initialHabit;
  final Reminder? initialReminder;
  final void Function(String title, List<int> targetDays)? onSaveHabit;
  final void Function(String title, DateTime dueDateTime, bool isPinned)? onSaveReminder;

  const GlassBottomSheet({
    super.key,
    required this.isHabitsMode,
    this.initialHabit,
    this.initialReminder,
    this.onSaveHabit,
    this.onSaveReminder,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isHabitsMode,
    Habit? initialHabit,
    Reminder? initialReminder,
    void Function(String title, List<int> targetDays)? onSaveHabit,
    void Function(String title, DateTime dueDateTime, bool isPinned)? onSaveReminder,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassBottomSheet(
        isHabitsMode: isHabitsMode,
        initialHabit: initialHabit,
        initialReminder: initialReminder,
        onSaveHabit: onSaveHabit,
        onSaveReminder: onSaveReminder,
      ),
    );
  }

  @override
  State<GlassBottomSheet> createState() => _GlassBottomSheetState();
}

class _GlassBottomSheetState extends State<GlassBottomSheet> {
  late final TextEditingController _titleController;

  // Habits State
  late Set<int> _selectedDays;

  // Reminders State
  late bool _isPinned;
  late DateTime _selectedDateTime;
  int _selectedChipIndex = 0; // 0: +1 Hour, 1: Tonight 8 PM, 2: Tomorrow 9 AM, 3: Custom

  @override
  void initState() {
    super.initState();
    if (widget.isHabitsMode) {
      _titleController = TextEditingController(text: widget.initialHabit?.title ?? '');
      _selectedDays = widget.initialHabit != null
          ? widget.initialHabit!.targetDays.toSet()
          : {1, 2, 3, 4, 5, 6, 7};
    } else {
      _titleController = TextEditingController(text: widget.initialReminder?.title ?? '');
      _isPinned = widget.initialReminder?.isPinned ?? false;
      _selectedDateTime = widget.initialReminder?.dueDateTime ?? _calculateQuickTime(0);
      if (widget.initialReminder != null) {
        _selectedChipIndex = 3; // Custom
      }
    }
  }

  DateTime _calculateQuickTime(int chipIndex) {
    final now = DateTime.now();
    switch (chipIndex) {
      case 0: // +1 Hour
        return now.add(const Duration(hours: 1));
      case 1: // Tonight 8 PM
        final tonight = DateTime(now.year, now.month, now.day, 20, 0);
        return tonight.isAfter(now)
            ? tonight
            : DateTime(now.year, now.month, now.day + 1, 20, 0);
      case 2: // Tomorrow 9 AM
        return DateTime(now.year, now.month, now.day + 1, 9, 0);
      default:
        return now.add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleDayToggle(int day) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _pickCustomDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime.isAfter(now) ? _selectedDateTime : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.warmAmber,
              surface: Color(0xFF1E2430),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.warmAmber,
                surface: Color(0xFF1E2430),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedChipIndex = 3;
        });
      }
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    unawaited(HapticFeedback.lightImpact());
    if (widget.isHabitsMode) {
      widget.onSaveHabit?.call(title, _selectedDays.toList()..sort());
    } else {
      widget.onSaveReminder?.call(title, _selectedDateTime, _isPinned);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isHabits = widget.isHabitsMode;
    final themeColor = isHabits ? AppColors.emerald : AppColors.warmAmber;
    final viewInsets = MediaQuery.of(context).viewInsets;

    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GlassSurface(
            borderRadius: 28,
            surfaceColor: Colors.black.withOpacity(0.72),
            padding: const EdgeInsets.all(22),
            customBorder: Border.all(
              color: themeColor.withOpacity(0.35),
              width: 1.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHabits
                          ? (widget.initialHabit != null ? 'Edit Habit' : 'New Habit')
                          : (widget.initialReminder != null ? 'Edit Reminder' : 'New Reminder'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title Input Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: isHabits
                          ? 'e.g. Read 20 pages'
                          : 'e.g. Submit project deck',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 15,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(height: 20),

                // ================= HABITS CONTENT =================
                if (isHabits) ...[
                  Text(
                    'SCHEDULE DAYS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // M-T-W-T-F-S-S Weekday Selector Circles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final dayNum = index + 1; // 1 = Mon, 7 = Sun
                      final isSelected = _selectedDays.contains(dayNum);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _handleDayToggle(dayNum),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.emerald
                                : Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.emerald
                                  : Colors.white.withOpacity(0.18),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.emerald.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              dayLetters[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.black : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                // ================= REMINDERS CONTENT =================
                if (!isHabits) ...[
                  // Pin Toggle
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      unawaited(HapticFeedback.selectionClick());
                      setState(() => _isPinned = !_isPinned);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isPinned
                            ? AppColors.warmAmber.withOpacity(0.15)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isPinned
                              ? AppColors.warmAmber.withOpacity(0.5)
                              : Colors.white.withOpacity(0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.push_pin_rounded,
                                size: 18,
                                color: _isPinned
                                    ? AppColors.warmAmber
                                    : Colors.white60,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Pin to top',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isPinned,
                            onChanged: (val) {
                              unawaited(HapticFeedback.selectionClick());
                              setState(() => _isPinned = val);
                            },
                            activeColor: AppColors.warmAmber,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'QUICK TIME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // One-tap Quick Time Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickChip(
                        label: '+1 Hour',
                        isSelected: _selectedChipIndex == 0,
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          setState(() {
                            _selectedChipIndex = 0;
                            _selectedDateTime = _calculateQuickTime(0);
                          });
                        },
                      ),
                      _QuickChip(
                        label: 'Tonight 8 PM',
                        isSelected: _selectedChipIndex == 1,
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          setState(() {
                            _selectedChipIndex = 1;
                            _selectedDateTime = _calculateQuickTime(1);
                          });
                        },
                      ),
                      _QuickChip(
                        label: 'Tomorrow 9 AM',
                        isSelected: _selectedChipIndex == 2,
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          setState(() {
                            _selectedChipIndex = 2;
                            _selectedDateTime = _calculateQuickTime(2);
                          });
                        },
                      ),
                      _QuickChip(
                        label: _selectedChipIndex == 3
                            ? DateFormat('MMM d, h:mm a').format(_selectedDateTime)
                            : 'Custom',
                        icon: Icons.calendar_today_rounded,
                        isSelected: _selectedChipIndex == 3,
                        onTap: () => unawaited(_pickCustomDateTime()),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 26),

                // Save Button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _submit,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHabits
                            ? [AppColors.emerald, AppColors.teal]
                            : [AppColors.warmAmber, AppColors.coral],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isHabits ? AppColors.emerald : AppColors.warmAmber)
                              .withOpacity(0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isHabits ? 'Save Habit' : 'Save Reminder',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warmAmber.withOpacity(0.24)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.warmAmber
                : Colors.white.withOpacity(0.14),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.warmAmber : Colors.white70,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
