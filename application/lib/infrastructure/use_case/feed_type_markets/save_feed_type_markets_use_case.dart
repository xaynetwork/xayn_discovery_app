import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/repository/feed_type_markets_repository.dart';

@injectable
class SaveFeedTypeMarketsUseCase
    extends UseCase<FeedTypeMarkets, FeedTypeMarkets> {
  final FeedTypeMarketsRepository _repository;

  SaveFeedTypeMarketsUseCase(
    this._repository,
  );

  @override
  Stream<FeedTypeMarkets> transaction(FeedTypeMarkets param) async* {
    _repository.save(param);

    yield param;
  }
}
