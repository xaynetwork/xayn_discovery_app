import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';

/// If you change this file,
/// please also update [FeedMarketToFlagAssetPathMapper]
class SupportedCountryCodes {
  SupportedCountryCodes._();

  static final Set<String> allValues = {
    austria,
    belgium,
    canada,
    switzerland,
    germany,
    spain,
    uk,
    ireland,
    netherlands,
    poland,
    usa,
  };

  static const String austria = 'AT';
  static const String belgium = 'BE';
  static const String canada = 'CA';
  static const String switzerland = 'CH';
  static const String germany = 'DE';
  static const String spain = 'ES';
  static const String uk = 'GB';
  static const String ireland = 'IE';
  static const String netherlands = 'NL';
  static const String poland = 'PL';
  static const String usa = 'US';
}

/// If you change this file,
/// please also update [LanguageCodeToLanguageNameMapper]
class SupportedLanguageCodes {
  SupportedLanguageCodes._();

  static final Set<String> allValues = {
    dutch,
    english,
    french,
    german,
    polish,
    spanish
  };

  static const String dutch = 'nl';
  static const String english = 'en';
  static const String french = 'fr';
  static const String german = 'de';
  static const String polish = 'pl';
  static const String spanish = 'es';
}

const defaultFeedMarket = FeedMarket(
  countryCode: SupportedCountryCodes.usa,
  languageCode: SupportedLanguageCodes.english,
);

final FeedMarkets supportedFeedMarkets = <FeedMarket>{
  const FeedMarket(
    countryCode: SupportedCountryCodes.austria,
    languageCode: SupportedLanguageCodes.german,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.belgium,
    languageCode: SupportedLanguageCodes.french,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.belgium,
    languageCode: SupportedLanguageCodes.dutch,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.canada,
    languageCode: SupportedLanguageCodes.english,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.switzerland,
    languageCode: SupportedLanguageCodes.german,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.germany,
    languageCode: SupportedLanguageCodes.german,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.spain,
    languageCode: SupportedLanguageCodes.spanish,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.uk,
    languageCode: SupportedLanguageCodes.english,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.ireland,
    languageCode: SupportedLanguageCodes.english,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.netherlands,
    languageCode: SupportedLanguageCodes.dutch,
  ),
  const FeedMarket(
    countryCode: SupportedCountryCodes.poland,
    languageCode: SupportedLanguageCodes.polish,
  ),
  defaultFeedMarket,
};

//region utils

final _listOfSupportedCountryCodes =
    supportedFeedMarkets.map((e) => e.countryCode).toList();

bool _isCountryHasMultipleLanguages(String countryCode) =>
    _listOfSupportedCountryCodes
        .where((element) => countryCode == element)
        .length >
    1;

///TODO change to a real lazy initialization if possible
// ignore: unnecessary_late
late final _multiLanguageCountryMap = Map.fromEntries(
  supportedFeedMarkets.map(
    (e) => MapEntry(
      e.countryCode,
      _isCountryHasMultipleLanguages(e.countryCode),
    ),
  ),
);

bool isCountryMultilingual(String? countryCode) =>
    countryCode != null && _multiLanguageCountryMap[countryCode] == true;
//endregion utils
