import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/purchasable_lottie.dart';
import 'package:farmodo/data/sample_data/default_task_data.dart';
import 'package:farmodo/data/services/lottie_service.dart';
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
  final LottieService _lottieService = LottieService();
  final PageController _pageController = PageController();
  
  List<PurchasableLottie> _userLotties = [];
  String _selectedLottieAssetPath = '';
  int _currentIndex = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _loadUserLotties();
  }

  Future<void> _loadUserLotties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lotties = await _lottieService.getUserLotties();
      final selectedId = await _lottieService.getSelectedLottieId();
      
      final allLotties = [
        PurchasableLottie(
          id: 'default',
          name: 'Default Timer',
          assetPath: _lottieService.defaultLottieAssetPath,
          price: 0,
          description: 'Default timer animation',
          isAvailable: true,
          createdAt: DateTime.now(),
        ),
        ...lotties,
      ];
      int selectedIndex = 0;
      if (selectedId != null) {
        final index = allLotties.indexWhere((l) => l.id == selectedId);
        if (index != -1) {
          selectedIndex = index;
        }
      }

      if (mounted) {
        setState(() {
          _userLotties = allLotties;
          _currentIndex = selectedIndex;
          _selectedLottieAssetPath = allLotties[selectedIndex].assetPath;
          _isLoading = false;
        });
        // PageController'ı doğru sayfaya ayarla
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && mounted) {
            _pageController.jumpToPage(selectedIndex);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userLotties = [
            PurchasableLottie(
              id: 'default',
              name: 'Default Timer',
              assetPath: _lottieService.defaultLottieAssetPath,
              price: 0,
              description: 'Default timer animation',
              isAvailable: true,
              createdAt: DateTime.now(),
            ),
          ];
          _currentIndex = 0;
          _selectedLottieAssetPath = _lottieService.defaultLottieAssetPath;
        });
      }
    }
  }

  Future<void> _onPageChanged(int index) async {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
      _selectedLottieAssetPath = _userLotties[index].assetPath;
    });

    final lottie = _userLotties[index];
    await _lottieService.selectLottie(lottie.id, lottie.assetPath);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateAnimation(bool isRunning) {
    if (isRunning) {
      if (!_animationController.isAnimating && _animationController.duration != null) {
        _animationController.repeat();
      }
    } else {
      _animationController.stop();
    }
  }
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sadece ilk kez yükle, sürekli yeniden yükleme
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
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
                '$currentSession / $totalSessions ${'tasks.session'.tr()}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_isLoading)
              SizedBox(
                width: context.dynamicWidth(0.55),
                height: context.dynamicHeight(0.3),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_userLotties.isNotEmpty)
              SizedBox(
                height: context.dynamicHeight(0.3),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _userLotties.length,
                  itemBuilder: (context, index) {
                    final lottie = _userLotties[index];
                    final isCurrent = index == _currentIndex;
                    
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(
                        horizontal: isCurrent ? 0 : context.dynamicWidth(0.05),
                      ),
                      child: Opacity(
                        opacity: isCurrent ? 1.0 : 0.3,
                        child: Transform.scale(
                          scale: isCurrent ? 1.0 : 0.85,
                          child: Column(
                            children: [
                              Expanded(
                                child: Lottie.asset(
                                  lottie.assetPath,
                                  controller: isCurrent ? _animationController : null,
                                  onLoaded: isCurrent ? (composition) {
                                    _animationController.duration = composition.duration;
                                    if(widget.timerController.isRunning.value) {
                                      _animationController.repeat();
                                    } else {
                                      _animationController.stop();
                                    }
                                  } : null,
                                ),
                              ),
                              if (_userLotties.length > 1)
                                Padding(
                                  padding: EdgeInsets.only(top: context.dynamicHeight(0.01)),
                                  child: Text(
                                    lottie.name,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Sayfa göstergesi (indicator)
            if (_userLotties.length > 1)
              Padding(
                padding: EdgeInsets.only(top: context.dynamicHeight(0.01)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_userLotties.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentIndex ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentIndex
                            ? AppColors.danger
                            : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: ProgressBorderPainter(
        progress: progress,
        progressColor: progressColor,
        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
      child: Container(
        width: context.dynamicWidth(0.6),
        padding: EdgeInsets.all(context.dynamicHeight(0.01)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            widget.timerController.isOnBreak.value == true ?
             Text('home.break_time'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               fontWeight: FontWeight.w700,
             )) :
             const SizedBox.shrink(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final currentBreakType = tasksController.defaultBreakType.value;
      final isRunning = tasksController.timerController.isRunning.value;
      
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(
              context: context,
              label: 'home.short_break'.tr(),
              isSelected: currentBreakType == BreakDurationType.short,
              isEnabled: !isRunning,
              isDarkMode: isDark,
              onTap: () {
                if (!isRunning) {
                  tasksController.setDefaultBreakType(BreakDurationType.short);
                }
              },
            ),
            _buildToggleButton(
              context: context,
              label: 'home.long_break'.tr(),
              isSelected: currentBreakType == BreakDurationType.long,
              isEnabled: !isRunning,
              isDarkMode: isDark,
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
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.01),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.danger : isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: context.border.lowBorderRadius
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isDarkMode 
              ? isSelected ? AppColors.darkTextPrimary: isEnabled ? AppColors.darkTextPrimary : AppColors.darkTextSecondary
              : isSelected ? AppColors.darkTextPrimary : isEnabled ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
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
