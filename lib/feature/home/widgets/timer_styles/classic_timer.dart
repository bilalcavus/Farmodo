import 'dart:math';
import 'package:flutter/material.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';

class ClassicTimer extends StatelessWidget {
  const ClassicTimer({
    super.key,
    required this.timeText,
    required this.progress,
    required this.isActive,
    this.progressColor = AppColors.primary,
    this.size,
  });

  final String timeText;
  final double progress;
  final bool isActive;
  final Color progressColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final timerSize = size ?? context.dynamicWidth(0.28);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: timerSize,
      height: timerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle
          CustomPaint(
            size: Size(timerSize, timerSize),
            painter: CircularProgressPainter(
              progress: progress,
              progressColor: progressColor,
              backgroundColor: isDark 
                ? AppColors.darkBorder.withOpacity(0.3)
                : AppColors.lightBorder.withOpacity(0.3),
              strokeWidth: 6,
            ),
          ),
          
          // Time text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2; // Start from top
      final sweepAngle = 2 * pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

