import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';

@lazySingleton
class FeedSettingsMapper extends BaseDbEntityMapper<FeedSettings> {
  final DbEntityMapToFeedMarketMapper _feedMarketFromMapMapper;
  final FeedMarketToDbEntityMapMapper _feedMarketToMapMapper;

  const FeedSettingsMapper(
    this._feedMarketFromMapMapper,
    this._feedMarketToMapMapper,
  );

  @override
  FeedSettings? fromMap(Map? map) {
    if (map == null) return null;

    final feedMarkets = _mapMarkets(map);
    if (feedMarkets.isEmpty) return null;

    return FeedSettings(feedMarkets: feedMarkets);
  }

  @override
  DbEntityMap toMap(FeedSettings entity) => {
        FeedSettingsFields.feedMarkets:
            entity.feedMarkets.map(_feedMarketToMapMapper.map).toList(),
      };

  Set<FeedMarket> _mapMarkets(Map map) {
    final feedMarketsRaw = map[FeedSettingsFields.feedMarkets] as List? ?? [];

    final feedMarkets = <FeedMarket>{};
    for (final element in feedMarketsRaw) {
      final market =
          _feedMarketFromMapMapper.map(Map<int, dynamic>.from(element));
      if (market != null) {
        feedMarkets.add(market);
      }
    }
    return feedMarkets;
  }
}

abstract class FeedSettingsFields {
  FeedSettingsFields._();

  static const int feedMarkets = 0;
}
