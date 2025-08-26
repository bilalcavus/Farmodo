import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required FarmController farmController,
    required this.widget,
  }) : _farmController = farmController;

  final FarmController _farmController;
  final AnimalDetailSheet widget;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final updatedAnimal = _farmController.animals.firstWhere(
        (animal) => animal.id == widget.animal.id,
          orElse: () => widget.animal);
      return Row(
        children: [
          _sheetAnimalImage(context, updatedAnimal),
              context.dynamicWidth(0.04).width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(updatedAnimal.nickname.isNotEmpty 
                              ? updatedAnimal.nickname 
                              : updatedAnimal.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _farmController.toggleAnimalFavorite(updatedAnimal.id),
                          child: Icon(
                            updatedAnimal.isFavorite 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: context.dynamicHeight(0.035),
                          ),
                        ),
                      ],
                    ),
                    if (updatedAnimal.nickname.isNotEmpty)
                      Text(
                        updatedAnimal.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  context.dynamicHeight(0.01).height,
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dynamicWidth(0.03), 
                            vertical: context.dynamicHeight(0.008)
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Level ${updatedAnimal.level}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    context.dynamicWidth(0.03).width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Experience: ${updatedAnimal.experience} XP',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              context.dynamicHeight(0.005).height,
                              LinearProgressIndicator(
                                value: (updatedAnimal.experience % 100) / 100,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Container _sheetAnimalImage(BuildContext context, FarmAnimal updatedAnimal) {
    return Container(
      width: context.dynamicWidth(0.2),
      height: context.dynamicHeight(0.11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              updatedAnimal.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
  }

