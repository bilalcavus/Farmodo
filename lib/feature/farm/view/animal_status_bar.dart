import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class AnimalStatusBar extends StatelessWidget {
  const AnimalStatusBar({
    super.key,
    required this.farmController,
    required this.widget
  });
  final FarmController farmController;
  final AnimalDetailSheet widget;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
        final updatedAnimal = farmController.animals.firstWhere(
          (animal) => animal.id == widget.animal.id,
          orElse: () => widget.animal,
        );
        
        return Column(
          children: [
            _buildStatusBar(context, 'farm.status_hunger'.tr(), (updatedAnimal.status.hunger * 100).round(), Icons.restaurant, Colors.orange),
            context.dynamicHeight(0.015).height,
            _buildStatusBar(context, 'farm.status_love'.tr(), (updatedAnimal.status.love * 100).round(), Icons.favorite, Colors.red),
            context.dynamicHeight(0.015).height,
            _buildStatusBar(context, 'farm.status_energy'.tr(), (updatedAnimal.status.energy * 100).round(), Icons.battery_full, Colors.blue),
            context.dynamicHeight(0.015).height,
            _buildStatusBar(context, 'farm.status_health'.tr(), (updatedAnimal.status.health * 100).round(), Icons.health_and_safety, Colors.green),
          ],
        );
      });
  }

  Widget _buildStatusBar(BuildContext context, String label, int value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            context.dynamicWidth(0.015).width,
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

}
