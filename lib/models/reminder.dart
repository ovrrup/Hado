import 'package:intl/intl.dart';

class Reminder {
  final String id;
  final String title;
  final DateTime dueDateTime;
  final bool isPinned;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? notificationId;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    required this.dueDateTime,
    this.isPinned = false,
    this.isCompleted = false,
    this.completedAt,
    this.notificationId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (isCompleted) return false;
    return dueDateTime.isBefore(DateTime.now());
  }

  bool get isDueToday {
    final now = DateTime.now();
    return dueDateTime.year == now.year &&
        dueDateTime.month == now.month &&
        dueDateTime.day == now.day;
  }

  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDateTime.year == tomorrow.year &&
        dueDateTime.month == tomorrow.month &&
        dueDateTime.day == tomorrow.day;
  }

  bool get isUpcoming {
    if (isCompleted) return false;
    if (isDueToday) return false;
    return dueDateTime.isAfter(DateTime.now());
  }

  String get formattedDueTime {
    final timeStr = DateFormat('h:mm a').format(dueDateTime);
    if (isDueToday) {
      return 'Today, $timeStr';
    } else if (isDueTomorrow) {
      return 'Tomorrow, $timeStr';
    } else {
      final dateStr = DateFormat('MMM d').format(dueDateTime);
      return '$dateStr, $timeStr';
    }
  }

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dueDateTime,
    bool? isPinned,
    bool? isCompleted,
    DateTime? completedAt,
    int? notificationId,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDateTime': dueDateTime.toIso8601String(),
      'isPinned': isPinned,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'notificationId': notificationId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDateTime: DateTime.tryParse(json['dueDateTime'] as String? ?? '') ?? DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
      notificationId: json['notificationId'] as int?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
