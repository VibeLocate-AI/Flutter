import 'package:flutter/material.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final horizontal =
    width >= 600 ? 28.0 : 20.0;

    final cardWidth = width >= 600
        ? 350.0
        : (width * 0.78).clamp(270.0, 315.0);

    final cardHeight =
    (cardWidth * 1.16).clamp(315.0, 390.0);

    final baseColor = theme.brightness ==
        Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.outlineVariant
        .withValues(alpha: 0.45);

    return ListView(
      physics:
      const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontal,
        20,
        horizontal,
        40,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _Skeleton(
                height: 22,
                color: baseColor,
              ),
            ),
            const SizedBox(width: 14),
            _Skeleton(
              width: 46,
              height: 46,
              radius: 14,
              color: baseColor,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Skeleton(
          height: 58,
          radius: 18,
          color: baseColor,
        ),
        const SizedBox(height: 22),
        _Skeleton(
          width: 230,
          height: 22,
          color: baseColor,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, _) {
              return const SizedBox(width: 14);
            },
            itemBuilder: (_, _) {
              return Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius:
                  BorderRadius.circular(24),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        _Skeleton(
          width: 190,
          height: 22,
          color: baseColor,
        ),
        const SizedBox(height: 14),
        ...List.generate(
          3,
              (_) => Padding(
            padding:
            const EdgeInsets.only(bottom: 12),
            child: _Skeleton(
              height: 108,
              radius: 18,
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
    this.width = double.infinity,
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
        borderRadius:
        BorderRadius.circular(radius),
      ),
    );
  }
}