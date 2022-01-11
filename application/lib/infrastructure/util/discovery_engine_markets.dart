import 'package:intl/locale.dart';
import 'package:xayn_discovery_app/domain/model/market.dart';

/// TODO this is a copy-paste version of the BingMarkets from xayn_search
/// Needs to be adjusted for the real supported markets
class DiscoveryEngineMarket extends Market<Locale> {
  static const _default = 'undefined';
  @override
  final Locale locale;

  DiscoveryEngineMarket(this.locale);

  String get _countryCode => locale.countryCode?.toUpperCase() ?? _default;
  String get _languageCode => locale.languageCode.toLowerCase();
  String get _scriptCode => locale.scriptCode?.toLowerCase() ?? _default;

  @override
  String get fullCode => '$_languageCode-$_countryCode';

  // The supported bing languages is inconsistently composed of script and language codes,
  // thus this extra rules for chinese (i.e. zh-hans) or portuguese (pt-pt)
  // see also: https://docs.microsoft.com/en-us/rest/api/cognitiveservices-bingsearch/bing-news-api-v7-reference#bing-supported-languages
  @override
  String get language => (_languageCode == 'zh'
          ? '$_languageCode-$_scriptCode'
          : _languageCode == 'pt' ||
                  (_languageCode == 'en' && _countryCode == 'gb')
              ? '$_languageCode-$_countryCode'
              : _languageCode)
      .toLowerCase();

  @override
  String get country => _countryCode;

  @override
  bool get isMarketSupported => supportedMarkets.contains(this);

  @override
  bool get isLanguageSupported => supportedLanguages.contains(language);

  @override
  List<Object> get props => [fullCode];

  @override
  bool get stringify => true;

  static DiscoveryEngineMarket findSupportedMarketForLocale(Locale locale) {
    bool equalsCountry(Market element) =>
        element.country == locale.countryCode?.toUpperCase();
    final alwaysSupportedMarket = DiscoveryEngineMarket(
        Locale.fromSubtags(languageCode: 'en', countryCode: 'US'));
    DiscoveryEngineMarket equalsLanguage() => supportedMarkets.firstWhere(
          (element) => element.language == locale.languageCode,
          orElse: () => alwaysSupportedMarket,
        );
    return supportedMarkets.firstWhere(equalsCountry, orElse: equalsLanguage);
  }
}

final supportedMarkets = [
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'es', countryCode: 'AR')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'AU')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'de', countryCode: 'AT')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'BE')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'BE')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'CA')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'es', countryCode: 'CL')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'da', countryCode: 'DK')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'fi', countryCode: 'FI')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'IN')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'ID')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'it', countryCode: 'IT')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'ko', countryCode: 'KR')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'MY')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'es', countryCode: 'MX')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'NL')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'NZ')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'nb', countryCode: 'NO')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'PH')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'ZA')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'sv', countryCode: 'SE')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'CH')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'de', countryCode: 'CH')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'GB')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US')),
  DiscoveryEngineMarket(
      Locale.fromSubtags(languageCode: 'es', countryCode: 'US')),
];

const List<String> supportedLanguages = [
  'ar',
  'eu',
  'bn',
  'bg',
  'ca',
  'zh-hans',
  'zh-hant',
  'hr',
  'cs',
  'da',
  'nl',
  'en',
  'en-gb',
  'et',
  'fi',
  'fr',
  'gl',
  'de',
  'gu',
  'he',
  'hi',
  'hu',
  'is',
  'it',
  'jp',
  'kn',
  'ko',
  'lv',
  'lt',
  'ms',
  'ml',
  'mr',
  'nb',
  'pl',
  'pt-br',
  'pt-pt',
  'pa',
  'ro',
  'ru',
  'sr',
  'sk',
  'sl',
  'es',
  'sv',
  'ta',
  'te',
  'th',
  'tr',
  'uk',
  'vi',
];
