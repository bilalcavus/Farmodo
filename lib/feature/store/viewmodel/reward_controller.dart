import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RewardController extends GetxController {
  final FirestoreService firestoreService;
  TextEditingController rewardIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxnInt xpCost = RxnInt();
  String imageUrl = '';
  var errorMessage = ''.obs;
  final _isPremium = false.obs;
  final _isLoading = false.obs;
  RxBool get isPremium => _isPremium;
  RxBool get isLoading => _isLoading;
  RxList storeItems = <Reward>[].obs;



  @override
  void onReady() {
    super.onReady();
    getStoreItems();
  }

  
  RewardController(this.firestoreService);

  void setLoading(bool value){
    _isLoading.value = value;
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
}