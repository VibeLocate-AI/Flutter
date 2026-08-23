import 'package:flutter/material.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final imageHeight = (height * 0.46).clamp(
      280.0,
      430.0,
    );

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }
}