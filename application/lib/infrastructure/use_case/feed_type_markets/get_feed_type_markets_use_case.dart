import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/repository/feed_type_markets_repository.dart';

@injectable
class GetFeedTypeMarketsUseCase extends UseCase<FeedType, FeedTypeMarkets> {
  final FeedTypeMarketsRepository _repository;

  GetFeedTypeMarketsUseCase(
    this._repository,
  );

  @override
  Stream<FeedTypeMarkets> transaction(FeedType param) async* {
    switch (param) {
      case FeedType.feed:
        yield _repository.feed;
        break;
      case FeedType.search:
        yield _repository.search;
        break;
    }
  }
}
