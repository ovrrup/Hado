# Hado ⚡

> **A private, offline-first Habit Tracker and Reminders app with true glassmorphism, responsive layout, and smooth micro-interactions.**

Hado seamlessly unites recurring daily routines (Habits) and time-sensitive to-dos (Reminders) under an authentic dark glassmorphic workspace. Built 100% offline-first with zero tracking, zero cloud dependencies, and zero lag.

---

## 🎨 Visual Engine & Glassmorphism (v0.3.0)

- **`AmbientGlassScaffold`**: Deep obsidian base (`#0B0F17`) paired with 2 to 3 slowly drifting blurred radial gradient orbs on a 10-second loop. The ambient orbs dynamically cross-fade and interpolate their colors in real time based on active mode:
  - **Habits Mode**: Emerald (`#10B981`) & Teal (`#059669`).
  - **Reminders Mode**: Warm Amber (`#F59E0B`) & Coral (`#EA580C`).
- **`GlassSurface` Component**: Hardware-accelerated frosted glass container utilizing:
  - `RepaintBoundary` for rendering isolation
  - `ClipRRect` (borderRadius: 20px)
  - `BackdropFilter` (optical blur `sigmaX: 24`, `sigmaY: 24`)
  - `AnimatedContainer` with white opacity `0.06` (`0.12` when pressed)
  - 1px white highlight border with `0.14` opacity.
- **Zero Material Clutter**: Stripped out all default Material AppBars, BottomNavigationBars, Cards, elevation shadows, and onboarding flows. The app opens directly into your workspace.

---

## 🧭 Navigation & Responsive Layout

- **Horizontal `PageView`**: Full-screen swipeable workspace linking Habits (Page 0) and Reminders (Page 1).
- **Floating Glass Segmented Pill**: Positioned bottom-center, featuring an active sliding glass thumb that tracks `PageController` offset and cross-fades theme colors in real time.
- **Adjacent Circular Glass `+` FAB**: Seamless creation trigger adapting its glow to the active mode.
- **Adaptive Screen Responsiveness**: Wrapped in a responsive `LayoutBuilder`:
  - **Under 600px width**: Single-column vertical list with native `BouncingScrollPhysics`.
  - **600px width and wider**: Centered 2-to-3 column responsive grid (max-width capped at 1000px).

---

## 🌟 Key Features

### 🌿 Habits Mode
- **Minimal Date Header**: Prominent date label and real-time completion percentage.
- **Animated Glass Progress Bar**: Smoothly animates width and emerald glow as habits are completed.
- **Active vs Completed Sections**: Active habits appear at the top; completed habits smoothly transition to a dimmed bottom section.
- **`HabitGlassCard`**:
  - Displays title and schedule subtitle (*Daily*, *Weekdays*, *Weekends*, or specific days).
  - **Inline 7-Day Micro-History**: Row of 7 small 8px dots (Emerald filled for done, translucent white for missed).
  - **0.97 Scale Spring Animation**: Tapping the card triggers `HapticFeedback.lightImpact()` and springs down to 0.97 scale.
  - **Glass Action Menu**: Long-pressing opens frosted options to *Edit*, *Skip Today*, or *Delete*.

### ⏰ Reminders Mode
- **Smart Timeline Categorization**: Clean uppercase headers grouping items by **PINNED**, **TODAY**, **UPCOMING**, and **COMPLETED**.
- **`ReminderGlassCard`**:
  - Displays title with strikethrough when completed.
  - **Due Time Pill**: Highlighted Warm Amber if due today or overdue.
  - **Pin Icon**: Distinct amber indicator for high-priority tasks.
- **Gestures & Micro-Interactions**:
  - **Tap**: Toggle completion with haptic feedback.
  - **Swipe-Right**: Mark completed via `Dismissible`.
  - **Swipe-Left**: Snooze +1 hour and display an authentic floating **`GlassToast`**.
  - **Long-Press**: Open frosted glass menu for *Pin/Unpin*, *Edit*, or *Delete*.

### ⚡ Unified `GlassBottomSheet`
- Opens via the circular `+` button with transparent backdrop and keyboard inset padding.
- **In Habits Mode**: Title input, `M-T-W-T-F-S-S` weekday selector circles, and Emerald Save button.
- **In Reminders Mode**: Title input, Pin toggle, and one-tap **Quick Time Chips** (*+1 Hour*, *Tonight 8 PM*, *Tomorrow 9 AM*, *Custom*) for 3-second task creation.

---

## 🛠️ Architecture & Clean Code Structure

```
lib/
├── main.dart                      # Workspace entrypoint & system UI styling
├── theme/
│   ├── app_colors.dart            # Obsidian, Emerald, Amber tokens & glass specs
│   └── app_theme.dart             # Dark theme definition (Outfit typography)
├── models/
│   ├── habit.dart                 # Habit model, 7-day micro-history, JSON serialization
│   └── reminder.dart              # Reminder model, overdue/today helpers, JSON serialization
├── services/
│   └── notification_service.dart  # Offline system alerts via flutter_local_notifications
├── state/
│   ├── storage_service.dart       # Private local persistence via shared_preferences
│   └── app_state.dart             # Reactive state management with ChangeNotifier
├── widgets/
│   ├── ambient_glass_scaffold.dart# Deep obsidian background with drifting gradient orbs
│   ├── glass_surface.dart         # Reusable optical glass widget (sigma 24, 0.06/0.12 opacity)
│   ├── glass_nav_bar.dart         # Bottom floating segmented pill + Glass FAB
│   ├── glass_bottom_sheet.dart    # Unified creation & editing sheet
│   ├── glass_toast.dart           # Floating glass snooze notification
│   ├── habit_glass_card.dart      # Habit card with micro-history dots & scale spring
│   └── reminder_glass_card.dart   # Reminder card with due pill & swipe gestures
└── screens/
    ├── home_workspace_screen.dart # Main workspace with PageView & state listening
    ├── habits_view.dart           # Responsive Habits workspace & progress bar
    └── reminders_view.dart        # Responsive Reminders workspace & grouped headers
```

---

## 🚀 Building & Testing

- **Static Analysis**:
  ```bash
  flutter analyze
  ```
  Verified: **0 errors, 0 warnings**.
- **Unit & Widget Tests**:
  ```bash
  flutter test
  ```
  Verified: **28 unit, widget, and layout tests passing**.
- **Build Release APK**:
  ```bash
  flutter build apk --release
  ```
