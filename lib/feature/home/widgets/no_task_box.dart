import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class NoTasksBox extends StatefulWidget {
  const NoTasksBox({super.key});

  @override
  State<NoTasksBox> createState() => _NoTasksBoxState();
}

class _NoTasksBoxState extends State<NoTasksBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Color _borderColor = AppColors.border;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    setState(() => _borderColor = Colors.red);
    _controller.forward(from: 0).whenComplete(() {
      setState(() => _borderColor = AppColors.border);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: shake, // Butona tıklanırsa titre
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(context.dynamicHeight(0.016)),
              width: context.dynamicWidth(0.85),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(context.dynamicHeight(0.03)),
                border: Border.all(color: _borderColor, width: 2),
              ),
              child: Column(
                children: [
                  Text('No tasks yet', style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: context.dynamicHeight(0.01)),
                  Text('Please create a task first.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
