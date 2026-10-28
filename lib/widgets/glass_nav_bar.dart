import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Floating glass segmented pill paired with an adjacent circular Glass + FAB.
///
/// The active thumb slides and cross-fades colors in real time with the [pageOffset]
/// (0.0 = Habits Mode in Emerald/Teal, 1.0 = Reminders Mode in Warm Amber/Coral).
class GlassNavBar extends StatelessWidget {
  final double pageOffset;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onFabTap;

  const GlassNavBar({
    super.key,
    required this.pageOffset,
    required this.onTabSelected,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedOffset = pageOffset.clamp(0.0, 1.0);

    // Active color interpolation
    final activeGlowColor = Color.lerp(
      AppColors.emerald,
      AppColors.warmAmber,
      clampedOffset,
    )!;

    const double pillWidth = 224.0;
    const double barHeight = 52.0;
    const double innerPadding = 4.0;
    const double thumbWidth = (pillWidth - (innerPadding * 2)) / 2;
    const double thumbHeight = barHeight - (innerPadding * 2);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Segmented Pill
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppColors.glassBlurSigma,
                    sigmaY: AppColors.glassBlurSigma,
                  ),
                  child: Container(
                    width: pillWidth,
                    height: barHeight,
                    padding: const EdgeInsets.all(innerPadding),
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: AppColors.glassBorderWidth,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Sliding thumb
                        Positioned(
                          left: clampedOffset * (pillWidth - (innerPadding * 2) - thumbWidth),
                          top: 0,
                          width: thumbWidth,
                          height: thumbHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeGlowColor.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: activeGlowColor.withOpacity(0.70),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeGlowColor.withOpacity(0.20),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tab touch targets and labels
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onTabSelected(0),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                        color: Color.lerp(
                                          Colors.white,
                                          Colors.white.withOpacity(0.55),
                                          clampedOffset,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Habits',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: Color.lerp(
                                            Colors.white,
                                            Colors.white.withOpacity(0.55),
                                            clampedOffset,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onTabSelected(1),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.alarm_rounded,
                                        size: 16,
                                        color: Color.lerp(
                                          Colors.white.withOpacity(0.55),
                                          Colors.white,
                                          clampedOffset,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Reminders',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: Color.lerp(
                                            Colors.white.withOpacity(0.55),
                                            Colors.white,
                                            clampedOffset,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Circular Glass + FAB
            RepaintBoundary(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onFabTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: AppColors.glassBlurSigma,
                      sigmaY: AppColors.glassBlurSigma,
                    ),
                    child: Container(
                      width: barHeight,
                      height: barHeight,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeGlowColor.withOpacity(0.22),
                        border: Border.all(
                          color: activeGlowColor.withOpacity(0.8),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activeGlowColor.withOpacity(0.25),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
