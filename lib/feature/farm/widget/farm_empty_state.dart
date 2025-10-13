import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/store/store_view.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class FarmEmptyState extends StatelessWidget {
  const FarmEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    void showLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginBottomSheet(
        title: 'farm.login_to_buy_animals'.tr(),
        subTitle: 'farm.login_to_purchase_animals'.tr(),
      ),
    );
  }
    final authService = getIt<AuthService>();
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
                    color: Colors.green.withAlpha(55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: context.dynamicHeight(0.06),
                    color: Colors.green
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
                    'farm.farm_empty_title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                      'farm.farm_empty_description'.tr(),
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
                      if (!authService.isLoggedIn) {
                        showLoginBottomSheet();
                      } else {
                        Get.to(StoreView());
                      }
                    },
                    icon: const Icon(Icons.store),
                    label: Text('farm.go_to_store'.tr()),
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
                    decoration: AppContainerStyles.secondaryContainer(context),
                    child: Column(
                      children: [
                        Text(
                          'farm.animal_care_features'.tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        SizedBox(height: context.dynamicHeight(0.015)),
                        
                        _buildFeatureItem(
                          Icons.restaurant,
                          'farm.feeding'.tr(),
                          'farm.feeding_description'.tr(),
                          Colors.orange,
                        ),
                        
                        _buildFeatureItem(
                          Icons.favorite,
                          'farm.loving'.tr(),
                          'farm.loving_description'.tr(),
                          Colors.pink,
                        ),
                        
                        _buildFeatureItem(
                          Icons.sports_esports,
                          'farm.playing'.tr(),
                          'farm.playing_description'.tr(),
                          Colors.blue,
                        ),
                        
                        _buildFeatureItem(
                          Icons.healing,
                          'farm.health'.tr(),
                          'farm.health_description'.tr(),
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