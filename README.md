# Hado ⚡

> **A minimal, local-first Flutter Habit & Reminder Manager for Android.**

Hado unites recurring daily routines (Habits) and time-sensitive to-dos (Reminders) under a single home screen with a master switch toggle. Built with an offline-first philosophy using Drift and SQLite.

---

## 🌟 Key Features

### 🔀 Master Switch
- Prominently placed at the top of the home screen to seamlessly slide between **Habits** and **Reminders** without losing scroll position or state.
- Dynamic Action Button (+) automatically adapts to create habits or reminders depending on the active view.

### 🌱 Habit Tracking & Momentum
- **Daily Check-ins**: Tap the circular action indicator to mark habits complete for today.
- **Streak Tracking (🔥)**: Accurate current and longest streak calculations with automatic midnight rollover.
- **Customization**: Color tags, frequency options (Daily, Weekdays, Weekends), and custom notes.
- **Swipe-to-Delete**: Clean swipe gesture to remove habits.

### ⏰ Time-Bound Reminders
- **Date & Time Scheduling**: Schedule tasks with date and time pickers.
- **Smart Grouping**: Automatically categorizes reminders into **Today & Overdue**, **Upcoming**, and **Completed**.
- **System Notifications**: Integrates with Android's notification system (`flutter_local_notifications`) to alert you even when the app is closed.
- **Strike-Through Progress**: Visual checkbox with completion timestamps.

### 🛡️ Privacy & Local-First
- **100% Offline**: No accounts, no cloud sync, no tracking, and zero latency.
- **Reactive Drift Database**: Backed by Drift and SQLite for ACID reliability and real-time UI updates via Streams.

---

## 🚀 Downloading the App

You can download the compiled Android APK directly:
1. Head to the **[Releases](https://github.com/ovrrup/Hado/releases)** tab.
2. Download `app-release.apk` under the latest release asset list (e.g. `v0.1.0`).
3. Alternatively, check the **[Actions](https://github.com/ovrrup/Hado/actions)** tab to download the latest artifact from any workflow run.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Database**: [Drift](https://drift.simonbinder.eu/) + `sqlite3_flutter_libs`
- **Notifications**: `flutter_local_notifications`
- **Design System**: Material 3 Design
- **CI/CD Pipeline**: GitHub Actions (`ubuntu-latest` building release APK)

---

## 💻 Local Development

### Prerequisites
- Flutter SDK (stable channel)
- Android SDK (API 34)
- Java 17

### Setup & Run
```bash
# Clone the repository
git clone https://github.com/ovrrup/Hado.git
cd Hado

# Fetch dependencies
flutter pub get

# Generate Drift database files
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run on connected Android device
flutter run
```

---

## 📜 License
Created by [ovrrup](https://github.com/ovrrup). Distributed under the MIT License.
