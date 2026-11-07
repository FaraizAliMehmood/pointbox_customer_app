import 'dart:ui';

import 'package:get/get.dart';
import 'package:pointbox_mobile/app/translations/ar_translations.dart';
import 'package:pointbox_mobile/app/translations/en_translations.dart';

class LocalizationService extends Translations {
  static const locale = Locale('en', 'US');
  static const fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enTranslations,
        'ar_SA': arTranslations,
      };
}

