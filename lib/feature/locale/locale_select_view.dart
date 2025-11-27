import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/constants/locales.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/locale/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Locale değişikliklerini dinle ve controller'ı senkronize et
    final localeController = getIt<LocaleController>();
    localeController.syncWithContext(context.locale);
  }

  @override
  Widget build(BuildContext context) {
    final localeController = getIt<LocaleController>();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.03),
      ),
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Obx(() {
        final currentLocale = localeController.getCurrentLocaleEnum();
        
        return DropdownButton<Locales>(
          value: currentLocale,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).iconTheme.color,
          ),
          style: TextStyle(
            fontSize: context.dynamicHeight(0.018),
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          items: Locales.values.map((Locales locale) {
            return DropdownMenuItem<Locales>(
              value: locale,
              child: Row(
                children: [
                  Text(
                    _getLanguageFlag(locale),
                    style: TextStyle(fontSize: context.dynamicHeight(0.025)),
                  ),
                  SizedBox(width: context.dynamicWidth(0.03)),
                  Expanded(
                    child: Text(
                      localeController.getLocaleName(locale),
                      style: TextStyle(
                        fontSize: context.dynamicHeight(0.018),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (Locales? newLocale) async {
            if (newLocale != null && newLocale != currentLocale) {
              await localeController.changeLanguage(context, newLocale);
              
              if (mounted && context.mounted) {
                setState(() {});
                
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${'messages.language_changed'.tr()} ${localeController.getLocaleName(newLocale)}'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
              }
            }
          },
        );
      }),
    );
  }

  String _getLanguageFlag(Locales locale) {
    switch (locale) {
      case Locales.en:
        return '🇺🇸';
      case Locales.tr:
        return '🇹🇷';
      case Locales.de:
        return '🇩🇪';
      case Locales.fr:
        return '🇫🇷';
      case Locales.ar:
        return '🇸🇦';
      case Locales.id:
        return '🇮🇩';
      case Locales.ms:
        return '🇲🇾';
      case Locales.ja:
        return '🇯🇵';
      case Locales.ko:
        return '🇰🇷';
      case Locales.th:
        return '🇹🇭';
      case Locales.vi:
        return '🇻🇳';
      case Locales.zhTw:
        return '🇹🇼';
      case Locales.no:
        return '🇳🇴';
      case Locales.ptBR:
        return '🇧🇷';
      case Locales.sk:
        return '🇸🇰';
      case Locales.es:
        return '🇪🇸';
      case Locales.sv:
        return '🇸🇪';
    }
  }
}
