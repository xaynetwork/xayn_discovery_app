import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';

@singleton
class FeedTypeMarketsMapper extends BaseDbEntityMapper<FeedTypeMarkets> {
  final DbEntityMapToFeedMarketMapper _feedMarketFromMapMapper;
  final FeedMarketToDbEntityMapMapper _feedMarketToMapMapper;

  const FeedTypeMarketsMapper(
    this._feedMarketFromMapMapper,
    this._feedMarketToMapMapper,
  );

  @override
  FeedTypeMarkets? fromMap(Map? map) {
    if (map == null) return null;

    final String id =
        map[FeedTypeMarketsMapperFields.id] ?? throwMapperException() as String;
    final int feedTypeValue = map[FeedTypeMarketsMapperFields.feedType] ??
        throwMapperException() as int;
    final feedMarkets = _mapMarkets(map);

    late final FeedType feedType;

    switch (feedTypeValue) {
      case 0:
        feedType = FeedType.feed;
        break;
      case 1:
        feedType = FeedType.search;
        break;
      default:
        throwMapperException();
    }

    return FeedTypeMarkets(
      id: UniqueId.fromTrustedString(id),
      feedType: feedType,
      feedMarkets: feedMarkets,
    );
  }

  @override
  DbEntityMap toMap(FeedTypeMarkets entity) {
    late final int feedTypeValue;

    switch (entity.feedType) {
      case FeedType.feed:
        feedTypeValue = 0;
        break;
      case FeedType.search:
        feedTypeValue = 1;
        break;
    }
    return {
      FeedTypeMarketsMapperFields.id: entity.id.value,
      FeedTypeMarketsMapperFields.feedType: feedTypeValue,
      FeedTypeMarketsMapperFields.feedMarkets:
          entity.feedMarkets.map(_feedMarketToMapMapper.map).toList(),
    };
  }

  @override
  void throwMapperException([
    String exceptionText =
        'CollectionMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);

  Set<FeedMarket> _mapMarkets(Map map) {
    final feedMarketsRaw =
        map[FeedTypeMarketsMapperFields.feedMarkets] as List? ?? [];

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

abstract class FeedTypeMarketsMapperFields {
  static const int id = 0;
  static const int feedType = 1;
  static const int feedMarkets = 2;
}
