import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FarmGameView extends StatefulWidget {
  const FarmGameView({super.key});

  @override
  State<FarmGameView> createState() => _FarmGameViewState();
}

class _FarmGameViewState extends State<FarmGameView> {
  late FarmGame farmGame;
  late FarmController farmController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    farmController = Get.find<FarmController>();
    farmGame = FarmGame();
    farmGame.onAnimalTap = (animal) {
      _showAnimalDetailSheet(context, animal);
    };
    
    // FarmGame yüklendikten sonra hayvanları güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          farmGame.updateFarmAnimals(farmController.animals);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAnimalDetailSheet(BuildContext context, FarmAnimal animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnimalDetailSheet(animal: animal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildScrollableGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.06),
        vertical: context.dynamicHeight(0.02),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.025)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.pets_rounded,
              color: AppColors.onPrimary,
              size: context.dynamicHeight(0.028),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm View',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Obx(() => Text(
                  '${farmController.totalAnimals} animals',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildModernActionButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onTap: () async {
            await farmController.syncPurchasedAnimalsToFarm();
            farmGame.updateFarmAnimals(farmController.animals);
          },
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        _buildModernActionButton(
          icon: Icons.update_rounded,
          tooltip: 'Update Status',
          onTap: () async {
            await farmController.updateAnimalStatusesOverTime();
            farmGame.updateFarmAnimals(farmController.animals);
          },
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        _buildModernActionButton(
          icon: Icons.zoom_out_map_rounded,
          tooltip: 'Reset Zoom',
          onTap: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.025)),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: context.dynamicHeight(0.022),
          ),
        ).onTap(onTap),
      ),
    );
  }

  Widget _buildScrollableGame() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity,
        height: context.dynamicHeight(1.2), // Daha yüksek container
        child: GameWidget(game: farmGame),
      ),
    );
  }
}

// Basit Animal Detail Sheet
class _AnimalDetailSheet extends StatelessWidget {
  final FarmAnimal animal;

  const _AnimalDetailSheet({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.6),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: context.dynamicHeight(0.015)),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: context.dynamicWidth(0.04)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animal.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Level ${animal.level}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (animal.isFavorite)
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.03)),
                _buildStatusBars(),
                SizedBox(height: context.dynamicHeight(0.02)),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

 

  Widget _buildStatusBars() {
    return Column(
      children: [
        _buildStatusBar('Hunger', animal.status.hunger, Colors.orange),
        _buildStatusBar('Love', animal.status.love, Colors.pink),
        _buildStatusBar('Energy', animal.status.energy, Colors.blue),
        _buildStatusBar('Health', animal.status.health, Colors.green),
      ],
    );
  }

  Widget _buildStatusBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Feed',
            Icons.restaurant,
            Colors.orange,
            () {
              // Feed action
              Navigator.pop(context);
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context,
            'Love',
            Icons.favorite,
            Colors.pink,
            () {
              // Love action
              Navigator.pop(context);
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context,
            'Play',
            Icons.sports_esports,
            Colors.blue,
            () {
              // Play action
              Navigator.pop(context);
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            context,
            'Heal',
            Icons.medical_services,
            Colors.green,
            () {
              // Heal action
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
