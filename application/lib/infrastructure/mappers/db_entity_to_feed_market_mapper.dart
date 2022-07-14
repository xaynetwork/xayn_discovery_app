import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@lazySingleton
class DbEntityMapToFeedMarketMapper
    extends Mapper<DbEntityMap?, InternalFeedMarket?> {
  @override
  InternalFeedMarket? map(DbEntityMap? input) {
    if (input == null) return null;

    final countryCode = input[FeedMarketFields.countryCode];
    if (countryCode == null) return null;

    final languageCode = input[FeedMarketFields.languageCode];
    if (languageCode == null) return null;

    return InternalFeedMarket(
      countryCode: countryCode,
      languageCode: languageCode,
    );
  }
}

@lazySingleton
class FeedMarketToDbEntityMapMapper
    extends Mapper<InternalFeedMarket, DbEntityMap> {
  @override
  DbEntityMap map(InternalFeedMarket input) => {
        FeedMarketFields.countryCode: input.countryCode,
        FeedMarketFields.languageCode: input.languageCode,
      };
}

abstract class FeedMarketFields {
  FeedMarketFields._();

  static const int countryCode = 0;
  static const int languageCode = 1;
}
