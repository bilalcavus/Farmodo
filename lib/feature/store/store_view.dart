import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:farmodo/feature/store/widget/store_card.dart';
import 'package:farmodo/feature/store/widget/store_empty_state.dart';
import 'package:farmodo/feature/home/widgets/user_xp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;



class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  final rewardController = getIt<RewardController>();
  final authService = getIt<AuthService>();
  final navigationController = getIt<NavigationController>();
  final loginController = getIt<LoginController>();

  Future<void> _handlePurchase({
    required String rewardId,
    required String name,
  }) async {
    if (!authService.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    rewardController.resetPurchaseState();
    try {
      await rewardController.buyStoreRewards(rewardId);
      if (rewardController.purchaseSucceeded.value) {
        SnackMessages().showSuccessSnack('${'store.animal_purchased'.tr()}: $name',);
        setState(() {});
      } else {
        SnackMessages().showErrorSnack(rewardController.errorMessage.value);
      }
    } catch (e) {
      Get.closeAllSnackbars();
      SnackMessages().showErrorSnack(e.toString());
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('store.login_required'.tr()),
        content: Text('store.login_required_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              RouteHelper.pushAndCloseOther(context, const LoginView());
            },
            child: Text('store.go_to_login'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rewardController.getStoreItems();
      await rewardController.loadOwnedRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          'store.store'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(context.dynamicHeight(0.02)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserXp(authService: authService),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02)),
                child: Obx(() {
                  final allItems = rewardController.storeItems;
                  
                  if (rewardController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (allItems.isEmpty) return StoreEmptyState();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.dynamicWidth(0.024),
                      mainAxisSpacing: context.dynamicWidth(0.024),
                      childAspectRatio: 0.85,
                    ),
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      final reward = allItems[index];
                      return StoreCard(
                        reward: reward,
                        cardRadius: context.dynamicHeight(0.02),
                        isBuying: rewardController.purchasingRewardId.value == reward.id,
                        onBuy: () => _handlePurchase(
                          rewardId: reward.id,
                          name: reward.name,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

