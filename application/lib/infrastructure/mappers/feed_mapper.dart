import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class FeedMapper extends BaseDbEntityMapper<Feed> {
  @override
  Feed? fromMap(Map? map) {
    if (map == null) return null;

    final cardIndex =
        map[FeedMapperFields.cardIndex] ?? throwMapperException() as int;

    return Feed(id: Feed.globalId, cardIndex: cardIndex);
  }

  @override
  DbEntityMap toMap(Feed entity) => {
        FeedMapperFields.cardIndex: entity.cardIndex,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'CollectionMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class FeedMapperFields {
  static const int cardIndex = 0;
}
