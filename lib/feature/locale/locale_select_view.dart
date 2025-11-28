import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/constants/locales.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/locale/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class LocaleSelectView extends StatefulWidget {
  const LocaleSelectView({super.key});

  @override
  State<LocaleSelectView> createState() => _LocaleSelectViewState();
}

class _LocaleSelectViewState extends State<LocaleSelectView> {
  final LocaleController localeController = getIt<LocaleController>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer syncing to avoid triggering rebuilds during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        localeController.syncWithContext(context.locale);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('account.language'.tr()),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Obx(() {
          final selectedLocale = localeController.getCurrentLocaleEnum();
          return ListView.separated(
            itemCount: Locales.values.length,
            separatorBuilder: (_, __) => context.dynamicHeight(0.015).height,
            itemBuilder: (context, index) {
              final locale = Locales.values[index];
              final isSelected = locale == selectedLocale;
              return _LanguageTile(
                locale: locale,
                localeController: localeController,
                isSelected: isSelected,
                onTap: () => _onLocaleTap(locale, isSelected),
              );
            },
          );
        }),
      ),
    );
  }

  Future<void> _onLocaleTap(Locales locale, bool isSelected) async {
    if (isSelected) return;

    await localeController.changeLanguage(context, locale);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${'messages.language_changed'.tr()} ${localeController.getLocaleName(locale)}',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    RouteHelper.pop(context);
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.localeController,
    required this.isSelected,
    required this.onTap,
  });

  final Locales locale;
  final LocaleController localeController;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
        decoration: isSelected
            ? AppContainerStyles.accentContainer(
                context,
                accentColor: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              )
            : AppContainerStyles.secondaryContainer(context),
        child: Row(
          children: [
            Text(
              _getLanguageFlag(locale),
              style: TextStyle(fontSize: context.dynamicHeight(0.028)),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeController.getLocaleName(locale),
                    style: TextStyle(
                      fontSize: context.dynamicHeight(0.018),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    locale.locale.languageCode.toUpperCase(),
                    style: TextStyle(
                      fontSize: context.dynamicHeight(0.014),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
