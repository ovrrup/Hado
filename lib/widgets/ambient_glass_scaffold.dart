import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ambient scaffold featuring a deep obsidian base (#0B0F17) and 2 to 3 slowly
/// drifting blurred radial gradient orbs on a 10-second loop that smoothly
/// interpolate colors between Habits Mode (Emerald/Teal) and Reminders Mode (Warm Amber/Coral).
class AmbientGlassScaffold extends StatefulWidget {
  final Widget child;
  final double modeOffset; // 0.0 = Habits, 1.0 = Reminders
  final bool enableAnimation;

  const AmbientGlassScaffold({
    super.key,
    required this.child,
    this.modeOffset = 0.0,
    this.enableAnimation = true,
  });

  @override
  State<AmbientGlassScaffold> createState() => _AmbientGlassScaffoldState();
}

class _AmbientGlassScaffoldState extends State<AmbientGlassScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.enableAnimation) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AmbientGlassScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAnimation != oldWidget.enableAnimation) {
      if (widget.enableAnimation) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Interpolate orb colors based on modeOffset
    final clampedOffset = widget.modeOffset.clamp(0.0, 1.0);

    final color1 = Color.lerp(
      AppColors.emerald,
      AppColors.warmAmber,
      clampedOffset,
    )!;

    final color2 = Color.lerp(
      AppColors.teal,
      AppColors.coral,
      clampedOffset,
    )!;

    final color3 = Color.lerp(
      const Color(0xFF0D9488),
      const Color(0xFFD97706),
      clampedOffset,
    )!;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base obsidian canvas
          const ColoredBox(color: AppColors.obsidianBase),

          // Animated blurred drifting orbs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _AmbientOrbsPainter(
                  progress: widget.enableAnimation ? _controller.value : 0.0,
                  color1: color1,
                  color2: color2,
                  color3: color3,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Primary application view layer
          widget.child,
        ],
      ),
    );
  }
}

class _AmbientOrbsPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color1;
  final Color color2;
  final Color color3;

  _AmbientOrbsPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    // Orb 1: Upper-left drifting towards center
    final x1 = size.width * 0.22 + 60 * math.sin(t);
    final y1 = size.height * 0.24 + 45 * math.cos(t);
    final r1 = size.width * 0.48;

    final paint1 = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x1, y1),
        r1,
        [color1.withOpacity(0.34), color1.withOpacity(0.0)],
        [0.0, 1.0],
      );
    canvas.drawCircle(Offset(x1, y1), r1, paint1);

    // Orb 2: Lower-right drifting towards mid-right
    final x2 = size.width * 0.78 + 50 * math.cos(t);
    final y2 = size.height * 0.68 + 65 * math.sin(t);
    final r2 = size.width * 0.52;

    final paint2 = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x2, y2),
        r2,
        [color2.withOpacity(0.28), color2.withOpacity(0.0)],
        [0.0, 1.0],
      );
    canvas.drawCircle(Offset(x2, y2), r2, paint2);

    // Orb 3: Lower-left / bottom-center ambient glow
    final x3 = size.width * 0.32 + 45 * math.sin(t + math.pi);
    final y3 = size.height * 0.86 + 40 * math.cos(t + math.pi);
    final r3 = size.width * 0.44;

    final paint3 = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x3, y3),
        r3,
        [color3.withOpacity(0.22), color3.withOpacity(0.0)],
        [0.0, 1.0],
      );
    canvas.drawCircle(Offset(x3, y3), r3, paint3);
  }

  @override
  bool shouldRepaint(covariant _AmbientOrbsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.color3 != color3;
  }
}
