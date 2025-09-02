
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/home/widgets/pomodoro_timer.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:farmodo/feature/tasks/widget/user_xp.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    final timerController = getIt<TimerController>();
    return Stack(
      children: [
        CustomPaint(
        painter: _HeaderPainter(),
        child: SizedBox(
          height: 250,
          width: double.infinity,
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          context.dynamicHeight(0.017).height,
          UserXp(authService: authService),
          // context.dynamicHeight(0.017).height,
          // DropMenu(controller: taskController.taskSelectController, label: 'Select Task', hint: 'Select Task', items: [
          //   ...taskController.activeUserTasks.map((task) => task.title)
          // ]),
          context.dynamicHeight(0.05).height,
          PomodoroTimer(timerController: timerController),
      ],
      )
      ]
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(255, 211, 218, 232);
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(size.width / 2 , size.height, size.width, size.height - 40)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class LevelBar extends StatelessWidget {
  const LevelBar({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final int xp = authService.currentUser?.xp ?? 0;
    final int level = (xp ~/ 100) + 1;
    final int xpIntoLevel = xp % 100;
    final double progress = (xpIntoLevel.clamp(0, 100)) / 100.0;

    return Container(
      height: context.dynamicHeight(0.05),
      width: context.dynamicWidth(0.85),
      padding: EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.012)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.024)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02), vertical: context.dynamicHeight(0.005)),
            decoration: BoxDecoration(
              color: AppColors.danger.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Lv $level',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          context.dynamicWidth(0.015).width,
          SizedBox(
            width: context.dynamicWidth(0.45),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    color: AppColors.border,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '$xpIntoLevel/100',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}