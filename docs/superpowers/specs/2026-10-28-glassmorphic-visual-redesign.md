# Design Document: Glassmorphic Visual Redesign & Granular Shader

## 1. Intent and The Why
Hado needs a complete visual reimagining to stand out from utilitarian to-do lists. By combining authentic optical glassmorphism (frosted blur), dynamic dual-palette transitions, scaled-up high-legibility UI elements, and a custom GLSL granular particle shader, the app transforms into a calming, tactile daily companion.

## 2. Goals, Non-Goals, and Anti-Goals

### Goals
- **Minimal Mode Header**: A prominent, bold header displaying exclusively the active mode ("Habits" or "Reminders") with zero clutter or unnecessary icons.
- **Dedicated Sub-Header Toggle**: Positioned directly beneath the mode header, allowing immediate switching with haptic feedback.
- **Dual Dynamic Color Palettes**:
  - *Habits Mode*: Earthy Terracotta (`#b98258`), Soft Sage (`#8fb9b2`), and Warm Cream (`#e7dfd0`).
  - *Reminders Mode*: Warm Apricot (`#e9b17f`), Muted Coral (`#db7870`), and Celadon (`#d7e1d4`).
- **Granular Particle Shader**: A custom GLSL fragment shader (`shaders/grain.frag`) running on the GPU that generates an organic, animated film-grain texture over the background mesh.
- **True Optical Glassmorphism**: High-performance frosted glass containers (`GlassCard`, `GlassSheet`) utilizing `BackdropFilter`, dual-stop translucent gradient fills, and subtle highlight borders.
- **Enlarged High-Visibility UI**: Bigger typography, generous padding, minimum 56px touch targets, and high contrast for effortless navigation.
- **Curated Modern Typography**: Distinctive geometric/contemporary typography (using `google_fonts` Outfit or clean modern sans) that balances the softness of the glass.

### Non-Goals
- Time-of-day filters or tag filtering (explicitly excluded based on user feedback).
- Recurring reminders or priority flags (deferred to future feature iterations).
- Cloud sync or online dependencies.

### Anti-Goals
- Faux glass without optical blur (flat translucent rectangles with drop shadows).
- Resource-heavy, unoptimized shaders that drop frame rates on mobile GPUs.
- Cluttered header bars crowded with title, search, actions, and settings.

## 3. Constraints
- **Platform**: Flutter for Android, 100% offline.
- **Shader Pipeline**: Flutter 3.7+ shader compiler (`flutter: shaders: [shaders/grain.frag]`) supported by both Impeller and Skia.
- **Continuous CI/CD**: Must compile release APK cleanly on GitHub Actions `ubuntu-latest`.

## 4. Approaches Considered

### Approach 1: Hardware-Accelerated GLSL Shader & Optical Glass Compositor — **SELECTED**
- Custom GLSL fragment shader (`shaders/grain.frag`) coupled with `BackdropFilter` blur matrices (`sigma: 12-16`) and animated palette mesh.
- *Why chosen*: Delivers genuine optical refraction, tactile granular depth, and fluid 60fps animations as requested.

### Approach 2: Procedural Canvas Painter & Layered Translucency
- Fake glass using simple opacity overlays and custom painted dot grids.
- *Why rejected*: Lacks authentic frosted glass depth and looks flat.

## 5. System Architecture & UI Specifications

### 5.1 Palette & Theme Tokens
```dart
class HadoPalettes {
  // Habits Palette
  static const habitTerracotta = Color(0xFFB98258);
  static const habitSage = Color(0xFF8FB9B2);
  static const habitCream = Color(0xFFE7DFD0);

  // Reminders Palette
  static const reminderApricot = Color(0xFFE9B17F);
  static const reminderCoral = Color(0xFFDB7870);
  static const reminderCeladon = Color(0xFFD7E1D4);
}
```

### 5.2 Granular Shader (`shaders/grain.frag`)
- Inputs: `uniform vec2 uResolution`, `uniform float uTime`, `uniform float uIntensity`, `uniform vec3 uColorA`, `uniform vec3 uColorB`.
- Generates high-frequency pseudo-random white/simplex noise blended softly into the underlying gradient background to provide tactile depth beneath glass cards.

### 5.3 Presentation Structure
1. **Background**: `GrainShaderBackground` wrapping the scaffold, continuously interpolating between the two palette gradients.
2. **Top Header**:
   - `SafeArea` with prominent text: animated transition between `"Habits"` and `"Reminders"` in 34pt bold display typography.
3. **Sub-Header Toggle (`GlassSwitch`)**:
   - Floating frosted glass pill toggle centered right below the mode title.
4. **Content Area**:
   - `HabitsView` and `RemindersView` rendering oversized `GlassCard` items with 16px blur, 18pt titles, and large interactive action circles.
5. **Creation Modals**:
   - Full glassmorphic bottom sheets with frosted backdrop and rounded inputs.

## 6. What's Left to the Builder
- Precise noise speed and intensity tuning in the GLSL shader for optimal subtlety.
- Fine-tuning border gradient opacity (e.g. 0.3 highlight top-left to 0.05 bottom-right).
- Fallback painter in the event a device GPU driver blocks fragment shader initialization.
