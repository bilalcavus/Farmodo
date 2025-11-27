import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/purchase_items/lottie/woodpecker.json'),
      ),
    );
  }
}