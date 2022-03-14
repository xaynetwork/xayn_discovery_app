import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class FeedMapper extends BaseDbEntityMapper<Feed> {
  @override
  Feed? fromMap(Map? map) {
    if (map == null) return null;

    final cardIndexFeed = map[FeedMapperFields.cardIndexFeed] as int?;
    final cardIndexSearch = map[FeedMapperFields.cardIndexSearch] as int?;

    return Feed(
      id: Feed.globalId,
      cardIndexFeed: cardIndexFeed ?? 0,
      cardIndexSearch: cardIndexSearch ?? 0,
    );
  }

  @override
  DbEntityMap toMap(Feed entity) => {
        FeedMapperFields.cardIndexFeed: entity.cardIndexFeed,
        FeedMapperFields.cardIndexSearch: entity.cardIndexSearch,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'CollectionMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class FeedMapperFields {
  static const int cardIndexFeed = 0;
  static const int cardIndexSearch = 1;
}
