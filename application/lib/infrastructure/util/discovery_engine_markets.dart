import 'package:xayn_discovery_app/domain/model/market.dart';
import 'package:xayn_discovery_app/presentation/utils/app_locale.dart';

/// TODO this is a copy-paste version of the BingMarkets from xayn_search
/// Needs to be adjusted for the real supported markets
class DiscoveryEngineMarket extends Market<AppLocale> {
  static const _default = 'undefined';
  @override
  final AppLocale locale;

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

  static DiscoveryEngineMarket findSupportedMarketForLocale(AppLocale locale) {
    bool equalsCountry(Market element) =>
        element.country == locale.countryCode?.toUpperCase();
    final alwaysSupportedMarket = DiscoveryEngineMarket(
        AppLocale.fromSubtags(languageCode: 'en', countryCode: 'US'));
    DiscoveryEngineMarket equalsLanguage() => supportedMarkets.firstWhere(
          (element) => element.language == locale.languageCode,
          orElse: () => alwaysSupportedMarket,
        );
    return supportedMarkets.firstWhere(equalsCountry, orElse: equalsLanguage);
  }
}

/// TODO change to  real supported markets based on webz or discovery engine specifications
final supportedMarkets = [
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'es', countryCode: 'AR')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'AU')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'de', countryCode: 'AT')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'nl', countryCode: 'BE')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'fr', countryCode: 'BE')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'pt', countryCode: 'BR')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'CA')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'fr', countryCode: 'CA')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'es', countryCode: 'CL')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'da', countryCode: 'DK')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'fi', countryCode: 'FI')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'fr', countryCode: 'FR')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'de', countryCode: 'DE')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'zh', countryCode: 'HK')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'IN')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'ID')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'it', countryCode: 'IT')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'ja', countryCode: 'JP')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'ko', countryCode: 'KR')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'MY')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'es', countryCode: 'MX')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'nl', countryCode: 'NL')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'NZ')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'nb', countryCode: 'NO')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'zh', countryCode: 'CN')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'pl', countryCode: 'PL')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'PH')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'ru', countryCode: 'RU')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'ZA')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'es', countryCode: 'ES')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'sv', countryCode: 'SE')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'fr', countryCode: 'CH')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'de', countryCode: 'CH')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'zh', countryCode: 'TW')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'tr', countryCode: 'TR')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'GB')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'en', countryCode: 'US')),
  DiscoveryEngineMarket(
      AppLocale.fromSubtags(languageCode: 'es', countryCode: 'US')),
];

/// TODO change to  real supported languages based on webz or discovery engine specifications
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
