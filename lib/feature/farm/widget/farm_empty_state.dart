import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/store/store_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FarmEmptyState extends StatelessWidget {
  const FarmEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.02)),
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
                  width: context.dynamicWidth(0.25),
                  height: context.dynamicHeight(0.12),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: context.dynamicHeight(0.06),
                    color: Colors.green.withAlpha(25),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.03)),
          
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.015)),
          
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: context.dynamicHeight(0.03)),
          
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
                      Get.to(StoreView());
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
          
          SizedBox(height: context.dynamicHeight(0.04)),
          
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        
                        SizedBox(height: context.dynamicHeight(0.015)),
                        
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
          
          // Bottom padding to ensure content doesn't get cut off
          SizedBox(height: context.dynamicHeight(0.02)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.02)),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: context.dynamicHeight(0.025),
              ),
            ),
            
            SizedBox(width: context.dynamicWidth(0.03)),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}