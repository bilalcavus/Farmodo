import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AchievementUnlockAnimation extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onComplete;

  const AchievementUnlockAnimation({
    super.key,
    required this.achievement,
    this.onComplete,
  });

  @override
  State<AchievementUnlockAnimation> createState() => _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOutQuart,
    ));

    _controller.forward();
    _particleController.forward();

    // Auto dismiss after animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(200),
      child: Stack(
        children: [
          // Particle effects
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleAnimation.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: context.dynamicWidth(0.8),
                      padding: EdgeInsets.all(context.dynamicWidth(0.06)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.achievement.rarityColor.withAlpha(75),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Achievement icon with glow effect
                          Container(
                            width: context.dynamicWidth(0.2),
                            height: context.dynamicHeight(0.12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  widget.achievement.rarityColor.withAlpha(75),
                                  widget.achievement.rarityColor.withAlpha(25),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: context.dynamicWidth(0.14),
                                height: context.dynamicHeight(0.08),
                                decoration: BoxDecoration(
                                  color: widget.achievement.rarityColor.withAlpha(50),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.emoji_events,
                                  size: context.dynamicHeight(0.05),
                                  color: widget.achievement.rarityColor,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: context.dynamicHeight(0.02)),
                          
                          // "Achievement Unlocked" text
                          Text(
                            '🎉 Başarı Açıldı!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.achievement.rarityColor,
                            ),
                          ),
                          
                          SizedBox(height: context.dynamicHeight(0.015)),
                          
                          // Achievement title
                          Text(
                            widget.achievement.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: context.dynamicHeight(0.01)),
                          
                          // Achievement description
                          Text(
                            widget.achievement.description,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: context.dynamicHeight(0.02)),
                          
                          // Rarity and XP reward
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Rarity
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.dynamicWidth(0.03),
                                  vertical: context.dynamicHeight(0.008),
                                ),
                                decoration: BoxDecoration(
                                  color: widget.achievement.rarityColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.achievement.rarityIcon,
                                      color: widget.achievement.rarityColor,
                                      size: context.dynamicHeight(0.02),
                                    ),
                                    SizedBox(width: context.dynamicWidth(0.01)),
                                    Text(
                                      _getRarityText(widget.achievement.rarity),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: widget.achievement.rarityColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // XP Reward
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.dynamicWidth(0.03),
                                  vertical: context.dynamicHeight(0.008),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.blue,
                                      size: context.dynamicHeight(0.02),
                                    ),
                                    SizedBox(width: context.dynamicWidth(0.01)),
                                    Text(
                                      '+${widget.achievement.xpReward} XP',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: context.dynamicHeight(0.02)),
                          
                          // Tap to dismiss
                          Text(
                            'Devam etmek için dokunun',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ).onTap((){
                            Navigator.of(context).pop();
                              widget.onComplete?.call();
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRarityText(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Yaygın';
      case AchievementRarity.uncommon:
        return 'Nadir';
      case AchievementRarity.rare:
        return 'Az Bulunur';
      case AchievementRarity.epic:
        return 'Efsanevi';
      case AchievementRarity.legendary:
        return 'Efsane';
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final List<Particle> particles = [];

  ParticlePainter(this.progress) {
    // Create particles if not already created
    if (particles.isEmpty) {
      for (int i = 0; i < 20; i++) {
        particles.add(Particle());
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow.withAlpha(200);

    for (final particle in particles) {
      final x = size.width * particle.x + (particle.velocityX * progress * 200);
      final y = size.height * particle.y + (particle.velocityY * progress * 200);
      final radius = particle.size * (1 - progress);

      if (radius > 0) {
        canvas.drawCircle(
          Offset(x, y),
          radius,
          // ignore: deprecated_member_use
          paint..color = particle.color.withOpacity((1 - progress) * 0.8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Particle {
  final double x = (Get.width * 0.5 + (100 * (0.5 - Get.context!.hashCode % 100 / 100))) / Get.width;
  final double y = (Get.height * 0.5 + (100 * (0.5 - Get.context!.hashCode % 100 / 100))) / Get.height;
  final double velocityX = (0.5 - Get.context!.hashCode % 100 / 100) * 2;
  final double velocityY = (0.5 - Get.context!.hashCode % 100 / 100) * 2;
  final double size = 3.0 + (Get.context!.hashCode % 5);
  final Color color = [Colors.yellow, Colors.orange, Colors.red, Colors.pink][Get.context!.hashCode % 4];
}

