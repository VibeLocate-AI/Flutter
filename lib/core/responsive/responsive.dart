import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

abstract final class Responsive {
  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static bool isSmallMobile(BuildContext context) {
    return width(context) < AppBreakpoints.mobile;
  }

  static bool isMobile(BuildContext context) {
    final screenWidth = width(context);

    return screenWidth >= AppBreakpoints.mobile &&
        screenWidth < AppBreakpoints.largeMobile;
  }

  static bool isLargeMobile(BuildContext context) {
    final screenWidth = width(context);

    return screenWidth >= AppBreakpoints.largeMobile &&
        screenWidth < AppBreakpoints.tablet;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= AppBreakpoints.tablet;
  }
}