import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimalCard extends StatelessWidget {
  final FarmAnimal animal;
  final VoidCallback? onTap;
  final bool showActions;

  const AnimalCard({
    super.key,
    required this.animal,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final farmController = Get.find<FarmController>();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(context.dynamicWidth(0.025)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Hayvan resmi ve durum göstergeleri
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Hayvan resmi
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: AssetImage(animal.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Favori işareti
                  if (animal.isFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  
                  // Seviye göstergesi
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lv.${animal.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  // Durum göstergeleri
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _buildStatusIndicator(
                          'Açlık',
                          animal.status.hunger,
                          Colors.orange,
                          Icons.restaurant,
                        ),
                        const SizedBox(width: 4),
                        _buildStatusIndicator(
                          'Sevgi',
                          animal.status.love,
                          Colors.pink,
                          Icons.favorite,
                        ),
                        const SizedBox(width: 4),
                        _buildStatusIndicator(
                          'Enerji',
                          animal.status.energy,
                          Colors.blue,
                          Icons.flash_on,
                        ),
                        const SizedBox(width: 4),
                        _buildStatusIndicator(
                          'Sağlık',
                          animal.status.health,
                          Colors.green,
                          Icons.health_and_safety,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Hayvan bilgileri
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İsim ve takma ad
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            animal.nickname.isNotEmpty ? animal.nickname : animal.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (animal.nickname.isNotEmpty)
                          Flexible(
                            child: Text(
                              '(${animal.name})',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Deneyim çubuğu
                    LinearProgressIndicator(
                      value: (animal.experience % 100) / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${animal.experience % 100}/100 XP',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Aksiyon butonları
                    if (showActions)
                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.restaurant,
                              color: Colors.orange,
                              isLoading: farmController.feedingAnimalId.value == animal.id,
                              onTap: () => farmController.feedAnimal(animal.id),
                              tooltip: 'Besle',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.favorite,
                              color: Colors.pink,
                              isLoading: farmController.lovingAnimalId.value == animal.id,
                              onTap: () => farmController.loveAnimal(animal.id),
                              tooltip: 'Sev',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.sports_esports,
                              color: Colors.blue,
                              isLoading: farmController.playingAnimalId.value == animal.id,
                              onTap: () => farmController.playWithAnimal(animal.id),
                              tooltip: 'Oyna',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.healing,
                              color: Colors.green,
                              isLoading: farmController.healingAnimalId.value == animal.id,
                              onTap: () => farmController.healAnimal(animal.id),
                              tooltip: 'İyileştir',
                            ),
                          ),
                        ],
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLoading ? Colors.grey.shade300 : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isLoading ? Colors.grey.shade400 : color.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
          ),
        ),
      ),
    );
  }
}
