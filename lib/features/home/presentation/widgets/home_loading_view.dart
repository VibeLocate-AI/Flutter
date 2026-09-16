import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.darkSurfaceAlt
        : AppColors.grayBorderLight;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Row(
          children: [
            Expanded(
              child: _Skeleton(
                width: 180,
                height: 24,
                color: baseColor,
              ),
            ),
            _Skeleton(
              width: 48,
              height: 48,
              radius: 24,
              color: baseColor,
            ),
          ],
        ),

        const SizedBox(height: 22),

        _Skeleton(
          width: double.infinity,
          height: 56,
          radius: 18,
          color: baseColor,
        ),

        const SizedBox(height: 28),

        _Skeleton(
          width: 210,
          height: 24,
          color: baseColor,
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, _) {
              return _PropertySkeleton(
                color: baseColor,
              );
            },
          ),
        ),

        const SizedBox(height: 30),

        _Skeleton(
          width: 170,
          height: 24,
          color: baseColor,
        ),

        const SizedBox(height: 16),

        ...List.generate(
          3,
              (_) => Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: _NearbySkeleton(
              color: baseColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 10,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _PropertySkeleton extends StatelessWidget {
  const _PropertySkeleton({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            height: 165,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _Skeleton(
                  width: double.infinity,
                  height: 15,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 10),
                _Skeleton(
                  width: 150,
                  height: 12,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 20),
                _Skeleton(
                  width: 100,
                  height: 16,
                  color: color.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbySkeleton extends StatelessWidget {
  const _NearbySkeleton({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Skeleton(
            width: 90,
            height: double.infinity,
            radius: 13,
            color: color.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Skeleton(
                  width: 150,
                  height: 14,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 10),
                _Skeleton(
                  width: 100,
                  height: 11,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 10),
                _Skeleton(
                  width: 80,
                  height: 13,
                  color: color.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}