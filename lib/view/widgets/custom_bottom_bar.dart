import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';


class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double barHeight = context.dynamicHeight(0.085);
    final double circleSize = barHeight * 0.65; // white circle size
    final double iconSize = circleSize * 0.5;

    const int itemCount = 4;
    final List<IconData> icons = [
      Iconsax.home,
      Iconsax.note_favorite,
      Iconsax.shop,
      HugeIcons.strokeRoundedUser,
    ];
    final List<String> labels = [
      'Home',
      'Tasks',
      'Store',
      'Profile',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicHeight(0.01),
      ),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: Colors.white, // arka plan siyah değil
          borderRadius: BorderRadius.circular(context.dynamicHeight(0.03)),
          boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          ]
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Slotlar: eşit alanlar, seçili olan boş bırakılır
                Row(
                  children: List.generate(itemCount, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: currentIndex == index
                                ? SizedBox(
                                    key: ValueKey('placeholder-$index'),
                                    width: circleSize * 2.2, // pill yaklaşan genişlikte yer tutucu
                                    height: circleSize,
                                  )
                                : _buildCircle(icons[index], circleSize, iconSize),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Kayan sarı pill
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: _alignmentForIndex(currentIndex, itemCount),
                  child: _buildPill(
                    icon: icons[currentIndex],
                    label: labels[currentIndex],
                    circleSize: circleSize,
                    iconSize: iconSize,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Alignment _alignmentForIndex(int index, int itemCount) {
    if (itemCount <= 1) return Alignment.center;
    final double x = -1.0 + (2.0 * index / (itemCount - 1));
    return Alignment(x, 0);
  }

  Widget _buildCircle(IconData icon, double size, double iconSize) {
    return Container(
      key: ValueKey('circle-$icon'),
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: Colors.black,
        size: iconSize,
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required double circleSize,
    required double iconSize,
  }) {
    const Color pillColor = Color(0xFFE9C34A);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: circleSize,
        padding: EdgeInsets.symmetric(horizontal: circleSize * 0.5),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(circleSize),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: iconSize * 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}