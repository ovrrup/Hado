import 'package:drift/drift.dart';
import 'habits.dart';

class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get completedDate => text()(); // YYYY-MM-DD
  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, completedDate}
      ];
}
