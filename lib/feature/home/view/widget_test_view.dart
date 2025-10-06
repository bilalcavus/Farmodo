import 'package:farmodo/core/services/home_widget_service.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class WidgetTestView extends StatefulWidget {
  const WidgetTestView({super.key});

  @override
  State<WidgetTestView> createState() => _WidgetTestViewState();
}

class _WidgetTestViewState extends State<WidgetTestView> {
  bool _isRunning = false;
  int _secondsRemaining = 1500; // 25 dakika
  bool _isOnBreak = false;
  int _totalSeconds = 1500;
  String _taskTitle = "Test Görevi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Widget Test'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: context.padding.normal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Widget Test',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              context.dynamicHeight(0.02).height,
              
              // Widget durumu
              Container(
                width: double.infinity,
                padding: context.padding.normal,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: context.border.normalBorderRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Widget Durumu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    context.dynamicHeight(0.01).height,
                    _buildStatusRow('Çalışıyor', _isRunning ? 'Evet' : 'Hayır'),
                    _buildStatusRow('Kalan Süre', _formatTime(_secondsRemaining)),
                    _buildStatusRow('Mola', _isOnBreak ? 'Evet' : 'Hayır'),
                    _buildStatusRow('Toplam Süre', _formatTime(_totalSeconds)),
                    _buildStatusRow('Görev', _taskTitle),
                  ],
                ),
              ),
              
              context.dynamicHeight(0.03).height,
              
              // Kontrol butonları
              Text(
                'Widget Kontrolleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              context.dynamicHeight(0.02).height,
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildControlButton(
                    'Başlat/Durdur',
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    () => _toggleTimer(),
                  ),
                  _buildControlButton(
                    'Mola Modu',
                    Icons.coffee,
                    () => _toggleBreak(),
                  ),
                  _buildControlButton(
                    'Süreyi Güncelle',
                    Icons.update,
                    () => _updateWidget(),
                  ),
                  _buildControlButton(
                    'Widget Temizle',
                    Icons.clear,
                    () => _clearWidget(),
                  ),
                ],
              ),
              
              context.dynamicHeight(0.03).height,
              
              // Süre ayarları
              Text(
                'Süre Ayarları',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              context.dynamicHeight(0.02).height,
              
              Row(
                children: [
                  Expanded(
                    child: _buildTimeButton('5 dk', 300),
                  ),
                  context.dynamicWidth(0.02).width,
                  Expanded(
                    child: _buildTimeButton('15 dk', 900),
                  ),
                  context.dynamicWidth(0.02).width,
                  Expanded(
                    child: _buildTimeButton('25 dk', 1500),
                  ),
                ],
              ),
              
              context.dynamicHeight(0.02).height,
              
              // Görev başlığı
              Text(
                'Görev Başlığı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              context.dynamicHeight(0.01).height,
              
              TextField(
                onChanged: (value) {
                  setState(() {
                    _taskTitle = value.isEmpty ? 'Test Görevi' : value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Görev başlığını girin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, int seconds) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _secondsRemaining = seconds;
          _totalSeconds = seconds;
        });
        _updateWidget();
      },
      child: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });
    _updateWidget();
  }

  void _toggleBreak() {
    setState(() {
      _isOnBreak = !_isOnBreak;
    });
    _updateWidget();
  }

  void _updateWidget() {
    HomeWidgetService.updateWidget(
      timerRunning: _isRunning,
      secondsRemaining: _secondsRemaining,
      isOnBreak: _isOnBreak,
      totalSeconds: _totalSeconds,
      taskTitle: _taskTitle,
    );
  }

  void _clearWidget() {
    HomeWidgetService.clearWidget();
    setState(() {
      _isRunning = false;
      _secondsRemaining = 0;
      _isOnBreak = false;
      _totalSeconds = 0;
      _taskTitle = 'No active task';
    });
  }
}
