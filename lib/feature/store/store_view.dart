import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/models/lottie_pack.dart';
import 'package:farmodo/data/models/purchasable_lottie.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:farmodo/feature/store/widget/category_selector.dart';
import 'package:farmodo/feature/store/widget/coin_card.dart';
import 'package:farmodo/feature/store/widget/lottie_pack_card.dart';
import 'package:farmodo/feature/store/view/lottie_pack_detail_view.dart';
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
  StoreCategory _selectedCategory = StoreCategory.animals;
  bool _bootstrapped = false;

  Future<void> _bootstrapStoreData() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    if (!authService.isLoggedIn) return;

    // Ensure ownership state is up to date on every app launch/entering store
    await rewardController.loadOwnedRewards();

    // If Adapty profile is already available, sync lottie purchases once more
    final profile = rewardController.billingService.profile;
    if (profile != null) {
      await rewardController.lottieService.syncWithAdapty(profile);
      await rewardController.loadOwnedRewards();
    }
  }

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

  Future<void> _handleCoinPurchase(String coinId, String name) async {
    if(!authService.isLoggedIn){
      _showLoginDialog();
      return;
    }

    try {
      await rewardController.buyStoreCoin(coinId);
      if(rewardController.purchaseSucceeded.value){
        SnackMessages().showSuccessSnack('store.coin_purchased'.tr());
        setState(() {});
      } else {
        SnackMessages().showErrorSnack(rewardController.errorMessage.value);
      }
    } catch (e) {
      Get.closeAllSnackbars();
      SnackMessages().showErrorSnack(e.toString());
    }
  }

  Future<void> _handleLottieActivation(LottiePackType type) async {
    if (!authService.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    try {
      await rewardController.selectLottiePack(type);
      SnackMessages().showSuccessSnack('Lottie pack activated');
      setState(() {});
    } catch (e) {
      Get.closeAllSnackbars();
      SnackMessages().showErrorSnack(e.toString());
    }
  }

  Future<void> _handleLottiePackPurchase(LottiePack pack) async {
    if (!authService.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    rewardController.resetPurchaseState();
    try {
      await rewardController.buyLottiePack(pack);
      if (rewardController.purchaseSucceeded.value) {
        SnackMessages().showSuccessSnack('${'store.lottie_purchased'.tr()}: ${pack.name}');
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
    _bootstrapStoreData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rewardController.loadAllStoreData();
      await rewardController.loadOwnedRewards();
    });
  }

  void _onCategoryChanged(StoreCategory category) {
    setState(() {
      _selectedCategory = category;
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
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategoryChanged: _onCategoryChanged,
              ),
              SizedBox(height: context.dynamicHeight(0.02)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02)),
                child: _buildCategoryGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Obx(() {
      final isInitialLoading = rewardController.isLoading.value && 
          !rewardController.animalsLoaded.value &&
          !rewardController.coinsLoaded.value &&
          !rewardController.lottiesLoaded.value;
          
      if (isInitialLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      switch (_selectedCategory) {
        case StoreCategory.animals:
          final allItems = rewardController.storeItems;
          if (allItems.isEmpty) return const StoreEmptyState();
          
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

        case StoreCategory.coins:
          final coins = rewardController.purchasableCoins;
          if (coins.isEmpty) return const StoreEmptyState();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: context.dynamicWidth(0.024),
              mainAxisSpacing: context.dynamicWidth(0.024),
              childAspectRatio: 0.85,
            ),
            itemCount: coins.length,
            itemBuilder: (context, index) {
              final coin = coins[index];
              return CoinCard(
                coin: coin,
                cardRadius: context.dynamicHeight(0.02),
                isBuying: rewardController.purchasingCoinId.value == coin.id,
                onBuy: () => _handleCoinPurchase(coin.id, coin.name),
              );
            },
          );

        case StoreCategory.lotties:
          final lottiePacks = rewardController.lottiePacks;
          if (lottiePacks.isEmpty) return const StoreEmptyState();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: context.dynamicWidth(0.024),
              mainAxisSpacing: context.dynamicWidth(0.024),
              childAspectRatio: 0.85,
            ),
            itemCount: lottiePacks.length,
            itemBuilder: (context, index) {
              final pack = lottiePacks[index] as LottiePack;
              final imagePath = switch (pack.type) {
                LottiePackType.small => 'assets/purchase_items/lottie/pack_icon/small_pack.png',
                LottiePackType.medium => 'assets/purchase_items/lottie/pack_icon/medium_pack.png',
                LottiePackType.advanced => 'assets/purchase_items/lottie/pack_icon/advanced_pack.png',
                LottiePackType.unknown => null,
              };
              return LottiePackCard(
                pack: pack,
                cardRadius: context.dynamicHeight(0.02),
                isBuying: rewardController.purchasingLottiePackType.value == pack.type,
                isOwned: rewardController.isPackOwned(pack.type),
                isActive: rewardController.isPackActive(pack.type),
                imageAssetPath: imagePath,
                onBuy: () => _handleLottiePackPurchase(pack),
                onActivate: () => _handleLottieActivation(pack.type),
                onView: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LottiePackDetailView(
                        pack: pack,
                        isOwned: rewardController.isPackOwned(pack.type),
                        isActive: rewardController.isPackActive(pack.type),
                      ),
                    ),
                  );
                },
              );
            },
          );
      }
    });
  }
}
