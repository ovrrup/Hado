# Hado ⚡

> **A minimal, local-first Flutter Habit & Reminder Manager with Glassmorphic Aesthetics.**

Hado unites recurring daily routines (Habits) and time-sensitive to-dos (Reminders) under a single immersive glassmorphic interface. Built with an offline-first philosophy using Drift and SQLite, featuring custom GLSL shaders, tactile frosted glass components, and distinct curated color palettes.

---

## 🎨 Visual Redesign (v0.2.0)

- **Pure Minimalist Mode Header**: A clutter-free header strictly displaying the current active mode (**"Habits"** or **"Reminders"**) with fluid crossfade transitions.
- **Sub-Header Mode Switcher**: Centered frosted-glass pill toggle directly beneath the header for quick switching between modes.
- **Granular Particle Shader Background**: Custom GLSL fragment shader (`shaders/grain.frag`) generating dynamic organic film grain and noise across smooth gradient backdrops.
- **Dual Mode-Specific Palettes**:
  - **Habits Mode**: Terracotta (`#b98258`), Sage (`#8fb9b2`), and Warm Cream (`#e7dfd0`).
  - **Reminders Mode**: Apricot (`#e9b17f`), Coral (`#db7870`), and Celadon (`#d7e1d4`).
- **Tactile Glassmorphic Cards**: Enlarged 24px-radius frosted glass containers with backdrop blurs, luminous borders, oversized touch targets, and spring animations.
- **Curated Typography**: Crisp, modern typography powered by `GoogleFonts.outfit` for exceptional legibility and display hierarchy.

---

## 🌟 Key Features

### 🌱 Habit Tracking & Momentum
- **Daily Check-ins**: Tap the circular action indicator to mark habits complete for today.
- **Streak Tracking (🔥)**: Accurate current and longest streak calculations with automatic midnight rollover.
- **Customization**: Color tags, frequency options (Daily, Weekdays, Weekends), and custom notes.
- **Swipe-to-Delete**: Clean swipe gesture to remove habits.

### ⏰ Time-Bound Reminders
- **Date & Time Scheduling**: Frosted glass scheduling modal with oversized date and time selector cards.
- **Smart Grouping**: Automatically categorizes reminders into **Today & Overdue**, **Upcoming**, and **Completed**.
- **System Notifications**: Integrates with Android's notification system (`flutter_local_notifications`) to alert you even when the app is closed.
- **Strike-Through Progress**: Oversized custom checkbox with instant completion feedback.

### 🛡️ Privacy & Local-First
- **100% Offline**: No accounts, no cloud sync, no tracking, and zero latency.
- **Reactive Drift Database**: Backed by Drift and SQLite for ACID reliability and real-time UI updates via Streams.

---

## 🚀 Downloading the App

You can download the compiled Android APK directly:
1. Head to the **[Releases](https://github.com/ovrrup/Hado/releases)** tab.
2. Download `app-release.apk` under the latest release asset list (e.g. `v0.2.0`).
3. Alternatively, check the **[Actions](https://github.com/ovrrup/Hado/actions)** tab to download the latest artifact from any workflow run.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Shader Pipeline**: Flutter Fragment Programs (GLSL)
- **Typography**: [Google Fonts (Outfit)](https://pub.dev/packages/google_fonts)
- **Database**: [Drift](https://drift.simonbinder.eu/) + `sqlite3_flutter_libs`
- **Notifications**: `flutter_local_notifications`
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
