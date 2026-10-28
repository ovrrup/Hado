import 'package:drift/drift.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get frequency => text().withDefault(const Constant('daily'))();
  TextColumn get targetDays => text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF6750A4))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}
