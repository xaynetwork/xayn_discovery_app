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

  static const String your = 'Your';

  static const String personalAreaTitle = 'Area';
  static const String personalAreaCollections = 'Collections';
  static const String personalAreaHomeFeed = 'Home Feed';
  static const String personalAreaSettings = 'Settings';

  static const String activeSearchSearchHint = 'Search';
  static const String settingsTitle = 'Settings';
  static const String settingsSectionTitleAppTheme = 'Your App Theme';
  static const String settingsSectionScrollDirection =
      'Discovery feed scroll direction';
  static const String settingsSectionTitleGeneralInfo = 'General information';
  static const String settingsSectionTitleHelpImprove = 'Help Us Improve!';
  static const String settingsSectionTitleSpreadTheWord = 'Spread the Word';

  static const String settingsAppThemeSystem = 'System default';
  static const String settingsAppThemeLight = 'Light mode';
  static const String settingsAppThemeDark = 'Dark mode';

  static const String settingsScrollDirectionVertical = 'Vertical';
  static const String settingsScrollDirectionHorizontal = 'Horizontal';

  static const String settingsAboutXayn = 'About Xayn';
  static const String settingsCarbonNeutral = 'We\'re carbon neutral!';
  static const String settingsImprint = 'Imprint';
  static const String settingsPrivacyPolicy = 'Privacy Policy';
  static const String settingsTermsAndConditions = 'Terms & Conditions';
  static const String settingsHaveFoundBug = 'Have you found a bug?';
  static const String settingsShareBtn = 'Share with friends';
  static const String settingsVersion = 'Version:';
  static const String settingsBuild = 'Build:';

  static const String minAgo = 'min ago';
  static const String momentsAgo = 'moments ago';
  static const String hourAgo = 'hour ago';
  static const String hoursAgo = 'hours ago';
  static const String dayAgo = 'day ago';
  static const String daysAgo = 'days ago';

  static const String readingTimeUnitSingular = 'minute';
  static const String readingTimeUnitPlural = 'minutes';
  static const String readingTimeSuffix = 'read';

  static const String cannotLoadUrlError = 'Unable to load image with url: ';

  static const String errorMsgTryingToCreateCollectionUsingExistingName =
      'Trying to create a collection using an existing name';
  static const String errorMsgTryingToCreateAgainDefaultCollection =
      'Trying to create again the default collection';
  static const String errorMsgTryingToGetCardDataForNotExistingCollection =
      'Trying to get card data for a collection that doesn\'t exist';
  static const String errorMsgTryingToRemoveDefaultCollection =
      'Trying to remove the default collection';
  static const String errorMsgTryingToRemoveNotExistingCollection =
      'Trying to remove a collection that doesn\t exist';
  static const String errorMsgTryingToRenameCollectionUsingExistingName =
      'Trying to rename a collection using an existing name';
  static const String errorMsgTryingToRenameNotExistingCollection =
      'Trying to rename a collection that doesn\t exist';
}

/// Helper method so we can use strings.my_translated_key
Translations get strings => Strings.translation;
