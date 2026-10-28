import 'dart:async';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/ambient_glass_scaffold.dart';
import '../widgets/glass_bottom_sheet.dart';
import '../widgets/glass_nav_bar.dart';
import 'habits_view.dart';
import 'reminders_view.dart';

/// The central workspace opening straight into Habits and Reminders modes
/// with zero default Material AppBars, bottom nav bars, or elevation shadows.
class HomeWorkspaceScreen extends StatefulWidget {
  final AppState appState;
  final bool enableScaffoldAnimation;

  const HomeWorkspaceScreen({
    super.key,
    required this.appState,
    this.enableScaffoldAnimation = true,
  });

  @override
  State<HomeWorkspaceScreen> createState() => _HomeWorkspaceScreenState();
}

class _HomeWorkspaceScreenState extends State<HomeWorkspaceScreen> {
  late final PageController _pageController;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    if (_pageController.hasClients) {
      final page = _pageController.page ?? 0.0;
      if (page != _pageOffset) {
        setState(() {
          _pageOffset = page;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _openCreationSheet() {
    final activeIndex = (_pageController.hasClients ? (_pageController.page ?? 0.0).round() : 0);
    final isHabits = activeIndex == 0;

    unawaited(
      GlassBottomSheet.show(
        context: context,
        isHabitsMode: isHabits,
        onSaveHabit: (title, targetDays) {
          unawaited(
            widget.appState.addHabit(
              title: title,
              targetDays: targetDays,
            ),
          );
        },
        onSaveReminder: (title, dueDateTime, isPinned) {
          unawaited(
            widget.appState.addReminder(
              title: title,
              dueDateTime: dueDateTime,
              isPinned: isPinned,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return AmbientGlassScaffold(
          modeOffset: _pageOffset,
          enableAnimation: widget.enableScaffoldAnimation,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-screen horizontal PageView
              SafeArea(
                bottom: false,
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    HabitsView(appState: widget.appState),
                    RemindersView(appState: widget.appState),
                  ],
                ),
              ),

              // Bottom-centered Floating Glass Segmented Pill paired with circular Glass + FAB
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: GlassNavBar(
                    pageOffset: _pageOffset,
                    onTabSelected: (index) {
                      unawaited(
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                        ),
                      );
                    },
                    onFabTap: _openCreationSheet,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
