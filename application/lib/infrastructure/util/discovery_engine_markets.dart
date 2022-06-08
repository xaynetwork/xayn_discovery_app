import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// If you change this file,
/// please also update [FeedMarketToFlagAssetPathMapper]
enum SupportedMarkets {
  austria('de', 'AT'),
  belgiumFr('fr', 'BE', multiLingual: true),
  belgiumNl('nl', 'BE', multiLingual: true),
  canada('en', 'CA'),
  switzerland('de', 'CH'),
  germany('de', 'DE'),
  spain('es', 'ES'),
  uk('en', 'GB'),
  ireland('en', 'IE'),
  netherlands('nl', 'NL'),
  poland('pl', 'PL'),
  usa('en', 'US');

  final String languageCode;
  final String countryCode;
  final bool multiLingual;

  const SupportedMarkets(this.languageCode, this.countryCode,
      {this.multiLingual = false});

  FeedMarket get toFeedMarket =>
      FeedMarket(countryCode: countryCode, languageCode: languageCode);

  // Use a function instead of hardcoding the string, because R.assets.illustrations is not a const
  String get flag {
    switch (this) {
      case SupportedMarkets.austria:
        return R.assets.illustrations.flagAustria;
      case SupportedMarkets.belgiumFr:
        return R.assets.illustrations.flagBelgium;
      case SupportedMarkets.belgiumNl:
        return R.assets.illustrations.flagBelgium;
      case SupportedMarkets.canada:
        return R.assets.illustrations.flagCanada;
      case SupportedMarkets.switzerland:
        return R.assets.illustrations.flagSwitzerland;
      case SupportedMarkets.germany:
        return R.assets.illustrations.flagGermany;
      case SupportedMarkets.spain:
        return R.assets.illustrations.flagSpain;
      case SupportedMarkets.uk:
        return R.assets.illustrations.flagUK;
      case SupportedMarkets.ireland:
        return R.assets.illustrations.flagIreland;
      case SupportedMarkets.netherlands:
        return R.assets.illustrations.flagNetherlands;
      case SupportedMarkets.poland:
        return R.assets.illustrations.flagPoland;
      case SupportedMarkets.usa:
        return R.assets.illustrations.flagUSA;
    }
  }

  String get languageName {
    switch (this) {
      case SupportedMarkets.belgiumFr:
        return R.strings.langNameFrench;
      case SupportedMarkets.switzerland:
      case SupportedMarkets.austria:
      case SupportedMarkets.germany:
        return R.strings.langNameGerman;
      case SupportedMarkets.spain:
        return R.strings.langNameSpanish;
      case SupportedMarkets.belgiumNl:
      case SupportedMarkets.netherlands:
        return R.strings.langNameDutch;
      case SupportedMarkets.poland:
        return R.strings.langNamePolish;
      case SupportedMarkets.canada:
      case SupportedMarkets.uk:
      case SupportedMarkets.ireland:
      case SupportedMarkets.usa:
        return R.strings.langNameEnglish;
    }
  }
}

final defaultFeedMarket = SupportedMarkets.usa.toFeedMarket;

final supportedFeedMarkets =
    SupportedMarkets.values.map((e) => e.toFeedMarket).toSet();

bool isCountryMultilingual(String? countryCode) =>
    SupportedMarkets.values.firstWhereOrNull((element) =>
        element.countryCode == countryCode && element.multiLingual) !=
    null;
