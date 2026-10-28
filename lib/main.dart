import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'data/database.dart';
import 'services/notification_service.dart';
import 'presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final notificationService = NotificationService.instance;
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(HadoApp(
    database: database,
    notificationService: notificationService,
  ));
}

class HadoApp extends StatelessWidget {
  final AppDatabase database;
  final NotificationService notificationService;

  const HadoApp({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(
        database: database,
        notificationService: notificationService,
      ),
    );
  }
}
