import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/services/adapty_billing_service.dart';
import 'package:farmodo/data/models/lottie_pack.dart';
import 'package:farmodo/data/models/purchasable_coin.dart';
import 'package:farmodo/data/models/purchasable_lottie.dart';
import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/data/services/animal_service.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/data/services/lottie_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;

enum StoreCategory { animals, coins, lotties }

enum StoreBuyingStates { loading, error, success}

class RewardController extends GetxController {
  final FirestoreService firestoreService;
  final LoginController loginController;
  final AuthService authService;
  final AdaptyBillingService billingService;
  final AnimalService animalService = AnimalService();
  final LottieService lottieService = LottieService();
  TextEditingController rewardIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxnInt xpCost = RxnInt();
  String imageUrl = '';
  var errorMessage = ''.obs;
  final _isPremium = false.obs;
  final _isLoading = false.obs;
  final _purchaseSucceeded = false.obs;
  final _isOwnedAnimal = false.obs;
  final RxSet<String> ownedRewardIds = <String>{}.obs;
  final RxSet<String> ownedLottieIds = <String>{}.obs;
  final RxSet<LottiePackType> ownedLottiePackTypes = <LottiePackType>{}.obs;
  final RxnString purchasingRewardId = RxnString();
  final RxnString purchasingCoinId = RxnString();
  final Rxn<LottiePackType> purchasingLottiePackType = Rxn<LottiePackType>();
  final Rxn<LottiePackType> activeLottiePackType = Rxn<LottiePackType>();
  RxBool get isPremium => _isPremium;
  RxBool get isLoading => _isLoading;
  RxBool get purchaseSucceeded => _purchaseSucceeded;
  RxList storeItems = <Reward>[].obs;
  RxList purchasableCoins = <PurchasableCoin>[].obs;
  RxList purchasableLotties = <PurchasableLottie>[].obs;
  RxList lottiePacks = <LottiePack>[].obs;
  RxList userPurchasedRewards = [].obs;
  RxBool get isOwnedAnimal => _isOwnedAnimal;
  
  // Cache flags - her kategori için bir kere yüklendi mi kontrolü
  final _animalsLoaded = false.obs;
  final _coinsLoaded = false.obs;
  final _lottiesLoaded = false.obs;
  
  RxBool get animalsLoaded => _animalsLoaded;
  RxBool get coinsLoaded => _coinsLoaded;
  RxBool get lottiesLoaded => _lottiesLoaded;
  bool get _debugFreePurchase => kDebugMode;

  @override
  void onReady() {
    super.onReady();
    loadAllStoreData();
    loadOwnedRewards();
    
    // Listen for Adapty profile updates (e.g. restore purchases)
    billingService.onProfileUpdate = (profile) {
      lottieService.syncWithAdapty(profile).then((_) {
        loadOwnedRewards(); // Refresh UI after sync
      });
    };
    
    // Initial sync if profile is already loaded
    if (billingService.profile != null) {
      lottieService.syncWithAdapty(billingService.profile!);
    }
  }
  
  Future<void> loadAllStoreData() async {
    await Future.wait([
      getStoreItems(),
      getPurchasableCoins(),
      getPurchasableLotties(),
    ]);
  }
  
  Future<void> refreshStoreData() async {
    _animalsLoaded.value = false;
    _coinsLoaded.value = false;
    _lottiesLoaded.value = false;
    lottiePacks.clear();
    await loadAllStoreData();
  }

  
  RewardController(
    this.firestoreService, 
    this.loginController, 
    this.authService,
    this.billingService,
  );

  void setLoading(bool value){
    _isLoading.value = value;
  }

  void resetPurchaseState(){
    errorMessage.value = '';
    _purchaseSucceeded.value = false;
  }

  Future<void> addRewardToStore() async {
    setLoading(true);
    try {
      await firestoreService.addStoreReward(
        rewardId: rewardIdController.text.trim(),
        name: nameController.text.trim(),
        imageUrl: imageUrlController.text.trim(),
        xpCost: xpCost.value ?? 0,
        description: descriptionController.text.trim(),
        type: 'customization',
        isPremium: false);
      
      await getStoreItems();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
      rewardIdController.clear();
      nameController.clear();
      descriptionController.clear();
      imageUrlController.clear();
      xpCost.value = null;
    }
  }


  Future<void> loadOwnedRewards() async {
    try {
      // Hayvanları yükle
      final animals = await animalService.getUserAnimals();
      ownedRewardIds
        ..clear()
        ..addAll(animals.map((a) => a.rewardId));
      
      // Lottie'leri yükle
      final lotties = await lottieService.getUserLotties();
      ownedLottieIds
        ..clear()
        ..addAll(lotties.map((l) => l.id));

      final ownedPacks = await lottieService.getOwnedPackTypes();
      ownedLottiePackTypes
        ..clear()
        ..addAll(ownedPacks);

      final selectedPack = await lottieService.getSelectedPackType();
      activeLottiePackType.value = selectedPack ?? (ownedPacks.isNotEmpty ? ownedPacks.first : null);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  bool isRewardOwned(String rewardId) {
    final isOwned = ownedRewardIds.contains(rewardId);
    return isOwned;
  }

  bool isLottieOwned(String lottieId) {
    return ownedLottieIds.contains(lottieId);
  }

  bool isPackOwned(LottiePackType type) {
    return ownedLottiePackTypes.contains(type);
  }

  bool isPackActive(LottiePackType type) {
    return activeLottiePackType.value == type;
  }

  // Future<void> getStoreItems() async {
  //   setLoading(true);
  //   try {
  //     final items = await firestoreService.getStoreItems();
  //     if(items.isNotEmpty){
  //       storeItems.assignAll(items);
  //     } else {
  //       storeItems.clear();
  //     }
  //   } catch (e) {
  //     errorMessage.value = e.toString();
  //   } finally {
  //     setLoading(false);
  //   }
  // }



  Future<void> fetchingStoreItems<T>({
    required Future<List<T>> Function() fetchFunction,
    required RxList<T> targetList,
  }) async {
    setLoading(true);
    try {
      final items = await fetchFunction();
      if(items.isNotEmpty){
        targetList.assignAll(items);
      } else {
        targetList.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally{
      setLoading(false);
    }
  }

  void _rebuildLottiePacks({List<AdaptyPaywallProduct>? paywallProducts}) {
    final Map<LottiePackType, List<PurchasableLottie>> grouped = {};
    for (final lottie in purchasableLotties.cast<PurchasableLottie>()) {
      final type = lottie.packType;
      if (type == LottiePackType.unknown) continue;
      grouped.putIfAbsent(type, () => []).add(lottie);
    }

    final packs = grouped.entries.map((entry) {
      final lotties = entry.value;
      final preview = lotties.isNotEmpty ? lotties.first : null;
      final productId = preview?.productId?.isNotEmpty == true
          ? preview?.productId
          : billingService.lottieDefaultProductId(entry.key);
      String? localizedPrice;
      if (paywallProducts != null && productId != null) {
        localizedPrice = billingService.getLocalizedPriceForProduct(
          products: paywallProducts,
          productId: productId,
        );
      }
      return LottiePack(
        type: entry.key,
        name: entry.key.readableName,
        description: '${lotties.length} animation',
        price: preview?.price ?? 0,
        displayPrice: localizedPrice,
        lotties: lotties,
        productId: productId,
      );
    }).toList()
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    lottiePacks.assignAll(packs);
  }

  Future<void> getPurchasableLotties() async {
    if (_lottiesLoaded.value) {
      return;
    }
    List<AdaptyPaywallProduct>? products;
    if (billingService.isAvailable) {
      final paywall = await billingService.getPaywallWithProducts(
        AdaptyBillingService.lottiePackPlacementId,
      );
      final rawProducts = paywall?['products'];
      if (rawProducts is List<AdaptyPaywallProduct>) {
        products = rawProducts;
      } else if (rawProducts is List) {
        products = rawProducts.cast<AdaptyPaywallProduct>();
      }
    }

    await fetchingStoreItems(
      fetchFunction: () => firestoreService.fetchPurchasableLotties(),
      targetList: purchasableLotties
    );
    _rebuildLottiePacks(paywallProducts: products);
    _lottiesLoaded.value = true;
  }

  Future<void> getPurchasableCoins() async {
    if (_coinsLoaded.value) {
      return;
    }
    List<AdaptyPaywallProduct>? products;
    if (billingService.isAvailable) {
      final paywall = await billingService.getCoinPaywallWithProducts();
      final rawProducts = paywall?['products'];
      if (rawProducts is List<AdaptyPaywallProduct>) {
        products = rawProducts;
      } else if (rawProducts is List) {
        products = rawProducts.cast<AdaptyPaywallProduct>();
      }
    }

    await fetchingStoreItems(
      fetchFunction: () => firestoreService.fetchPurchasableCoins(),
      targetList: purchasableCoins,
    );

    if (products != null && products.isNotEmpty) {
      // Enrich coins with localized price from Adapty
      final updated = purchasableCoins
          .cast<PurchasableCoin>()
          .map((coin) {
            final id = coin.productId;
            if (id == null) return coin;
            final localizedPrice = billingService.getLocalizedPriceForProduct(
              products: products!,
              productId: id,
            );
            final adaptyAmount = products
                .firstWhereOrNull((p) => p.vendorProductId == id)
                ?.price
                .amount;

            // Override UI prices with Adapty values (ignore Firestore price)
            return coin.copyWith(
              displayPrice: localizedPrice,
              adaptyAmount: adaptyAmount,
              price: adaptyAmount != null ? adaptyAmount.round() : coin.price,
            );
          })
          .toList();
      purchasableCoins.assignAll(updated);
    }
    _coinsLoaded.value = true;
  }

  Future<void> getStoreItems() async {
    if (_animalsLoaded.value) {
      return;
    }
    await fetchingStoreItems(fetchFunction: () => firestoreService.getStoreItems(), targetList: storeItems);
    _animalsLoaded.value = true;
  }

  


  Future<void> buyStoreRewards(String rewardId) async {
    setLoading(true);
    resetPurchaseState();
    purchasingRewardId.value = rewardId;
    try {
      final reward = storeItems.firstWhere((item) => item.id == rewardId);
      await animalService.addAnimalFromReward(reward);
      _purchaseSucceeded.value = true;
      ownedRewardIds.add(rewardId);
      await authService.fetchAndSetCurrentUser();
      loginController.refreshUserXp();
      await loadOwnedRewards();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
      purchasingRewardId.value = null;
    }
  }

  Future<void> buyStoreCoin(String coinId) async {
    setLoading(true);
    resetPurchaseState();
    purchasingCoinId.value = coinId;
    
    try {
      final coin = purchasableCoins.firstWhere((item) => item.id == coinId);
      
      if (_debugFreePurchase) {
        await firestoreService.buyCoin(coin);
        _purchaseSucceeded.value = true;
        await authService.fetchAndSetCurrentUser();
        debugPrint('Debug mode: coin granted without billing (${coin.name})');
        return;
      }
      
      if (billingService.isAvailable && coin.productId != null) {
        debugPrint('Starting Adapty purchase for coin: ${coin.name} (${coin.value} coins)');
        
        final result = await billingService.purchaseCoins(
          coin.value,
          productIdOverride: coin.productId,
        );
        
        if (result['success'] == true) {
          debugPrint('Adapty purchase successful, updating Firebase...');
          await firestoreService.buyCoin(coin);
          _purchaseSucceeded.value = true;
          await authService.fetchAndSetCurrentUser();
          debugPrint('Coin purchase completed successfully');
        } else {
          final error = result['error'] ?? 'Unknown error';
          debugPrint('Adapty purchase failed: $error');
          if (error == 'purchase_cancelled') {
            errorMessage.value = 'store.purchase_cancelled'.tr();
            return;
          }
          if (error == 'purchase_not_confirmed') {
            errorMessage.value = 'store.purchase_cancelled'.tr();
            return;
          }
          if (error == 'purchase_pending') {
            errorMessage.value = 'store.purchase_cancelled'.tr();
            return;
          }
          if (error.contains('Paywall not found') || error.contains('not_found')) {
            errorMessage.value = 'Store setup incomplete. Please configure Adapty placement and products.';
          } else {
            errorMessage.value = error;
          }
        }
      } else {
        final errorMsg = !billingService.isAvailable 
            ? 'In-app purchases not available on this platform'
            : 'Product ID not configured for this coin';
        debugPrint('Cannot purchase coin: $errorMsg');
        errorMessage.value = errorMsg;
      }
    } catch (e) {
      debugPrint('Error in buyStoreCoin: $e');
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
      purchasingCoinId.value = null;
    }
  }

  Future<void> buyLottiePack(LottiePack pack) async {
    setLoading(true);
    resetPurchaseState();
    purchasingLottiePackType.value = pack.type;
    
    try {
      Map<String, dynamic>? purchaseResult;

      if (_debugFreePurchase) {
        await lottieService.registerPackPurchase(
          pack: pack,
          purchaseMethod: 'debug',
        );
        final granted = await lottieService.ensurePackGranted(
          pack: pack,
          purchaseMethod: 'debug',
        );
        if (!granted) {
          errorMessage.value = 'store.purchase_grant_failed'.tr();
          return;
        }
        _purchaseSucceeded.value = true;
        ownedLottiePackTypes.add(pack.type);
        activeLottiePackType.value = pack.type;
        await authService.fetchAndSetCurrentUser();
        loginController.refreshUserXp();
        await loadOwnedRewards();
        await getPurchasableLotties();
        debugPrint('Debug mode: lottie pack granted without billing (${pack.type})');
        return;
      }

      if (billingService.isAvailable) {
        purchaseResult = await billingService.purchaseLottiePack(
          pack.type,
          productIdOverride: pack.productId,
        );
      } else {
        // Billing service not available (e.g. simulator or error)
        // DO NOT give for free unless explicitly intended for debug
        errorMessage.value = 'Store not available';
        return;
      }

      final success = purchaseResult != null && purchaseResult['success'] == true;
      if (!success) {
        final error = purchaseResult['error'];
        if (error == 'purchase_cancelled') {
          errorMessage.value = 'store.purchase_cancelled'.tr();
        } else {
          errorMessage.value = error ?? 'Purchase failed';
        }
        return;
      }

      await lottieService.registerPackPurchase(
        pack: pack,
        purchaseMethod: 'iap',
      );

      final granted = await lottieService.ensurePackGranted(
        pack: pack,
        purchaseMethod: 'iap',
      );
      if (!granted) {
        errorMessage.value = 'store.purchase_grant_failed'.tr();
        return;
      }
      _purchaseSucceeded.value = true;
      ownedLottiePackTypes.add(pack.type);
      activeLottiePackType.value = pack.type;

      await authService.fetchAndSetCurrentUser();
      loginController.refreshUserXp();
      await loadOwnedRewards();
      await getPurchasableLotties(); // refresh localized prices if needed
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
      purchasingLottiePackType.value = null;
    }
  }

  Future<void> selectLottiePack(LottiePackType type) async {
    await lottieService.selectPackType(type);
    activeLottiePackType.value = type;
  }
}
