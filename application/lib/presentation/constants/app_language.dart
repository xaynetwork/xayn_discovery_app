import 'package:instabug_flutter/Instabug.dart';
import 'package:intl/locale.dart' as intl;
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations_de.i18n.dart';

enum AppLanguage {
  english,
  german,
}

class AppLanguageHelper {
  static AppLanguage from({
    required intl.Locale locale,
  }) {
    var dialects = AppLanguage.values
        .where((language) => language.languageCode == locale.languageCode);
    return dialects.firstWhere(
        (language) => language.countryCode == locale.countryCode,
        orElse: () =>
            dialects.isNotEmpty ? dialects.first : AppLanguage.english);
  }
}

extension Utils on AppLanguage {
  Translations get translations {
    switch (this) {
      case AppLanguage.english:
        return const Translations();
      case AppLanguage.german:
        return const TranslationsDe();
    }
  }

  String get languageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.german:
        return 'de';
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

  // Currently we don't have country specific dialects so returning null.
  String? get countryCode => null;

  String get languageTag {
    if (countryCode != null) {
      return '$languageCode-$countryCode';
    }
    return languageCode;
  }
}
