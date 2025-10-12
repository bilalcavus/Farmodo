import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/utility/constants/locales.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ProductLocalization extends EasyLocalization {
  ProductLocalization({
    required super.child,
    required Locale startLocale,
    super.key}) : super(
      path: 'assets/translations',
      supportedLocales: Locales.supportedLocales,
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      startLocale: startLocale
    );

}