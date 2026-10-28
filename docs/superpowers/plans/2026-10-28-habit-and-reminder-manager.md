# Habit & Reminder Manager (v0.1.0) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a clean, local-first Flutter Android app (v0.1.0 Beta) that unifies habit tracking and time-sensitive reminders under a seamless home screen master switch, backed by a reactive Drift SQLite database, and automated via GitHub Actions APK compilation.

**Architecture:** The application follows a clean presentation-service-database layered architecture. A central Material 3 home screen hosts a segmented master toggle switching between `HabitsView` and `RemindersView`. The data layer uses Drift with SQLite for reactive `Stream` queries (`watch()`) and type-safe database tables, complemented by an Android local notification service for scheduled alarms.

**Tech Stack:** Flutter 3.x / Dart 3.x, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `flutter_local_notifications`, `intl`, GitHub Actions CI (`ubuntu-latest`).

**Spec:** [`docs/superpowers/specs/2026-10-28-habit-reminder-manager-design.md`](file:///data/data/com.termux/files/home/Hado/docs/superpowers/specs/2026-10-28-habit-reminder-manager-design.md)

## Global Constraints

- **Platform:** Flutter for Android (minSdkVersion 21, targetSdkVersion 34+).
- **Offline First:** 100% local device storage with SQLite via Drift.
- **Compilation Environment:** Compiled via GitHub Actions `ubuntu-latest` workflow without requiring local Android SDK on the host machine.
- **Version:** Version 0.1.0 (Beta release).
- **Source Control:** GitHub repository created and managed under account `ovrrup`.

## Review Focus

1. **Midnight rollover on streak calculation:** A habit completed yesterday must increment the streak; a habit completed two days ago without completion yesterday must reset the streak to 0 or 1 upon completion today.
2. **Scheduled reminder past due at boot:** If the phone was turned off during the scheduled time, opening the app must display the reminder in an "Overdue / Today" group rather than failing silently.
3. **App terminated notification handling:** Android 13+ requires `POST_NOTIFICATIONS` runtime permission and exact alarm permission (`SCHEDULE_EXACT_ALARM`) for high-precision reminder delivery.
4. **Instant Master Switch state preservation:** Flipping between Habits and Reminders must preserve scroll position and not cause unnecessary database re-queries.
5. **CI Drift code generation synchronization:** GitHub Actions runner must execute `dart run build_runner build --delete-conflicting-outputs` before running tests or building the release APK to prevent missing `*.drift.dart` symbols.

---

### Task 1: Project Scaffolding, Android Configuration & Git Setup

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `.gitignore`
- Create: `android/app/src/main/AndroidManifest.xml`
- Create: `android/app/build.gradle`
- Create: `android/build.gradle`
- Create: `android/settings.gradle`
- Create: `lib/main.dart`

**Interfaces:**
- Produces: Base Flutter project runnable by GitHub Actions and Dart toolchain.

- [ ] **Step 1: Create `pubspec.yaml` with required dependencies**
  Configure dependencies: `flutter`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `flutter_local_notifications`, `intl`. Dev dependencies: `drift_dev`, `build_runner`, `flutter_test`, `flutter_lints`. Set version to `0.1.0+1`.

- [ ] **Step 2: Create Android manifests and gradle configurations**
  Add permissions to `android/app/src/main/AndroidManifest.xml`:
  `android.permission.RECEIVE_BOOT_COMPLETED`, `android.permission.VIBRATE`, `android.permission.POST_NOTIFICATIONS`, `android.permission.SCHEDULE_EXACT_ALARM`, `android.permission.USE_EXACT_ALARM`.

- [ ] **Step 3: Create `.gitignore` and `analysis_options.yaml`**
  Ignore `*.g.dart`, `*.drift.dart`, `.dart_tool/`, `build/`, `.idea/`, `.gradle/`, `.superpowers/`.

- [ ] **Step 4: Initialize Git repository and create remote on GitHub**
  Initialize git, create `main` branch, run `gh repo create Hado --public --source=. --remote=origin` (or private if preferred) to connect to `ovrrup/Hado`.

- [ ] **Step 5: Commit baseline structure**
  `git add . && git commit -m "chore: scaffold flutter project structure and android configuration"`

---

### Task 2: Drift Database Schema, DAOs & Streak Calculation

**Files:**
- Create: `lib/data/tables/habits.dart`
- Create: `lib/data/tables/habit_logs.dart`
- Create: `lib/data/tables/reminders.dart`
- Create: `lib/data/database.dart`
- Create: `test/database_test.dart`

**Interfaces:**
- Consumes: `drift`, `drift_flutter`
- Produces: `AppDatabase` singleton with reactive streams:
  - `watchHabitsWithTodayStatus(): Stream<List<HabitItem>>`
  - `watchReminders({bool includeCompleted = false}): Stream<List<Reminder>>`
  - `logHabit(int habitId, DateTime date)`
  - `undoHabit(int habitId, DateTime date)`
  - `calculateStreak(int habitId): Future<HabitStreak>`
  - `insertReminder(RemindersCompanion reminder): Future<int>`
  - `updateReminderCompletion(int id, bool completed): Future<void>`
  - `deleteReminder(int id): Future<void>`

- [ ] **Step 1: Define Drift table classes**
  Implement `Habits`, `HabitLogs` with unique `(habitId, completedDate)`, and `Reminders` table definitions in `lib/data/tables/`.

- [ ] **Step 2: Implement `AppDatabase` and query methods**
  Create `lib/data/database.dart` with methods to query habits, calculate current & longest streaks based on consecutive daily records, log habit completions, and manage reminders.

- [ ] **Step 3: Write database unit tests**
  Create `test/database_test.dart` to verify inserting habits, logging completion, calculating streaks across multi-day dates, and toggling reminder completion using an in-memory Drift SQLite instance.

- [ ] **Step 4: Commit database layer**
  `git add lib/data test/database_test.dart && git commit -m "feat(data): implement reactive drift database and streak calculations"`

---

### Task 3: Local Notification Service

**Files:**
- Create: `lib/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

**Interfaces:**
- Consumes: `flutter_local_notifications`
- Produces:
  - `NotificationService.instance`
  - `Future<void> init()`
  - `Future<void> requestPermissions()`
  - `Future<void> scheduleReminder({required int id, required String title, String? notes, required DateTime scheduledDate})`
  - `Future<void> cancelReminder(int id)`

- [ ] **Step 1: Implement `NotificationService`**
  Implement initialization with `AndroidInitializationSettings('@mipmap/ic_launcher')`, notification channel `habit_reminder_channel` ("Reminders"), timezone conversion, and cancel methods.

- [ ] **Step 2: Add mockable wrapper/tests for notification logic**
  Ensure ID hashing and scheduling bounds check dates that are in the past.

- [ ] **Step 3: Commit notification service**
  `git add lib/services/ && git commit -m "feat(notifications): add local notification scheduling service"`

---

### Task 4: UI Master Switch & App Shell

**Files:**
- Create: `lib/core/theme.dart`
- Create: `lib/presentation/widgets/master_switch.dart`
- Create: `lib/presentation/home_screen.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `NotificationService`
- Produces:
  - `MasterSwitch(selectedTab: AppTab, onTabChanged: ValueChanged<AppTab>)`
  - `HomeScreen`: Top AppBar with `MasterSwitch`, body with `IndexedStack` or animated switch between `HabitsView` and `RemindersView`, FAB switching between creating a habit vs creating a reminder.

- [ ] **Step 1: Define Material 3 Theme in `lib/core/theme.dart`**
  Configure modern color scheme (primary purple/indigo accents, dark mode support, rounded card shapes).

- [ ] **Step 2: Implement `MasterSwitch` widget**
  Create a smooth segmented pill toggle with icons (`Icons.check_circle_outline` for Habits and `Icons.alarm` for Reminders) and haptic feedback.

- [ ] **Step 3: Implement `HomeScreen` shell**
  Build the scaffold that hosts the header, the `MasterSwitch`, and dynamic Floating Action Button (+).

- [ ] **Step 4: Commit UI shell**
  `git add lib/core/ lib/presentation/ lib/main.dart && git commit -m "feat(ui): add master switch and home screen shell"`

---

### Task 5: Habits View, Cards & Habit Creation Dialog

**Files:**
- Create: `lib/presentation/views/habits_view.dart`
- Create: `lib/presentation/widgets/habit_card.dart`
- Create: `lib/presentation/dialogs/create_habit_sheet.dart`

**Interfaces:**
- Consumes: `AppDatabase`
- Produces:
  - `HabitsView`: Displays active habits, empty state when none exist, and completion status for today.
  - `HabitCard`: Displays title, streak count with flame badge (🔥), and interactive completion button with checkmark animation.
  - `CreateHabitSheet`: Bottom modal sheet with title input, frequency selector, color palette picker, and save button.

- [ ] **Step 1: Build `HabitCard`**
  Display title, streak badge, and animated check button. Tapping the button calls `database.logHabit` or `database.undoHabit`.

- [ ] **Step 2: Build `CreateHabitSheet`**
  Form with validation, color circles for customization, and clean submit action calling `database.insertHabit`.

- [ ] **Step 3: Build `HabitsView`**
  Connect with `StreamBuilder` listening to `database.watchHabitsWithTodayStatus()`. Includes friendly empty state when no habits are found.

- [ ] **Step 4: Commit habits feature**
  `git add lib/presentation/views/habits_view.dart lib/presentation/widgets/habit_card.dart lib/presentation/dialogs/create_habit_sheet.dart && git commit -m "feat(habits): implement habits view, habit card, and creation modal"`

---

### Task 6: Reminders View, Cards & Reminder Creation Dialog

**Files:**
- Create: `lib/presentation/views/reminders_view.dart`
- Create: `lib/presentation/widgets/reminder_card.dart`
- Create: `lib/presentation/dialogs/create_reminder_sheet.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `NotificationService`
- Produces:
  - `RemindersView`: Lists reminders grouped by "Today / Overdue", "Upcoming", and "Completed".
  - `ReminderCard`: Displays title, notes, scheduled date & time chip, and completion checkbox.
  - `CreateReminderSheet`: Bottom modal sheet with title, optional notes, date picker, time picker, and save button that schedules the system notification.

- [ ] **Step 1: Build `ReminderCard`**
  Card with strike-through animation when completed, formatted datetime chip, and delete swipe or button.

- [ ] **Step 2: Build `CreateReminderSheet`**
  Form with date & time pickers defaulting to 1 hour from current time, validation, and notification trigger.

- [ ] **Step 3: Build `RemindersView`**
  Sectioned list using `StreamBuilder` to listen to `database.watchReminders()`.

- [ ] **Step 4: Commit reminders feature**
  `git add lib/presentation/views/reminders_view.dart lib/presentation/widgets/reminder_card.dart lib/presentation/dialogs/create_reminder_sheet.dart && git commit -m "feat(reminders): implement reminders view, reminder card, and creation modal"`

---

### Task 7: GitHub Actions CI/CD APK Compilation Workflow

**Files:**
- Create: `.github/workflows/build-apk.yml`
- Create: `README.md`

**Interfaces:**
- Produces: Automated release APK builds on GitHub Actions and release asset publishing.

- [ ] **Step 1: Create `.github/workflows/build-apk.yml`**
  Define GitHub Actions workflow running on `ubuntu-latest`:
  - Java 17 setup (`actions/setup-java@v4`).
  - Flutter SDK setup (`subosito/flutter-action@v2` with `channel: 'stable'`).
  - `flutter pub get`.
  - `dart run build_runner build --delete-conflicting-outputs`.
  - `flutter test`.
  - `flutter build apk --release`.
  - Upload `build/app/outputs/flutter-apk/app-release.apk` artifact via `actions/upload-artifact@v4`.
  - If event is a tag `v*`, use `softprops/action-gh-release@v2` to create a GitHub Release with the APK attached.

- [ ] **Step 2: Create comprehensive `README.md`**
  Document app features, architecture, screenshots/mockup description, building locally vs downloading the APK from GitHub Actions releases.

- [ ] **Step 3: Commit workflow and documentation**
  `git add .github/ README.md && git commit -m "ci: add github actions apk compilation workflow and documentation"`

---

### Task 8: Version 0.1.0 Tag, Remote Push & Build Verification

**Files:**
- Verify: Full repository integrity.

- [ ] **Step 1: Tag release v0.1.0**
  Run `git tag -a v0.1.0 -m "Release v0.1.0 (Beta)"`.

- [ ] **Step 2: Push code and tags to GitHub**
  Push `main` branch and `v0.1.0` tag to `origin`.

- [ ] **Step 3: Verify GitHub Actions build status**
  Use `gh run list` / `gh run watch` to monitor the GitHub Actions APK compilation job until completion.
