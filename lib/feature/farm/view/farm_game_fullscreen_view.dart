import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FarmGameFullscreenView extends StatefulWidget {
  const FarmGameFullscreenView({super.key});

  @override
  State<FarmGameFullscreenView> createState() => _FarmGameFullscreenViewState();
}

class _FarmGameFullscreenViewState extends State<FarmGameFullscreenView> {
  late FarmController farmController;
  late FarmGame farmGame;
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    
    // Hide system UI for true fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    farmController = Get.find<FarmController>();
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
    // Restore system UI when leaving fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Fullscreen Game Area
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 3.0,
              constrained: false,
              scaleEnabled: true,
              panEnabled: true,
              child: SizedBox(
                width: context.dynamicWidth(2.0), // Larger game world for fullscreen
                height: context.dynamicHeight(2.0),
                child: GameWidget(game: farmGame),
              ),
            ),
          ),
          
          // Top Controls Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Exit Fullscreen Button
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white,
                    size: 24,
                  ),
                ).onTap(() {
                  Navigator.of(context).pop();
                }),
                
                // Zoom Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.zoom_in_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_currentScale * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Controls Overlay
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Animal Count Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${farmController.totalAnimals} Animals',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )),
                ),
                
                // Zoom Controls
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                        child: const Icon(
                          Icons.zoom_out,
                          color: Colors.white,
                          size: 20,
                        ),
                      ).onTap(() {
                        final currentMatrix = _transformationController.value;
                        final newScale = (currentMatrix.getMaxScaleOnAxis() * 0.8).clamp(0.5, 3.0);
                        _transformationController.value = Matrix4.identity()..scale(newScale);
                      }),
                      
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
                      ).onTap(() {
                        final currentMatrix = _transformationController.value;
                        final newScale = (currentMatrix.getMaxScaleOnAxis() * 1.2).clamp(0.5, 3.0);
                        _transformationController.value = Matrix4.identity()..scale(newScale);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
