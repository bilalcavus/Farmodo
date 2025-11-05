import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/farm/view/farm_view.dart';
import 'package:farmodo/feature/farm/view/farm_game_fullscreen_view.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:farmodo/feature/farm/view/animal_status_popup.dart';
import 'package:farmodo/feature/farm/widget/farm_view_container.dart';
import 'package:farmodo/feature/gamification/view/gamification_view.dart';
import 'package:farmodo/feature/store/store_view.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:hugeicons/hugeicons.dart';
import 'package:kartal/kartal.dart';

class FarmGameView extends StatefulWidget {
  const FarmGameView({super.key});

  @override
  State<FarmGameView> createState() => _FarmGameViewState();
}

class _FarmGameViewState extends State<FarmGameView> {
  late FarmController farmController;
  late FarmGame farmGame;
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  final authService = getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    farmController = Get.put<FarmController>(getIt<FarmController>());
    farmGame = FarmGame();
    farmController.loadAnimals();
    farmGame.onAnimalTap = (animal) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AnimalStatusPopup(
          animal: animal,
          farmController: farmController,
        ),
      );
    };
    
    farmGame.onAnimalsReordered = (reorderedAnimals) {
      farmController.animals.assignAll(reorderedAnimals);
    };
    
    // Zoom değişikliklerini dinle
    _transformationController.addListener(() {
      final Matrix4 matrix = _transformationController.value;
      final double scale = matrix.getMaxScaleOnAxis();
      if (mounted && scale != _currentScale) {
        setState(() {
          _currentScale = scale;
        });
      }
    });
    
    // FarmController'ı dinleyerek hayvanları otomatik güncelle
    ever(farmController.animals, (List<FarmAnimal> animals) {
      if (mounted) {
        farmGame.updateFarmAnimals(animals);
      }
    });
    
    // İlk yükleme için gecikmeli güncelleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          farmGame.updateFarmAnimals(farmController.animals);
        }
      });
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: Column(
          children: [
            // Modern Farm Game Area
            Container(
              height: context.dynamicHeight(0.45),
              decoration: BoxDecoration(
                // color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: context.border.lowBorderRadius,
                child: Stack(
                  children: [
                    _buildScrollableGame(),
                    _buildModernZoomIndicator(),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        height: context.dynamicHeight(0.045),
                        width: context.dynamicWidth(0.1),
                        decoration: AppContainerStyles.primaryContainer(context),
                        child: Icon(
                          Icons.fullscreen,
                          size: context.dynamicHeight(0.03),
                        ),
                      ).onTap(() {
                        RouteHelper.push(context, const FarmGameFullscreenView());
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _ContentSections(farmController: farmController, authService: authService),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableGame() {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.7,
      maxScale: 2.0,
      constrained: false,
      scaleEnabled: true,
      panEnabled: true,
      child: SizedBox(
        width: context.dynamicWidth(1.2),
        height: context.dynamicHeight(0.45),
        child: GameWidget(game: farmGame),
      ),
    );
  }

  Widget _buildModernZoomIndicator() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: context.padding.low,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(175),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.zoom_in_rounded,
              size: context.dynamicHeight(0.015),
              color: Colors.white,
            ),
            context.dynamicWidth(0.01).width,
            Text(
              '${(_currentScale * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentSections extends StatelessWidget {
  const _ContentSections({
    required this.farmController,
    required this.authService,
  });

  final FarmController farmController;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FarmViewContainer(
            farmController: farmController,
            title: "farm.my_animals".tr(),
            icon: Icons.pets_rounded,
            iconColor: Color(0xFF10B981),
            iconContainerColor: Color(0xFF10B981).withAlpha(25),
            onTap: () => RouteHelper.push(context, const FarmView()),
            widget: Obx(() => 
              Text('${farmController.totalAnimals} ${'farm.animals_in_farm'.tr()}',style: Theme.of(context).textTheme.labelSmall)),
          ),

          context.dynamicHeight(0.01).height,
    
          FarmViewContainer(
            farmController: farmController,
            iconContainerColor: const Color(0xFFEF4444).withAlpha(25),
            iconColor: const Color(0xFFEF4444),
            title: "farm.farm_store".tr(),
            icon: HugeIcons.strokeRoundedShoppingCart01,
            widget: Text('farm.buy_animals'.tr(), style: Theme.of(context).textTheme.labelSmall, softWrap: true,),
            onTap: (){
              if (!authService.isLoggedIn) {
                _showLoginBottomSheet(context);
              } else {
                RouteHelper.push(context, const StoreView());
              }
            }
          ),
          
          context.dynamicHeight(0.01).height,
          
          FarmViewContainer(
            farmController: farmController,
            icon: HugeIcons.strokeRoundedChampion,
            iconColor: const Color(0xFF6366F1),
            iconContainerColor: const Color(0xFF6366F1).withAlpha(25),
            title: "gamification.achievements_and_quests".tr(),
            widget: Text("farm.complete_focus_sessions".tr(), 
              style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis, softWrap: true,),
            onTap: (){
              if (!authService.isLoggedIn) {
                _showLoginBottomSheet(context);
              } else {
                RouteHelper.push(context, const GamificationView());
              }
            } ,
          )
        ],
      ),
    );
  }


  void _showLoginBottomSheet(BuildContext context) {
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
}

