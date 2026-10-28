# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.3.0] - Unreleased

### Added
- **`AmbientGlassScaffold`**: Deep obsidian background (`#0B0F17`) with 2-3 drifting blurred radial gradient orbs on a 10-second trigonometric loop that dynamically cross-fades and interpolates colors in real time with the active page offset:
  - *Habits Mode*: Emerald (`#10B981`) and Teal (`#059669`).
  - *Reminders Mode*: Warm Amber (`#F59E0B`) and Coral (`#EA580C`).
- **`GlassSurface` Component**: Reusable frosted glass container featuring:
  - Hardware-isolated rendering via `RepaintBoundary`.
  - `ClipRRect` with 20px border radius.
  - Authentic optical blur with `BackdropFilter` (`sigmaX: 24`, `sigmaY: 24`).
  - `AnimatedContainer` with white opacity `0.06` (`0.12` when pressed).
  - 1px highlight border with `0.14` white opacity.
- **Horizontal Workspace `PageView`**: Seamless swipeable full-screen view linking Habits (Page 0) and Reminders (Page 1).
- **Floating Glass Segmented Pill & FAB**:
  - Bottom-centered glass segmented pill whose active sliding thumb tracks `PageController` scroll offset and cross-fades theme colors in real time.
  - Paired circular Glass `+` FAB with dynamic glow matching the active mode.
- **Adaptive Screen Responsiveness**:
  - Mobile (<600px width): Single-column vertical list with native `BouncingScrollPhysics`.
  - Tablet / Desktop (≥600px width): Centered 2-to-3 column responsive grid capped at 1000px maximum width.
- **Habits Mode Micro-Interactions**:
  - Minimal date header with dynamic completion percentage.
  - Animated glass progress bar glowing with an Emerald-to-Teal gradient.
  - Active habits at the top, completed habits transitioning into a dimmed bottom section.
  - `HabitGlassCard` with title, schedule subtitle (*Daily*, *Weekdays*, *Weekends*, or specific days), and an inline 7-day micro-history row of 7 small 8px dots (Emerald for completed, translucent white for missed).
  - Tapping card triggers `HapticFeedback.lightImpact()` with a 0.97 scale spring micro-interaction.
  - Long-pressing card opens a frosted glass menu to *Edit*, *Skip Today*, or *Delete*.
- **Reminders Mode Hierarchy & Gestures**:
  - Clean sectional headers: `PINNED`, `TODAY`, `UPCOMING`, and `COMPLETED`.
  - `ReminderGlassCard` with strikethrough upon completion, amber-highlighted due time pill (when due today or overdue), and pin icon.
  - Tap-to-complete with haptic feedback.
  - Swipe-right (`Dismissible`) to complete.
  - Swipe-left to snooze +1 hour and trigger an authentic floating `GlassToast`.
  - Long-press menu for *Pin/Unpin*, *Edit*, or *Delete*.
- **Unified `GlassBottomSheet`**:
  - Transparent backdrop and keyboard inset padding with smooth scrolling to eliminate keyboard and small screen overflows.
  - Habits Mode: Title text field, `M-T-W-T-F-S-S` weekday selector circles, and Emerald save button.
  - Reminders Mode: Title text field, Pin toggle, and one-tap Quick Time Chips (*+1 Hour*, *Tonight 8 PM*, *Tomorrow 9 AM*, *Custom*) for 3-second task creation.
- **Comprehensive Test Suite**: 28 passing unit and widget tests covering models, persistence, glass components, and responsive grid layouts.

### Changed
- Migrated data storage to an offline-first, schema-lock-free `StorageService` using `shared_preferences` with JSON serialization.
- Overhauled application theme to pure dark obsidian glass with `GoogleFonts.outfit` display typography.
- Enhanced CI/CD GitHub Actions workflow with strict `flutter analyze` verification gate and automated release APK compilation.

### Removed
- Removed legacy Drift database, build_runner, and SQLite code generation dependencies.
- Removed default Material AppBars, BottomNavigationBars, Cards, elevation shadows, and onboarding screens.
- Removed legacy experimental GLSL grain shader in favor of the GPU-accelerated `AmbientGlassScaffold`.

---

## [0.2.0] - 2026-10-29

### Added
- Minimal mode header displaying active mode with animated crossfade transitions.
- Sub-header frosted-glass pill toggle directly below header.
- Dual color palettes:
  - *Habits*: Terracotta (`#B98258`), Sage (`#8FB9B2`), and Cream (`#E7DFD0`).
  - *Reminders*: Apricot (`#E9B17F`), Coral (`#DB7870`), and Celadon (`#D7E1D4`).
- Custom GLSL particle fragment shader (`shaders/grain.frag`) for animated film-grain texture.
- Initial glassmorphic containers and cards with backdrop blur.

### Fixed
- Test runner stabilization with `enableAnimation` flags to prevent infinite ticker loops during widget tests.
- Guarded `FragmentProgram` asset compilation in headless CI test runners.

---

## [0.1.0] - 2026-10-28

### Added
- Initial project scaffolding for Hado offline habit and reminder manager.
- Habit tracking with streak calculations (current streak, longest streak).
- Time-based reminder scheduling with system alerts via `flutter_local_notifications`.
- Local persistence using Drift and SQLite.
- Automated GitHub Actions build workflow for release Android APK compilation.
