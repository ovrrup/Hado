# Glassmorphic Visual Redesign & Granular Shader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Completely redesign Hado from scratch with an optical glassmorphism aesthetic, dual mode color palettes, custom GLSL granular particle shader, clean mode-only header, and oversized high-visibility UI components.

**Architecture:** An animated canvas background (`GrainShaderBackground`) continuously feeds resolution, time, and mode palette colors (`#b98258`/`#8fb9b2`/`#e7dfd0` for Habits vs `#e9b17f`/`#db7870`/`#d7e1d4` for Reminders) to a GLSL fragment shader. UI elements sit atop this canvas using reusable frosted `GlassContainer` widgets powered by `BackdropFilter` blurs. The top of the screen features a minimal mode header showing solely `"Habits"` or `"Reminders"`, followed by a sub-header toggle pill.

**Tech Stack:** Flutter 3.x, Dart 3.x, GLSL Fragment Shader (`shaders/grain.frag`), `google_fonts` (Outfit / Plus Jakarta Sans), Drift SQLite database, `flutter_local_notifications`.

**Spec:** [`docs/superpowers/specs/2026-10-28-glassmorphic-visual-redesign.md`](file:///data/data/com.termux/files/home/Hado/docs/superpowers/specs/2026-10-28-glassmorphic-visual-redesign.md)

## Global Constraints

- **Platform:** Flutter for Android (minSdkVersion 21, targetSdkVersion 34+).
- **100% Offline:** Local Drift SQLite storage; bundled or fallback font handling.
- **Color Palettes:**
  - Habits Mode: `#b98258`, `#8fb9b2`, `#e7dfd0`.
  - Reminders Mode: `#e9b17f`, `#db7870`, `#d7e1d4`.
- **Header:** Shows exclusively the active mode name ("Habits" or "Reminders") and nothing else.
- **Shader:** GLSL fragment shader configured in `pubspec.yaml` under `flutter: shaders:`.
- **Target Release:** v0.2.0 (Glassmorphic Beta).

## Review Focus

1. **Shader initialization failure fallback:** Older Android devices or test runners without GPU fragment shader support must gracefully degrade to a procedural gradient canvas rather than throwing unhandled exceptions.
2. **BackdropFilter performance:** `BackdropFilter` inside scrolling `ListView`s must use bounded `ClipRRect` and reasonable blur sigmas (12-16) to avoid dropping below 60fps.
3. **Palette morphing smoothness:** Flipping the sub-header toggle must smoothly animate both the background gradient colors and the accent glows over ~350ms.
4. **Keyboard inset visibility on glass modals:** High-blur bottom sheets must account for `viewInsets.bottom` so text fields remain visible and scrollable when the software keyboard opens.
5. **High-contrast readability on glass:** White or dark text on frosted translucent cards must maintain a minimum 4.5:1 WCAG contrast ratio against the textured background.

---

### Task 1: Asset Pipeline, GLSL Granular Particle Shader & Background Canvas

**Files:**
- Create: `shaders/grain.frag`
- Create: `lib/presentation/widgets/grain_shader_background.dart`
- Modify: `pubspec.yaml`
- Test: `test/shader_background_test.dart`

**Interfaces:**
- Produces:
  - `GrainShaderBackground(isHabitMode: bool, child: Widget)`
  - GLSL fragment program registered in `pubspec.yaml`.

- [ ] **Step 1: Create GLSL fragment shader in `shaders/grain.frag`**
  Implement high-frequency pseudo-random noise shader with uniform inputs (`uResolution`, `uTime`, `uColorA`, `uColorB`, `uColorC`, `uIntensity`).

- [ ] **Step 2: Update `pubspec.yaml` to register shaders**
  Add `shaders/grain.frag` under `flutter: shaders:`. Add `google_fonts: ^6.2.1`.

- [ ] **Step 3: Implement `GrainShaderBackground` widget with fallback**
  Create widget that loads `FragmentProgram.fromAsset('shaders/grain.frag')` and renders an animated mesh gradient canvas with particle noise; falls back to `CustomPainter` if shader loading fails.

- [ ] **Step 4: Write widget test for background**
  Create `test/shader_background_test.dart` to verify `GrainShaderBackground` renders child content without throwing.

- [ ] **Step 5: Commit shader and background canvas**
  `git add shaders/ lib/presentation/widgets/grain_shader_background.dart pubspec.yaml test/shader_background_test.dart && git commit -m "feat(graphics): implement glsl granular particle shader and dynamic background canvas"`

---

### Task 2: Palette System, Curated Typography & Glass Theme Tokens

**Files:**
- Modify: `lib/core/theme.dart`
- Test: `test/theme_test.dart`

**Interfaces:**
- Produces:
  - `HadoPalettes`: Mode-specific hex colors (`#b98258`, `#8fb9b2`, `#e7dfd0` vs `#e9b17f`, `#db7870`, `#d7e1d4`).
  - `AppTheme.getTheme(bool isHabitsMode)`: Dynamic ThemeData with Outfit typography and glass styling.

- [ ] **Step 1: Update `lib/core/theme.dart` with palettes and modern typography**
  Define color tokens, gradient pairs, glass border gradients, and GoogleFonts `Outfit` font styles.

- [ ] **Step 2: Write theme test**
  Verify color tokens match spec hex codes and contrast requirements.

- [ ] **Step 3: Commit theme updates**
  `git add lib/core/theme.dart test/theme_test.dart && git commit -m "feat(theme): configure dual mode color palettes and outfit typography"`

---

### Task 3: Reusable Glass Components (`GlassContainer`, `GlassCard`, `GlassSwitch`)

**Files:**
- Create: `lib/presentation/widgets/glass_container.dart`
- Modify: `lib/presentation/widgets/master_switch.dart` -> `lib/presentation/widgets/glass_switch.dart`
- Test: `test/glass_components_test.dart`

**Interfaces:**
- Produces:
  - `GlassContainer(blur, opacity, borderRadius, borderGradient, child)`
  - `GlassSwitch(selectedTab, onTabChanged, isHabitsMode)`

- [ ] **Step 1: Implement `GlassContainer`**
  Build frosted container with `ClipRRect`, `BackdropFilter(filter: ImageFilter.blur(...))`, translucent background fill, and dual-stop gradient border.

- [ ] **Step 2: Build `GlassSwitch`**
  Oversized pill toggle (height 54px, generous padding) with animated frosted pill indicator and haptic feedback.

- [ ] **Step 3: Write component tests**
  Verify `GlassContainer` and `GlassSwitch` tap handling and rendering.

- [ ] **Step 4: Commit glass components**
  `git add lib/presentation/widgets/ test/glass_components_test.dart && git commit -m "feat(ui): implement reusable glassmorphic container and glass switch"`

---

### Task 4: Minimal Mode Header & Immersive Home Shell

**Files:**
- Modify: `lib/presentation/home_screen.dart`
- Modify: `lib/main.dart`
- Test: `test/home_screen_test.dart`

**Interfaces:**
- Produces:
  - Modern edge-to-edge `HomeScreen` without standard `AppBar`.
  - Minimal animated mode header ("Habits" / "Reminders" in 34pt bold display text).
  - Floating `GlassSwitch` below header.
  - Floating oversized glass action button.

- [ ] **Step 1: Rewrite `HomeScreen` layout**
  Replace standard Scaffold AppBar with a clean `SafeArea` column hosting:
  1. 34pt bold mode title with `AnimatedSwitcher`.
  2. `GlassSwitch` centered directly beneath it.
  3. Body wrapped in `GrainShaderBackground`.
  4. Oversized glass FAB.

- [ ] **Step 2: Update `lib/main.dart`**
  Configure transparent system status bars and navigation bars for full edge-to-edge display.

- [ ] **Step 3: Commit home shell**
  `git add lib/presentation/home_screen.dart lib/main.dart test/home_screen_test.dart && git commit -m "feat(ui): redesign home screen with minimal mode header and edge-to-edge glass shell"`

---

### Task 5: Redesigned Habits View & Oversized Glass Habit Cards

**Files:**
- Modify: `lib/presentation/views/habits_view.dart`
- Modify: `lib/presentation/widgets/habit_card.dart`
- Modify: `lib/presentation/dialogs/create_habit_sheet.dart`

**Interfaces:**
- Produces:
  - High-visibility `HabitCard` with frosted glass backdrop, large typography, flame streak badge, and 52px circular completion button.
  - Glassmorphic `CreateHabitSheet` modal bottom sheet using Habits palette (`#b98258`, `#8fb9b2`, `#e7dfd0`).

- [ ] **Step 1: Redesign `HabitCard` into a glass card**
  Wrap in `GlassContainer`, enlarge title to 18pt bold, enlarge completion button to 52px with tactile scale animation.

- [ ] **Step 2: Redesign `CreateHabitSheet`**
  Convert modal bottom sheet into a frosted glass sheet with modern rounded text inputs and Habits color chips.

- [ ] **Step 3: Update `HabitsView` empty and loaded states**
  Use larger typography and translucent empty-state illustration.

- [ ] **Step 4: Commit redesigned habits view**
  `git add lib/presentation/views/habits_view.dart lib/presentation/widgets/habit_card.dart lib/presentation/dialogs/create_habit_sheet.dart && git commit -m "feat(habits): redesign habits view and habit card with glassmorphism"`

---

### Task 6: Redesigned Reminders View & Oversized Glass Reminder Cards

**Files:**
- Modify: `lib/presentation/views/reminders_view.dart`
- Modify: `lib/presentation/widgets/reminder_card.dart`
- Modify: `lib/presentation/dialogs/create_reminder_sheet.dart`

**Interfaces:**
- Produces:
  - High-visibility `ReminderCard` with glass styling, custom check indicator, formatted time badge, and strike-through animation.
  - Glassmorphic `CreateReminderSheet` using Reminders palette (`#e9b17f`, `#db7870`, `#d7e1d4`).

- [x] **Step 1: Redesign `ReminderCard` into a glass card**
  Enlarge card dimensions, use frosted glass background, add relative time chip with Reminders palette accents.

- [x] **Step 2: Redesign `CreateReminderSheet`**
  Convert to frosted glass sheet with large date/time picker buttons.

- [x] **Step 3: Update `RemindersView` section headers**
  Render section headers with Reminders palette colors (`#db7870`, `#e9b17f`).

- [x] **Step 4: Commit redesigned reminders view**
  `git add lib/presentation/views/reminders_view.dart lib/presentation/widgets/reminder_card.dart lib/presentation/dialogs/create_reminder_sheet.dart && git commit -m "feat(reminders): redesign reminders view and reminder card with glassmorphism"`

---

### Task 7: Version Bump (v0.2.0), Tag & CI/CD APK Compilation Verification

**Files:**
- Modify: `pubspec.yaml` (bump to `0.2.0+2`)
- Modify: `README.md`

**Interfaces:**
- Produces: GitHub Release `v0.2.0` with new compiled APK.

- [x] **Step 1: Bump version in `pubspec.yaml` to `0.2.0+2`**
  Update version and build number.

- [x] **Step 2: Update `README.md`**
  Highlight the new glassmorphic UI, custom GLSL shader, and dual color palettes.

- [ ] **Step 3: Commit and tag `v0.2.0`**
  Tag `v0.2.0`, push to GitHub `main` and tags.

- [ ] **Step 4: Verify CI/CD workflow and release publication**
  Monitor GitHub Actions to verify automated APK compilation and release asset publishing.
