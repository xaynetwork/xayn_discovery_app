import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class ChangeConfigurationUseCase extends UseCase<Configuration, EngineEvent> {
  final DiscoveryEngine _engine;

  ChangeConfigurationUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(Configuration param) async* {
    yield await _engine.changeConfiguration(
      feedMarkets: param.feedMarkets,
      maxItemsPerFeedBatch: param.maxItemsPerFeedBatch,
    );
  }
}

class Configuration {
  final Set<FeedMarket>? feedMarkets;
  final int? maxItemsPerFeedBatch;

  const Configuration({
    this.feedMarkets,
    this.maxItemsPerFeedBatch,
  });
}
