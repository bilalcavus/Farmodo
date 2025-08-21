import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
enum StoreBuyingStates { loading, error, success}
class RewardController extends GetxController {
  final FirestoreService firestoreService;
  final LoginController loginController;
  final AuthService authService;
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
  final RxnString purchasingRewardId = RxnString();
  RxBool get isPremium => _isPremium;
  RxBool get isLoading => _isLoading;
  RxBool get purchaseSucceeded => _purchaseSucceeded;
  RxList storeItems = <Reward>[].obs;
  RxList userPurchasedRewards = <Reward>[].obs;

  @override
  void onReady() {
    super.onReady();
    getStoreItems();
    getUserPurchasedRewards();
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

  Future<void> getStoreItems() async {
    setLoading(true);
    try {
      final items = await firestoreService.getStoreItems();
      if(items.isNotEmpty){
        storeItems.assignAll(items);
      } else {
        storeItems.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
    }
  }

  Future<void> getUserPurchasedRewards() async {
    try {
      final items = await firestoreService.getUserPurchasedRewards();
      if(items.isNotEmpty){
        userPurchasedRewards.assignAll(items);
      } else {
        userPurchasedRewards.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> buyStoreRewards(String rewardId, int xpCost) async {
    setLoading(true);
    resetPurchaseState();
    purchasingRewardId.value = rewardId;
    try {
      await firestoreService.buyStoreItem(rewardId: rewardId, xpCost: xpCost);
      _purchaseSucceeded.value = true;
      await authService.fetchAndSetCurrentUser(); 
      loginController.refreshUserXp();
      await getUserPurchasedRewards(); // Kullanıcının satın aldığı item'ları güncelle
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
      purchasingRewardId.value = null;
    }
  }
}