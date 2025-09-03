import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SheetAnimalStatus extends StatelessWidget {
  const SheetAnimalStatus({
    super.key,
    required FarmController farmController,
    required this.widget,
  }) : _farmController = farmController;

  final FarmController _farmController;
  final AnimalDetailSheet widget;

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold
              )
            ),
            
            context.dynamicHeight(0.012).height,
            
            Obx(() {
              final updatedAnimal = _farmController.animals.firstWhere(
                (animal) => animal.id == widget.animal.id,
                orElse: () => widget.animal,
              );
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: context.dynamicHeight(0.002),
                children: [
                  _buildStatusCard(
                    context,
                    'Hungery',
                    updatedAnimal.status.hunger,
                    Colors.orange,
                    Icons.restaurant,
                  ),
                  _buildStatusCard(
                    context,
                    'Love',
                    updatedAnimal.status.love,
                    Colors.pink,
                    Icons.favorite,
                  ),
                  _buildStatusCard(
                    context,
                    'Energy',
                    updatedAnimal.status.energy,
                    Colors.blue,
                    Icons.flash_on,
                  ),
                  _buildStatusCard(
                    context,
                    'Health',
                    updatedAnimal.status.health,
                    Colors.green,
                    Icons.health_and_safety,
                  ),
                ],
              );
            }),
          ],
        );
  }

  Widget _buildStatusCard(BuildContext context, String title, double value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(15),
        // border: Border.all(color: color.withAlpha(75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: context.dynamicHeight(0.025)),
              SizedBox(width: context.dynamicWidth(0.02)),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.dynamicHeight(0.01)),
          
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: context.dynamicHeight(0.008),
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
          ),
          
          SizedBox(height: context.dynamicHeight(0.005)),
          
          Text(
            '${(value * 100).toInt()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
