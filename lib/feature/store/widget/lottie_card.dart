// import 'package:easy_localization/easy_localization.dart';
// import 'package:farmodo/core/theme/app_colors.dart';
// import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
// import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
// import 'package:farmodo/data/models/purchasable_lottie.dart';
// import 'package:flutter/material.dart';
// import 'package:kartal/kartal.dart';
// import 'package:lottie/lottie.dart';

// class LottieCard extends StatelessWidget {
//   final PurchasableLottie lottie;
//   final double cardRadius;
//   final VoidCallback onBuy;
//   final bool isBuying;
//   final bool isOwned;

//   const LottieCard({
//     super.key,
//     required this.lottie,
//     required this.cardRadius,
//     required this.onBuy,
//     this.isBuying = false,
//     this.isOwned = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double padding = context.dynamicHeight(0.01);
//     final double buttonFont = context.dynamicHeight(0.016);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: context.dynamicWidth(0.015),
//         vertical: context.dynamicHeight(0.001),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
//           borderRadius: context.border.normalBorderRadius,
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(padding),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isDark
//                         ? const Color.fromARGB(255, 10, 16, 28)
//                         : Colors.grey.shade100,
//                     borderRadius: context.border.normalBorderRadius,
//                   ),
//                   child: Center(
//                     child: Lottie.asset(
//                       lottie.assetPath,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Icon(
//                           Icons.animation,
//                           size: context.dynamicHeight(0.06),
//                           color: Colors.blue,
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   lottie.name,
//                   style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.card_giftcard, color: Colors.green),
//                       SizedBox(width: context.dynamicWidth(0.01)),
//                       Text(
//                         'Free',
//                         style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                       ),
//                     ],
//                   ),
//                   context.dynamicHeight(0.006).height,
//                   isOwned
//                       ? Text(
//                           'store.owned'.tr(),
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                             fontSize: buttonFont,
//                           ),
//                         )
//                       : ElevatedButton(
//                           onPressed: isBuying ? null : onBuy,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.secondary,
//                             foregroundColor: isDark
//                                 ? AppColors.lightTextPrimary
//                                 : AppColors.darkTextPrimary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: context.border.normalBorderRadius,
//                             ),
//                           ),
//                           child: isBuying
//                               ? SizedBox(
//                                   height: context.dynamicHeight(0.02),
//                                   width: context.dynamicHeight(0.02),
//                                   child: const CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : Text(
//                                   'store.get'.tr(),
//                                   style: TextStyle(fontSize: buttonFont),
//                                 ),
//                         ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

