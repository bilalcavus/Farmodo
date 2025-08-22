import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/widget/animal_card.dart';
import 'package:farmodo/feature/farm/widget/animal_detail_sheet.dart';
import 'package:farmodo/feature/farm/widget/farm_empty_state.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FarmView extends StatefulWidget {
  const FarmView({super.key});

  @override
  State<FarmView> createState() => _FarmViewState();
}

class _FarmViewState extends State<FarmView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
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
    
    // RewardController verilerini yükle ve hayvanları senkronize et
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rewardController.getUserPurchasedRewards();
      await farmController.syncPurchasedAnimalsToFarm();
    });
  }

  @override
  void dispose() {
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
               // Header
               _buildHeader(),
               
               // İstatistik kartları
               _buildStatisticsCards(),
               
               // Hayvan listesi
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
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.pets,
              color: Colors.green,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Çiftliğim',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  '${farmController.totalAnimals} hayvan (${rewardController.userPurchasedRewards.length} satın alındı)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                )),
              ],
            ),
          ),
          
          // Yenile butonu
          IconButton(
            onPressed: () async {
              await rewardController.getUserPurchasedRewards();
              await farmController.syncPurchasedAnimalsToFarm();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        children: [
                     _buildStatCard(
             'Toplam',
             farmController.totalAnimals.toString(),
             Icons.pets,
             Colors.blue,
           ),
           _buildStatCard(
             'Satın Alınan',
             rewardController.userPurchasedRewards.length.toString(),
             Icons.shopping_cart,
             Colors.purple,
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
      )),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
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
          await rewardController.getUserPurchasedRewards();
          await farmController.syncPurchasedAnimalsToFarm();
        },
        child: GridView.builder(
          padding: EdgeInsets.all(context.dynamicWidth(0.05)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.dynamicWidth(0.03),
            mainAxisSpacing: context.dynamicWidth(0.03),
            childAspectRatio: 0.6,
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


