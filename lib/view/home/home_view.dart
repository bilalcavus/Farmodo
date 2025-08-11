import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/view/home/widgets/home_header.dart';
import 'package:farmodo/view/home/widgets/pomodoro_timer.dart';
import 'package:farmodo/view/home/widgets/time_start_button.dart';
import 'package:farmodo/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final timerController = getIt<TimerController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffECECEC),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              SizedBox(height: context.dynamicHeight(0.02)),
              dailyGoalsTitle(context),
              DailyGoalsContainer(),
              SizedBox(height: context.dynamicHeight(0.07)),
              PomodoroTimer(timerController: timerController),
              SizedBox(height: context.dynamicHeight(0.04)),
              TimeStartButton(timerController: timerController),
              SizedBox(height: context.dynamicHeight(0.04)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  timerOptions(HugeIcons.strokeRoundedAlertDiamond, 'Strict Mode'),
                  timerOptions(Iconsax.timer, 'Timer Mode'),
                  timerOptions(HugeIcons.strokeRoundedFullScreen, 'Full Screen'),
                ],
              )
            ],
        )),
      ),
    );
  }

  Column timerOptions(IconData icon, String title) {
    return Column(
      children: [
        InkWell(
          onTap: () => timerController.toggleFullScreen(context),
          child: Icon(icon)),
        Text(title),
      ],
    );
  }

  Padding dailyGoalsTitle(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.025)),
      child: Text('Daily Goals', style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.grey.shade700,
      )),
    );
  }
}

class DailyGoalsContainer extends StatelessWidget {
  const DailyGoalsContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
      child: Container(
        height: context.dynamicHeight(0.1),
        width: context.dynamicHeight(0.4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          children: [
            Padding(
              padding:  EdgeInsets.all(context.dynamicHeight(0.005)),
              child: CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 5.0,
                percent: 1.0,
                center: Text('%100'),
                progressColor: Colors.deepPurple.shade200,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your daily goals not completed yet', style: Theme.of(context).textTheme.labelMedium,),
                Text('2 of 10 completed', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade800
                )),
                Text('XP: 40/200', style: Theme.of(context).textTheme.labelMedium,)
              ],
            )
          ],
        )
      ),
    );
  }
}

