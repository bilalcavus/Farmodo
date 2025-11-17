import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/utility/constants/locales.dart';
import 'package:farmodo/core/utility/constants/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  final _currentLocale = const Locale("en").obs;

  Locale get currentLocale => _currentLocale.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString(StorageKeys.appLocale);
    
    if (savedLocaleCode != null) {
      final savedLocale = Locales.supportedLocales.firstWhere(
        (locale) => locale.languageCode == savedLocaleCode,
        orElse: () => const Locale('en'),
      );
      _currentLocale.value = savedLocale;
    }
  }

  void syncWithContext(Locale contextLocale) {
    if (_currentLocale.value.languageCode != contextLocale.languageCode) {
      _currentLocale.value = contextLocale;
    }
  }

  Future<void> changeLanguage(BuildContext context, Locales newLocale) async {
    _currentLocale.value = newLocale.locale;
    await context.setLocale(newLocale.locale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.appLocale, newLocale.locale.languageCode);
    
    update();
  }

  Locales getCurrentLocaleEnum() {
    return Locales.values.firstWhere(
      (locale) => locale.locale.languageCode == _currentLocale.value.languageCode,
      orElse: () => Locales.en,
    );
  }

  String getLocaleName(Locales locale) {
    switch (locale) {
      case Locales.en:
        return 'English';
      case Locales.tr:
        return 'Türkçe';
      case Locales.de:
        return 'Deutsch';
      case Locales.fr:
        return 'Français';
      case Locales.ar:
        return 'العربية';
      case Locales.id:
        return 'Bahasa Indonesia';
      case Locales.ms:
        return 'Bahasa Melayu';
      case Locales.ja:
        return '日本語';
      case Locales.ko:
        return '한국어';
      case Locales.th:
        return 'ไทย';
      case Locales.vi:
        return 'Tiếng Việt';
      case Locales.zhTw:
        return '繁體中文';
      case Locales.no:
        return 'Norsk';
      case Locales.sk:
        return 'Slovenčina';
      case Locales.es:
        return 'Español';
      case Locales.sv:
        return 'Svenska';
    }
  }
}