
// import 'package:farmodo/feature/home/widgets/pomodoro_timer.dart';
// import 'package:flutter/material.dart';

// mixin PomodoroTimerMixin on State<PomodoroTimer> {
//     late final AnimationController _animationController;
  
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(vsync: this);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _updateAnimation(bool isRunning) {
//     if (isRunning) {
//       if (!_animationController.isAnimating) {
//         _animationController.repeat();
//       }
//     } else {
//       _animationController.stop();
//     }
//   }
// }