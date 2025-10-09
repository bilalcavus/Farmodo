import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class LeaderBoardButton extends StatelessWidget {
  const LeaderBoardButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.04),
      padding: context.padding.horizontalLow,
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: context.dynamicHeight(0.025),
          ),
          context.dynamicWidth(0.01).width,
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}



