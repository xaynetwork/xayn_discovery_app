import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_mode.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'feed_settings.freezed.dart';

@freezed
class FeedSettings extends DbEntity with _$FeedSettings {
  /// [feedMarkets] represents a Set of FeedMarket
  factory FeedSettings._({
    required Set<InternalFeedMarket> feedMarkets,
    required FeedMode feedMode,
    required UniqueId id,
  }) = _FeedSettings;

  factory FeedSettings({
    required Set<InternalFeedMarket> feedMarkets,
    FeedMode? feedMode,
  }) =>
      FeedSettings._(
        feedMarkets: feedMarkets,
        feedMode: feedMode ?? FeedMode.stream,
        id: FeedSettings.globalId,
      );

  factory FeedSettings.initial() =>
      FeedSettings(feedMarkets: {}, feedMode: FeedMode.stream);

  static UniqueId globalId =
      const UniqueId.fromTrustedString('feed_settings_id');
}
