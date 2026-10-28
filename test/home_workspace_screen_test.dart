import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hado/screens/home_workspace_screen.dart';
import 'package:hado/services/notification_service.dart';
import 'package:hado/state/app_state.dart';
import 'package:hado/state/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HomeWorkspaceScreen Integration Tests', () {
    late StorageService storageService;
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.create();
      appState = AppState(
        storageService: storageService,
        notificationService: NotificationService(),
      );
      await appState.init();
    });

    testWidgets('Workspace opens directly into Habits view and can switch to Reminders',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWorkspaceScreen(
            appState: appState,
            enableScaffoldAnimation: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Habits header should be visible
      expect(find.text('Habits'), findsNWidgets(2)); // Title + Nav Pill
      expect(find.text('Reminders'), findsOneWidget); // Nav Pill

      // Switch to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Reminders title should now be visible
      expect(find.text('Reminders'), findsNWidgets(2)); // Title + Nav Pill
    });

    testWidgets('Tapping the + FAB opens GlassBottomSheet',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeWorkspaceScreen(
            appState: appState,
            enableScaffoldAnimation: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap + button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Should show New Habit bottom sheet with weekday circles
      expect(find.text('New Habit'), findsOneWidget);
      expect(find.text('SCHEDULE DAYS'), findsOneWidget);
      expect(find.text('Save Habit'), findsOneWidget);
    });

    testWidgets('Renders responsive layout on wide screen without overflow',
        (tester) async {
      // Set surface size to tablet/desktop width (800x600)
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeWorkspaceScreen(
            appState: appState,
            enableScaffoldAnimation: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Habits'), findsNWidgets(2));
      // No overflow errors should be thrown
      expect(tester.takeException(), isNull);
    });
  });
}
