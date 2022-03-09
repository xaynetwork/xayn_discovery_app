import 'dart:ui';

import 'package:instabug_flutter/Instabug.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_de.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_es.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_fr.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_nl.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_pl.i18n.dart';
import 'package:xayn_discovery_app/presentation/utils/app_locale.dart';
import 'package:xayn_discovery_app/presentation/utils/country_names.dart';

enum AppLanguage {
  english,
  german,
  dutch,
  french,
  polish,
  spanish,
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
      case AppLanguage.dutch:
        return const TranslationsNl();
      case AppLanguage.french:
        return const TranslationsFr();
      case AppLanguage.polish:
        return const TranslationsPl();
      case AppLanguage.spanish:
        return const TranslationsEs();
    }
  }

  String get _languageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.dutch:
        return 'nl';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.polish:
        return 'pl';
      case AppLanguage.spanish:
        return 'es';
    }
  }

  String get _countryCode {
    switch (this) {
      case AppLanguage.english:
        return 'US';
      case AppLanguage.german:
        return 'DE';
      case AppLanguage.dutch:
        return "NL";
      case AppLanguage.french:
        return "FR";
      case AppLanguage.polish:
        return "PL";
      case AppLanguage.spanish:
        return "ES";
    }
  }

  IBGLocale get instabugLocale {
    switch (this) {
      case AppLanguage.english:
        return IBGLocale.english;
      case AppLanguage.german:
        return IBGLocale.german;
      case AppLanguage.dutch:
        return IBGLocale.dutch;
      case AppLanguage.french:
        return IBGLocale.french;
      case AppLanguage.polish:
        return IBGLocale.polish;
      case AppLanguage.spanish:
        return IBGLocale.spanish;
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
