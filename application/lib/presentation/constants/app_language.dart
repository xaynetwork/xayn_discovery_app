import 'dart:ui';

import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_de.i18n.dart';
import 'package:xayn_discovery_app/presentation/utils/app_locale.dart';
import 'package:xayn_discovery_app/presentation/utils/country_names.dart';

enum AppLanguage {
  english,
  german,
}

class AppLanguageHelper {
  /// Searches for all dialects of a certain language and selects the one that has the closest match.
  /// I.e: for
  /// [german, germanAustria, english]
  /// de-DE  => Applanguage.german
  /// de-AU  => Applanguage.germanAustria
  /// de-CH  => Applanguage.german
  /// fr     => Applanguage.english
  static AppLanguage from({
    required AppLocale locale,
  }) {
    final dialects = AppLanguage.values
        .where((language) => language._languageCode == locale.languageCode);
    return dialects.firstWhere(
        (language) => language._countryCode == locale.countryCode,
        orElse: () =>
            dialects.isNotEmpty ? dialects.first : AppLanguage.english);
  }
}

extension AppLanguageExtension on AppLanguage {
  Translations get translations {
    switch (this) {
      case AppLanguage.english:
        return const Translations();
      case AppLanguage.german:
        return const TranslationsDe();
    }
  }

  String get _languageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.german:
        return 'de';
    }
  }

  String get _countryCode {
    switch (this) {
      case AppLanguage.english:
        return 'US';
      case AppLanguage.german:
        return 'DE';
    }
  }

  IBGLocale get instabugLocale {
    switch (this) {
      case AppLanguage.english:
        return IBGLocale.english;
      case AppLanguage.german:
        return IBGLocale.german;
    }
  }

  AppLocale get locale => AppLocale.fromSubtags(
      languageCode: _languageCode, countryCode: _countryCode);

  @Deprecated(
      "Try to avoid this locale because it adds a dependency on dart:ui")
  Locale get flutterLocale => Locale.fromSubtags(
      languageCode: _languageCode, countryCode: _countryCode);

  Future<CountryNames> get countryNames => getCountryNames(this);
}
