import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class OnboardImage extends StatelessWidget {
  const OnboardImage({
    super.key, 
    required this.assetPath,
  });

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.padding.normal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          assetPath, 
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
