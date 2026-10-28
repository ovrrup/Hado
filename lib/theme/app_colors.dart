import 'package:flutter/material.dart';

/// Design tokens for Hado's authentic dark glassmorphism system.
class AppColors {
  AppColors._();

  // Scaffold Base
  static const Color obsidianBase = Color(0xFF0B0F17);

  // Habits Mode (Emerald & Teal)
  static const Color emerald = Color(0xFF10B981);
  static const Color teal = Color(0xFF059669);
  static const Color deepTeal = Color(0xFF065F46);

  // Reminders Mode (Warm Amber & Coral)
  static const Color warmAmber = Color(0xFFF59E0B);
  static const Color coral = Color(0xFFEA580C);
  static const Color deepAmber = Color(0xFFB45309);

  // Glass Surface Constants
  static const double glassBlurSigma = 24.0;
  static const double glassBorderRadius = 20.0;
  static const double glassBorderWidth = 1.0;

  static final Color glassSurface = Colors.white.withOpacity(0.06);
  static final Color glassSurfacePressed = Colors.white.withOpacity(0.12);
  static final Color glassBorder = Colors.white.withOpacity(0.14);
  static final Color glassBorderHighlight = Colors.white.withOpacity(0.25);

  // Text & Content Hierarchy
  static const Color textPrimary = Colors.white;
  static final Color textSecondary = Colors.white.withOpacity(0.65);
  static final Color textTertiary = Colors.white.withOpacity(0.40);
  static final Color textDimmed = Colors.white.withOpacity(0.25);

  // Habit Dots
  static const Color habitDoneDot = Color(0xFF10B981);
  static final Color habitMissedDot = Colors.white.withOpacity(0.18);

  // Progress Bar Track
  static final Color progressTrack = Colors.white.withOpacity(0.08);
}
