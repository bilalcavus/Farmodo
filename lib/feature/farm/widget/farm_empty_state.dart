import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FarmEmptyState extends StatelessWidget {
  const FarmEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasyonlu ikon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 60,
                    color: Colors.green.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.04)),
          
          // Başlık
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    'Çiftliğiniz Boş',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.02)),
          
          // Açıklama
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.1),
                    ),
                    child: Text(
                      'Henüz hiç hayvanınız yok. Mağazadan hayvan satın alarak çiftliğinizi canlandırın!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.04)),
          
          // Mağaza butonu
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mağaza sayfasına yönlendir
                      Get.toNamed('/store');
                    },
                    icon: const Icon(Icons.store),
                    label: const Text('Mağazaya Git'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.06)),
          
          // Özellik listesi
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Container(
                    padding: EdgeInsets.all(context.dynamicWidth(0.05)),
                    margin: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.05),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Hayvan Bakım Özellikleri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        
                        SizedBox(height: context.dynamicHeight(0.02)),
                        
                        _buildFeatureItem(
                          Icons.restaurant,
                          'Besleme',
                          'Hayvanlarınızı düzenli olarak besleyin',
                          Colors.orange,
                        ),
                        
                        _buildFeatureItem(
                          Icons.favorite,
                          'Sevgi',
                          'Hayvanlarınıza sevgi gösterin',
                          Colors.pink,
                        ),
                        
                        _buildFeatureItem(
                          Icons.sports_esports,
                          'Oyun',
                          'Hayvanlarınızla oynayın',
                          Colors.blue,
                        ),
                        
                        _buildFeatureItem(
                          Icons.healing,
                          'Sağlık',
                          'Hasta hayvanlarınızı iyileştirin',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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
