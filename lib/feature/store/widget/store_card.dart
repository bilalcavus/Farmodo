
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class StoreCard extends StatelessWidget {
  final Reward reward;
  final double cardRadius;
  final VoidCallback onBuy;
  final bool isBuying;

  const StoreCard({super.key, 
    required this.reward,
    required this.cardRadius,
    required this.onBuy,
    this.isBuying = false,
  });

  @override
  Widget build(BuildContext context) {
    final double padding = context.dynamicHeight(0.01);
    final double starSize = context.dynamicHeight(0.025);
    final double buttonFont = context.dynamicHeight(0.016);
    final rewardController = getIt<RewardController>();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.015),
        vertical: context.dynamicHeight(0.001),
      ),
      child: Obx((){
        final isOwned = rewardController.ownedRewardIds.contains(reward.id);
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: isOwned ? Colors.green : AppColors.primary.withOpacity(0.1)
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Image.asset(
                      reward.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported, size: context.dynamicHeight(0.04));
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    reward.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    reward.description,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/xp_star.png', height: starSize),
                        Text(
                          '${reward.xpCost} XP',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    context.dynamicHeight(0.006).height,
                    isOwned ?
                    Text(
                      'Owned',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: buttonFont
                      ),
                    ) : 
                    ElevatedButton(
                      onPressed: isBuying ? null : onBuy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: isBuying
                          ? SizedBox(
                              height: context.dynamicHeight(0.02),
                              width: context.dynamicHeight(0.02),
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Buy', style: TextStyle(fontSize: buttonFont)),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }
      ),
    );
    
  }
}
