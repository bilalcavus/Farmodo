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
        title: Text('Widget Ekleme Rehberi', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.padding.normal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              
              Text(
                'Widget\'ı ana ekranınıza ekleyerek Pomodoro timer\'ınızı hızlıca kontrol edebilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              context.dynamicHeight(0.03).height,
              
              // Android Rehberi
              _buildPlatformSection(
                context,
                'Android',
                Icons.android,
                [
                  _buildStep(context, '1', 'Ana ekranda boş bir alana uzun basın'),
                  _buildStep(context, '2', '"Widgets" seçeneğine dokunun'),
                  _buildStep(context, '3', '"Farmodo" uygulamasını bulun'),
                  _buildStep(context, '4', '"Pomodoro Timer" widget\'ını seçin'),
                  _buildStep(context, '5', 'Ana ekranda istediğiniz konuma sürükleyin'),
                ],
              ),
              
              context.dynamicHeight(0.03).height,
              
              // iOS Rehberi
              _buildPlatformSection(
                context,
                'iOS',
                Icons.phone_iphone,
                [
                  _buildStep(context, '1', 'Ana ekranda boş bir alana uzun basın'),
                  _buildStep(context, '2', 'Sol üst köşedeki "+" butonuna dokunun'),
                  _buildStep(context, '3', '"Farmodo" uygulamasını arayın'),
                  _buildStep(context, '4', 'Widget boyutunu seçin'),
                  _buildStep(context, '5', '"Add Widget" butonuna dokunun'),
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
                'Widget Özellikleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          context.dynamicHeight(0.02).height,
          _buildFeatureItem(context, '⏱️', 'Gerçek zamanlı timer görüntüleme'),
          _buildFeatureItem(context, '📝', 'Aktif görev bilgileri'),
          _buildFeatureItem(context, '▶️', 'Timer kontrolü (başlat/durdur)'),
          _buildFeatureItem(context, '🔄', 'Otomatik güncelleme'),
          _buildFeatureItem(context, '📱', 'Uygulamayı açma'),
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
                'Sorun Giderme',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          context.dynamicHeight(0.02).height,
          _buildTroubleshootingItem(
            context,
            'Widget görünmüyor',
            'Uygulamayı yeniden başlatın ve widget\'ı tekrar ekleyin.',
          ),
          _buildTroubleshootingItem(
            context,
            'Widget güncellenmiyor',
            'Uygulamanın arka planda çalıştığından emin olun.',
          ),
          _buildTroubleshootingItem(
            context,
            'Timer senkronize değil',
            'Widget\'ı kaldırıp tekrar ekleyin.',
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
