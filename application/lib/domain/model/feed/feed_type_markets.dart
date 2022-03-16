import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'feed_type_markets.freezed.dart';

@freezed
class FeedTypeMarkets extends DbEntity with _$FeedTypeMarkets {
  static UniqueId feedId = const UniqueId.fromTrustedString('feed_id');
  static UniqueId searchId = const UniqueId.fromTrustedString('search_id');

  factory FeedTypeMarkets({
    required UniqueId id,
    required FeedType feedType,
    required FeedMarkets feedMarkets,
  }) = _FeedTypeMarkets;
}
