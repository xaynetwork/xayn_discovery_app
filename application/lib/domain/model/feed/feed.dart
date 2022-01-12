import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'feed.freezed.dart';

const kDefaultCollectionId = 'defaultCollectionId';

@freezed
class Feed extends DbEntity with _$Feed {
  static UniqueId globalId = const UniqueId.fromTrustedString('feed_id');

  @Assert('cardIndex >= 0', 'cardIndex cannot be smaller than 0')
  factory Feed({
    required UniqueId id,
    required int cardIndex,
  }) = _Feed;

  factory Feed.initial() => Feed(id: globalId, cardIndex: 0);
}
