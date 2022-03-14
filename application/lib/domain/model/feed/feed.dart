import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'feed.freezed.dart';

@freezed
class Feed extends DbEntity with _$Feed {
  static UniqueId globalId = const UniqueId.fromTrustedString('feed_id');

  @Assert('cardIndexFeed >= 0', 'cardIndexFeed cannot be smaller than 0')
  @Assert('cardIndexSearch >= 0', 'cardIndexSearch cannot be smaller than 0')
  factory Feed({
    required UniqueId id,
    required int cardIndexFeed,
    required int cardIndexSearch,
  }) = _Feed;

  factory Feed.initial() => Feed(
        id: globalId,
        cardIndexFeed: 0,
        cardIndexSearch: 0,
      );
}
