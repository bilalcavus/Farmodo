import 'dart:async';

import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/widget/animal_card.dart';
import 'package:farmodo/feature/farm/widget/farm_empty_state.dart';
import 'package:farmodo/feature/farm/widget/refresh_button.dart';
import 'package:farmodo/feature/farm/widget/sheet_animal_header.dart';
import 'package:farmodo/feature/farm/widget/sheet_animal_status_card.dart';
import 'package:farmodo/feature/gamification/view/gamification_view.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

part 'animal_detail_sheet.dart';
part 'farm_header.dart';
part 'stats_cards.dart';
part 'user_animal_list.dart';

class FarmView extends StatefulWidget {
  const FarmView({super.key});

  @override
  State<FarmView> createState() => _FarmViewState();
}

class _FarmViewState extends State<FarmView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _statusUpdateTimer;
  
  final FarmController farmController = Get.put(FarmController());
  final RewardController rewardController = getIt<RewardController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
                _FarmHeader(context: context, farmController: farmController),
                _achievementsAndQuests(context),
                _StatsCards(farmController: farmController),
                Expanded(
                  child: _UserAnimalList(farmController: farmController, context: context)
                ),
              ],
            ),
          ),
        ),
      );
    }

  Widget _achievementsAndQuests(BuildContext context) {
    return InkWell(
      onTap: () => RouteHelper.push(context, const GamificationView()),
      child: Container(
        width: context.dynamicWidth(0.8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(HugeIcons.strokeRoundedChampion,),
            context.dynamicWidth(0.02).width,
            Text('Başarılar ve Görevler'),
            Spacer(),
            Icon(HugeIcons.strokeRoundedArrowRight01)
          ],
        ),
      ),
    );
  }
}

