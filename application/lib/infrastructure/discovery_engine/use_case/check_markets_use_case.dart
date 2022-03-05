import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

enum MarketChange {
  noChange,
  willChange,
  didChange,
}

@injectable
class CheckMarketsUseCase extends UseCase<None, MarketChange> {
  final DiscoveryEngine _engine;

  CheckMarketsUseCase(this._engine);

  @override
  Stream<MarketChange> transaction(None param) async* {
    final engine = _engine as AppDiscoveryEngine;

    if (await engine.willUpdateMarkets()) {
      yield MarketChange.willChange;
      await engine.maybeUpdateMarkets();
      yield MarketChange.didChange;
    } else {
      yield MarketChange.noChange;
    }
  }
}
