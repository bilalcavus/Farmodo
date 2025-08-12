import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
