import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/database.dart';
import '../services/notification_service.dart';
import 'widgets/glass_switch.dart';
import 'widgets/grain_shader_background.dart';
import 'views/habits_view.dart';
import 'views/reminders_view.dart';
import 'dialogs/create_habit_sheet.dart';
import 'dialogs/create_reminder_sheet.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase database;
  final NotificationService notificationService;
  final bool enableShaderAnimation;

  const HomeScreen({
    super.key,
    required this.database,
    required this.notificationService,
    this.enableShaderAnimation = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTab _selectedTab = AppTab.habits;

  bool get _isHabits => _selectedTab == AppTab.habits;

  void _openCreationModal() {
    if (_isHabits) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateHabitSheet(database: widget.database),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateReminderSheet(
          database: widget.database,
          notificationService: widget.notificationService,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePaletteColor = _isHabits
        ? HadoPalettes.habitTerracotta
        : HadoPalettes.reminderCoral;

    return GrainShaderBackground(
      isHabitMode: _isHabits,
      enableAnimation: widget.enableShaderAnimation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Minimal Header: Shows strictly the active mode name and nothing else
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, -0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _isHabits ? 'Habits' : 'Reminders',
                    key: ValueKey<String>(_isHabits ? 'Habits' : 'Reminders'),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C241E),
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Dedicated Sub-Header Toggle
              Center(
                child: GlassSwitch(
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                ),
              ),
              const SizedBox(height: 14),
              // Main Content Area
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isHabits
                      ? HabitsView(
                          key: const ValueKey('HabitsView'),
                          database: widget.database,
                        )
                      : RemindersView(
                          key: const ValueKey('RemindersView'),
                          database: widget.database,
                          notificationService: widget.notificationService,
                        ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOversizedGlassFab(activePaletteColor),
        ),
      ),
    );
  }

  Widget _buildOversizedGlassFab(Color activeColor) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openCreationModal,
              splashColor: Colors.white24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      _isHabits ? 'New Habit' : 'New Reminder',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
