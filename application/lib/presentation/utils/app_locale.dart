import 'package:flutter/material.dart';
import 'package:intl/locale.dart' as intl;

/// The intl.locale so that we don't need to import it always as intl
typedef AppLocale = intl.Locale;

AppLocale createLocale(String languageCode, String countryCode) =>
    intl.Locale.fromSubtags(
        languageCode: languageCode, countryCode: countryCode);

extension LocaleExtension on Locale {
  AppLocale toAppLocale() => AppLocale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
      scriptCode: scriptCode);
}
