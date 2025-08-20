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

import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/home/widgets/home_header.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  final rewardController = getIt<RewardController>();
  final authService = getIt<AuthService>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      rewardController.getStoreItems();
    });
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
          Padding(
            padding: EdgeInsets.all(context.dynamicHeight(0.016)),
            child: Row(
              children: [
                Text(
                  'Store',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600
                  )
                ),
                Spacer(),
                UserXp(authService: authService)
              ],
            ),
          ),
          Obx((){
            if (rewardController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            } else if(rewardController.storeItems.isEmpty) {
              return Center(
                child: Text('No items'),
              );
            } else {
              return Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.dynamicWidth(0.01),
                    mainAxisSpacing: context.dynamicWidth(0.03),
                    childAspectRatio: 0.8,
                  ),
                  itemCount: rewardController.storeItems.length,
                  itemBuilder: (context, index) {
                    final reward = rewardController.storeItems[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.015),
                        vertical: context.dynamicHeight(0.001)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(context.dynamicHeight(0.04)),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(context.dynamicHeight(0.01)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Image widget
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Image.asset(reward.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported, size: 40);
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
                              // Description
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
                              // XP Cost
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.025),),
                                      Text(
                                        '${reward.xpCost} XP',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {

                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.textPrimary,
                                      foregroundColor: AppColors.surface,
                                      
                                    ),
                                    child: Text('Buy', style: TextStyle(fontSize: context.dynamicHeight(0.016))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          })
        ],
      )),
    );
  }
}