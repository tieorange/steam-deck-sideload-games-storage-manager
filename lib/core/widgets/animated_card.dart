import 'package:flutter/material.dart';

/// A reusable widget that provides a staggered fade-in and slide-up animation.
///
/// Used for cards using [AnimationController] to orchestrate the entrance.
class AnimatedCard extends StatelessWidget {
  const AnimatedCard({
    required this.controller,
    required this.delay,
    required this.child,
    this.slideOffset = const Offset(0, 0.1),
    super.key,
  });

  /// The animation controller driving the animation.
  final AnimationController controller;

  /// The delay in seconds (normalized 0.0 to 1.0 relative to controller duration)
  /// before this specific card starts animating.
  final double delay;

  /// The child widget to animate.
  final Widget child;

  /// The initial offset for the slide animation. Defaults to a slight upward slide.
  final Offset slideOffset;

  @override
  Widget build(BuildContext context) {
    // Ensure the interval doesn't go out of bounds (0.0 to 1.0)
    final start = delay.clamp(0.0, 1.0);
    final end = (delay + 0.4).clamp(0.0, 1.0);

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      ),
    );
  }
}
