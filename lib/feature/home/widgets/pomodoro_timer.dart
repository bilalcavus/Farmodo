
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/sample_data/default_task_data.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({
    super.key,
    required this.timerController,
  });

  final TimerController timerController;

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation(bool isRunning) {
    if (isRunning) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      _animationController.stop();
    }
  }
  @override
  Widget build(BuildContext context) {
    final tasksController = getIt<TasksController>();
    
    return Center(
      child: Obx(() {
        final isRunning = widget.timerController.isRunning.value;
        _updateAnimation(isRunning);
        
        final isUsingDefault = tasksController.isUsingDefaultTask.value;
        final selectedIndex = tasksController.selctedTaskIndex.value;
        
        int currentSession = 0;
        int totalSessions = 0;
        String taskName = '';
        
        if (isUsingDefault) {
          currentSession = tasksController.defaultTaskCurrentSession.value;
          totalSessions = tasksController.defaultTask.totalSessions;
          taskName = tasksController.defaultTask.title;
        } else if (selectedIndex != -1 && 
                   tasksController.activeUserTasks.isNotEmpty &&
                   selectedIndex < tasksController.activeUserTasks.length) {
          final task = tasksController.activeUserTasks[selectedIndex];
          currentSession = task.completedSessions;
          totalSessions = task.totalSessions;
          taskName = task.title;
        }
        
         final progress = widget.timerController.displayProgress;
         final progressColor = widget.timerController.isOnBreak.value 
           ? AppColors.secondary 
           : AppColors.danger;
         
         return Column(
           children: [
              // Break Type Toggle (sadece default task kullanılıyorsa göster)
              if (isUsingDefault) ...[
                BreakTypeToggle(tasksController: tasksController),
                SizedBox(height: context.dynamicHeight(0.02)),
              ],
              TimerContainer(progress: progress, progressColor: progressColor, widget: widget),
              if (totalSessions > 0) ...[
              SizedBox(height: context.dynamicHeight(0.03)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSessions, (index) {
                  final isCompleted = index < currentSession;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                        ? AppColors.danger 
                        : Colors.grey.shade300,
                      border: Border.all(
                        color: isCompleted 
                          ? AppColors.danger 
                          : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              context.dynamicHeight(0.01).height,
              Text(taskName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold
              )),
              SizedBox(height: context.dynamicHeight(0.01)),
              Text(
                '$currentSession / $totalSessions sessions',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            Lottie.asset(
              'assets/lottie/timer_lottie.json',
              width: context.dynamicWidth(0.55),
              height: context.dynamicHeight(0.3),
              controller: _animationController,
              onLoaded: (composition) {
                _animationController.duration = composition.duration;
                if(widget.timerController.isRunning.value) {
                  _animationController.repeat();
                } else {
                  _animationController.stop();
                }
              }
            ),
          ],
        );
      }),
    );
  }
}

class TimerContainer extends StatelessWidget {
  const TimerContainer({
    super.key,
    required this.progress,
    required this.progressColor,
    required this.widget,
  });

  final double progress;
  final Color progressColor;
  final PomodoroTimer widget;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ProgressBorderPainter(
        progress: progress,
        progressColor: progressColor,
        backgroundColor: Colors.grey.shade200,
      ),
      child: Container(
        width: context.dynamicWidth(0.6),
        padding: EdgeInsets.all(context.dynamicHeight(0.01)),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.timerController.isOnBreak.value
                  ? widget.timerController.formatTime(widget.timerController.breakSecondsRemaining.value)
                  :  widget.timerController.formatTime(widget.timerController.secondsRemaining.value),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            widget.timerController.isOnBreak.value == true ?
             Text('Break Time', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               color: AppColors.textPrimary,
               fontWeight: FontWeight.w700,
             )) :
             SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class BreakTypeToggle extends StatelessWidget {
  const BreakTypeToggle({
    super.key,
    required this.tasksController,
  });

  final TasksController tasksController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentBreakType = tasksController.defaultBreakType.value;
      final isRunning = tasksController.timerController.isRunning.value;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(
              context: context,
              label: 'Short Break (5m)',
              isSelected: currentBreakType == BreakDurationType.short,
              isEnabled: !isRunning,
              onTap: () {
                if (!isRunning) {
                  tasksController.setDefaultBreakType(BreakDurationType.short);
                }
              },
            ),
            _buildToggleButton(
              context: context,
              label: 'Long Break (15m)',
              isSelected: currentBreakType == BreakDurationType.long,
              isEnabled: !isRunning,
              onTap: () {
                if (!isRunning) {
                  tasksController.setDefaultBreakType(BreakDurationType.long);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.01),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.danger : Colors.grey.shade200,
          borderRadius: context.border.lowBorderRadius
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected 
              ? Colors.white 
              : (isEnabled ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  ProgressBorderPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(16);
    final rrect = borderRadius.toRRect(rect);
    
    // Background border
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawRRect(rrect, backgroundPaint);
    
    // Progress border - Sol ortadan başlayıp saat yönünün tersine (yukarı)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
  
    // Saat yönünün tersine çizim için arcTo kullanacağız
    // Başlangıç: Sol orta (180 derece / π radyan)
    // Bitiş: Sol orta (tam tur: 180 - 360 = -180 derece)
    
    if (progress > 0) {
      // Rounded rectangle için path oluştur
      final rrectPath = Path()..addRRect(rrect);
      
      final pathMetric = rrectPath.computeMetrics().first;
      final totalLength = pathMetric.length;
      final progressLength = totalLength * progress;
      
      // Sol alt köşeden başla (perimeter başlangıcı)
      final extractedPath = pathMetric.extractPath(0, progressLength);
      
      canvas.drawPath(extractedPath, progressPaint);
    }
  }

  @override
  bool shouldRepaint(ProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}
