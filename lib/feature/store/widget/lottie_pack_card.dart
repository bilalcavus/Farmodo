import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/lottie_pack.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';

class LottiePackCard extends StatelessWidget {
  final LottiePack pack;
  final double cardRadius;
  final VoidCallback onBuy;
  final VoidCallback onActivate;
  final VoidCallback onView;
  final String? imageAssetPath;
  final bool isBuying;
  final bool isOwned;
  final bool isActive;

  const LottiePackCard({
    super.key,
    required this.pack,
    required this.cardRadius,
    required this.onBuy,
    required this.onActivate,
    required this.onView,
    this.imageAssetPath,
    this.isBuying = false,
    this.isOwned = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final preview = pack.previewLottie;
    final double buttonFont = context.dynamicHeight(0.016);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceLabel = pack.displayPrice ?? (pack.price > 0 ? '${pack.price}' : 'store.free'.tr());

    return Padding(
      padding: context.padding.horizontalLow,
      child: InkWell(
        onTap: onView,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: isActive ? AppColors.success : Colors.transparent,
              width: isActive ? 2 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: onView,
                  tooltip: 'store.view_pack'.tr(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: imageAssetPath != null
                      ? Image.asset(
                          imageAssetPath!,
                          fit: BoxFit.contain,
                        )
                      : preview != null
                          ? Lottie.asset(
                              preview.assetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.animation,
                                  size: context.dynamicHeight(0.06),
                                  color: Colors.blue,
                                );
                              },
                            )
                          : Icon(
                              Icons.category,
                              size: context.dynamicHeight(0.06),
                              color: Colors.grey,
                            ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pack.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    context.dynamicHeight(0.004).height,
                    Text(
                      '${pack.lotties.length} ${'store.category_lotties'.tr()}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: isOwned
                        ? []
                        : [
                          // icon for price
                            Text(
                              priceLabel,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                            ),
                          ],
                  ),
                  if (!isOwned) context.dynamicHeight(0.006).height,
                  if (isOwned)
                    Column(
                      children: [
                        Text(
                          isActive ? 'store.active'.tr() : 'store.owned'.tr(),
                          style: TextStyle(
                            color: isActive ? AppColors.danger : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: buttonFont,
                          ),
                        ),
                        context.dynamicHeight(0.006).height,
                        if (!isActive)
                          TextButton(
                            onPressed: isBuying ? null : onActivate,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: context.dynamicHeight(0.0012),
                                horizontal: context.dynamicWidth(0.05),
                              ),
                              backgroundColor: AppColors.secondary,
                              foregroundColor: isDark
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(cardRadius * 0.5),
                            ),
                          ),
                          child: Text(
                            'store.activate'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium
                          ),
                        ),
                      ],
                    )
                  else
                    TextButton(
                    onPressed: (){
                      onBuy();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: context.dynamicHeight(0.0012),
                        horizontal: context.dynamicWidth(0.05),
                      ),
                    ),
                      child: isBuying
                          ? SizedBox(
                              height: context.dynamicHeight(0.02),
                              width: context.dynamicHeight(0.02),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('store.buy'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold
                              ),),
                              context.dynamicWidth(0.01).width,
                              Icon(Icons.shopping_cart, color: Colors.green, size: context.dynamicHeight(0.022)),
                            ],
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
