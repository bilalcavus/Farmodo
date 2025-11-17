import 'package:farmodo/data/models/purchasable_coin.dart';
import 'package:farmodo/data/models/purchasable_lottie.dart';
import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/data/services/animal_service.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum StoreCategory { animals, coins, lotties }

enum StoreBuyingStates { loading, error, success}

class RewardController extends GetxController {
  final FirestoreService firestoreService;
  final LoginController loginController;
  final AuthService authService;
  final AnimalService animalService = AnimalService();
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
  final _isOwnedAnimal = false.obs; // legacy single-flag (kept for compatibility)
  final RxSet<String> ownedRewardIds = <String>{}.obs;
  final RxnString purchasingRewardId = RxnString();
  final RxnString purchasingCoinId = RxnString();
  RxBool get isPremium => _isPremium;
  RxBool get isLoading => _isLoading;
  RxBool get purchaseSucceeded => _purchaseSucceeded;
  RxList storeItems = <Reward>[].obs;
  RxList purchasableCoins = <PurchasableCoin>[].obs;
  RxList purchasableLotties = <PurchasableLottie>[].obs;
  RxList userPurchasedRewards = [].obs;
  RxBool get isOwnedAnimal => _isOwnedAnimal;
  
  // Cache flags - her kategori için bir kere yüklendi mi kontrolü
  final _animalsLoaded = false.obs;
  final _coinsLoaded = false.obs;
  final _lottiesLoaded = false.obs;
  
  RxBool get animalsLoaded => _animalsLoaded;
  RxBool get coinsLoaded => _coinsLoaded;
  RxBool get lottiesLoaded => _lottiesLoaded;

  @override
  void onReady() {
    super.onReady();
    loadAllStoreData();
    loadOwnedRewards();
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
    await loadAllStoreData();
  }

  
  RewardController(this.firestoreService, this.loginController, this.authService);

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
      final animals = await animalService.getUserAnimals();
      ownedRewardIds
        ..clear()
        ..addAll(animals.map((a) => a.rewardId));
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  bool isRewardOwned(String rewardId) {
    final isOwned = ownedRewardIds.contains(rewardId);
    return isOwned;
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

  Future<void> getPurchasableLotties() async {
    if (_lottiesLoaded.value) {
      return;
    }
    await fetchingStoreItems(
      fetchFunction: () => firestoreService.fetchPurchasableLotties(),
      targetList: purchasableLotties
    );
    _lottiesLoaded.value = true;
  }

  Future<void> getPurchasableCoins() async {
    if (_coinsLoaded.value) {
      return;
    }
    await fetchingStoreItems(
      fetchFunction: () => firestoreService.fetchPurchasableCoins(),
      targetList: purchasableCoins
    );
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
      await firestoreService.buyCoin(coin);
      _purchaseSucceeded.value = true;
      await authService.fetchAndSetCurrentUser();
    } catch (e) {
        errorMessage.value = e.toString();
    } finally {
      setLoading(false);
      purchasingCoinId.value = null;
    }

  }
}