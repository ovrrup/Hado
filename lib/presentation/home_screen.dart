import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/database.dart';
import '../services/notification_service.dart';
import 'widgets/master_switch.dart';
import 'views/habits_view.dart';
import 'views/reminders_view.dart';
import 'dialogs/create_habit_sheet.dart';
import 'dialogs/create_reminder_sheet.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase database;
  final NotificationService notificationService;

  const HomeScreen({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTab _selectedTab = AppTab.habits;

  void _openCreationModal() {
    if (_selectedTab == AppTab.habits) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hado',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MasterSwitch(
              selectedTab: _selectedTab,
              onTabChanged: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _selectedTab == AppTab.habits
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreationModal,
        icon: const Icon(Icons.add),
        label: Text(_selectedTab == AppTab.habits ? 'New Habit' : 'New Reminder'),
      ),
    );
  }
}
