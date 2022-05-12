import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_market_to_flag_path_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/language_code_to_language_name_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

typedef SupportedCountries = Iterable<Country>;

@injectable
class GetSupportedCountriesUseCase extends UseCase<None, SupportedCountries> {
  final FeedMarketToFlagAssetPathMapper _flagMapper;
  final LanguageCodeToLanguageNameMapper _languageNameMapper;

  GetSupportedCountriesUseCase(
    this._flagMapper,
    this._languageNameMapper,
  );

  @override
  Stream<SupportedCountries> transaction(None param) async* {
    final countryNames = await Strings.countryNames;
    final countries = supportedFeedMarkets.map((FeedMarket market) {
      final flag = _flagMapper.map(market);
      if (flag == null) throw FlagNotFindForMarketException(market);
      final countryName = countryNames[market.countryCode]!;

      final language = isCountryMultilingual(market.countryCode)
          ? _languageNameMapper.map(market.languageCode)
          : null;

      return Country(
        name: countryName,
        svgFlagAssetPath: flag,
        countryCode: market.countryCode,
        langCode: market.languageCode,
        language: language,
      );
    });

    yield countries;
  }
}

class FlagNotFindForMarketException implements Exception {
  final FeedMarket market;

  FlagNotFindForMarketException(this.market);

  @override
  String toString() => 'Can\'t find flag for market: $market';
}
