import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

@lazySingleton
class FeedMarketToFlagAssetPathMapper extends Mapper<FeedMarket, String?> {
  @override
  String? map(FeedMarket input) {
    switch (input.countryCode) {
      case SupportedCountryCodes.austria:
        return R.assets.illustrations.flagAustria;
      case SupportedCountryCodes.belgium:
        return R.assets.illustrations.flagBelgium;
      case SupportedCountryCodes.canada:
        return R.assets.illustrations.flagCanada;
      case SupportedCountryCodes.switzerland:
        return R.assets.illustrations.flagSwitzerland;
      case SupportedCountryCodes.germany:
        return R.assets.illustrations.flagGermany;
      case SupportedCountryCodes.spain:
        return R.assets.illustrations.flagSpain;
      case SupportedCountryCodes.uk:
        return R.assets.illustrations.flagUK;
      case SupportedCountryCodes.ireland:
        return R.assets.illustrations.flagIreland;
      case SupportedCountryCodes.netherlands:
        return R.assets.illustrations.flagNetherlands;
      case SupportedCountryCodes.poland:
        return R.assets.illustrations.flagPoland;
      case SupportedCountryCodes.usa:
        return R.assets.illustrations.flagUSA;
    }
    return null;
  }
}
