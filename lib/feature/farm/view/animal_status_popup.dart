import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimalStatusPopup extends StatelessWidget {
  const AnimalStatusPopup({
    super.key,
    required this.animal,
    required this.farmController,
  });

  final FarmAnimal animal;
  final FarmController farmController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.1),
        vertical: context.dynamicHeight(0.1),
      ),
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            context.dynamicHeight(0.025).height,
            _buildStatusBars(context),
            context.dynamicHeight(0.025).height,
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Animal Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getAnimalColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getAnimalColor(),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.pets,
              color: _getAnimalColor(),
              size: 24,
            ),
          ),
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Level ${animal.level}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (animal.isFavorite) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFFD700),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBars(BuildContext context) {
    return Obx(() {
      final updatedAnimal = farmController.animals.firstWhere(
        (a) => a.id == animal.id,
        orElse: () => animal,
      );
      
      return Column(
        children: [
          _buildStatusBar(
            context,
            'Hunger',
            (updatedAnimal.status.hunger * 100).round(),
            Icons.restaurant,
            Colors.orange,
          ),
          context.dynamicHeight(0.02).height,
          _buildStatusBar(
            context,
            'Love',
            (updatedAnimal.status.love * 100).round(),
            Icons.favorite,
            Colors.red,
          ),
          context.dynamicHeight(0.02).height,
          _buildStatusBar(
            context,
            'Energy',
            (updatedAnimal.status.energy * 100).round(),
            Icons.battery_full,
            Colors.blue,
          ),
          context.dynamicHeight(0.02).height,
          _buildStatusBar(
            context,
            'Health',
            (updatedAnimal.status.health * 100).round(),
            Icons.health_and_safety,
            Colors.green,
          ),
        ],
      );
    });
  }

  Widget _buildStatusBar(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$value%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Close',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getAnimalColor() {
    if (animal.status.isHappy) {
      return const Color(0xFF10B981); // Green
    } else if (animal.status.isHungry) {
      return const Color(0xFFEF4444); // Red
    } else if (animal.status.isSick) {
      return const Color(0xFFDC2626); // Dark Red
    } else if (animal.status.needsLove) {
      return const Color(0xFFEC4899); // Pink
    } else {
      return const Color(0xFF6366F1); // Blue
    }
  }
}
