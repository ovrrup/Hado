class Habit {
  final String id;
  final String title;
  final List<int> targetDays; // 1 = Monday, 7 = Sunday
  final DateTime createdAt;
  final Set<String> completedDates; // Format: 'YYYY-MM-DD'
  final Set<String> skippedDates; // Format: 'YYYY-MM-DD'

  Habit({
    required this.id,
    required this.title,
    List<int>? targetDays,
    DateTime? createdAt,
    Set<String>? completedDates,
    Set<String>? skippedDates,
  })  : targetDays = targetDays ?? [1, 2, 3, 4, 5, 6, 7],
        createdAt = createdAt ?? DateTime.now(),
        completedDates = completedDates ?? <String>{},
        skippedDates = skippedDates ?? <String>{};

  static String formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool isCompletedOn(DateTime dt) => completedDates.contains(formatDate(dt));

  bool get isCompletedToday => isCompletedOn(DateTime.now());

  bool isSkippedOn(DateTime dt) => skippedDates.contains(formatDate(dt));

  bool get isSkippedToday => isSkippedOn(DateTime.now());

  bool isScheduledFor(DateTime dt) => targetDays.contains(dt.weekday);

  bool get isScheduledToday => isScheduledFor(DateTime.now());

  String get scheduleSubtitle {
    if (targetDays.length == 7) {
      return 'Daily';
    }
    if (targetDays.length == 5 &&
        targetDays.contains(1) &&
        targetDays.contains(2) &&
        targetDays.contains(3) &&
        targetDays.contains(4) &&
        targetDays.contains(5)) {
      return 'Weekdays';
    }
    if (targetDays.length == 2 &&
        targetDays.contains(6) &&
        targetDays.contains(7)) {
      return 'Weekends';
    }

    const dayLabels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final sorted = List<int>.from(targetDays)..sort();
    return sorted.map((d) => dayLabels[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  /// Returns 7 booleans for the last 7 calendar days up to and including today.
  List<bool> get last7DaysHistory {
    final today = DateTime.now();
    final result = <bool>[];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      result.add(isCompletedOn(day));
    }
    return result;
  }

  Habit copyWith({
    String? id,
    String? title,
    List<int>? targetDays,
    DateTime? createdAt,
    Set<String>? completedDates,
    Set<String>? skippedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDays: targetDays ?? List<int>.from(this.targetDays),
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? Set<String>.from(this.completedDates),
      skippedDates: skippedDates ?? Set<String>.from(this.skippedDates),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.toList(),
      'skippedDates': skippedDates.toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      targetDays: (json['targetDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5, 6, 7],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      completedDates: (json['completedDates'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? <String>{},
      skippedDates: (json['skippedDates'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? <String>{},
    );
  }
}
