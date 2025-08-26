import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:flutter/material.dart';

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
              Colors.grey.shade100,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
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
                      top: context.dynamicHeight(0.01),
                      right: context.dynamicWidth(0.02),
                      child: Container(
                        padding: EdgeInsets.all(context.dynamicWidth(0.01)),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: context.dynamicHeight(0.02),
                        ),
                      ),
                    ),
                  
                  // Seviye göstergesi
                  Positioned(
                    top: context.dynamicHeight(0.01),
                    left: context.dynamicWidth(0.02),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.02), 
                        vertical: context.dynamicHeight(0.005)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lv.${animal.level}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Durum göstergeleri
                  Positioned(
                    bottom: context.dynamicHeight(0.002),
                    left: context.dynamicWidth(0.02),
                    right: context.dynamicWidth(0.02),
                    child: Row(
                      children: [
                        _buildStatusIndicator(
                          'Açlık',
                          animal.status.hunger,
                          Colors.orange,
                          Icons.restaurant,
                        ),
                        SizedBox(width: context.dynamicWidth(0.01)),
                        _buildStatusIndicator(
                          'Sevgi',
                          animal.status.love,
                          Colors.pink,
                          Icons.favorite,
                        ),
                        SizedBox(width: context.dynamicWidth(0.01)),
                        _buildStatusIndicator(
                          'Enerji',
                          animal.status.energy,
                          Colors.blue,
                          Icons.flash_on,
                        ),
                        SizedBox(width: context.dynamicWidth(0.01)),
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        ),
                        if (animal.nickname.isNotEmpty)
                          Flexible(
                            child: Text(
                              '(${animal.name})',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                    
                    // Deneyim puanı
                    SizedBox(height: context.dynamicHeight(0.005)),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: context.dynamicHeight(0.015),
                          color: Colors.amber,
                        ),
                        SizedBox(width: context.dynamicWidth(0.01)),
                        Text(
                          '${animal.experience} XP',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: context.dynamicHeight(0.005)),
                    
                    // Deneyim çubuğu
                    LinearProgressIndicator(
                      value: (animal.experience % 100) / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    
                    SizedBox(height: context.dynamicHeight(0.005)),
                    
                    Text(
                      '${animal.experience % 100}/100 XP',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
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
    return Builder(
      builder: (context) => Expanded(
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: context.dynamicHeight(0.02),
            ),
            SizedBox(height: context.dynamicHeight(0.003)),
            LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: context.dynamicHeight(0.004),
            ),
          ],
        ),
      ),
    );
  }
}
