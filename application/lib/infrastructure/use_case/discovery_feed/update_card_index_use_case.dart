import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';

@injectable
class UpdateCardIndexUseCase extends UseCase<FeedTypeAndIndex, int> {
  final FeedRepository feedRepository;

  UpdateCardIndexUseCase(this.feedRepository);

  @override
  Stream<int> transaction(FeedTypeAndIndex param) async* {
    late final Feed feed;

    switch (param.feedType) {
      case FeedType.feed:
        feed = feedRepository.get().copyWith(cardIndexFeed: param.cardIndex);
        break;
      case FeedType.search:
        feed = feedRepository.get().copyWith(cardIndexSearch: param.cardIndex);
        break;
    }

    feedRepository.save(feed);

    yield param.cardIndex;
  }
}

class FeedTypeAndIndex {
  final FeedType feedType;
  final int cardIndex;

  const FeedTypeAndIndex.feed({required this.cardIndex})
      : feedType = FeedType.feed;
  const FeedTypeAndIndex.search({required this.cardIndex})
      : feedType = FeedType.search;
}
