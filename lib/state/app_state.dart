import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  List<Habit> _habits = [];
  List<Reminder> _reminders = [];
  bool _isInitialized = false;

  AppState({
    required StorageService storageService,
    NotificationService? notificationService,
  })  : _storageService = storageService,
        _notificationService = notificationService ?? NotificationService.instance;

  bool get isInitialized => _isInitialized;
  List<Habit> get habits => List.unmodifiable(_habits);
  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Future<void> init() async {
    _habits = await _storageService.loadHabits();
    _reminders = await _storageService.loadReminders();
    _isInitialized = true;
    notifyListeners();
  }

  // ================= HABITS API =================

  List<Habit> get activeHabits =>
      _habits.where((h) => !h.isCompletedToday).toList();

  List<Habit> get completedHabits =>
      _habits.where((h) => h.isCompletedToday).toList();

  double get todayCompletionRatio {
    if (_habits.isEmpty) return 0.0;
    final scheduled = _habits.where((h) => h.isScheduledToday).toList();
    if (scheduled.isEmpty) {
      return _habits.where((h) => h.isCompletedToday).length / _habits.length;
    }
    final completed = scheduled.where((h) => h.isCompletedToday).length;
    return completed / scheduled.length;
  }

  Future<void> toggleHabitToday(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final today = Habit.formatDate(DateTime.now());
    final newCompleted = Set<String>.from(habit.completedDates);

    if (newCompleted.contains(today)) {
      newCompleted.remove(today);
    } else {
      newCompleted.add(today);
      unawaited(HapticFeedback.lightImpact());
    }

    _habits[index] = habit.copyWith(completedDates: newCompleted);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  Future<void> skipHabitToday(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final today = Habit.formatDate(DateTime.now());
    final newSkipped = Set<String>.from(habit.skippedDates);

    if (newSkipped.contains(today)) {
      newSkipped.remove(today);
    } else {
      newSkipped.add(today);
    }

    _habits[index] = habit.copyWith(skippedDates: newSkipped);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  Future<void> addHabit({
    required String title,
    required List<int> targetDays,
  }) async {
    final newHabit = Habit(
      id: 'habit_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      targetDays: targetDays,
    );
    _habits.insert(0, newHabit);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  Future<void> updateHabit(Habit updated) async {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index != -1) {
      _habits[index] = updated;
      notifyListeners();
      await _storageService.saveHabits(_habits);
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  // ================= REMINDERS API =================

  List<Reminder> get pinnedReminders =>
      _reminders.where((r) => r.isPinned && !r.isCompleted).toList();

  List<Reminder> get todayReminders => _reminders
      .where((r) => !r.isPinned && !r.isCompleted && r.isDueToday)
      .toList();

  List<Reminder> get upcomingReminders => _reminders
      .where((r) => !r.isPinned && !r.isCompleted && !r.isDueToday)
      .toList();

  List<Reminder> get completedReminders =>
      _reminders.where((r) => r.isCompleted).toList();

  Future<void> toggleReminderCompletion(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final rem = _reminders[index];
    final becomingCompleted = !rem.isCompleted;

    if (becomingCompleted) {
      unawaited(HapticFeedback.lightImpact());
      if (rem.notificationId != null) {
        unawaited(_notificationService.cancelReminder(rem.notificationId!));
      }
    }

    _reminders[index] = rem.copyWith(
      isCompleted: becomingCompleted,
      completedAt: becomingCompleted ? DateTime.now() : null,
    );
    notifyListeners();
    await _storageService.saveReminders(_reminders);
  }

  Future<void> snoozeReminder(String id, Duration duration) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final rem = _reminders[index];
    final newDueTime = DateTime.now().add(duration);
    unawaited(HapticFeedback.lightImpact());

    _reminders[index] = rem.copyWith(
      dueDateTime: newDueTime,
      isCompleted: false,
    );

    if (rem.notificationId != null) {
      unawaited(
        _notificationService.scheduleReminder(
          id: rem.notificationId!,
          title: rem.title,
          scheduledDate: newDueTime,
        ),
      );
    }

    notifyListeners();
    await _storageService.saveReminders(_reminders);
  }

  Future<void> togglePinReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final rem = _reminders[index];
    _reminders[index] = rem.copyWith(isPinned: !rem.isPinned);
    notifyListeners();
    await _storageService.saveReminders(_reminders);
  }

  Future<void> addReminder({
    required String title,
    required DateTime dueDateTime,
    bool isPinned = false,
  }) async {
    final notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final newReminder = Reminder(
      id: 'rem_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      dueDateTime: dueDateTime,
      isPinned: isPinned,
      notificationId: notifId,
    );

    _reminders.insert(0, newReminder);

    if (dueDateTime.isAfter(DateTime.now())) {
      unawaited(
        _notificationService.scheduleReminder(
          id: notifId,
          title: newReminder.title,
          scheduledDate: dueDateTime,
        ),
      );
    }

    notifyListeners();
    await _storageService.saveReminders(_reminders);
  }

  Future<void> updateReminder(Reminder updated) async {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _reminders[index] = updated;
      if (updated.notificationId != null &&
          updated.dueDateTime.isAfter(DateTime.now()) &&
          !updated.isCompleted) {
        unawaited(
          _notificationService.scheduleReminder(
            id: updated.notificationId!,
            title: updated.title,
            scheduledDate: updated.dueDateTime,
          ),
        );
      }
      notifyListeners();
      await _storageService.saveReminders(_reminders);
    }
  }

  Future<void> deleteReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final rem = _reminders[index];
      if (rem.notificationId != null) {
        unawaited(_notificationService.cancelReminder(rem.notificationId!));
      }
      _reminders.removeAt(index);
      notifyListeners();
      await _storageService.saveReminders(_reminders);
    }
  }
}
