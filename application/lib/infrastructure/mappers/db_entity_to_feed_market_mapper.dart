import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@lazySingleton
class DbEntityMapToFeedMarketMapper extends Mapper<DbEntityMap?, FeedMarket?> {
  @override
  FeedMarket? map(DbEntityMap? input) {
    if (input == null) return null;

    final countryCode = input[FeedMarketFields.countryCode];
    if (countryCode == null) return null;

    final languageCode = input[FeedMarketFields.languageCode];
    if (languageCode == null) return null;

    return FeedMarket(
      countryCode: countryCode,
      languageCode: languageCode,
    );
  }
}

@lazySingleton
class FeedMarketToDbEntityMapMapper extends Mapper<FeedMarket, DbEntityMap> {
  @override
  DbEntityMap map(FeedMarket input) => {
        FeedMarketFields.countryCode: input.countryCode,
        FeedMarketFields.languageCode: input.languageCode,
      };
}

abstract class FeedMarketFields {
  FeedMarketFields._();

  static const int countryCode = 0;
  static const int languageCode = 1;
}
