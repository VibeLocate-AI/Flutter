import 'package:flutter/material.dart';

import 'responsive.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.smallMobile,
    this.largeMobile,
    this.tablet,
  });

  final Widget mobile;
  final Widget? smallMobile;
  final Widget? largeMobile;
  final Widget? tablet;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    }

    if (Responsive.isLargeMobile(context)) {
      return largeMobile ?? mobile;
    }

    if (Responsive.isSmallMobile(context)) {
      return smallMobile ?? mobile;
    }

    return mobile;
  }
}