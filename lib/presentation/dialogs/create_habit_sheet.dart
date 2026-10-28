import 'package:flutter/material.dart';
import '../../data/database.dart';

class CreateHabitSheet extends StatelessWidget {
  final AppDatabase database;

  const CreateHabitSheet({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('Create Habit')),
    );
  }
}
