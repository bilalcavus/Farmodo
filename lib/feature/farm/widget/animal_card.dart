import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Column(
        children: [
          // Hayvan resmi ve durum göstergeleri
          Expanded(
            flex: 5,
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
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    image: DecorationImage(
                      image: AssetImage(animal.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Favori işareti
                if (animal.isFavorite)
                  Positioned(
                    top: context.dynamicHeight(0.012),
                    right: context.dynamicWidth(0.02),
                    child: Container(
                      padding: EdgeInsets.all(context.dynamicWidth(0.012)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withAlpha(75),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: AppColors.onPrimary,
                        size: context.dynamicHeight(0.015),
                      ),
                    ),
                  ),
                
                // Seviye göstergesi
                Positioned(
                  top: context.dynamicHeight(0.012),
                  left: context.dynamicWidth(0.02),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.02), 
                      vertical: context.dynamicHeight(0.006)
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(75),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Lv.${animal.level}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Hayvan bilgileri
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(context.dynamicWidth(0.03)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // İsim
                  Text(
                    animal.nickname.isNotEmpty ? animal.nickname : animal.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  ),
                  
                  // XP bilgisi
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.dynamicWidth(0.008)),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          size: context.dynamicHeight(0.012),
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: context.dynamicWidth(0.01)),
                      Text(
                        '${animal.experience} XP',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // XP progress bar
                  Container(
                    height: context.dynamicHeight(0.006),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (animal.experience % 100) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    ).onTap(onTap!);
  }
}
