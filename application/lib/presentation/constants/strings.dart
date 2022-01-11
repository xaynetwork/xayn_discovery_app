import 'package:flutter/cupertino.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

/// Key is country code, value is localized country name.
typedef CountryNames = Map<String, String>;

typedef GetCountryNamesCallback = Future<CountryNames> Function(
    AppLanguage appLanguage);

/// The Strings class with constants is now replaced with yaml files under messages.
/// Use them in the format `translations[_locale].i18n.yaml`
/// The `translations.i18n.yaml` is the default english translation.
///
/// In order to regenerate the translations.i18n.dart files run
///
/// # For continuous generation, best while development
///     `flutter packages pub run build_runner watch`
/// # For single shot generation:
///     `flutter pub run build_runner build --delete-conflicting-outputs ; flutter format lib/messages/`
///  TODO: IN CASE OF ANY ISSUE (OR FOR MORE DETAILS) - REFERENCE TO THE [run_prepush_checks.sh]
///
/// see `https://pub.dev/packages/i18n` for further usage of the i18n package
/// but for now it makes sense to only use yaml files in the default way, until we
/// agree on an automatic translation process.
///
/// This String allows to switch translations on demand, by changing the _translation
/// field, which is done by the [switchTranslations(Locale)] method.
///
/// For new languages add the  `messages/translations[_newlang].i18n.yaml` file
/// and extend the `switchTranslations(Locale)` implementation.
///
class Strings {
  static Translations? _translation;
  static const Translations _defaultTranslation = Translations();
  static CountryNames? _countryNames;
  static CountryNames? _defaultCountryNames;

  static Translations get translation => _translation ?? _defaultTranslation;

  static CountryNames get countryNames =>
      _countryNames ?? _defaultCountryNames!;

  /// languageCode is i.e. de, en, ...
  /// countryCode is i.e. DE, US, ...
  static Future<void> switchTranslations(
    AppLanguage appLanguage,
    GetCountryNamesCallback setCountryNamesCallback,
  ) async {
    _switchTranslations(appLanguage);
    _countryNames = await setCountryNamesCallback(appLanguage);
  }

  static void _switchTranslations(AppLanguage appLanguage) {
    logger.i('Initialize translations with $appLanguage');
    if (_translation != null) {
      logger.w(
          'Translations have been already set to $_translation, do you really wanna set it again?');
    }

    _translation = appLanguage.translations;
  }

  static void setDefaultCountryNames(CountryNames countryNames) async {
    _defaultCountryNames = countryNames;
  }

  @visibleForTesting
  static void reset() {
    _translation = null;
  }
}

/// Helper method so we can use strings.my_translated_key
Translations get strings => Strings.translation;
