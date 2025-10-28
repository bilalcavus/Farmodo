import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class FlipDigit extends StatefulWidget {
  final String digit;
  final double width;
  final double height;
  final double fontSize;

  const FlipDigit({
    super.key,
    required this.digit,
    required this.width,
    required this.height,
    required this.fontSize
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  String _currentDigit = '0';
  String _nextDigit = '0';

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _nextDigit = widget.digit;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _nextDigit = widget.digit;
      _animationController.forward().then((_) {
        setState(() {
          _currentDigit = _nextDigit;
        });
        _animationController.reset();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          if (_flipAnimation.value < 0.5) {
            return _buildDigitCard(_currentDigit);
          } else {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001),
              child: _buildDigitCard(_nextDigit),
            );
          }
        },
      ),
    );
  }

  Widget _buildDigitCard(String digit) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 36, 36, 37),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(75),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class FlipTimer extends StatelessWidget {
  final String timeString;
  final double digitWidth;
  final double digitHeight;
  final double fontSize;
  final TimerController timerController;

  const FlipTimer({
    super.key,
    required this.timeString,
    this.digitWidth = 120,
    this.digitHeight = 180,
    required this.fontSize,
    required this.timerController,
  });

  @override
  Widget build(BuildContext context) {
    final parts = timeString.split(':');
    if (parts.length != 2) {
      return Text('home.invalid_time_format'.tr());
    }

    final minutes = parts[0].padLeft(2, '0');
    final seconds = parts[1].padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlipDigit(
              digit: minutes[0],
              width: digitWidth,
              height: digitHeight,
              fontSize: fontSize,
            ),
            FlipDigit(
              digit: minutes[1],
              width: digitWidth,
              height: digitHeight,
              fontSize: fontSize,
            ),
            SizedBox(
              width: 50,
              height: digitHeight,
              child: Center(
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Saniye - onlar basamağı
            FlipDigit(
              digit: seconds[0],
              width: digitWidth,
              height: digitHeight,
              fontSize: fontSize,
            ),
            // Saniye - birler basamağı
            FlipDigit(
              digit: seconds[1],
              width: digitWidth,
              height: digitHeight,
              fontSize: fontSize,
            ),
          ],
        ),
        SizedBox(height: context.dynamicHeight(0.05)),
        Obx((){
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              timerButton(Icon(HugeIcons.strokeRoundedRefresh), context, () => timerController.resetTimer()),
              SizedBox(width: context.dynamicWidth(.04)),
              timerButton(
                timerController.isRunning.value 
                ? Icon(HugeIcons.strokeRoundedPause) 
                : Icon(HugeIcons.strokeRoundedPlay), 
                context,
                timerController.isRunning.value ? () => timerController.pauseTimer() : () => timerController.startTimer()),
            ],
          );
        }
        )
      ],
    );
  }

  Widget timerButton(Widget icon, BuildContext context, VoidCallback onTap) {
    return Container(
      height: context.dynamicHeight(0.1),
      width: context.dynamicWidth(0.05),
      decoration: AppContainerStyles.primaryContainer(context),
      child: IconButton(
        onPressed: onTap,
        icon: icon,
      ),
    );
  }
}

