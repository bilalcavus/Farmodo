import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/feature/farm/mixin/farm_view_mixin.dart';
import 'package:farmodo/feature/farm/view/animal_status_bar.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/farm/widget/animal_card.dart';
import 'package:farmodo/feature/farm/widget/farm_empty_state.dart';
import 'package:farmodo/feature/farm/widget/sheet_animal_header.dart';
import 'package:farmodo/feature/gamification/view/gamification_view.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

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
  
  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(context.dynamicHeight(0.04)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      iconSize: 20,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _farmHeader(),
            Expanded(
              child: _UserAnimalList(farmController: farmController, context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _farmHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.06),
        vertical: context.dynamicHeight(0.02),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.025)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets_rounded,
                  color: AppColors.onPrimary,
                  size: context.dynamicHeight(0.028),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.04)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Farm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Obx(() => Text(
                      '${farmController.totalAnimals} animals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ],
                ),
              ),
              _buildActionButtons(),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.025)),
          _buildAchievementsCard(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildModernActionButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onTap: () async => await farmController.syncPurchasedAnimalsToFarm(),
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        _buildModernActionButton(
          icon: Icons.update_rounded,
          tooltip: 'Update Status',
          onTap: () async {
            await farmController.updateAnimalStatusesOverTime();
            SnackMessages().showUpdateSnack();
          },
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        _buildModernActionButton(
          icon: HugeIcons.strokeRoundedDiscoverCircle,
          tooltip: 'Statistics',
          onTap: () => _showStatsDialog(context),
        ),
      ],
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.025)),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: context.dynamicHeight(0.022),
          ),
        ).onTap(onTap),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(25),
            AppColors.primary.withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withAlpha(25),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.025)),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                HugeIcons.strokeRoundedChampion,
                color: AppColors.onPrimary,
                size: context.dynamicHeight(0.022),
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.035)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements & Quests',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Complete tasks and earn rewards',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.primary,
              size: context.dynamicHeight(0.022),
            ),
          ],
        ).onTap(() => RouteHelper.push(context, const GamificationView())),
      ),
    );
  }
}

