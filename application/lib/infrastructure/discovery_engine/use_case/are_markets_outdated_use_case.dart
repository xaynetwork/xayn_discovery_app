import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/feed_market_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_local_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/get_feed_type_markets_use_case.dart';

@injectable
class AreMarketsOutdatedUseCase extends UseCase<FeedType, bool> {
  final GetFeedTypeMarketsUseCase _getFeedTypeMarketsUseCase;
  final GetLocalMarketsUseCase _getLocalMarketsUseCase;

  AreMarketsOutdatedUseCase(
    this._getFeedTypeMarketsUseCase,
    this._getLocalMarketsUseCase,
  );

  @override
  Stream<bool> transaction(FeedType param) async* {
    final markets = await _getLocalMarketsUseCase.singleOutput(none);
    final localMarkets = markets.map((it) => it.toLocal()).toSet();
    final feedTypeMarkets =
        await _getFeedTypeMarketsUseCase.singleOutput(param);

    yield feedTypeMarkets.feedMarkets.length != localMarkets.length ||
        !feedTypeMarkets.feedMarkets.every(localMarkets.contains);
  }
}
