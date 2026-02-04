import 'package:flutter/material.dart';

/// A shimmer skeleton loading widget for placeholder content
class SkeletonLoading extends StatefulWidget {
  const SkeletonLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade200;
    final highlightColor = isDark ? const Color(0xFF3A3A50) : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a game list item
class GameListItemSkeleton extends StatelessWidget {
  const GameListItemSkeleton({super.key, this.index = 0});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const SkeletonLoading(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(width: 120.0 + (index % 3) * 40, height: 16),
                const SizedBox(height: 8),
                SkeletonLoading(width: 80.0 + (index % 2) * 30, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SkeletonLoading(width: 60, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for the games page loading state
class GamesPageSkeleton extends StatelessWidget {
  const GamesPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SkeletonLoading(width: 60.0 + i * 10, height: 32, borderRadius: 16),
            )),
          ),
        ),
        // Stats bar skeleton
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoading(width: 100, height: 14),
              SkeletonLoading(width: 80, height: 14),
            ],
          ),
        ),
        const Divider(),
        // Game list items skeleton
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) => GameListItemSkeleton(index: index),
          ),
        ),
      ],
    );
  }
}

/// Skeleton for a dashboard card
class DashboardCardSkeleton extends StatelessWidget {
  const DashboardCardSkeleton({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoading(width: 140, height: 18),
            const SizedBox(height: 12),
            SkeletonLoading(height: height - 62),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the storage page
class StoragePageSkeleton extends StatelessWidget {
  const StoragePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        DashboardCardSkeleton(height: 160),
        SizedBox(height: 12),
        DashboardCardSkeleton(height: 100),
        SizedBox(height: 12),
        DashboardCardSkeleton(height: 100),
      ],
    );
  }
}
