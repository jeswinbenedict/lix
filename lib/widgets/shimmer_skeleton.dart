import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Animated shimmer effect widget for loading states.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
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
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                AppTheme.shimmerBase,
                AppTheme.shimmerHigh,
                AppTheme.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer skeleton for a movie card in a grid
class MovieCardSkeleton extends StatelessWidget {
  const MovieCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusMD),
              ),
              child: ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 14, borderRadius: 6),
                const SizedBox(height: 6),
                ShimmerBox(width: 80, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for a song tile in a list
class SongTileSkeleton extends StatelessWidget {
  const SongTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 60, height: 60, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 14, borderRadius: 6),
                const SizedBox(height: 6),
                ShimmerBox(width: 100, height: 12, borderRadius: 6),
              ],
            ),
          ),
          ShimmerBox(width: 32, height: 32, borderRadius: 16),
        ],
      ),
    );
  }
}

/// Builds a shimmer grid for movies
Widget buildMovieShimmerGrid() {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 220,
      mainAxisExtent: 290,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) => const MovieCardSkeleton(),
      childCount: 6,
    ),
  );
}

/// Builds a shimmer grid for songs
Widget buildSongShimmerGrid() {
  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 320,
      mainAxisExtent: 100,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) => const SongTileSkeleton(),
      childCount: 6,
    ),
  );
}
