import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/mixin/farm_view_mixin.dart';
import 'package:farmodo/feature/farm/view/animal_status_bar.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:farmodo/feature/farm/widget/animal_card.dart';
import 'package:farmodo/feature/farm/widget/farm_empty_state.dart';
import 'package:farmodo/feature/farm/widget/sheet_animal_header.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'animal_detail_sheet.dart';
// part 'farm_header.dart';
part 'stats_cards.dart';
part 'user_animal_list.dart';

class FarmView extends StatefulWidget {
  const FarmView({super.key});

  @override
  State<FarmView> createState() => _FarmViewState();
}

class _FarmViewState extends State<FarmView> with TickerProviderStateMixin, FarmViewMixin {
  final navigationController = getIt<NavigationController>();
  late FarmGame farmGame;
  
  @override
  void initState() {
    super.initState();
    farmGame = FarmGame();
    farmGame.onAnimalTap = (animal) {
      _showAnimalDetailSheet(context, animal);
    };
  }

  

  void _showAnimalDetailSheet(BuildContext context, FarmAnimal animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimalDetailSheet(animal: animal),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ActionButtons(farmController: farmController),
            Expanded(
              child: _UserAnimalList(farmController: farmController, context: context),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key, required this.farmController,
  });

  final FarmController farmController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildModernActionButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onTap: () async => await farmController.syncPurchasedAnimalsToFarm(),
          context: context
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        _buildModernActionButton(
          icon: Icons.update_rounded,
          tooltip: 'Update Status',
          onTap: () async {
            await farmController.updateAnimalStatusesOverTime();
            SnackMessages().showUpdateSnack();
          },
          context: context
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        _buildModernActionButton(
          icon: Icons.info_outline,
          tooltip: 'Statistics',
          onTap: () => _showStatsDialog(context),
          context: context
        ),
        
      ],
    );
  }
   Widget _buildModernActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Container(
      decoration: AppContainerStyles.primaryContainer(context),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.025)),
          child: Icon(
            icon,
            size: context.dynamicHeight(0.022),
          ),
        ).onTap(onTap),
      ),
    );
  }
  
  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(context.dynamicHeight(0.04)),
            decoration: AppContainerStyles.secondaryContainer(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Farm Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close,),
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.03)),
                _StatsCards(),
              ],
            ),
          ),
        );
      },
    );
  }
}

