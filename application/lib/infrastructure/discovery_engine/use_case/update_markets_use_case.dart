import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/feed_market_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class UpdateMarketsUseCase extends UseCase<FeedType, EngineEvent> {
  final DiscoveryEngine _engine;
  final GetLocalMarketsUseCase _getLocalMarketsUseCase;
  final SaveFeedTypeMarketsUseCase _saveFeedTypeMarketsUseCase;

  UpdateMarketsUseCase(
    this._engine,
    this._getLocalMarketsUseCase,
    this._saveFeedTypeMarketsUseCase,
  );

  @override
  Stream<EngineEvent> transaction(FeedType param) async* {
    final nextMarkets = await _getLocalMarketsUseCase.singleOutput(none);
    late final UniqueId id;

    switch (param) {
      case FeedType.feed:
        id = FeedTypeMarkets.feedId;
        break;
      case FeedType.search:
        id = FeedTypeMarkets.searchId;
        break;
    }

    await _saveFeedTypeMarketsUseCase.singleOutput(
      FeedTypeMarkets(
        id: id,
        feedType: param,
        feedMarkets: nextMarkets.map((it) => it.toLocal()).toSet(),
      ),
    );

    yield await _engine.changeConfiguration(feedMarkets: nextMarkets);
  }
}
