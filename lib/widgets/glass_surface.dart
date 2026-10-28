import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Authentic optical frosted glass container.
///
/// Implements the exact specifications:
/// - RepaintBoundary for optimized rendering isolation
/// - ClipRRect with borderRadius (default 20)
/// - BackdropFilter with ImageFilter.blur sigmaX 24, sigmaY 24
/// - AnimatedContainer with white opacity 0.06 (0.12 when pressed)
/// - 1px white border with 0.14 opacity
class GlassSurface extends StatefulWidget {
  final Widget? child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? surfaceColor;
  final Color? pressedSurfaceColor;
  final Border? customBorder;
  final AlignmentGeometry? alignment;

  const GlassSurface({
    super.key,
    this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.surfaceColor,
    this.pressedSurfaceColor,
    this.customBorder,
    this.alignment,
  });

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppColors.glassBorderRadius;
    final defaultSurface = _isPressed
        ? (widget.pressedSurfaceColor ?? AppColors.glassSurfacePressed)
        : (widget.surfaceColor ?? AppColors.glassSurface);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: defaultSurface,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: widget.customBorder ??
            Border.all(
              color: AppColors.glassBorder,
              width: AppColors.glassBorderWidth,
            ),
      ),
      child: widget.child,
    );

    Widget glass = RepaintBoundary(
      child: Container(
        margin: widget.margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppColors.glassBlurSigma,
              sigmaY: AppColors.glassBlurSigma,
            ),
            child: content,
          ),
        ),
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: glass,
      );
    }

    return glass;
  }
}
