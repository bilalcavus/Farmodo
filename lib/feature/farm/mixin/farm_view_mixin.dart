

import 'dart:async';

import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin FarmViewMixin on State<FarmView> {
  Timer? _statusUpdateTimer;
  
  final FarmController farmController = Get.put(FarmController(getIt<LoginController>(), getIt<AuthService>()));
  final RewardController rewardController = getIt<RewardController>();

  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await farmController.syncPurchasedAnimalsToFarm();
      await farmController.updateAnimalStatusesOverTime();
    });
    
    // Her 5 dakikada bir hayvan durumlarını güncelle
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      farmController.updateAnimalStatusesOverTime();
    });
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }
}


