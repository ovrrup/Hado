import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GrainShaderBackground extends StatefulWidget {
  final bool isHabitMode;
  final Widget child;
  final bool enableAnimation;

  const GrainShaderBackground({
    super.key,
    required this.isHabitMode,
    required this.child,
    this.enableAnimation = true,
  });

  @override
  State<GrainShaderBackground> createState() => _GrainShaderBackgroundState();
}

class _GrainShaderBackgroundState extends State<GrainShaderBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.FragmentShader? _shader;
  bool _shaderLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.enableAnimation) {
      _controller.repeat();
      _loadShader();
    } else {
      _shaderLoadFailed = true;
    }
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/grain.frag');
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _shaderLoadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mode-specific color palette targets
    final targetColorA = widget.isHabitMode
        ? HadoPalettes.habitTerracotta
        : HadoPalettes.reminderCoral;
    final targetColorB = widget.isHabitMode
        ? HadoPalettes.habitSage
        : HadoPalettes.reminderApricot;
    final targetColorC = widget.isHabitMode
        ? HadoPalettes.habitCream
        : HadoPalettes.reminderCeladon;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background animated grain or procedural gradient
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_shader != null && !_shaderLoadFailed) {
              return CustomPaint(
                painter: _ShaderPainter(
                  shader: _shader!,
                  time: _controller.value * 2 * math.pi,
                  colorA: targetColorA,
                  colorB: targetColorB,
                  colorC: targetColorC,
                ),
              );
            }
            return _FallbackBackground(
              colorA: targetColorA,
              colorB: targetColorB,
              colorC: targetColorC,
              time: _controller.value,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final Color colorA;
  final Color colorB;
  final Color colorC;

  _ShaderPainter({
    required this.shader,
    required this.time,
    required this.colorA,
    required this.colorB,
    required this.colorC,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, 0.075); // intensity

    // colorA (RGB)
    shader.setFloat(4, colorA.red / 255.0);
    shader.setFloat(5, colorA.green / 255.0);
    shader.setFloat(6, colorA.blue / 255.0);

    // colorB (RGB)
    shader.setFloat(7, colorB.red / 255.0);
    shader.setFloat(8, colorB.green / 255.0);
    shader.setFloat(9, colorB.blue / 255.0);

    // colorC (RGB)
    shader.setFloat(10, colorC.red / 255.0);
    shader.setFloat(11, colorC.green / 255.0);
    shader.setFloat(12, colorC.blue / 255.0);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => true;
}

class _FallbackBackground extends StatelessWidget {
  final Color colorA;
  final Color colorB;
  final Color colorC;
  final double time;

  const _FallbackBackground({
    required this.colorA,
    required this.colorB,
    required this.colorC,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorC.withOpacity(0.95),
            colorB.withOpacity(0.65),
            colorA.withOpacity(0.85),
          ],
        ),
      ),
    );
  }
}
