// import 'package:farmodo/core/di/injection.dart';
// import 'package:farmodo/view/widgets/custom_text_field.dart';
// import 'package:farmodo/viewmodel/reward/reward_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';

// class StoreView extends StatelessWidget {
//   const StoreView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final rewardController = getIt<RewardController>();
//     return Scaffold(
//       body: SafeArea(child: Column(
//         children: [
//           CustomTextField(controller: rewardController.rewardIdController, hintText: 'Id', prefixIcon: Icon(Iconsax.activity)),
//           CustomTextField(controller: rewardController.nameController, hintText: 'Name', prefixIcon: Icon(Iconsax.activity)),
//           CustomTextField(controller: rewardController.imageUrlController, hintText: 'Image URL', prefixIcon: Icon(Iconsax.activity)),
//           CustomTextField(controller: rewardController.descriptionController, hintText: 'Description', prefixIcon: Icon(Iconsax.activity)),
//           ElevatedButton(onPressed: () async {
//             await rewardController.addRewardToStore();
//           }, child: Text('Add'))
//         ],
//       )),
//     );
//   }
// }

import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:farmodo/feature/store/widget/store/store_card.dart';
import 'package:farmodo/feature/store/widget/store/store_empty_state.dart';
import 'package:farmodo/feature/tasks/widget/user_xp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  final rewardController = getIt<RewardController>();
  final authService = getIt<AuthService>();

  Future<void> _handlePurchase({
    required String rewardId,
    required int xpCost,
    required String name,
  }) async {
    rewardController.resetPurchaseState();
    try {
      await rewardController.buyStoreRewards(rewardId, xpCost);
      if (rewardController.purchaseSucceeded.value) {
        SnackMessages(context).showSuccessSnack('Hayvan satın alındı ve çiftliğinize eklendi: $name',);
      } else {
        SnackMessages(context).showErrorSnack(rewardController.errorMessage.value);
      }
    } catch (e) {
      Get.closeAllSnackbars();
      SnackMessages(context).showErrorSnack(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rewardController.getStoreItems();
      // await rewardController.getUserPurchasedRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Store',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UserXp(authService: authService)
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02)),
              sliver: Obx(() {
                final allItems = rewardController.storeItems;
                
                if (rewardController.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (allItems.isEmpty) return SliverFillRemaining(child: StoreEmptyState());
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.dynamicWidth(0.024),
                    mainAxisSpacing: context.dynamicWidth(0.024),
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reward = allItems[index];
                      return StoreCard(
                        reward: reward,
                        cardRadius: context.dynamicHeight(0.02),
                        isBuying: rewardController.purchasingRewardId.value == reward.id,
                        onBuy: () => _handlePurchase(
                          rewardId: reward.id,
                          xpCost: reward.xpCost,
                          name: reward.name,
                        ),
                      );
                    },
                    childCount: allItems.length,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

