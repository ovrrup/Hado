# Design Document: Habit & Reminder Manager (v0.1.0)

## 1. Intent and The Why
Users need a focused, distraction-free Android app to manage both recurring daily routines (habits) and time-bound action items (reminders). Most existing apps either over-complicate tasks with enterprise project management features or separate habits and reminders into disconnected apps. This app bridges both worlds under a single, seamless home screen with a master toggle switch. It is built to be 100% offline, local-first, privacy-respecting, and fast.

## 2. Goals, Non-Goals, and Anti-Goals

### Goals
- **Unified Switch Experience**: Instant toggle between "Habits" and "Reminders" views on the main screen without reloading the page or losing place.
- **Robust Habit Tracking**: Create habits with customizable names, frequencies (daily/selected days), and maintain accurate streak counts (current streak, longest streak, completion history).
- **Actionable Reminders**: Create time-sensitive reminders with title, optional notes, scheduled date/time, and completion status.
- **Reliable Local Alerts**: Android system notifications triggering at scheduled reminder times even if the app process is terminated.
- **Relational Data Integrity**: SQLite-backed storage ensuring reliable ACID transactions, historical tracking, and robust queries.
- **Automated CI/CD**: Fully automated GitHub Actions workflow to build and export downloadable Android release APKs on push/release.
- **Version 0.1.0 Beta Delivery**: Deliver an end-to-end working MVP tagged as v0.1.0 with its own GitHub repository.

### Non-Goals (v0.1.0)
- Cloud synchronization, user authentication, or backend servers.
- Complex analytics or multi-year graph plotting (reserved for future versions).
- Social sharing or multi-user collaboration.
- WearOS or web companion interfaces.

### Anti-Goals
- Bloated onboarding flows, permission walls, or telemetry tracking.
- Untyped, raw SQL queries prone to runtime typos.
- Silent failures when alarms or notifications cannot be scheduled.

## 3. Constraints
- **Platform**: Flutter for Android, targeting modern Android (SDK 21+).
- **Offline First**: All user data resides in local SQLite storage on the device.
- **Compilation Environment**: Must compile cleanly into an APK via GitHub Actions `ubuntu-latest` workflow without requiring local Android Studio on the authoring environment.
- **Version**: Version 0.1.0 (Beta release).
- **Source Control**: Managed under a dedicated Git repository on the user's GitHub account (`ovrrup`).

## 4. Approaches Considered

### Approach 1: Lean Local Store (ChangeNotifier + Hive / JSON)
- Direct serialization to key-value or document storage.
- *Pros*: Simple, zero schema migrations, fast setup.
- *Cons*: Weak query capabilities for complex historical habit date math.

### Approach 2: Reactive SQL with Drift (`drift` + `drift_flutter`) — **SELECTED**
- Type-safe relational database mapping with reactive auto-updating queries (`watch()`), strongly-typed data classes, compile-time SQL verification, and SQLite backend.
- *Why chosen*: Selected by user for v0.1.0. It gives compile-time type safety over database schemas, reactive Streams that automatically update the UI when habits or reminders change, and robust relational querying for streak logic.

## 5. System Architecture & Decisions

### 5.1 Presentation Layer & UI Flow
- **Home Screen**:
  - Top header with clean app branding and the **Master Switch** (a Material 3 segmented button or animated pill toggle: "Habits" | "Reminders").
  - Content area displays either the `HabitsView` or `RemindersView` based on active toggle.
  - Floating Action Button (+) dynamically binds to the active mode:
    - If Habits is active: opens `CreateHabitSheet`.
    - If Reminders is active: opens `CreateReminderSheet`.
- **Habits View**:
  - Filter/Sort: Today's active habits at the top, completed habits grayed/checked.
  - Card elements: Habit title, icon/color tag, current streak counter (🔥), and a quick-action check button for today.
  - Tap card: Opens detailed view showing streak history and edit/delete actions.
- **Reminders View**:
  - Filter/Sort: Grouped by "Upcoming / Today", "Later", and "Completed".
  - Card elements: Title, scheduled date/time chip, notes preview, and checkbox.
  - Tap card: Opens edit/reschedule sheet.

### 5.2 Database Layer (Drift Reactive Database)
Implemented with `drift` & `drift_flutter` with SQLite native bindings (`sqlite3_flutter_libs`):

1. **Tables Definition**:
   - `Habits`:
     - `id`: `integer().autoIncrement()()`
     - `title`: `text().withLength(min: 1, max: 100)()`
     - `description`: `text().nullable()()`
     - `frequency`: `text().withDefault(const Constant('daily'))()`
     - `targetDays`: `text().withDefault(const Constant('1,2,3,4,5,6,7'))()`
     - `colorValue`: `integer().withDefault(const Constant(0xFF6750A4))()`
     - `createdAt`: `dateTime().withDefault(currentDateAndTime)()`
     - `isArchived`: `boolean().withDefault(const Constant(false))()`
   - `HabitLogs`:
     - `id`: `integer().autoIncrement()()`
     - `habitId`: `integer().references(Habits, #id, onDelete: KeyAction.cascade)()`
     - `completedDate`: `text()()` (YYYY-MM-DD formatted)
     - `notes`: `text().nullable()()`
     - *Unique Index*: on `(habitId, completedDate)`
   - `Reminders`:
     - `id`: `integer().autoIncrement()()`
     - `title`: `text().withLength(min: 1, max: 150)()`
     - `notes`: `text().nullable()()`
     - `dueDateTime`: `dateTime()()`
     - `isCompleted`: `boolean().withDefault(const Constant(false))()`
     - `completedAt`: `dateTime().nullable()()`
     - `notificationId`: `integer().nullable()()`
     - `createdAt`: `dateTime().withDefault(currentDateAndTime)()`

2. **Reactive Queries**:
   - DAOs / Queries providing reactive `Stream<List<HabitWithStreak>>` and `Stream<List<Reminder>>` using Drift's `.watch()` so the UI stays in sync without manual reload boilerplate.

### 5.3 Notification Service
- Powered by `flutter_local_notifications`.
- Configures Android notification channel `habit_reminder_alerts` with high importance.
- Requests notification permissions on Android 13+ (API 33).
- Uses standard timezone-aware scheduled notifications for due reminders.

### 5.4 CI/CD Pipeline (GitHub Actions)
- File: `.github/workflows/build-apk.yml`.
- Triggers on push to `main` and release tags.
- Environment: `ubuntu-latest`.
- Steps:
  - Checkout repository.
  - Setup Java 17.
  - Setup Flutter (stable channel).
  - Run `flutter pub get`.
  - Run `dart run build_runner build --delete-conflicting-outputs` (generates Drift database classes).
  - Run `flutter analyze` & `flutter test`.
  - Run `flutter build apk --release`.
  - Upload `app-release.apk` as a workflow artifact and attach to GitHub Release if tagged.

## 6. What's Left to the Builder
- Selection of Material 3 color palette and typography defaults.
- Precise streak calculation algorithm (handling timezone cutoffs at midnight).
- Exact animation timing for the master switch toggle transition.
- Standard empty state illustrations and error feedback snackbars.
