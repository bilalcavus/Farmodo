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
import 'package:farmodo/feature/farm/widget/sheet_animal_header.dart';
import 'package:farmodo/feature/farm/widget/sheet_animal_status_card.dart';
import 'package:farmodo/feature/gamification/view/gamification_view.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

part 'animal_detail_sheet.dart';


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
                _buildHeader(),
                InkWell(
                  onTap: () => RouteHelper.push(context, const GamificationView()),
                  child: Container(
                    width: context.dynamicWidth(0.8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(HugeIcons.strokeRoundedChampion,),
                        context.dynamicWidth(0.02).width,
                        Text('Başarılar ve Görevler'),
                      ],
                    ),
                  ),
                ),
                _buildStatisticsCards(),
                Expanded(
                  child: _buildAnimalList(),
                ),
              ],
            ),
          ),
        ),
      );
    }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicWidth(0.03),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.025)),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.pets,
              color: Colors.green,
              size: context.dynamicHeight(0.03),
            ),
          ),
          
          SizedBox(width: context.dynamicWidth(0.04)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Çiftliğim',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${farmController.totalAnimals} hayvan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Son güncelleme: ${farmController.lastUpdateTimeString}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          
          // Yenile butonu
          IconButton(
            onPressed: () async {
              // await rewardController.getUserPurchasedRewards();
              await farmController.syncPurchasedAnimalsToFarm();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
          
          // Hayvan durumlarını güncelle butonu
          IconButton(
            onPressed: () async {
              await farmController.updateAnimalStatusesOverTime();
              Get.snackbar(
                'Güncellendi!',
                'Hayvan durumları güncellendi',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            icon: const Icon(Icons.update),
            tooltip: 'Hayvan Durumlarını Güncelle',
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Obx(() => SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Toplam',
            farmController.totalAnimals.toString(),
            Icons.pets,
          Colors.blue,
          ),
          
          _buildStatCard(
            'Favori',
            farmController.totalFavorites.toString(),
            Icons.favorite,
            Colors.red,
          ),
          _buildStatCard(
            'Aç',
            farmController.totalHungry.toString(),
            Icons.restaurant,
            Colors.orange,
          ),
          _buildStatCard(
            'Sevgi',
            farmController.totalNeedingLove.toString(),
            Icons.favorite_border,
            Colors.pink,
          ),
          _buildStatCard(
            'Yorgun',
            farmController.totalTired.toString(),
            Icons.bedtime,
            Colors.purple,
          ),
          _buildStatCard(
            'Hasta',
            farmController.totalSick.toString(),
            Icons.healing,
            Colors.red,
          ),
          _buildStatCard(
            'Mutlu',
            farmController.totalHappy.toString(),
            Icons.sentiment_satisfied,
            Colors.green,
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: context.dynamicWidth(0.22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: context.dynamicHeight(0.03),
          ),
          SizedBox(height: context.dynamicHeight(0.005)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalList() {
    return Obx(() {
      if (farmController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (farmController.animals.isEmpty) {
        return const FarmEmptyState();
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          // await rewardController.getUserPurchasedRewards();
          await farmController.syncPurchasedAnimalsToFarm();
          await farmController.updateAnimalStatusesOverTime();
        },
        child: GridView.builder(
          padding: EdgeInsets.all(context.dynamicWidth(0.05)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.dynamicWidth(0.03),
            mainAxisSpacing: context.dynamicWidth(0.02),
            childAspectRatio: 0.7,
          ),
          itemCount: farmController.animals.length,
          itemBuilder: (context, index) {
            final animal = farmController.animals[index];
            return AnimalCard(
              animal: animal,
              onTap: () => _showAnimalDetail(animal),
            );
          },
        ),
      );
    });
  }

  void _showAnimalDetail(animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimalDetailSheet(animal: animal),
    );
  }
}


