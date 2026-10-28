import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_workspace_screen.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'state/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge transparent system navigation and status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.create();
  final notificationService = NotificationService.instance;
  await notificationService.init();
  await notificationService.requestPermissions();

  final appState = AppState(
    storageService: storageService,
    notificationService: notificationService,
  );
  await appState.init();

  runApp(HadoApp(appState: appState));
}

class HadoApp extends StatelessWidget {
  final AppState appState;
  final bool enableScaffoldAnimation;

  const HadoApp({
    super.key,
    required this.appState,
    this.enableScaffoldAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: HomeWorkspaceScreen(
        appState: appState,
        enableScaffoldAnimation: enableScaffoldAnimation,
      ),
    );
  }
}
