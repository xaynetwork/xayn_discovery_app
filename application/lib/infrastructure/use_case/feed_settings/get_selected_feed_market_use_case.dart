import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';

@injectable
class GetSelectedFeedMarketsUseCase extends UseCase<None, FeedMarkets> {
  final FeedSettingsRepository _repository;

  GetSelectedFeedMarketsUseCase(
    this._repository,
  );

  @override
  Stream<FeedMarkets> transaction(None param) async* {
    final settings = _repository.settings;
    yield settings.feedMarkets;
  }
}
