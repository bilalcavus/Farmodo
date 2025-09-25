import 'package:flutter/material.dart';

class OnboardPageIndicator extends StatelessWidget {
  const OnboardPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: currentPage == index
                ? Colors.lightGreenAccent
                : Colors.grey.withAlpha(100),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}
