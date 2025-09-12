import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/view/farm_game_fullscreen_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:farmodo/feature/farm/widget/animal_card.dart';
import 'package:farmodo/feature/gamification/view/gamification_view.dart';
import 'package:farmodo/feature/store/store_view.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class FarmGameView extends StatefulWidget {
  const FarmGameView({super.key});

  @override
  State<FarmGameView> createState() => _FarmGameViewState();
}

class _FarmGameViewState extends State<FarmGameView> {
  late FarmController farmController;
  late FarmGame farmGame;
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    farmController = Get.put<FarmController>(getIt<FarmController>());
    farmGame = FarmGame();
    
    farmGame.onAnimalTap = (animal) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AnimalDetailSheet(animal: animal),
      );
    };
    
    farmGame.onAnimalsReordered = (reorderedAnimals) {
      // Update the controller's animals list to match the new order
      farmController.animals.assignAll(reorderedAnimals);
    };
    
    // Zoom değişikliklerini dinle
    _transformationController.addListener(() {
      final Matrix4 matrix = _transformationController.value;
      final double scale = matrix.getMaxScaleOnAxis();
      if (mounted && scale != _currentScale) {
        setState(() {
          _currentScale = scale;
        });
      }
    });
    
    // FarmController'ı dinleyerek hayvanları otomatik güncelle
    ever(farmController.animals, (List<FarmAnimal> animals) {
      if (mounted) {
        farmGame.updateFarmAnimals(animals);
      }
    });
    
    // İlk yükleme için gecikmeli güncelleme
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
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Farm Game Area
            Container(
              height: context.dynamicHeight(0.45),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    _buildScrollableGame(),
                    _buildModernZoomIndicator(),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        height: context.dynamicHeight(0.045),
                        width: context.dynamicWidth(0.1),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(175),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: context.dynamicHeight(0.03),
                        ),
                      ).onTap(() {
                        RouteHelper.push(context, const FarmGameFullscreenView());
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Modern Content Sections
            Expanded(
              child: _ContentSections(farmController: farmController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableGame() {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.7,
      maxScale: 2.0,
      constrained: false,
      scaleEnabled: true,
      panEnabled: true,
      child: SizedBox(
        width: context.dynamicWidth(1.2),
        height: context.dynamicHeight(0.45),
        child: GameWidget(game: farmGame),
      ),
    );
  }

  Widget _buildModernZoomIndicator() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(175),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.zoom_in_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              '${(_currentScale * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentSections extends StatelessWidget {
  const _ContentSections({
    required this.farmController,
  });

  final FarmController farmController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Modern My Animals Section
            _buildModernMyAnimalsSection(context),
            context.dynamicHeight(0.015).height,

            // Modern Store Section
            _buildModernStoreSection(context),
            context.dynamicHeight(0.015).height,
            
           
            // Modern Achievements Section
            _buildModernAchievementsSection(context),
            SizedBox(height: context.dynamicHeight(0.015)),
            
            
          ],
        ),
      ),
    );
  }

  Widget _buildModernAchievementsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                HugeIcons.strokeRoundedChampion,
                size: 24,
                color: const Color(0xFF6366F1),
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements & Quests',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Complete tasks and earn rewards',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF64748B),
                size: 14,
              ),
            ),
          ],
        ).onTap(() => RouteHelper.push(context, const GamificationView())),
      ),
    );
  }

  Widget _buildModernStoreSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                HugeIcons.strokeRoundedShoppingCart01,
                size: 24,
                color: const Color(0xFFEF4444),
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Store',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buy animals',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF64748B),
                size: 14,
              ),
            ),
          ],
        ).onTap(() {
          RouteHelper.push(context, const StoreView());
        }),
      ),
    );
  }

  Widget _buildModernMyAnimalsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 24,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.04)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Animals',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                          '${farmController.totalAnimals} animals in your farm',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF64748B),
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
        ).onTap(() {
          RouteHelper.push(context, const FarmView());
        }),
      ),
    );
  }

  Widget _buildModernLoadingState(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildModernEmptyState(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF64748B).withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.pets_outlined,
                color: Color(0xFF64748B),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No animals yet',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAnimalPreview(BuildContext context) {
    final previewAnimals = farmController.animals.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ...previewAnimals.asMap().entries.map((entry) {
            final index = entry.key;
            final animal = entry.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < previewAnimals.length - 1 ? 12 : 0,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AnimalCard(
                        animal: animal,
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AnimalDetailSheet(animal: animal),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          
          if (farmController.animals.length > 3) ...[
            const SizedBox(width: 12),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+${farmController.animals.length - 3}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}