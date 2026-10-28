import 'package:flutter/material.dart';

void main() {
  runApp(const HadoApp());
}

class HadoApp extends StatelessWidget {
  const HadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hado',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Hado - Habit & Reminder Manager'),
        ),
      ),
    );
  }
}
