import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class WidgetGuideView extends StatelessWidget {
  const WidgetGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('widget.widget_installation_guide'.tr(), style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.padding.normal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              
              Text(
                'widget.add_widget_description'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              context.dynamicHeight(0.03).height,
              
              // Android Rehberi
              _buildPlatformSection(
                context,
                'widget.android'.tr(),
                Icons.android,
                [
                  _buildStep(context, '1', 'widget.android_step_1'.tr()),
                  _buildStep(context, '2', 'widget.android_step_2'.tr()),
                  _buildStep(context, '3', 'widget.android_step_3'.tr()),
                  _buildStep(context, '4', 'widget.android_step_4'.tr()),
                  _buildStep(context, '5', 'widget.android_step_5'.tr()),
                ],
              ),
              
              context.dynamicHeight(0.03).height,
              
              // iOS Rehberi
              _buildPlatformSection(
                context,
                'widget.ios'.tr(),
                Icons.phone_iphone,
                [
                  _buildStep(context, '1', 'widget.ios_step_1'.tr()),
                  _buildStep(context, '2', 'widget.ios_step_2'.tr()),
                  _buildStep(context, '3', 'widget.ios_step_3'.tr()),
                  _buildStep(context, '4', 'widget.ios_step_4'.tr()),
                  _buildStep(context, '5', 'widget.ios_step_5'.tr()),
                ],
              ),
              
              context.dynamicHeight(0.03).height,
              
              // Widget Özellikleri
              _buildFeatureSection(context),
              
              context.dynamicHeight(0.03).height,
              
              // Sorun Giderme
              _buildTroubleshootingSection(context),
              
              context.dynamicHeight(0.02).height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformSection(
    BuildContext context,
    String platform,
    IconData icon,
    List<Widget> steps,
  ) {
    return Container(
      width: double.infinity,
      padding: context.padding.normal,
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              context.dynamicWidth(0.02).width,
              Text(
                platform,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          context.dynamicHeight(0.02).height,
          ...steps,
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ),
          context.dynamicWidth(0.03).width,
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.padding.normal,
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: AppColors.secondary, size: 24),
              context.dynamicWidth(0.02).width,
              Text(
                'widget.widget_features'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          context.dynamicHeight(0.02).height,
          _buildFeatureItem(context, '⏱️', 'widget.feature_realtime_timer'.tr()),
          _buildFeatureItem(context, '📝', 'widget.feature_active_task'.tr()),
          _buildFeatureItem(context, '▶️', 'widget.feature_timer_control'.tr()),
          _buildFeatureItem(context, '🔄', 'widget.feature_auto_update'.tr()),
          _buildFeatureItem(context, '📱', 'widget.feature_open_app'.tr()),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          context.dynamicWidth(0.02).width,
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.padding.normal,
      decoration:  AppContainerStyles.secondaryContainer(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.danger),
              context.dynamicWidth(0.02).width,
              Text(
                'widget.troubleshooting'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          context.dynamicHeight(0.02).height,
          _buildTroubleshootingItem(
            context,
            'widget.problem_widget_not_visible'.tr(),
            'widget.solution_widget_not_visible'.tr(),
          ),
          _buildTroubleshootingItem(
            context,
            'widget.problem_widget_not_updating'.tr(),
            'widget.solution_widget_not_updating'.tr(),
          ),
          _buildTroubleshootingItem(
            context,
            'widget.problem_timer_not_synced'.tr(),
            'widget.solution_timer_not_synced'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(
    BuildContext context,
    String problem,
    String solution,
  ) {
    return Padding(
      padding: context.padding.onlyBottomLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            problem,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          context.dynamicHeight(0.007).height,
          Text(
            solution,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
