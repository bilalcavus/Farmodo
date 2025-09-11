import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:flame/game.dart' hide Matrix4;
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
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    farmController = Get.find<FarmController>();
    farmGame = FarmGame();
    farmGame.onAnimalTap = (animal) {
      _showAnimalDetailSheet(context, animal);
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
      backgroundColor: Color(0xFF8BC34A), 
      body: SafeArea(
        child: Column(
          children: [
            // _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildScrollableGame(),
                  _buildZoomIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


 
  Widget _buildScrollableGame() {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.5,
      maxScale: 3.0,
      constrained: false,
      scaleEnabled: true,
      panEnabled: true,
      child: SizedBox(
        width: context.dynamicWidth(1.5), // Genişliği artır
        height: context.dynamicHeight(1.5), // Yüksekliği artır
        child: GameWidget(game: farmGame),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Positioned(
      bottom: context.dynamicHeight(0.03),
      right: context.dynamicWidth(0.05),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.03),
          vertical: context.dynamicHeight(0.01),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.zoom_in_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
            Text(
              '${(_currentScale * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animal Detail Sheet with FarmController integration
class _AnimalDetailSheet extends StatefulWidget {
  final FarmAnimal animal;

  const _AnimalDetailSheet({required this.animal});

  @override
  State<_AnimalDetailSheet> createState() => _AnimalDetailSheetState();
}

class _AnimalDetailSheetState extends State<_AnimalDetailSheet> {
  late FarmController farmController;

  @override
  void initState() {
    super.initState();
    farmController = Get.find<FarmController>();
  }

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
                            widget.animal.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Level ${widget.animal.level}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.animal.isFavorite)
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
        _buildStatusBar('Hunger', widget.animal.status.hunger, Colors.orange),
        _buildStatusBar('Love', widget.animal.status.love, Colors.pink),
        _buildStatusBar('Energy', widget.animal.status.energy, Colors.blue),
        _buildStatusBar('Health', widget.animal.status.health, Colors.green),
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
            () async {
              await farmController.feedAnimal(widget.animal.id);
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
            () async {
              await farmController.loveAnimal(widget.animal.id);
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
            () async {
              await farmController.playWithAnimal(widget.animal.id);
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
            () async {
              await farmController.healAnimal(widget.animal.id);
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
    Future<void> Function() onTap,
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
          onTap: () async => await onTap(),
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
