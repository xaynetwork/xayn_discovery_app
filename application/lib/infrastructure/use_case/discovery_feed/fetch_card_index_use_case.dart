import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';

@injectable
class FetchCardIndexUseCase extends UseCase<FeedType, int> {
  final FeedRepository feedRepository;

  FetchCardIndexUseCase(this.feedRepository);

  @override
  Stream<int> transaction(FeedType param) async* {
    final feed = feedRepository.get();

    switch (param) {
      case FeedType.feed:
        yield feed.cardIndexFeed;
        break;
      case FeedType.search:
        yield feed.cardIndexSearch;
        break;
    }
  }
}
