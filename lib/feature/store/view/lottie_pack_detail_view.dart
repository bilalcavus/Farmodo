import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/models/lottie_pack.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottiePackDetailView extends StatelessWidget {
  final LottiePack pack;
  final bool isOwned;
  final bool isActive;

  const LottiePackDetailView({
    super.key,
    required this.pack,
    required this.isOwned,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(pack.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${pack.lotties.length} animation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: context.dynamicWidth(0.02),
                  mainAxisSpacing: context.dynamicWidth(0.02),
                ),
                itemCount: pack.lotties.length,
                itemBuilder: (context, index) {
                  final lottie = pack.lotties[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.danger : Colors.transparent,
                        width: isActive ? 1.2 : 0.5,
                      ),
                    ),
                    padding: EdgeInsets.all(context.dynamicWidth(0.03)),
                    child: Column(
                      children: [
                        Expanded(
                          child: Lottie.asset(
                            lottie.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.008)),
                        Text(
                          lottie.name.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
