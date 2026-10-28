import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';

class GlassToast {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.snooze_rounded,
    Color glowColor = AppColors.warmAmber,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _GlassToastWidget(
        message: message,
        icon: icon,
        glowColor: glowColor,
        onDismissed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _GlassToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onDismissed;

  const _GlassToastWidget({
    required this.message,
    required this.icon,
    required this.glowColor,
    required this.onDismissed,
  });

  @override
  State<_GlassToastWidget> createState() => _GlassToastWidgetState();
}

class _GlassToastWidgetState extends State<_GlassToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    unawaited(_controller.forward());

    unawaited(Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismissed();
          }
        });
      }
    }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 96,
      left: 20,
      right: 20,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: GlassSurface(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                customBorder: Border.all(
                  color: widget.glowColor.withOpacity(0.5),
                  width: 1.0,
                ),
                surfaceColor: Colors.black.withOpacity(0.4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.glowColor,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
