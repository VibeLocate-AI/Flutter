import 'package:flutter/material.dart';

abstract final class ThemeHelpers {
  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 900 ? (width - 860) / 2 : width >= 600 ? 32.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, 16, horizontal, 28);
  }

  static double gridColumns(BuildContext context, {double maxCardWidth = 220}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  static double gridCardWidth(BuildContext context, double columns) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = pagePadding(context).horizontal;
    final gaps = (columns - 1) * 14;
    return ((width - padding - gaps) / columns).clamp(120.0, 420.0).toDouble();
  }

  static double gridCardHeight(BuildContext context, double columns) {
    final cardWidth = gridCardWidth(context, columns);
    // Taller cards on narrow phones prevent price/stat rows from being
    // clipped; large screens stay visually compact.
    return (cardWidth * 1.42).clamp(300.0, 500.0).toDouble();
  }
}
