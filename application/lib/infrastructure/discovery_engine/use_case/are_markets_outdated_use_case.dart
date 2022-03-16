import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class AreMarketsOutdatedUseCase extends UseCase<FeedType, bool> {
  final DiscoveryEngine _engine;

  AreMarketsOutdatedUseCase(this._engine);

  @override
  Stream<bool> transaction(FeedType param) async* {
    final engine = _engine as AppDiscoveryEngine;

    yield await engine.areMarketsOutdated(param);
  }
}
