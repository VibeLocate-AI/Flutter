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
}
