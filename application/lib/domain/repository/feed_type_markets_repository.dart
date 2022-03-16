import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';

abstract class FeedTypeMarketsRepository {
  void save(FeedTypeMarkets feedTypeMarkets);
  FeedTypeMarkets get feed;
  FeedTypeMarkets get search;
}
