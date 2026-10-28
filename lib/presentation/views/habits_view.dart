import 'package:flutter/material.dart';
import '../../data/database.dart';

class HabitsView extends StatelessWidget {
  final AppDatabase database;

  const HabitsView({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Habits View Placeholder'),
    );
  }
}
