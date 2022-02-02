import 'package:flutter/cupertino.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';
import 'package:xayn_discovery_app/presentation/utils/country_names.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

/// The Strings class with constants is now replaced with yaml files under translations.
/// Use them in the format `translations[_locale].i18n.yaml`
/// The `translations.i18n.yaml` is the default english translation.
///
/// In order to regenerate the translations.i18n.dart files run
///
///     `fastlane update_strings`
///
/// see `https://pub.dev/packages/i18n` for further usage of the i18n package
///
/// This String allows to switch translations on demand, by changing the _translation
/// field, which is done by the [switchTranslations(appLanguage)] method.
class Strings {
  static Translations? _translation;
  static const Translations _defaultTranslation = Translations();
  static Future<CountryNames>? _countryNames;
  static late final Future<CountryNames> _defaultCountryNames =
      AppLanguage.english.countryNames;

  static Translations get translation => _translation ?? _defaultTranslation;

  static Future<CountryNames> get countryNames =>
      _countryNames ?? _defaultCountryNames;

  static void switchTranslations(AppLanguage appLanguage) {
    _switchTranslations(appLanguage);
    _countryNames = appLanguage.countryNames;
  }

  static void _switchTranslations(AppLanguage appLanguage) {
    logger.i('Initialize translations with $appLanguage');
    if (_translation != null) {
      logger.w(
          'Translations have been already set to $_translation, do you really wanna set it again?');
    }

    _translation = appLanguage.translations;
  }

  @visibleForTesting
  static void reset() {
    _translation = null;
    _countryNames = null;
  }

  const Strings._();
}

/// Helper method so we can use strings.my_translated_key
Translations get strings => Strings.translation;
