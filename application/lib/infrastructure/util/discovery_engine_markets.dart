import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

// we only require to display languages for a few countries
enum _DisplayLanguageName { french, dutch }

/// If you change this file,
/// please also update [FeedMarketToFlagAssetPathMapper]
enum SupportedMarkets {
  austria._('de', 'AT'),
  belgiumFr._('fr', 'BE', _DisplayLanguageName.french),
  belgiumNl._('nl', 'BE', _DisplayLanguageName.dutch),
  canada._('en', 'CA'),
  switzerland._('de', 'CH'),
  germany._('de', 'DE'),
  spain._('es', 'ES'),
  uk._('en', 'GB'),
  ireland._('en', 'IE'),
  netherlands._('nl', 'NL'),
  poland._('pl', 'PL'),
  usa._('en', 'US'),
  italy._('it', 'IT'),
  turkey._('tr', 'TR'),
  france._('fr', 'FR'),
  mexico._('es', 'MX'),
  argentina._('es', 'AR'),
  // Not yet supported because of missing assets
  colombia._('es', 'CO'),
  peru._('es', 'PE'),
  ukraine._('uk', 'UA'),
  russia._('ru', 'RU');

  final String languageCode;
  final String countryCode;
  final _DisplayLanguageName? _languageName;

  const SupportedMarkets._(this.languageCode, this.countryCode,
      [this._languageName]);

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
      case SupportedMarkets.italy:
        return R.assets.illustrations.flagItaly;
      case SupportedMarkets.turkey:
        return R.assets.illustrations.flagTurkey;
      case SupportedMarkets.france:
        return R.assets.illustrations.flagFrance;
      case SupportedMarkets.mexico:
        return R.assets.illustrations.flagMexico;
      case SupportedMarkets.argentina:
        return R.assets.illustrations.flagArgentina;
      case SupportedMarkets.colombia:
        return R.assets.illustrations.flagColombia;
      case SupportedMarkets.peru:
        return R.assets.illustrations.flagPeru;
      case SupportedMarkets.ukraine:
        return R.assets.illustrations.flagUkraine;
      case SupportedMarkets.russia:
        return R.assets.illustrations.flagRussia;
    }
  }

  String? get languageName {
    switch (_languageName) {
      case _DisplayLanguageName.french:
        return R.strings.langNameFrench;
      case _DisplayLanguageName.dutch:
        return R.strings.langNameDutch;
      case null:
        return null;
    }
  }
}

final defaultFeedMarket = SupportedMarkets.usa.toFeedMarket;

final supportedFeedMarkets =
    SupportedMarkets.values.map((e) => e.toFeedMarket).toSet();
